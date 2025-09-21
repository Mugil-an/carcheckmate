"""
service_ocr_extract_table.py
Extended OCR + structured extraction for CarCheckMate service records.
Saves:
 - JSON per input file (raw text + parsed fields + events)
 - CSV / Excel of per-service events
 - SQLite table "service_events"
"""

import os
import re
import json
import sqlite3
from datetime import datetime
from pathlib import Path
from typing import Dict, Optional, List, Any

import cv2
import numpy as np
from PIL import Image
import pytesseract
import pytesseract
pytesseract.pytesseract.tesseract_cmd = r"C:\Program Files\Tesseract-OCR\tesseract.exe"

from pdf2image import convert_from_path
from docx import Document
import pandas as pd

# If tesseract binary not in PATH, set here:
# pytesseract.pytesseract.tesseract_cmd = r"C:\Program Files\Tesseract-OCR\tesseract.exe"

# ======= Config =======
TRUSTED_GARAGES = {
    # populate with known authorized service centers per make/city
    "Volkswagen Service" : True,
    "V W Service" : True,
    "Authorized VW Dealer" : True,
    # add more...
}

# Date regexes (same as earlier, kept comprehensive)
DATE_PATTERNS = [
    r'(\d{1,2}[/-]\d{1,2}[/-]\d{2,4})',
    r'(\d{4}[/-]\d{1,2}[/-]\d{1,2})',
    r'((?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Sept|Oct|Nov|Dec)[a-z]*\.?\s*\d{1,2}\,?\s*\d{2,4})',
]

ODOMETER_PATTERNS = [
    r'(?:odo|odometer|mileage|km reading|kms|kilometres|kilometers)[\s:]*([\d,]{3,})',
    r'([\d,]{4,7})\s*(?:km|kms|kilometres|kilometers|mi|miles)\b'
]

INVOICE_PATTERNS = [
    r'(?:invoice|inv|bill|receipt|tax invoice)[\s#:-]*([A-Za-z0-9\/-]{3,})',
]

TOTAL_AMOUNT_PATTERNS = [
    r'\btotal(?:\s+amount)?[:\s₹]*([\d,]+\.\d{2}|\d{1,3}(?:,\d{3})*)',
    r'\bgrand\s+total[:\s₹]*([\d,]+\.\d{2}|\d{1,3}(?:,\d{3})*)',
    r'\bnet\s+payable[:\s₹]*([\d,]+\.\d{2}|\d{1,3}(?:,\d{3})*)',
    r'\btotal[:\s₹]*([\d,]+)'
]

# helper util: try multiple regex patterns and return first group
def find_first_group(text: str, patterns: List[str], flags=0) -> Optional[str]:
    for p in patterns:
        m = re.search(p, text, flags=re.IGNORECASE)
        if m:
            # return first non-empty group
            for g in m.groups():
                if g:
                    return g.strip()
            return m.group(0).strip()
    return None

# ----- OCR / preprocessing (same style as before) -----
def preprocess_image_for_ocr(pil_img: Image.Image) -> np.ndarray:
    img = np.array(pil_img.convert('RGB'))[:,:,::-1]
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    blur = cv2.GaussianBlur(gray, (3,3), 0)
    th = cv2.adaptiveThreshold(blur, 255,
                               cv2.ADAPTIVE_THRESH_GAUSSIAN_C,
                               cv2.THRESH_BINARY, 15, 8)
    return th

def ocr_image_full(pil_img: Image.Image, psm=3):
    processed = preprocess_image_for_ocr(pil_img)
    # full text
    custom_config = f'--psm {psm}'
    full_text = pytesseract.image_to_string(processed, config=custom_config)
    # TSV data (for positional / line grouping)
    tsv = pytesseract.image_to_data(processed, config=custom_config, output_type=pytesseract.Output.DICT)
    return full_text, tsv

def pdf_to_images(pdf_path: str, dpi=300) -> List[Image.Image]:
    return convert_from_path(pdf_path, dpi=dpi)

# ----- Build structured events from tsv + text heuristics -----
def tsv_lines_to_text_lines(tsv: Dict[str, List[Any]]) -> List[Dict[str,Any]]:
    # group words by line_num, construct lines with bounding box info
    n = len(tsv['text'])
    lines = {}
    for i in range(n):
        text = tsv['text'][i].strip()
        if text == "":
            continue
        block_num = tsv.get('block_num', [None]*n)[i]
        par_num = tsv.get('par_num', [None]*n)[i]
        line_num = tsv.get('line_num', [None]*n)[i]
        key = (block_num, par_num, line_num)
        if key not in lines:
            lines[key] = {
                'words': [],
                'left': tsv.get('left', [0]*n)[i],
                'top': tsv.get('top', [0]*n)[i],
                'width': tsv.get('width', [0]*n)[i],
                'height': tsv.get('height', [0]*n)[i],
            }
        lines[key]['words'].append(text)
    # convert to list sorted by top coordinate
    out = []
    for k,v in lines.items():
        v['text'] = " ".join(v['words'])
        out.append(v)
    out_sorted = sorted(out, key=lambda x: x['top'])
    return out_sorted

def parse_service_events_from_lines(lines: List[Dict[str,Any]]) -> List[Dict[str,Any]]:
    """
    Heuristic grouping: find lines that contain a date token, and then
    collect neighboring lines up/down to form a single 'service event' block.
    Then try to detect odometer, invoice, garage, total within the block.
    """
    events = []
    for idx, line in enumerate(lines):
        text = line['text']
        # detect if line contains a date -> candidate service header
        date_match = find_first_group(text, DATE_PATTERNS)
        total_match = find_first_group(text, TOTAL_AMOUNT_PATTERNS)
        inv_match = find_first_group(text, INVOICE_PATTERNS)

        # also accept lines that say 'Service Date' or 'Date'
        if date_match or 'service' in text.lower() and 'date' in text.lower() or re.search(r'\bdate\b', text, re.I):
            # gather a window of ±3 lines to build event block
            start = max(0, idx-3)
            end = min(len(lines), idx+4)
            block_text = " ".join([l['text'] for l in lines[start:end]])
            # extract fields from the block
            service_date = find_first_group(block_text, DATE_PATTERNS)
            odo = find_first_group(block_text, ODOMETER_PATTERNS)
            invoice_no = find_first_group(block_text, INVOICE_PATTERNS)
            total_amt = find_first_group(block_text, TOTAL_AMOUNT_PATTERNS)
            # garage detection: look for words like "Service", "Workshop", "Garage", "Dealer", common substrings
            garage = None
            # prefer lines in the upward area (garage often at top of invoice)
            for j in range(start, min(start+3, end)):
                cand = lines[j]['text']
                if re.search(r'(service|garage|workshop|dealer|service center|service centre|authorized|showroom)', cand, re.I):
                    garage = cand
                    break
            # fallback: find any line with keywords
            if not garage:
                for j in range(start, end):
                    cand = lines[j]['text']
                    if re.search(r'(service|garage|workshop|dealer|showroom)', cand, re.I):
                        garage = cand
                        break
            # collect possible parts/line items by scanning the block for currency numbers or item-like patterns
            parts = []
            amounts = []
            # look lines in block for patterns like "PartName ... 1234"
            for j in range(start, end):
                ltext = lines[j]['text']
                # a simple detect for item + amount at line end
                m = re.search(r'(.+?)\s+₹\s*([\d,]+(?:\.\d{1,2})?)$', ltext)
                if m:
                    parts.append(m.group(1).strip())
                    amounts.append(m.group(2).replace(',', ''))
                else:
                    # alternative: number at end
                    m2 = re.search(r'(.+?)\s+([\d,]+)$', ltext)
                    if m2 and len(m2.group(2))>2:
                        parts.append(m2.group(1).strip())
                        amounts.append(m2.group(2).replace(',', ''))

            events.append({
                'service_date': service_date,
                'odometer': odo,
                'invoice_no': invoice_no,
                'total_amount': total_amt,
                'garage': garage,
                'parts': parts,
                'parts_amounts': amounts,
                'raw_block_text': block_text
            })
    # deduplicate events by date+odo+invoice
    dedup = []
    seen = set()
    for e in events:
        key = (e.get('service_date'), e.get('odometer'), e.get('invoice_no'))
        if key in seen:
            continue
        seen.add(key)
        dedup.append(e)
    return dedup

# ----- Owner / transfer detection (simple heuristics) -----
OWNER_PATTERNS = [
    r'\b(owner|registered owner|name of owner|sold to|transferred to|buyer)\b[:\s]*([A-Za-z ]{3,60})',
    r'\b(sold by|transfer from)\b[:\s]*([A-Za-z ]{3,60})'
]

def find_owner_names(full_text: str) -> List[str]:
    out = []
    for p in OWNER_PATTERNS:
        for m in re.finditer(p, full_text, flags=re.I):
            g = m.groups()
            if g and len(g)>=2:
                candidate = g[-1].strip()
                if len(candidate) > 2 and len(candidate) < 60:
                    out.append(candidate)
    # fallback: look for words preceded by "Mr." or "Mrs." or "M/s"
    for m in re.finditer(r'\b(Mr|Mrs|Ms|M/s)\.?\s+([A-Z][a-z]+\s?[A-Z]?[a-z]*)', full_text):
        out.append(m.group(0))
    # unique
    return list(dict.fromkeys(out))

# ----- Suspicion / derived logic -----
def detect_missing_periods(events: List[Dict[str,Any]], max_months_allowed=18) -> Dict[str,Any]:
    # sort events by date (try parsing)
    parsed = []
    for e in events:
        d = e.get('service_date')
        dt = None
        if d:
            for fmt in ("%d/%m/%Y","%d-%m-%Y","%Y-%m-%d","%d/%m/%y","%d-%b-%Y"):
                try:
                    dt = datetime.strptime(d, fmt)
                    break
                except:
                    continue
        parsed.append((dt, e))
    parsed = sorted(parsed, key=lambda x: x[0] or datetime.min)
    gaps = []
    for i in range(1, len(parsed)):
        if parsed[i-1][0] and parsed[i][0]:
            diff_months = (parsed[i][0].year - parsed[i-1][0].year)*12 + parsed[i][0].month - parsed[i-1][0].month
            if diff_months > max_months_allowed:
                gaps.append({
                    'from': parsed[i-1][0].strftime("%Y-%m-%d"),
                    'to': parsed[i][0].strftime("%Y-%m-%d"),
                    'months_gap': diff_months
                })
    return {'gaps': gaps}

def detect_odometer_rollback(events: List[Dict[str,Any]]) -> Dict[str,Any]:
    # look for non-monotonic odometer values
    odos = []
    for e in events:
        o = e.get('odometer')
        if o:
            o_clean = re.sub(r'\D','', o)
            if o_clean:
                try:
                    odos.append(int(o_clean))
                except:
                    pass
    rollback = False
    decreases = []
    for i in range(1, len(odos)):
        if odos[i] < odos[i-1]:
            rollback = True
            decreases.append({'index': i, 'prev': odos[i-1], 'cur': odos[i]})
    return {'rollback': rollback, 'decreases': decreases, 'odo_list': odos}

# ----- Save to DB / CSV / Excel -----
def ensure_db(db_path: str = "service_records.db"):
    conn = sqlite3.connect(db_path)
    cur = conn.cursor()
    cur.execute('''
      CREATE TABLE IF NOT EXISTS service_events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        source_file TEXT,
        service_date TEXT,
        odometer INTEGER,
        invoice_no TEXT,
        total_amount TEXT,
        garage TEXT,
        parts TEXT,
        parts_amounts TEXT,
        raw_block_text TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''')
    conn.commit()
    return conn

def insert_event(conn, source_file, event):
    cur = conn.cursor()
    odo_val = None
    if event.get('odometer'):
        try:
            odo_val = int(re.sub(r'\D','', event['odometer']))
        except:
            odo_val = None
    cur.execute('''
      INSERT INTO service_events (source_file, service_date, odometer, invoice_no, total_amount, garage, parts, parts_amounts, raw_block_text)
      VALUES (?,?,?,?,?,?,?,?,?)
    ''', (
        source_file, event.get('service_date'), odo_val, event.get('invoice_no'),
        event.get('total_amount'), event.get('garage'),
        json.dumps(event.get('parts')), json.dumps(event.get('parts_amounts')), event.get('raw_block_text')
    ))
    conn.commit()
    return cur.lastrowid

# ----- Main processing function -----
def process_file(path: str, output_dir: str, db_conn):
    p = Path(path)
    output_dir = Path(output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    images = []
    if p.suffix.lower() == '.pdf':
        images = pdf_to_images(str(p))
    else:
        images = [Image.open(p)]

    all_text_pages = []
    all_events = []
    for i, pil_img in enumerate(images):
        text, tsv = ocr_image_full(pil_img, psm=3)
        all_text_pages.append(text)
        lines = tsv_lines_to_text_lines(tsv)
        page_events = parse_service_events_from_lines(lines)
        # attach page index
        for ev in page_events:
            ev['page_index'] = i+1
        all_events.extend(page_events)

    full_text = "\n\n---PAGE---\n\n".join(all_text_pages)

    # Owner detection
    owners = find_owner_names(full_text)
    unique_owner_count = len(owners)

    # Derived signals
    missing_periods = detect_missing_periods(all_events)
    odo_issues = detect_odometer_rollback(all_events)

    # Unauthorized garage hits
    unauthorized = []
    for ev in all_events:
        g = ev.get('garage') or ''
        if g:
            # simple match: if none of trusted substrings in garage string, flag
            trusted = any(k.lower() in g.lower() for k in TRUSTED_GARAGES.keys())
            if not trusted:
                unauthorized.append(g)

    # save per-file JSON
    summary = {
        'file': p.name,
        'parsed_events_count': len(all_events),
        'events': all_events,
        'owners': owners,
        'unique_owner_count': unique_owner_count,
        'missing_periods': missing_periods,
        'odometer_issues': odo_issues,
        'unauthorized_garages': list(dict.fromkeys(unauthorized)),
        'raw_text': full_text[:4000]  # store a snippet
    }

    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    json_out = output_dir / f"{p.stem}_parsed_{timestamp}.json"
    with open(json_out, 'w', encoding='utf-8') as f:
        json.dump(summary, f, ensure_ascii=False, indent=2)

    # Save events to CSV / Excel and DB
    if all_events:
        df_rows = []
        for ev in all_events:
            df_rows.append({
                'file': p.name,
                'page': ev.get('page_index'),
                'service_date': ev.get('service_date'),
                'odometer': ev.get('odometer'),
                'invoice_no': ev.get('invoice_no'),
                'total_amount': ev.get('total_amount'),
                'garage': ev.get('garage'),
                'parts': "; ".join(ev.get('parts') or []),
                'parts_amounts': "; ".join(ev.get('parts_amounts') or []),
                'raw_block_text': ev.get('raw_block_text')[:1000]
            })
        df = pd.DataFrame(df_rows)
        csv_out = output_dir / f"{p.stem}_events_{timestamp}.csv"
        xlsx_out = output_dir / f"{p.stem}_events_{timestamp}.xlsx"
        df.to_csv(csv_out, index=False, encoding='utf-8')
        df.to_excel(xlsx_out, index=False)

        # Write into DB rows
        for ev in all_events:
            insert_event(db_conn, p.name, ev)

    else:
        # still write an empty CSV with raw text note
        csv_out = output_dir / f"{p.stem}_events_{timestamp}.csv"
        pd.DataFrame([]).to_csv(csv_out)

    print(f"Processed {p.name}. Events found: {len(all_events)}. JSON: {json_out}, CSV: {csv_out}")
    return summary

# ======= CLI entrypoint =======
if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", required=True, help="file or folder to process")
    parser.add_argument("--out", default="ocr_output", help="output folder")
    parser.add_argument("--db", default="service_records.db", help="sqlite db file")
    args = parser.parse_args()

    db_conn = ensure_db(args.db)

    p = Path(args.input)
    results = []
    if p.is_dir():
        for f in p.iterdir():
            if f.suffix.lower() in ['.pdf','.png','.jpg','.jpeg','.tiff']:
                results.append(process_file(str(f), args.out, db_conn))
    else:
        results.append(process_file(str(p), args.out, db_conn))

    print("Done. Summaries:")
    for r in results:
        print(r['file'], "events:", r['parsed_events_count'])
