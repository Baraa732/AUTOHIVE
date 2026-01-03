import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/network/api_service.dart';
import '../../../data/models/deposit_withdrawal_request.dart';

class AdminWalletRequestsProvider extends ChangeNotifier {
  final ApiService apiService;
  
  List<DepositWithdrawalRequest> _requests = [];
  String? _selectedStatus;
  bool _isLoading = false;
  String? _error;

  AdminWalletRequestsProvider({required this.apiService});

  List<DepositWithdrawalRequest> get requests => _requests;
  String? get selectedStatus => _selectedStatus;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadRequests({String? status}) async {
    _isLoading = true;
    _error = null;
    _selectedStatus = status;
    notifyListeners();

    try {
      final response = await apiService.getAdminWalletRequests(status: status);
      if (response['success'] == true) {
        final List<dynamic> data = response['data'] as List<dynamic>;
        _requests = data
            .map((item) => DepositWithdrawalRequest.fromJson(item as Map<String, dynamic>))
            .toList();
        _error = null;
      } else {
        _error = response['message'] ?? 'Failed to load requests';
      }
    } catch (e) {
      _error = 'Error loading requests: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> approveRequest(int requestId) async {
    try {
      final response = await apiService.approveWalletRequest(requestId);
      if (response['success'] == true) {
        _requests.removeWhere((req) => req.id == requestId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> rejectRequest(int requestId, String reason) async {
    try {
      final response = await apiService.rejectWalletRequest(requestId, reason);
      if (response['success'] == true) {
        _requests.removeWhere((req) => req.id == requestId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}

class AdminWalletRequestsScreen extends StatefulWidget {
  const AdminWalletRequestsScreen({Key? key}) : super(key: key);

  @override
  State<AdminWalletRequestsScreen> createState() => _AdminWalletRequestsScreenState();
}

class _AdminWalletRequestsScreenState extends State<AdminWalletRequestsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<AdminWalletRequestsProvider>().loadRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminWalletRequestsProvider(
        apiService: context.read<ApiService>(),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Wallet Requests'),
          elevation: 0,
          backgroundColor: const Color(0xFF1e5631),
        ),
        body: Consumer<AdminWalletRequestsProvider>(
          builder: (context, provider, _) {
            return Column(
              children: [
                // Filter Buttons
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      _filterButton(context, 'All', null, provider.selectedStatus == null),
                      const SizedBox(width: 8),
                      _filterButton(context, 'Pending', 'pending',
                          provider.selectedStatus == 'pending'),
                      const SizedBox(width: 8),
                      _filterButton(context, 'Approved', 'approved',
                          provider.selectedStatus == 'approved'),
                      const SizedBox(width: 8),
                      _filterButton(context, 'Rejected', 'rejected',
                          provider.selectedStatus == 'rejected'),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: provider.isLoading && provider.requests.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : provider.error != null && provider.requests.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(provider.error ?? 'Error loading requests'),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () {
                                      provider.loadRequests(status: provider.selectedStatus);
                                    },
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            )
                          : provider.requests.isEmpty
                              ? const Center(child: Text('No requests found'))
                              : RefreshIndicator(
                                  onRefresh: () => provider.loadRequests(
                                    status: provider.selectedStatus,
                                  ),
                                  child: ListView.separated(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    itemCount: provider.requests.length,
                                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                                    itemBuilder: (context, index) {
                                      return _RequestCard(
                                        request: provider.requests[index],
                                        onApprove: () {
                                          _showApproveDialog(context, provider, index);
                                        },
                                        onReject: () {
                                          _showRejectDialog(context, provider, index);
                                        },
                                      );
                                    },
                                  ),
                                ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _filterButton(BuildContext context, String label, String? status,
      bool isSelected) {
    return ElevatedButton(
      onPressed: () {
        context.read<AdminWalletRequestsProvider>().loadRequests(status: status);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? const Color(0xFF1e5631) : Colors.grey[300],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  void _showApproveDialog(BuildContext context,
      AdminWalletRequestsProvider provider, int index) {
    final request = provider.requests[index];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('User: ${request.userId}'),
            Text('Type: ${request.type.displayName}'),
            Text('Amount: \$${request.amountUsd.toStringAsFixed(2)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await provider.approveRequest(request.id);
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success ? 'Request approved successfully' : 'Failed to approve',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context,
      AdminWalletRequestsProvider provider, int index) {
    final request = provider.requests[index];
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('User: ${request.userId}'),
            Text('Type: ${request.type.displayName}'),
            Text('Amount: \$${request.amountUsd.toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                hintText: 'Rejection reason',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await provider.rejectRequest(
                request.id,
                reasonController.text,
              );
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success ? 'Request rejected successfully' : 'Failed to reject',
                    ),
                    backgroundColor: success ? Colors.orange : Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final DepositWithdrawalRequest request;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _RequestCard({
    required this.request,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (request.status) {
      case RequestStatus.pending:
        statusColor = Colors.orange;
        break;
      case RequestStatus.approved:
        statusColor = Colors.green;
        break;
      case RequestStatus.rejected:
        statusColor = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${request.type.displayName} - \$${request.amountUsd.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'User ID: ${request.userId}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  request.status.displayName,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Created: ${request.createdAt.toString().split('.')[0]}',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
          if (request.reason != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Reason: ${request.reason}',
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
            ),
          ],
          if (request.status == RequestStatus.pending) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onApprove,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text('Approve'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onReject,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text('Reject'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
