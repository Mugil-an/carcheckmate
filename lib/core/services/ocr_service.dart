import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OCRService {
  static const String _baseUrl = 'YOUR_OCR_API_ENDPOINT'; // Replace with actual endpoint
  static const String _apiKey = 'YOUR_API_KEY'; // Replace with actual API key

  /// Extract text from image using OCR service
  Future<OCRResult> extractTextFromImage(File imageFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/ocr'));
      request.headers['Authorization'] = 'Bearer $_apiKey';
      request.headers['Content-Type'] = 'multipart/form-data';

      // Add image file to request
      var stream = http.ByteStream(imageFile.openRead());
      var length = await imageFile.length();
      var multipartFile = http.MultipartFile(
        'image',
        stream,
        length,
        filename: imageFile.path.split('/').last,
      );
      request.files.add(multipartFile);

      // Send request
      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        var jsonData = json.decode(responseData);
        return OCRResult.fromJson(jsonData);
      } else {
        throw OCRException('Failed to process image: ${response.statusCode}');
      }
    } catch (e) {
      throw OCRException('OCR processing failed: $e');
    }
  }

  /// Extract text from PDF using OCR service
  Future<OCRResult> extractTextFromPDF(File pdfFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/pdf-ocr'));
      request.headers['Authorization'] = 'Bearer $_apiKey';
      request.headers['Content-Type'] = 'multipart/form-data';

      // Add PDF file to request
      var stream = http.ByteStream(pdfFile.openRead());
      var length = await pdfFile.length();
      var multipartFile = http.MultipartFile(
        'pdf',
        stream,
        length,
        filename: pdfFile.path.split('/').last,
      );
      request.files.add(multipartFile);

      // Send request
      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        var jsonData = json.decode(responseData);
        return OCRResult.fromJson(jsonData);
      } else {
        throw OCRException('Failed to process PDF: ${response.statusCode}');
      }
    } catch (e) {
      throw OCRException('PDF OCR processing failed: $e');
    }
  }

  /// Parse service history from extracted text
  ServiceHistoryAnalysis parseServiceHistory(String extractedText) {
    // This is a simplified parsing logic - implement based on your requirements
    List<ServiceRecord> records = [];
    List<String> issues = [];
    
    // Extract service records using regex patterns
    RegExp datePattern = RegExp(r'\b\d{1,2}[/-]\d{1,2}[/-]\d{2,4}\b');
    RegExp amountPattern = RegExp(r'₹\s*[\d,]+');
    RegExp odometerPattern = RegExp(r'\b\d+\s*km\b', caseSensitive: false);
    
    var dates = datePattern.allMatches(extractedText);
    var amounts = amountPattern.allMatches(extractedText);
    var odometers = odometerPattern.allMatches(extractedText);
    
    // Create service records from extracted data
    for (int i = 0; i < dates.length && i < amounts.length; i++) {
      var date = dates.elementAt(i).group(0) ?? '';
      var amount = amounts.elementAt(i).group(0) ?? '';
      var odometer = i < odometers.length ? odometers.elementAt(i).group(0) ?? '' : '';
      
      records.add(ServiceRecord(
        date: date,
        amount: amount,
        odometer: odometer,
        description: 'Service performed', // Extract from context
      ));
    }
    
    // Detect potential issues
    if (records.length < 6) {
      issues.add('Insufficient service history - less than 6 months');
    }
    
    // Check for gaps in service history
    // Add more validation logic here
    
    return ServiceHistoryAnalysis(
      records: records,
      issues: issues,
      totalRecords: records.length,
      confidenceScore: _calculateConfidence(extractedText, records),
    );
  }

  double _calculateConfidence(String text, List<ServiceRecord> records) {
    double confidence = 0.5; // Base confidence
    
    // Increase confidence based on data quality
    if (records.isNotEmpty) confidence += 0.2;
    if (text.contains('authorized') || text.contains('genuine')) confidence += 0.1;
    if (text.contains('₹') && text.contains('km')) confidence += 0.2;
    
    return confidence.clamp(0.0, 1.0);
  }
}

class OCRResult {
  final String extractedText;
  final double confidence;
  final List<String> detectedLanguages;

  OCRResult({
    required this.extractedText,
    required this.confidence,
    required this.detectedLanguages,
  });

  factory OCRResult.fromJson(Map<String, dynamic> json) {
    return OCRResult(
      extractedText: json['text'] ?? '',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      detectedLanguages: List<String>.from(json['languages'] ?? []),
    );
  }
}

class ServiceRecord {
  final String date;
  final String amount;
  final String odometer;
  final String description;

  ServiceRecord({
    required this.date,
    required this.amount,
    required this.odometer,
    required this.description,
  });
}

class ServiceHistoryAnalysis {
  final List<ServiceRecord> records;
  final List<String> issues;
  final int totalRecords;
  final double confidenceScore;

  ServiceHistoryAnalysis({
    required this.records,
    required this.issues,
    required this.totalRecords,
    required this.confidenceScore,
  });
}

class OCRException implements Exception {
  final String message;
  OCRException(this.message);
  
  @override
  String toString() => 'OCRException: $message';
}