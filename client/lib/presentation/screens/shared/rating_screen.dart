import 'package:flutter/material.dart';
import '../../widgets/rating_widget.dart';
import '../../../data/models/booking.dart';
import '../../../data/models/apartment.dart';
import '../../../core/network/api_service.dart';
import '../../../core/constants/app_config.dart';

class RatingScreen extends StatefulWidget {
  final Booking booking;
  final Apartment apartment;

  const RatingScreen({Key? key, required this.booking, required this.apartment})
    : super(key: key);

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  final _apiService = ApiService();

  int _overallRating = 0;
  int _cleanlinessRating = 0;
  int _locationRating = 0;
  int _valueRating = 0;
  int _communicationRating = 0;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadImageUrl();
  }

  String _imageUrl = '';

  Future<void> _loadImageUrl() async {
    if (widget.apartment.images.isNotEmpty) {
      final baseUrl = await AppConfig.baseUrl;
      final imagePath = widget.apartment.images.first;
      setState(() {
        _imageUrl = imagePath.startsWith('http') 
            ? imagePath 
            : '$baseUrl/storage/$imagePath';
      });
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_overallRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide an overall rating'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final response = await _apiService
          .submitReview(int.parse(widget.booking.id), {
            'rating': _overallRating,
            'comment': _commentController.text.trim(),
            'cleanliness_rating': _cleanlinessRating > 0
                ? _cleanlinessRating
                : null,
            'location_rating': _locationRating > 0 ? _locationRating : null,
            'value_rating': _valueRating > 0 ? _valueRating : null,
            'communication_rating': _communicationRating > 0
                ? _communicationRating
                : null,
          });

      if (response['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        // Handle specific error cases
        String errorMessage = response['message'] ?? 'Failed to submit review';
        String? reason = response['reason'];
        
        // Show user-friendly message for duplicate review
        if (reason != null && reason.contains('already reviewed')) {
          errorMessage = 'You have already submitted a review for this booking.';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to submit review. Please try again later.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Rate Your Stay'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFff6f2d), Color(0xFF4a90e2)],
            ),
          ),
        ),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Apartment Info Header
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: _imageUrl.isNotEmpty
                        ? Image.network(
                            _imageUrl,
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFff6f2d).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFff6f2d)),
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFff6f2d).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.apartment,
                                  size: 35,
                                  color: Color(0xFFff6f2d),
                                ),
                              );
                            },
                          )
                        : Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: const Color(0xFFff6f2d).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.apartment,
                              size: 35,
                              color: Color(0xFFff6f2d),
                            ),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.apartment.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                widget.apartment.address,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_formatDate(widget.booking.checkIn)} - ${_formatDate(widget.booking.checkOut)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Form Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Overall Rating Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFff6f2d), Color(0xFF4a90e2)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFff6f2d).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Overall Rating',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'How was your overall experience?',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 16),
                          StarRatingWidget(
                            initialRating: _overallRating,
                            onRatingChanged: (rating) => setState(() => _overallRating = rating),
                            size: 40.0,
                            filledColor: Colors.amber,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Detailed Ratings
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Rate Specific Aspects',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildCompactRating(
                            Icons.cleaning_services,
                            'Cleanliness',
                            _cleanlinessRating,
                            (rating) => setState(() => _cleanlinessRating = rating),
                          ),
                          const Divider(height: 24),
                          _buildCompactRating(
                            Icons.location_on,
                            'Location',
                            _locationRating,
                            (rating) => setState(() => _locationRating = rating),
                          ),
                          const Divider(height: 24),
                          _buildCompactRating(
                            Icons.attach_money,
                            'Value',
                            _valueRating,
                            (rating) => setState(() => _valueRating = rating),
                          ),
                          const Divider(height: 24),
                          _buildCompactRating(
                            Icons.chat_bubble_outline,
                            'Communication',
                            _communicationRating,
                            (rating) => setState(() => _communicationRating = rating),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Comment Section
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.rate_review, size: 20, color: Color(0xFFff6f2d)),
                              const SizedBox(width: 8),
                              const Text(
                                'Share Your Experience',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _commentController,
                            maxLines: 5,
                            decoration: InputDecoration(
                              hintText: 'Tell us about your stay...',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              filled: true,
                              fillColor: Colors.grey[50],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFff6f2d), width: 2),
                              ),
                            ),
                            validator: (value) {
                              if (value != null && value.length > 1000) {
                                return 'Comment must be less than 1000 characters';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Submit Button
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: _isSubmitting
                            ? LinearGradient(
                                colors: [Colors.grey[400]!, Colors.grey[500]!],
                              )
                            : const LinearGradient(
                                colors: [Color(0xFFff6f2d), Color(0xFF4a90e2)],
                              ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: _isSubmitting
                            ? []
                            : [
                                BoxShadow(
                                  color: const Color(0xFFff6f2d).withOpacity(0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitReview,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.send, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Submit Review',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactRating(
    IconData icon,
    String title,
    int currentRating,
    Function(int) onRatingChanged,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFff6f2d).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: const Color(0xFFff6f2d)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        StarRatingWidget(
          initialRating: currentRating,
          onRatingChanged: onRatingChanged,
          size: 24.0,
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
