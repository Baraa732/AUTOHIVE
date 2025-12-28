import 'package:flutter/material.dart';
import '../../../core/network/api_service.dart';
import '../../../data/models/rental_application.dart';
import 'rental_application_detail.dart';

class IncomingRentalApplicationsScreen extends StatefulWidget {
  const IncomingRentalApplicationsScreen({Key? key}) : super(key: key);

  @override
  State<IncomingRentalApplicationsScreen> createState() => _IncomingRentalApplicationsScreenState();
}

class _IncomingRentalApplicationsScreenState extends State<IncomingRentalApplicationsScreen> {
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
      final response = await _apiService.getIncomingRentalApplications();
      
      if (response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>;
        final List<dynamic>? appsList = data['data'] as List<dynamic>?;
        
        final applicationsList = appsList?.map((app) {
          return RentalApplication.fromJson(app as Map<String, dynamic>);
        }).toList() ?? [];
        
        setState(() {
          _applications = applicationsList;
          _errorMessage = null;
        });
      } else {
        setState(() => _errorMessage = response['message'] ?? 'Failed to load applications');
      }
    } catch (e, stackTrace) {
      print('Error loading applications: $e');
      print('Stack trace: $stackTrace');
      setState(() => _errorMessage = 'Error loading applications: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Incoming Applications'),
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
                      child: Text('No pending applications'),
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
    final tenantName = app.user != null 
        ? '${app.user!['first_name']} ${app.user!['last_name']}'
        : 'Unknown Tenant';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              app.apartment?['title'] ?? 'Unknown Apartment',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue[100],
                  child: Text(
                    tenantName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tenantName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      if (app.user != null)
                        Text(
                          app.user!['phone'] ?? 'No phone',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
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
                      ),
                    ),
                  );
                  if (result == true && mounted) {
                    await Future.delayed(const Duration(milliseconds: 300));
                    if (mounted) {
                      _loadApplications();
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
