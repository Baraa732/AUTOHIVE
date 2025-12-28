import 'package:flutter/material.dart';
import '../../../core/network/api_service.dart';
import '../../../data/models/rental_application.dart';
import '../../../data/models/apartment.dart';

class RentalApplicationsListScreen extends StatefulWidget {
  const RentalApplicationsListScreen({Key? key}) : super(key: key);

  @override
  State<RentalApplicationsListScreen> createState() => _RentalApplicationsListScreenState();
}

class _RentalApplicationsListScreenState extends State<RentalApplicationsListScreen> {
  late ApiService _apiService;
  bool _isLoading = true;
  List<RentalApplication> _applications = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _loadApplications();
  }

  Future<void> _loadApplications() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.getMyRentalApplications();
      
      if (response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>;
        final applicationsList = (data['data'] as List?)?.map((app) {
          return RentalApplication.fromJson(app as Map<String, dynamic>);
        }).toList() ?? [];
        
        setState(() {
          _applications = applicationsList;
          _errorMessage = null;
        });
      } else {
        setState(() => _errorMessage = response['message'] ?? 'Failed to load applications');
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
      appBar: AppBar(
        title: const Text('My Rental Applications'),
        elevation: 0,
      ),
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
                  ? const Center(
                      child: Text('No rental applications yet'),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadApplications,
                      child: ListView.builder(
                        itemCount: _applications.length,
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (context, index) {
                          final app = _applications[index];
                          return _buildApplicationCard(app);
                        },
                      ),
                    ),
    );
  }

  Widget _buildApplicationCard(RentalApplication app) {
    final statusColor = app.status == 'approved'
        ? Colors.green
        : app.status == 'rejected'
            ? Colors.red
            : Colors.orange;

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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    app.status.toUpperCase(),
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
            if (app.rejectedReason != null && app.rejectedReason!.isNotEmpty) ...[
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
            if (app.status == 'rejected' && app.submissionAttempt < 2) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Resubmission feature coming soon')),
                    );
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
