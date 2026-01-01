import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/rental_application.dart';
import '../../../data/providers/rental_applications_provider.dart';
import '../../../presentation/widgets/application_status_badge.dart';
import '../../../presentation/widgets/tenant_profile_card.dart';
import 'rental_application_detail.dart';

class IncomingRentalApplicationsScreen extends ConsumerStatefulWidget {
  const IncomingRentalApplicationsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<IncomingRentalApplicationsScreen> createState() => _IncomingRentalApplicationsScreenState();
}

class _IncomingRentalApplicationsScreenState extends ConsumerState<IncomingRentalApplicationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(rentalApplicationProvider.notifier).loadIncomingApplications();
    });
  }

  Future<void> _refreshApplications() async {
    await ref.read(rentalApplicationProvider.notifier).loadIncomingApplications();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(rentalApplicationProvider);
    final applications = state.incomingApplications;
    final isLoading = state.isLoading;
    final error = state.error;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Incoming Applications'),
        elevation: 0,
      ),
      body: isLoading && applications.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(error),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _refreshApplications,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : applications.isEmpty
                  ? const Center(
                      child: Text('No pending applications'),
                    )
                  : RefreshIndicator(
                      onRefresh: _refreshApplications,
                      child: ListView.builder(
                        itemCount: applications.length,
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (context, index) {
                          final app = applications[index];
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
            TenantProfileCard(
              user: app.user,
              horizontal: true,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    '${app.checkIn.toString().split(' ')[0]} to ${app.checkOut.toString().split(' ')[0]}',
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ),
            if (app.message != null && app.message!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Message from Tenant:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      app.message!,
                      style: const TextStyle(fontSize: 12),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => RentalApplicationDetailScreen(
                        application: app,
                        onApplicationUpdated: _refreshApplications,
                      ),
                    ),
                  );
                  if (result == true && mounted) {
                    await Future.delayed(const Duration(milliseconds: 300));
                    if (mounted) {
                      _refreshApplications();
                    }
                  }
                },
                child: const Text('Review & Respond'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
