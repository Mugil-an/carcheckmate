import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// Custom exception for OCR-related errors
class OCRException implements Exception {
  final String message;
  const OCRException(this.message);

  @override
  String toString() => 'OCRException: $message';
}

/// Represents a bounding box for text elements
class OCRBoundingBox {
  final double left;
  final double top;
  final double width;
  final double height;

  const OCRBoundingBox({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  Map<String, dynamic> toJson() => {
        'left': left,
        'top': top,
        'width': width,
        'height': height,
      };
}

/// Represents a text element with its properties
class OCRTextElement {
  final String text;
  final OCRBoundingBox boundingBox;
  final double confidence;

  const OCRTextElement({
    required this.text,
    required this.boundingBox,
    required this.confidence,
  });

  Map<String, dynamic> toJson() => {
        'text': text,
        'boundingBox': boundingBox.toJson(),
        'confidence': confidence,
      };
}

/// Represents a line of text containing multiple elements
class OCRTextLine {
  final String text;
  final List<OCRTextElement> elements;
  final OCRBoundingBox boundingBox;
  final double confidence;

  const OCRTextLine({
    required this.text,
    required this.elements,
    required this.boundingBox,
    required this.confidence,
  });

  Map<String, dynamic> toJson() => {
        'text': text,
        'elements': elements.map((e) => e.toJson()).toList(),
        'boundingBox': boundingBox.toJson(),
        'confidence': confidence,
      };
}

/// Represents a block of text containing multiple lines
class OCRTextBlock {
  final String text;
  final List<OCRTextLine> lines;
  final OCRBoundingBox boundingBox;
  final double confidence;

  const OCRTextBlock({
    required this.text,
    required this.lines,
    required this.boundingBox,
    required this.confidence,
  });

  Map<String, dynamic> toJson() => {
        'text': text,
        'lines': lines.map((l) => l.toJson()).toList(),
        'boundingBox': boundingBox.toJson(),
        'confidence': confidence,
      };
}

/// Structured data extracted from documents
class StructuredData {
  final List<String> phoneNumbers;
  final List<String> emailAddresses;
  final List<String> dates;
  final List<String> amounts;
  final List<String> vehiclePlates;
  final List<String> odometerReadings;
  final String documentType;

  const StructuredData({
    this.phoneNumbers = const [],
    this.emailAddresses = const [],
    this.dates = const [],
    this.amounts = const [],
    this.vehiclePlates = const [],
    this.odometerReadings = const [],
    this.documentType = 'unknown',
  });

  Map<String, dynamic> toJson() => {
        'phoneNumbers': phoneNumbers,
        'emailAddresses': emailAddresses,
        'dates': dates,
        'amounts': amounts,
        'vehiclePlates': vehiclePlates,
        'odometerReadings': odometerReadings,
        'documentType': documentType,
      };
}

/// Result of OCR processing
class OCRResult {
  final String extractedText;
  final double confidence;
  final List<String> detectedLanguages;
  final List<OCRTextBlock> textBlocks;
  final StructuredData structuredData;

  const OCRResult({
    required this.extractedText,
    required this.confidence,
    this.detectedLanguages = const ['en'],
    this.textBlocks = const [],
    this.structuredData = const StructuredData(),
  });

  factory OCRResult.fromJson(Map<String, dynamic> json) {
    return OCRResult(
      extractedText: json['extractedText'] ?? '',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      detectedLanguages: List<String>.from(json['detectedLanguages'] ?? ['en']),
      textBlocks: [],
      structuredData: const StructuredData(),
    );
  }

  Map<String, dynamic> toJson() => {
        'extractedText': extractedText,
        'confidence': confidence,
        'detectedLanguages': detectedLanguages,
        'textBlocks': textBlocks.map((b) => b.toJson()).toList(),
        'structuredData': structuredData.toJson(),
      };
}

/// Represents a service record
class ServiceRecord {
  final String date;
  final String odometer;
  final String amount;
  final String description;

  const ServiceRecord({
    required this.date,
    required this.odometer,
    required this.amount,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
        'date': date,
        'odometer': odometer,
        'amount': amount,
        'description': description,
      };
}

/// Analysis result for service history
class ServiceHistoryAnalysis {
  final List<ServiceRecord> records;
  final List<String> issues;
  final String documentType;
  final double confidence;

  const ServiceHistoryAnalysis({
    required this.records,
    required this.issues,
    required this.documentType,
    required this.confidence,
  });

  Map<String, dynamic> toJson() => {
        'records': records.map((r) => r.toJson()).toList(),
        'issues': issues,
        'documentType': documentType,
        'confidence': confidence,
      };
}

/// Service for performing OCR on images and documents
class OCRService {
  static final OCRService _instance = OCRService._internal();
  factory OCRService() => _instance;
  OCRService._internal();

  late final TextRecognizer _textRecognizer;
  bool _isInitialized = false;

  /// Initialize the OCR service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      _isInitialized = true;
    } catch (e) {
      throw OCRException('Failed to initialize OCR service: $e');
    }
  }

  /// Extract text from image file
  Future<OCRResult> extractTextFromImage(File imageFile) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final inputImage = InputImage.fromFile(imageFile);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      // Convert ML Kit results to our custom format
      final textBlocks = _convertTextBlocks(recognizedText.blocks);
      final structuredData = extractStructuredData(recognizedText.text);
      final confidence = _calculateConfidence(recognizedText.blocks);

      return OCRResult(
        extractedText: recognizedText.text,
        confidence: confidence,
        detectedLanguages: [
          'en'
        ], // ML Kit doesn't provide language detection in this version
        textBlocks: textBlocks,
        structuredData: structuredData,
      );
    } catch (e) {
      throw OCRException('Image OCR processing failed: $e');
    }
  }

  /// Extract text from image bytes
  Future<OCRResult> extractTextFromBytes(Uint8List imageBytes) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final inputImage = InputImage.fromBytes(
        bytes: imageBytes,
        metadata: InputImageMetadata(
          size: const Size(640, 480), // Default size, adjust as needed
          rotation: InputImageRotation.rotation0deg,
          format: InputImageFormat.nv21,
          bytesPerRow: 640,
        ),
      );

      final recognizedText = await _textRecognizer.processImage(inputImage);

      // Convert ML Kit results to our custom format
      final textBlocks = _convertTextBlocks(recognizedText.blocks);
      final structuredData = extractStructuredData(recognizedText.text);
      final confidence = _calculateConfidence(recognizedText.blocks);

      return OCRResult(
        extractedText: recognizedText.text,
        confidence: confidence,
        detectedLanguages: ['en'],
        textBlocks: textBlocks,
        structuredData: structuredData,
      );
    } catch (e) {
      throw OCRException('Image bytes OCR processing failed: $e');
    }
  }

  /// Extract text from PDF (converts first page to image)
  Future<OCRResult> extractTextFromPDF(File pdfFile) async {
    try {
      // PDF OCR would require additional dependencies like pdf_render
      // For now, return an informative error
      throw OCRException(
          'PDF OCR requires additional setup. Please convert PDF to image first.');
    } catch (e) {
      throw OCRException('PDF OCR processing failed: $e');
    }
  }

  /// Convert ML Kit text blocks to our custom format
  List<OCRTextBlock> _convertTextBlocks(List<TextBlock> mlkitBlocks) {
    return mlkitBlocks.map((block) {
      final lines = block.lines.map((line) {
        final elements = line.elements.map((element) {
          return OCRTextElement(
            text: element.text,
            boundingBox: OCRBoundingBox(
              left: element.boundingBox.left.toDouble(),
              top: element.boundingBox.top.toDouble(),
              width: element.boundingBox.width.toDouble(),
              height: element.boundingBox.height.toDouble(),
            ),
            confidence: 0.8, // ML Kit doesn't provide element-level confidence
          );
        }).toList();

        return OCRTextLine(
          text: line.text,
          elements: elements,
          boundingBox: OCRBoundingBox(
            left: line.boundingBox.left.toDouble(),
            top: line.boundingBox.top.toDouble(),
            width: line.boundingBox.width.toDouble(),
            height: line.boundingBox.height.toDouble(),
          ),
          confidence: 0.8, // ML Kit doesn't provide line-level confidence
        );
      }).toList();

      return OCRTextBlock(
        text: block.text,
        lines: lines,
        boundingBox: OCRBoundingBox(
          left: block.boundingBox.left.toDouble(),
          top: block.boundingBox.top.toDouble(),
          width: block.boundingBox.width.toDouble(),
          height: block.boundingBox.height.toDouble(),
        ),
        confidence: 0.8, // ML Kit doesn't provide block-level confidence
      );
    }).toList();
  }

  /// Extract structured data from text using regex patterns
  StructuredData extractStructuredData(String text) {
    // Phone number patterns (Indian format)
    final phoneRegex = RegExp(r'(\+91[-\s]?)?[6-9]\d{9}');
    final phoneNumbers =
        phoneRegex.allMatches(text).map((match) => match.group(0)!).toList();

    // Email patterns
    final emailRegex =
        RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b');
    final emailAddresses =
        emailRegex.allMatches(text).map((match) => match.group(0)!).toList();

    // Date patterns (DD/MM/YYYY, DD-MM-YYYY, etc.)
    final dateRegex = RegExp(r'\b\d{1,2}[/-]\d{1,2}[/-]\d{4}\b');
    final dates =
        dateRegex.allMatches(text).map((match) => match.group(0)!).toList();

    // Amount patterns (₹ symbol, numbers with commas)
    final amountRegex = RegExp(
        r'₹\s*[\d,]+(?:\.\d{2})?|\b\d{1,3}(?:,\d{3})*(?:\.\d{2})?\s*(?:rupees?|rs?\.?|inr)\b',
        caseSensitive: false);
    final amounts =
        amountRegex.allMatches(text).map((match) => match.group(0)!).toList();

    // Vehicle plate patterns (Indian format)
    final plateRegex = RegExp(r'\b[A-Z]{2}\s*\d{2}\s*[A-Z]{1,2}\s*\d{4}\b');
    final vehiclePlates =
        plateRegex.allMatches(text).map((match) => match.group(0)!).toList();

    // Odometer readings
    final odometerRegex =
        RegExp(r'\b\d{1,6}\s*(?:km|kms|kilometers?)\b', caseSensitive: false);
    final odometerReadings =
        odometerRegex.allMatches(text).map((match) => match.group(0)!).toList();

    // Document type detection
    final documentType = _detectDocumentType(text);

    return StructuredData(
      phoneNumbers: phoneNumbers,
      emailAddresses: emailAddresses,
      dates: dates,
      amounts: amounts,
      vehiclePlates: vehiclePlates,
      odometerReadings: odometerReadings,
      documentType: documentType,
    );
  }

  /// Detect document type based on keywords
  String _detectDocumentType(String text) {
    final lowerText = text.toLowerCase();

    if (lowerText.contains('service') &&
        (lowerText.contains('history') || lowerText.contains('record'))) {
      return 'service_record';
    } else if (lowerText.contains('insurance') &&
        lowerText.contains('policy')) {
      return 'insurance_document';
    } else if (lowerText.contains('registration') &&
        lowerText.contains('certificate')) {
      return 'registration_certificate';
    } else if (lowerText.contains('invoice') ||
        lowerText.contains('bill') ||
        lowerText.contains('receipt')) {
      return 'invoice';
    } else if (lowerText.contains('loan') && lowerText.contains('agreement')) {
      return 'loan_document';
    } else {
      return 'unknown';
    }
  }

  /// Calculate overall confidence from text blocks
  double _calculateConfidence(List<TextBlock> blocks) {
    if (blocks.isEmpty) return 0.0;

    // ML Kit doesn't provide block-level confidence in this version
    // Use a default confidence based on the amount of text detected
    if (blocks.length > 5) return 0.9;
    if (blocks.length > 2) return 0.8;
    if (blocks.length > 0) return 0.7;
    return 0.5;
  }

  /// Parse service history from extracted text
  ServiceHistoryAnalysis parseServiceHistory(String extractedText) {
    final records = <ServiceRecord>[];
    final issues = <String>[];

    // Extract service records using regex patterns
    final lines = extractedText.split('\n');
    String currentDate = '';
    String currentOdometer = '';
    String currentAmount = '';
    String currentDescription = '';

    for (String line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;

      // Look for date patterns
      final dateMatch =
          RegExp(r'\b\d{1,2}[/-]\d{1,2}[/-]\d{4}\b').firstMatch(line);
      if (dateMatch != null) {
        // If we have accumulated data, create a record
        if (currentDate.isNotEmpty && currentDescription.isNotEmpty) {
          records.add(ServiceRecord(
            date: currentDate,
            odometer: currentOdometer.isEmpty ? 'N/A' : currentOdometer,
            amount: currentAmount.isEmpty ? 'N/A' : currentAmount,
            description: currentDescription,
          ));
        }

        // Start new record
        currentDate = dateMatch.group(0)!;
        currentOdometer = '';
        currentAmount = '';
        currentDescription = '';
      }

      // Look for odometer readings
      final odometerMatch = RegExp(r'\b(\d{1,6})\s*(?:km|kms|kilometers?)\b',
              caseSensitive: false)
          .firstMatch(line);
      if (odometerMatch != null) {
        currentOdometer = '${odometerMatch.group(1)} km';
      }

      // Look for amounts
      final amountMatch = RegExp(
              r'₹\s*[\d,]+(?:\.\d{2})?|\b\d{1,3}(?:,\d{3})*(?:\.\d{2})?\s*(?:rupees?|rs?\.?|inr)\b',
              caseSensitive: false)
          .firstMatch(line);
      if (amountMatch != null) {
        currentAmount = amountMatch.group(0)!;
      }

      // Look for service descriptions
      final serviceKeywords = [
        'service',
        'repair',
        'maintenance',
        'replacement',
        'check',
        'oil',
        'brake',
        'engine',
        'transmission',
        'suspension',
        'battery',
        'filter',
        'alignment'
      ];
      if (serviceKeywords
          .any((keyword) => line.toLowerCase().contains(keyword))) {
        if (currentDescription.isEmpty) {
          currentDescription = line;
        } else {
          currentDescription += ', $line';
        }
      }
    }

    // Add the last record if we have data
    if (currentDate.isNotEmpty && currentDescription.isNotEmpty) {
      records.add(ServiceRecord(
        date: currentDate,
        odometer: currentOdometer.isEmpty ? 'N/A' : currentOdometer,
        amount: currentAmount.isEmpty ? 'N/A' : currentAmount,
        description: currentDescription,
      ));
    }

    // Analyze for issues
    _detectServiceHistoryIssues(extractedText, records, issues);

    // Detect document type
    String documentType = 'service_record';
    if (extractedText.toLowerCase().contains('authorized')) {
      documentType = 'authorized_service_record';
    }

    // Calculate confidence based on found records
    double confidence =
        records.isEmpty ? 0.3 : (records.length > 3 ? 0.9 : 0.7);

    return ServiceHistoryAnalysis(
      records: records,
      issues: issues,
      documentType: documentType,
      confidence: confidence,
    );
  }

  /// Detect potential issues in service history
  void _detectServiceHistoryIssues(
      String text, List<ServiceRecord> records, List<String> issues) {
    final lowerText = text.toLowerCase();

    // Check for unauthorized service centers
    if (!lowerText.contains('authorized') && !lowerText.contains('official')) {
      issues.add('Service may not be from an authorized service center');
    }

    // Check for missing information
    if (records.isEmpty) {
      issues.add('No clear service records found in the document');
    } else {
      // Check for records without amounts
      int recordsWithoutAmount = records.where((r) => r.amount == 'N/A').length;
      if (recordsWithoutAmount > 0) {
        issues.add(
            '$recordsWithoutAmount service records are missing amount information');
      }

      // Check for records without odometer readings
      int recordsWithoutOdometer =
          records.where((r) => r.odometer == 'N/A').length;
      if (recordsWithoutOdometer > 0) {
        issues.add(
            '$recordsWithoutOdometer service records are missing odometer readings');
      }

      // Check for potential service gaps (if we have dates)
      final datesWithYear = records
          .where((r) => r.date.contains('/') && r.date.length >= 8)
          .map((r) => r.date)
          .toList();

      if (datesWithYear.isNotEmpty && datesWithYear.length >= 2) {
        // Simple check for potential gaps (this could be more sophisticated)
        issues.add('Please verify service intervals for any potential gaps');
      }
    }

    // Check for quality indicators
    if (lowerText.contains('duplicate') || lowerText.contains('copy')) {
      issues.add('Document appears to be a copy - verify authenticity');
    }

    if (lowerText.contains('expired') || lowerText.contains('invalid')) {
      issues.add('Document may be expired or invalid');
    }
  }

  /// Dispose resources
  void dispose() {
    if (_isInitialized) {
      _textRecognizer.close();
      _isInitialized = false;
    }
  }
}
