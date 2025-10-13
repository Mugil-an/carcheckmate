import 'package:flutter/material.dart';
import '../widgets/common_background.dart';
import '../../app/theme.dart';

class SurveyFeedbackScreen extends StatefulWidget {
  const SurveyFeedbackScreen({super.key});

  @override
  State<SurveyFeedbackScreen> createState() => _SurveyFeedbackScreenState();
}

class _SurveyFeedbackScreenState extends State<SurveyFeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _feedbackController = TextEditingController();
  
  int _overallRating = 0;
  int _appUsabilityRating = 0;
  int _featureUsefulnessRating = 0;
  String _selectedImprovement = '';
  bool _isSubmitting = false;

  final List<String> _improvementOptions = [
    'More fraud detection features',
    'Better user interface',
    'Faster processing',
    'More detailed reports',
    'Mobile app improvements',
    'Customer support',
    'Other'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  Widget _buildRatingSection(String title, int currentRating, Function(int) onRatingChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: List.generate(5, (index) {
            return GestureDetector(
              onTap: () => onRatingChanged(index + 1),
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Icon(
                  Icons.star,
                  size: 32,
                  color: (index + 1) <= currentRating 
                      ? Colors.amber
                      : Colors.white.withOpacity(0.3),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 4),
        Text(
          _getRatingText(currentRating),
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1: return 'Poor';
      case 2: return 'Fair';
      case 3: return 'Good';
      case 4: return 'Very Good';
      case 5: return 'Excellent';
      default: return 'Not rated';
    }
  }

  Widget _buildTextInput({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    int maxLines = 1,
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.black87),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey.shade600),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Future<void> _submitSurvey() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_overallRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide an overall rating')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isSubmitting = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thank you for your feedback!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const CommonAppBar(
          title: "Survey & Feedback",
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // Header
              const Text(
                'Help Us Improve',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your feedback is valuable to us. Please take a moment to share your experience.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 32),

              // Personal Information
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Contact Information',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextInput(
                      label: 'Name',
                      controller: _nameController,
                      hintText: 'Enter your name',
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Name is required';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextInput(
                      label: 'Email',
                      controller: _emailController,
                      hintText: 'Enter your email',
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Email is required';
                        if (!value!.contains('@')) return 'Enter a valid email';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Ratings Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rate Your Experience',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildRatingSection(
                      'Overall Experience *',
                      _overallRating,
                      (rating) => setState(() => _overallRating = rating),
                    ),
                    const SizedBox(height: 24),
                    _buildRatingSection(
                      'App Usability',
                      _appUsabilityRating,
                      (rating) => setState(() => _appUsabilityRating = rating),
                    ),
                    const SizedBox(height: 24),
                    _buildRatingSection(
                      'Feature Usefulness',
                      _featureUsefulnessRating,
                      (rating) => setState(() => _featureUsefulnessRating = rating),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Improvement Suggestions
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'What would you like us to improve?',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._improvementOptions.map((option) {
                      return RadioListTile<String>(
                        title: Text(
                          option,
                          style: const TextStyle(color: Colors.white),
                        ),
                        value: option,
                        groupValue: _selectedImprovement,
                        onChanged: (value) {
                          setState(() => _selectedImprovement = value ?? '');
                        },
                        activeColor: Colors.white,
                        contentPadding: EdgeInsets.zero,
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Additional Comments
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: _buildTextInput(
                  label: 'Additional Comments',
                  controller: _feedbackController,
                  maxLines: 4,
                  hintText: 'Share your thoughts, suggestions, or any issues you encountered...',
                  validator: (value) => null,
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitSurvey,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.95),
                    foregroundColor: AppColors.primaryDark,
                    elevation: 4,
                    shadowColor: Colors.black26,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(
                          color: Color(0xFF2E3A59),
                        )
                      : const Text(
                          'Submit Feedback',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}