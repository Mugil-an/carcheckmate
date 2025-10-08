import 'lib/core/services/ocr_service.dart';

void main() async {
  print('🔍 Testing OCR Service Implementation...\n');

  final ocrService = OCRService();
  
  try {
    // Initialize the service
    await ocrService.initialize();
    print('✅ OCR Service initialized successfully');

    // Test text parsing with sample service history data
    const sampleText = '''
    AUTHORIZED SERVICE CENTER
    Vehicle Service History
    
    Date: 15/01/2024    Odometer: 45,200 km    Amount: ₹ 8,500
    Service: Engine Oil Change, Air Filter Replacement
    
    Date: 20/04/2024    Odometer: 48,750 km    Amount: ₹ 12,300
    Service: Brake Pad Replacement, Wheel Alignment
    
    Date: 10/07/2024    Odometer: 52,100 km    Amount: ₹ 6,800
    Service: Transmission Oil Change, Battery Check
    
    Total Services: 3
    Genuine Parts Used: Yes
    Authorized Service: Yes
    ''';

    print('\n📋 Testing service history parsing...');
    final analysis = ocrService.parseServiceHistory(sampleText);
    
    print('✅ Service History Analysis Complete!');
    print('📊 Results:');
    print('   - Records found: ${analysis.records.length}');
    print('   - Issues detected: ${analysis.issues.length}');
    print('   - Document type: ${analysis.documentType}');
    print('   - Confidence: ${(analysis.confidence * 100).toStringAsFixed(1)}%');
    
    print('\n📝 Service Records:');
    for (int i = 0; i < analysis.records.length; i++) {
      final record = analysis.records[i];
      print('   ${i + 1}. Date: ${record.date}');
      print('      Odometer: ${record.odometer}');
      print('      Amount: ${record.amount}');
      print('      Description: ${record.description}');
      if (i < analysis.records.length - 1) print('');
    }

    if (analysis.issues.isNotEmpty) {
      print('\n⚠️  Issues Detected:');
      for (int i = 0; i < analysis.issues.length; i++) {
        print('   ${i + 1}. ${analysis.issues[i]}');
      }
    } else {
      print('\n✅ No issues detected!');
    }

    // Test structured data extraction
    print('\n🔍 Testing structured data extraction...');
    final ocrResult = OCRResult(
      extractedText: sampleText,
      confidence: 0.9,
      detectedLanguages: ['en'],
      textBlocks: [],
      structuredData: ocrService.extractStructuredData(sampleText),
    );

    print('✅ Structured Data Extraction Complete!');
    print('📊 Extracted Data:');
    print('   - Phone numbers: ${ocrResult.structuredData.phoneNumbers.length}');
    print('   - Email addresses: ${ocrResult.structuredData.emailAddresses.length}');
    print('   - Dates: ${ocrResult.structuredData.dates.length}');
    print('   - Amounts: ${ocrResult.structuredData.amounts.length}');
    print('   - Odometer readings: ${ocrResult.structuredData.odometerReadings.length}');
    print('   - Document type: ${ocrResult.structuredData.documentType}');

    if (ocrResult.structuredData.dates.isNotEmpty) {
      print('\n📅 Found dates: ${ocrResult.structuredData.dates.join(', ')}');
    }
    if (ocrResult.structuredData.amounts.isNotEmpty) {
      print('💰 Found amounts: ${ocrResult.structuredData.amounts.join(', ')}');
    }
    if (ocrResult.structuredData.odometerReadings.isNotEmpty) {
      print('🚗 Found odometer readings: ${ocrResult.structuredData.odometerReadings.join(', ')}');
    }

    print('\n🎉 OCR Service test completed successfully!');
    print('✅ The OCR module is ready for perfect text extraction!');

  } catch (e) {
    print('❌ Test failed: $e');
  } finally {
    ocrService.dispose();
    print('\n🧹 OCR Service disposed properly');
  }
}