import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../widgets/common_background.dart';
import '../../../core/services/ocr_service.dart';
import '../../../app/theme.dart';

class OCRScreen extends StatefulWidget {
  const OCRScreen({super.key});

  @override
  State<OCRScreen> createState() => _OCRScreenState();
}

class _OCRScreenState extends State<OCRScreen> {
  final OCRService _ocrService = OCRService();
  final ImagePicker _picker = ImagePicker();
  bool _isProcessing = false;
  ServiceHistoryAnalysis? _analysis;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _isProcessing = true;
          _analysis = null;
        });

        final file = File(image.path);
        final ocrResult = await _ocrService.extractTextFromImage(file);
        final analysis = _ocrService.parseServiceHistory(ocrResult.extractedText);
        
        setState(() {
          _analysis = analysis;
          _isProcessing = false;
        });
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      if (mounted) {
        _showErrorDialog('Image Processing Error', e.toString());
      }
    }
  }

  Future<void> _pickPDF() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _isProcessing = true;
          _analysis = null;
        });

        final file = File(result.files.single.path!);
        final ocrResult = await _ocrService.extractTextFromPDF(file);
        final analysis = _ocrService.parseServiceHistory(ocrResult.extractedText);
        
        setState(() {
          _analysis = analysis;
          _isProcessing = false;
        });
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      if (mounted) {
        _showErrorDialog('PDF Processing Error', e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const CommonAppBar(title: 'Service History OCR'),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  'assets/images/carcheckmate_logo.png',
                  height: 100,
                  width: 100,
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Service History OCR',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Upload service invoices or PDFs. We will flag missing months, multiple owners, and unauthorized garages.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 40),
              
              if (_isProcessing)
                _buildProcessingIndicator()
              else if (_analysis != null)
                _buildAnalysisResult()
              else
                _buildUploadOptions(),
              
              const SizedBox(height: 40),
              _buildTipCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProcessingIndicator() {
    return Center(
      child: Column(
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          const SizedBox(height: 16),
          const Text(
            'Processing document...',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisResult() {
    if (_analysis == null) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Analysis Results',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              if (_analysis!.records.isNotEmpty) ...[
                const Text(
                  'Service Records Found:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ..._analysis!.records.map((record) => _buildServiceRecord(record)),
              ],
              
              const SizedBox(height: 16),
              
              if (_analysis!.issues.isNotEmpty) ...[
                const Text(
                  'Issues Detected:',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ..._analysis!.issues.map((issue) => _buildIssue(issue)),
              ] else ...[
                const Text(
                  'No issues detected!',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _analysis = null;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Analyze Another Document',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildServiceRecord(ServiceRecord record) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Date: ${record.date}',
            style: const TextStyle(color: Colors.white70),
          ),
          Text(
            'Odometer: ${record.odometer}',
            style: const TextStyle(color: Colors.white70),
          ),
          Text(
            'Amount: ${record.amount}',
            style: const TextStyle(color: Colors.white70),
          ),
          Text(
            'Description: ${record.description}',
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildIssue(String issue) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning,
            color: Colors.red,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              issue,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadOptions() {
    return Column(
      children: [
        // Capture from Camera option
        _buildOptionCard(
          icon: Icons.camera_alt,
          title: 'Capture from Camera',
          onTap: () => _pickImage(ImageSource.camera),
        ),
        const SizedBox(height: 20),
        
        // Upload from Gallery option
        _buildOptionCard(
          icon: Icons.photo_library,
          title: 'Choose from Gallery',
          onTap: () => _pickImage(ImageSource.gallery),
        ),
        const SizedBox(height: 20),
        
        // Upload PDF option
        _buildOptionCard(
          icon: Icons.upload_file,
          title: 'Upload PDF Document',
          onTap: _pickPDF,
        ),
      ],
    );
  }

  Widget _buildTipCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            color: Colors.white70,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tip:',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Include odometer readings and dates on every page for best results.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.white54,
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: AppColors.borderColor.withOpacity(0.3)),
          ),
          title: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: AppColors.error,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            _getUserFriendlyErrorMessage(message),
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'OK',
                style: TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _getUserFriendlyErrorMessage(String error) {
    final lowerError = error.toLowerCase();
    
    if (lowerError.contains('no host specified') || lowerError.contains('your_ocr_api_endpoint')) {
      return 'OCR service is not configured. The app is running in demo mode with sample data. To use real OCR functionality, please configure the API endpoint.';
    } else if (lowerError.contains('network') || lowerError.contains('connection')) {
      return 'Network connection error. Please check your internet connection and try again.';
    } else if (lowerError.contains('permission')) {
      return 'Permission denied. Please grant camera and storage permissions to use this feature.';
    } else if (lowerError.contains('file not found') || lowerError.contains('path')) {
      return 'The selected file could not be found or accessed. Please try selecting the file again.';
    } else if (lowerError.contains('unsupported') || lowerError.contains('format')) {
      return 'Unsupported file format. Please select a valid image (JPG, PNG) or PDF file.';
    } else if (lowerError.contains('timeout')) {
      return 'Request timed out. Please check your connection and try again.';
    } else if (lowerError.contains('api')) {
      return 'OCR service error. Please try again later or contact support if the problem persists.';
    } else {
      return 'An error occurred while processing the file. Please try again or select a different file.';
    }
  }
}