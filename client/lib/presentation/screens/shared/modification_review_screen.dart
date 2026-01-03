import 'package:flutter/material.dart';
import '../../../core/network/api_service.dart';
import '../../../data/models/rental_application.dart';
import '../../widgets/modification_diff_viewer.dart';
import '../../widgets/tenant_profile_card.dart';
import '../../widgets/tenant_rating_summary.dart';
import '../../widgets/tenant_review_card.dart';

class ModificationReviewScreen extends StatefulWidget {
  final RentalApplication application;
  final Map<String, dynamic> modification;

  const ModificationReviewScreen({
    Key? key,
    required this.application,
    required this.modification,
  }) : super(key: key);

  @override
  State<ModificationReviewScreen> createState() => _ModificationReviewScreenState();
}

class _ModificationReviewScreenState extends State<ModificationReviewScreen> {
  late ApiService _apiService;
  bool _isProcessing = false;
  final TextEditingController _rejectionReasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
  }

  @override
  void dispose() {
    _rejectionReasonController.dispose();
    super.dispose();
  }

  Future<void> _approveModification() async {
    setState(() => _isProcessing = true);

    try {
      final response = await _apiService.approveModification(
        widget.application.id,
        widget.modification['id'].toString(),
      );

      if (mounted) {
        if (response['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Modification approved successfully!')),
          );
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted && Navigator.of(context).canPop()) {
            Navigator.pop(context, true);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'] ?? 'Failed to approve modification')),
          );
          if (mounted) {
            setState(() => _isProcessing = false);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _rejectModification() async {
    setState(() => _isProcessing = true);

    try {
      final response = await _apiService.rejectModification(
        widget.application.id,
        widget.modification['id'].toString(),
        rejectionReason: _rejectionReasonController.text.isEmpty
            ? null
            : _rejectionReasonController.text,
      );

      if (mounted) {
        if (response['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Modification rejected')),
          );
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted && Navigator.of(context).canPop()) {
            Navigator.pop(context, true);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'] ?? 'Failed to reject modification')),
          );
          if (mounted) {
            setState(() => _isProcessing = false);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showRejectDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Modification'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Are you sure you want to reject this modification?'),
              const SizedBox(height: 16),
              const Text(
                'The application will revert to its previous status.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              const Text(
                'Optional: Provide a reason (will be shown to the user)',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _rejectionReasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Reason for rejection...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _rejectModification();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Modification'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Apartment',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.application.apartment?['title'] ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tenant Information',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TenantProfileCard(
                      user: widget.application.user,
                      horizontal: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tenant Review History',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TenantRatingSummary(
                      averageRating: widget.application.user?['average_rating'] as double?,
                      reviewCount: widget.application.user?['review_count'] as int? ?? 0,
                    ),
                    if (widget.application.user?['reviews'] != null && (widget.application.user!['reviews'] as List).isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 12),
                      const Text(
                        'Recent Reviews',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...(((widget.application.user!['reviews'] as List)
                          .cast<Map<String, dynamic>>()
                          .take(5)
                          .map((review) => TenantReviewCard(
                                rating: (review['rating'] as num?)?.toInt() ?? 0,
                                comment: review['comment'] as String?,
                                apartmentTitle: review['apartment']?['title'] as String?,
                                createdAt: review['created_at'] != null
                                    ? DateTime.parse(review['created_at'] as String)
                                    : null,
                              ))
                          .toList())),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ModificationDiffViewer(
                  modification: widget.modification,
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _approveModification,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green,
                ),
                child: _isProcessing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Approve Modification',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _isProcessing ? null : _showRejectDialog,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.red),
                ),
                child: const Text(
                  'Reject Modification',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
