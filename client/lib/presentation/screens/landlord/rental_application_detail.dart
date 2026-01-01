import 'package:flutter/material.dart';
import '../../../core/network/api_service.dart';
import '../../../data/models/rental_application.dart';
import '../../../presentation/widgets/application_status_badge.dart';
import '../../../presentation/widgets/tenant_profile_card.dart';
import '../shared/modification_review_screen.dart';

class RentalApplicationDetailScreen extends StatefulWidget {
  final RentalApplication application;
  final VoidCallback? onApplicationUpdated;

  const RentalApplicationDetailScreen({
    Key? key,
    required this.application,
    this.onApplicationUpdated,
  }) : super(key: key);

  @override
  State<RentalApplicationDetailScreen> createState() => _RentalApplicationDetailScreenState();
}

class _RentalApplicationDetailScreenState extends State<RentalApplicationDetailScreen> {
  late ApiService _apiService;
  late RentalApplication _application;
  bool _isProcessing = false;
  bool _loadingModifications = false;
  List<dynamic> _modifications = [];
  final TextEditingController _rejectionReasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _application = widget.application;
    _debugLogApplicationStatus();
    if (_application.hasModification()) {
      _loadModifications();
    }
  }

  void _debugLogApplicationStatus() {
    print('🔍 DEBUG: Application Detail Screen Loaded');
    print('   - ID: ${_application.id}');
    print('   - Status: ${_application.status}');
    print('   - Tenant: ${_application.user?['first_name']} ${_application.user?['last_name']}');
    print('   - Apartment: ${_application.apartment?['title']}');
    print('   - Status allows approve/reject: ${_application.status == 'pending' || _application.status == 'modified-pending'}');
  }

  Future<void> _loadModifications() async {
    setState(() => _loadingModifications = true);
    try {
      final response = await _apiService.getModificationHistory(_application.id);
      if (response['success'] == true && mounted) {
        setState(() {
          _modifications = response['data'] as List<dynamic>? ?? [];
          _loadingModifications = false;
        });
      }
    } catch (e) {
      print('Error loading modifications: $e');
      if (mounted) {
        setState(() => _loadingModifications = false);
      }
    }
  }

  @override
  void dispose() {
    _rejectionReasonController.dispose();
    super.dispose();
  }

  Future<void> _approveApplication() async {
    print('👍 DEBUG: Approve button pressed for application ${_application.id}');
    print('   - Current status: ${_application.status}');
    
    if (_application.status != 'pending' && _application.status != 'modified-pending') {
      print('❌ DEBUG: Cannot approve - invalid status');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot approve - application status does not allow it')),
        );
      }
      return;
    }

    setState(() => _isProcessing = true);
    print('⏳ DEBUG: Starting approval API call...');

    try {
      final response = await _apiService.approveRentalApplication(_application.id);
      print('📡 DEBUG: Approval API response: ${response['success']}');

      if (mounted) {
        if (response['success'] == true) {
          print('✅ DEBUG: Approval successful');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Application approved successfully!')),
          );
          
          if (widget.onApplicationUpdated != null) {
            widget.onApplicationUpdated!();
          }
          
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted && Navigator.of(context).canPop()) {
            Navigator.pop(context, true);
          }
        } else {
          final message = response['message'] ?? 'Failed to approve application';
          print('❌ DEBUG: Approval failed: $message');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
          if (mounted) {
            setState(() => _isProcessing = false);
          }
        }
      }
    } catch (e, stackTrace) {
      print('❌ DEBUG: Exception during approval: $e');
      print('   Stack: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _rejectApplication() async {
    print('👎 DEBUG: Reject button pressed for application ${_application.id}');
    print('   - Current status: ${_application.status}');
    print('   - Rejection reason: ${_rejectionReasonController.text}');
    
    if (_application.status != 'pending') {
      print('❌ DEBUG: Cannot reject - invalid status (only pending can be rejected)');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot reject - only pending applications can be rejected')),
        );
      }
      return;
    }

    setState(() => _isProcessing = true);
    print('⏳ DEBUG: Starting rejection API call...');

    try {
      final response = await _apiService.rejectRentalApplication(
        _application.id,
        rejectedReason: _rejectionReasonController.text.isEmpty 
            ? null 
            : _rejectionReasonController.text,
      );
      print('📡 DEBUG: Rejection API response: ${response['success']}');

      if (mounted) {
        if (response['success'] == true) {
          print('✅ DEBUG: Rejection successful');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Application rejected')),
          );
          
          if (widget.onApplicationUpdated != null) {
            widget.onApplicationUpdated!();
          }
          
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted && Navigator.of(context).canPop()) {
            Navigator.pop(context, true);
          }
        } else {
          final message = response['message'] ?? 'Failed to reject application';
          print('❌ DEBUG: Rejection failed: $message');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
          if (mounted) {
            setState(() => _isProcessing = false);
          }
        }
      }
    } catch (e, stackTrace) {
      print('❌ DEBUG: Exception during rejection: $e');
      print('   Stack: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showRejectDialog() {
    print('🗑️ DEBUG: Reject dialog opened');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Application'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Are you sure you want to reject this application?'),
              const SizedBox(height: 16),
              const Text(
                'Optional: Provide a reason (will be shown to the tenant)',
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
            onPressed: () {
              print('🗑️ DEBUG: Reject dialog cancelled');
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              print('🗑️ DEBUG: Reject dialog confirmed');
              Navigator.pop(context);
              _rejectApplication();
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
    final tenantName = _application.user != null 
        ? '${_application.user!['first_name']} ${_application.user!['last_name']}'
        : 'Unknown Tenant';
    final tenantPhone = _application.user?['phone'] ?? 'N/A';
    final apartmentTitle = _application.apartment?['title'] ?? 'Unknown';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Application Details'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    apartmentTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                ApplicationStatusBadge(
                  status: _application.status,
                  timestamp: _application.respondedAt ?? _application.submittedAt,
                  showTimestamp: false,
                ),
              ],
            ),
            const SizedBox(height: 16),
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
                      apartmentTitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
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
                      user: _application.user,
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
                      'Rental Period',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          '${_application.checkIn.toString().split(' ')[0]} to ${_application.checkOut.toString().split(' ')[0]}',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.nights_stay, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          '${_application.checkOut.difference(_application.checkIn).inDays} night(s)',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (_application.message != null && _application.message!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tenant Message',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _application.message!,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (_application.status == 'modified-pending' && _modifications.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                color: Colors.purple[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.edit, color: Colors.purple, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Pending Modification',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'The applicant has requested to modify this application. Review the changes below.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _loadingModifications
                              ? null
                              : () async {
                                  final modification = _modifications.isNotEmpty
                                      ? _modifications[0] as Map<String, dynamic>
                                      : null;
                                  if (modification != null) {
                                    final result = await Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => ModificationReviewScreen(
                                          application: _application,
                                          modification: modification,
                                        ),
                                      ),
                                    );
                                    if (result == true && mounted) {
                                      Navigator.pop(context, true);
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                          ),
                          child: _loadingModifications
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text('Review Modification'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (_application.status == 'pending' || _application.status == 'modified-pending') ...[
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _approveApplication,
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
                          'Approve Application',
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
                    'Reject Application',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ] else if (_application.status == 'rejected') ...[
              const SizedBox(height: 32),
              Card(
                color: Colors.red[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Application Status',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This application has been rejected',
                        style: TextStyle(color: Colors.red[700]),
                      ),
                      if (_application.rejectedReason != null && _application.rejectedReason!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Reason: ${_application.rejectedReason}',
                          style: TextStyle(color: Colors.red[700], fontSize: 12),
                        ),
                      ]
                    ],
                  ),
                ),
              ),
            ] else ...[
              const SizedBox(height: 32),
              Card(
                color: Colors.green[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Application Status',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This application has been ${_application.status}',
                        style: TextStyle(color: Colors.green[700]),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
