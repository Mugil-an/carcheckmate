import os, uuid, shutil
from pathlib import Path
from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from fastapi.staticfiles import StaticFiles

from carcheckmate.lib.Logzz.ocrback import process_file, ensure_db

BASE_DIR   = Path(__file__).resolve().parent.parent
UPLOAD_DIR = BASE_DIR / "uploads"
OUTPUT_DIR = BASE_DIR / "ocr_output"
DB_PATH    = BASE_DIR / "service_records.db"

UPLOAD_DIR.mkdir(parents=True, exist_ok=True)
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

os.environ.setdefault("TESSERACT_CMD", r"C:\Program Files\Tesseract-OCR\tesseract.exe")

db_conn = ensure_db(str(DB_PATH))

app = FastAPI(title="CarCheckMate OCR API", version="1.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# serve generated files so FE can download them later
app.mount("/files", StaticFiles(directory=str(OUTPUT_DIR)), name="files")

@app.get("/")
def root():
    return {"ok": True}

@app.post("/upload")
async def upload(file: UploadFile = File(...)):
    ext = Path(file.filename).suffix.lower()
    if ext not in {".png",".jpg",".jpeg",".tiff",".pdf"}:
        raise HTTPException(status_code=400, detail="Unsupported file type")

    job_id = str(uuid.uuid4())
    saved_path = UPLOAD_DIR / f"{job_id}{ext}"
    with saved_path.open("wb") as f:
        shutil.copyfileobj(file.file, f)

    try:
        summary = process_file(str(saved_path), str(OUTPUT_DIR), db_conn)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"OCR failed: {e}")

    stem = saved_path.stem
    latest_json = sorted(OUTPUT_DIR.glob(f"{stem}_parsed_*.json"), reverse=True)
    latest_csv  = sorted(OUTPUT_DIR.glob(f"{stem}_events_*.csv"),  reverse=True)
    latest_xlsx = sorted(OUTPUT_DIR.glob(f"{stem}_events_*.xlsx"), reverse=True)

    json_url = f"/files/{Path(latest_json[0]).name}" if latest_json else None
    csv_url  = f"/files/{Path(latest_csv[0]).name}"  if latest_csv  else None
    xlsx_url = f"/files/{Path(latest_xlsx[0]).name}" if latest_xlsx else None

    return JSONResponse({
        "job_id": job_id,
        "input_file": str(saved_path),
        "summary": summary,
        "exports": {
            "json_summary_url": json_url,
            "csv_events_url":  csv_url,
            "xlsx_events_url": xlsx_url
        }
    })
