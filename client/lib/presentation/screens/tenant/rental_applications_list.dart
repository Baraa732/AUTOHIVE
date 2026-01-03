import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_service.dart';
import '../../../data/models/rental_application.dart';
import '../../../data/models/apartment.dart';
import '../../../presentation/widgets/application_status_badge.dart';
import '../../../presentation/widgets/wallet_balance_widget.dart';
import '../../../presentation/widgets/booking_payment_info_widget.dart';
import '../../../presentation/providers/wallet_provider.dart';
import '../shared/modify_application_form.dart';
import '../wallet/wallet_screen.dart';

class RentalApplicationsListScreen extends ConsumerStatefulWidget {
  const RentalApplicationsListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RentalApplicationsListScreen> createState() =>
      _RentalApplicationsListScreenState();
}

class _RentalApplicationsListScreenState
    extends ConsumerState<RentalApplicationsListScreen> {
  late ApiService _apiService;
  bool _isLoading = true;
  List<RentalApplication> _applications = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _loadApplications();
    Future.microtask(() {
      ref.read(walletProvider.notifier).loadWallet();
    });
  }

  Future<void> _loadApplications() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.getMyRentalApplications();

      if (response['success'] == true) {
        late List<dynamic> appsList;
        final data = response['data'];

        if (data is List) {
          appsList = data;
        } else if (data is Map && data.containsKey('data')) {
          appsList = data['data'] as List<dynamic>? ?? [];
        } else {
          appsList = [];
        }

        final applicationsList = appsList.map((app) {
          return RentalApplication.fromJson(app as Map<String, dynamic>);
        }).toList();

        setState(() {
          _applications = applicationsList;
          _errorMessage = null;
        });
      } else {
        setState(
          () => _errorMessage =
              response['message'] ?? 'Failed to load applications',
        );
      }
    } catch (e) {
      setState(() => _errorMessage = 'Error loading applications: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Rental Applications'), elevation: 0),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_errorMessage!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadApplications,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : _applications.isEmpty
          ? const Center(child: Text('No rental applications yet'))
          : RefreshIndicator(
              onRefresh: _loadApplications,
              child: ListView.builder(
                itemCount: _applications.length + 1,
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Consumer(
                        builder: (context, ref, _) {
                          final walletState = ref.watch(walletProvider);
                          if (walletState.wallet != null) {
                            return WalletBalanceWidget(compact: false);
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    );
                  }
                  final app = _applications[index - 1];
                  return _buildApplicationCard(app);
                },
              ),
            ),
    );
  }

  Widget _buildApplicationCard(RentalApplication app) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    app.apartment?['title'] ?? 'Unknown Apartment',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                ApplicationStatusBadge(
                  status: app.status,
                  showTimestamp: false,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  '${app.checkIn.toString().split(' ')[0]} to ${app.checkOut.toString().split(' ')[0]}',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.send, size: 14, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Submission #${app.submissionAttempt + 1}',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
            if (app.message != null && app.message!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  app.message!,
                  style: const TextStyle(fontSize: 13),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
            if (app.rejectedReason != null &&
                app.rejectedReason!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rejection Reason:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      app.rejectedReason!,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
            if (app.modificationSubmittedAt != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.purple[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Last Modified:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      app.modificationSubmittedAt.toString().split(' ')[0],
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
            if (app.status == 'pending' || app.status == 'modified_pending') ...[
              const SizedBox(height: 12),
              BookingPaymentInfoWidget(
                rentalAmount: (app.apartment?['price_per_month'] as num?)?.toDouble() ?? 0,
                apartmentTitle: app.apartment?['title'] ?? 'Apartment',
                checkIn: app.checkIn,
                checkOut: app.checkOut,
              ),
            ],
            if (app.canBeModified()) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            ModifyApplicationFormScreen(application: app),
                      ),
                    );
                    if (result == true && mounted) {
                      await Future.delayed(const Duration(milliseconds: 300));
                      if (mounted) {
                        _loadApplications();
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: const Text('Modify Application'),
                ),
              ),
            ],
            if (app.status == 'rejected' && app.submissionAttempt < 2) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            ModifyApplicationFormScreen(application: app),
                      ),
                    );
                    if (result == true && mounted) {
                      await Future.delayed(const Duration(milliseconds: 300));
                      if (mounted) {
                        _loadApplications();
                      }
                    }
                  },
                  child: const Text('Resubmit Application'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
