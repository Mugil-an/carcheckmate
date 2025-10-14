import 'package:flutter_test/flutter_test.dart';
import 'package:carcheckmate/core/services/ocr_service.dart';

void main() {
  group('OCRService Tests', () {
    late OCRService ocrService;

    setUp(() {
      ocrService = OCRService();
    });

    test('should extract structured data from service record text', () {
      const testText = '''
      ABC Motors Service Invoice
      Date: 15/03/2024
      Odometer: 45,250 km
      Service Amount: ₹3,500
      Oil change and filter replacement
      Next service due: 50,000 km
      Phone: 9876543210
      Email: service@abcmotors.com
      Vehicle: KA01AB1234
      ''';

      final structuredData = ocrService.extractStructuredData(testText);

      expect(structuredData.phoneNumbers, contains('9876543210'));
      expect(structuredData.emailAddresses, contains('service@abcmotors.com'));
      expect(structuredData.dates, contains('15/03/2024'));
      expect(structuredData.amounts.isNotEmpty, true);
      expect(structuredData.vehiclePlates, contains('KA01AB1234'));
      expect(structuredData.odometerReadings, contains('45,250 km'));
    });

    test('should parse service history correctly', () {
      const testText = '''
      Service History Report
      
      Date: 10/01/2024
      Odometer: 40,000 km
      Amount: ₹2,500
      Oil change service
      
      Date: 15/03/2024
      Odometer: 45,250 km
      Amount: ₹3,500
      Oil change and filter replacement
      ''';

      final analysis = ocrService.parseServiceHistory(testText);

      expect(analysis.records.length, greaterThanOrEqualTo(2));
      expect(analysis.confidence, greaterThan(0.5));
      expect(analysis.documentType, 'service_record');
    });

    test('should detect document type correctly', () {
      const invoiceText = 'Service Invoice - Oil change receipt';
      const registrationText = 'Registration Certificate - Vehicle RC';
      const insuranceText = 'Insurance Policy Document';

      final invoiceData = ocrService.extractStructuredData(invoiceText);
      final registrationData = ocrService.extractStructuredData(registrationText);
      final insuranceData = ocrService.extractStructuredData(insuranceText);

      expect(invoiceData.documentType, 'invoice');
      expect(registrationData.documentType, 'registration_certificate');
      expect(insuranceData.documentType, 'insurance_document');
    });

    test('should handle empty text gracefully', () {
      const emptyText = '';

      expect(() => ocrService.extractStructuredData(emptyText), returnsNormally);
      expect(() => ocrService.parseServiceHistory(emptyText), returnsNormally);
    });

    tearDown(() {
      ocrService.dispose();
    });
  });
}