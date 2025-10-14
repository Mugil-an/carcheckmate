import 'package:flutter/material.dart';
import '../widgets/common_background.dart';
import '../../app/theme.dart';
import '../../utilities/dialogs/error_dialog.dart';
import '../../core/exceptions/survey_exceptions.dart';
import '../../core/exceptions/network_exceptions.dart';

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
    try {
      // Validate form
      if (!_formKey.currentState!.validate()) {
        throw SurveyValidationException();
      }
      
      // Validate required rating
      if (_overallRating == 0) {
        throw SurveyFieldRequiredException('Overall rating');
      }

      // Validate email format
      if (_emailController.text.isNotEmpty && !_isValidEmail(_emailController.text)) {
        throw InvalidEmailFormatException();
      }

      // Validate feedback length
      if (_feedbackController.text.isNotEmpty) {
        if (_feedbackController.text.trim().length < 10) {
          throw FeedbackTooShortException();
        }
        if (_feedbackController.text.trim().length > 1000) {
          throw FeedbackTooLongException();
        }
      }

      setState(() => _isSubmitting = true);

      // Prepare survey data
      final surveyData = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'overallRating': _overallRating,
        'appUsabilityRating': _appUsabilityRating,
        'featureUsefulnessRating': _featureUsefulnessRating,
        'selectedImprovement': _selectedImprovement,
        'feedback': _feedbackController.text.trim(),
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Simulate API call with potential failures
      await _performSurveySubmission(surveyData);

      setState(() => _isSubmitting = false);

      if (mounted) {
        // Show success message
        await showErrorDialog(
          context,
          'Your feedback has been submitted successfully. We appreciate your time and input.',
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      
      if (mounted) {
        if (e is SurveyException) {
          await showErrorDialog(context, e.toString());
        } else {
          await showErrorDialog(context, 'Failed to submit survey. Please try again.');
        }
      }
    }
  }

  Future<void> _performSurveySubmission(Map<String, dynamic> surveyData) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    
    // Simulate potential failures (for demonstration)
    if (surveyData['email'] == 'test@error.com') {
      throw SurveySubmissionException();
    }
    
    // Simulate network errors
    if (surveyData['name'] == 'NetworkError') {
      throw NoInternetConnectionException();
    }
    
    // Simulate rate limiting
    if (surveyData['feedback'].toString().toLowerCase().contains('spam')) {
      throw SurveyRateLimitException();
    }
    
    // Success case - in real implementation, this would make actual API call
    debugPrint('Survey submitted successfully: $surveyData');
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
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
                        if (value!.trim().length < 2) return 'Name must be at least 2 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextInput(
                      label: 'Email',
                      controller: _emailController,
                      hintText: 'Enter your email (optional)',
                      validator: (value) {
                        if (value?.isNotEmpty ?? false) {
                          if (!_isValidEmail(value!)) return 'Enter a valid email address';
                        }
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