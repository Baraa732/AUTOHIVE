import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_service.dart';

class DebugBookingsScreen extends ConsumerStatefulWidget {
  const DebugBookingsScreen({super.key});

  @override
  ConsumerState<DebugBookingsScreen> createState() =>
      _DebugBookingsScreenState();
}

class _DebugBookingsScreenState extends ConsumerState<DebugBookingsScreen> {
  final ApiService _apiService = ApiService();
  String _debugOutput = 'Press buttons to test API endpoints\n';

  void _addLog(String message) {
    setState(() {
      _debugOutput += '\n$message';
    });
  }

  Future<void> _testGetMyBookings() async {
    _addLog('\n🔵 Testing GET /bookings...');
    try {
      final result = await _apiService.getMyBookings();
      _addLog('✅ Response: ${result.toString()}');
      _addLog('Success: ${result['success']}');
      _addLog('Data type: ${result['data'].runtimeType}');
      if (result['data'] is Map) {
        _addLog('Data keys: ${(result['data'] as Map).keys.toList()}');
      }
    } catch (e) {
      _addLog('❌ Error: $e');
    }
  }

  Future<void> _testGetMyApartmentBookings() async {
    _addLog('\n🔵 Testing GET /my-apartment-bookings...');
    try {
      final result = await _apiService.getMyApartmentBookings();
      _addLog('✅ Response: ${result.toString()}');
      _addLog('Success: ${result['success']}');
      _addLog('Data type: ${result['data'].runtimeType}');
      if (result['data'] is Map) {
        _addLog('Data keys: ${(result['data'] as Map).keys.toList()}');
      }
    } catch (e) {
      _addLog('❌ Error: $e');
    }
  }

  Future<void> _testGetMyRentalApplications() async {
    _addLog('\n🔵 Testing GET /rental-applications/my-applications...');
    try {
      final result = await _apiService.getMyRentalApplications();
      _addLog('✅ Success: ${result['success']}');
      _addLog('Message: ${result['message']}');
      if (result['data'] is List) {
        _addLog('Applications count: ${(result['data'] as List).length}');
        if ((result['data'] as List).isNotEmpty) {
          final app = (result['data'] as List).first;
          _addLog('First app status: ${app['status']}');
          _addLog('First app ID: ${app['id']}');
        }
      }
    } catch (e) {
      _addLog('❌ Error: $e');
    }
  }

  Future<void> _testGetIncomingApplications() async {
    _addLog('\n🔵 Testing GET /rental-applications/incoming...');
    try {
      final result = await _apiService.getIncomingRentalApplications();
      _addLog('✅ Success: ${result['success']}');
      _addLog('Message: ${result['message']}');
      if (result['data'] is List) {
        _addLog('Applications count: ${(result['data'] as List).length}');
        if ((result['data'] as List).isNotEmpty) {
          final app = (result['data'] as List).first;
          _addLog('First app status: ${app['status']}');
          _addLog('First app ID: ${app['id']}');
          _addLog('User: ${app['user']}');
        }
      }
    } catch (e) {
      _addLog('❌ Error: $e');
    }
  }

  Future<void> _testModifyRentalApplication() async {
    _addLog('\n🔵 Testing POST /rental-applications/{id}/modify...');
    try {
      _addLog('First fetching a pending/approved application...');
      final appsResult = await _apiService.getMyRentalApplications();
      if (appsResult['success'] && (appsResult['data'] as List).isNotEmpty) {
        final app = (appsResult['data'] as List).firstWhere(
          (a) => a['status'] == 'pending' || a['status'] == 'approved',
          orElse: () => null,
        );
        if (app != null) {
          final appId = app['id'].toString();
          _addLog('Found application: $appId with status: ${app['status']}');
          
          final tomorrow = DateTime.now().add(const Duration(days: 1)).toString().split(' ')[0];
          final nextWeek = DateTime.now().add(const Duration(days: 8)).toString().split(' ')[0];
          
          final result = await _apiService.modifyRentalApplication(
            appId,
            checkIn: tomorrow,
            checkOut: nextWeek,
            message: 'Test modification from debug screen',
          );
          _addLog('✅ Success: ${result['success']}');
          _addLog('Message: ${result['message']}');
          if (result['data'] != null) {
            _addLog('Modification ID: ${result['data']['modification']?['id']}');
            _addLog('Application status: ${result['data']['application']?['status']}');
          }
        } else {
          _addLog('❌ No pending/approved application found');
        }
      } else {
        _addLog('❌ Could not fetch applications');
      }
    } catch (e) {
      _addLog('❌ Error: $e');
    }
  }

  Future<void> _testGetModificationHistory() async {
    _addLog('\n🔵 Testing GET /rental-applications/{id}/modifications...');
    try {
      _addLog('Fetching applications with modifications...');
      final appsResult = await _apiService.getMyRentalApplications();
      if (appsResult['success'] && (appsResult['data'] as List).isNotEmpty) {
        final app = (appsResult['data'] as List).firstWhere(
          (a) => a['status'] == 'modified-pending' || a['status'] == 'modified-approved',
          orElse: () => null,
        );
        if (app != null) {
          final appId = app['id'].toString();
          _addLog('Found modified application: $appId');
          
          final result = await _apiService.getModificationHistory(appId);
          _addLog('✅ Success: ${result['success']}');
          if (result['data'] is List) {
            _addLog('Modifications count: ${(result['data'] as List).length}');
            if ((result['data'] as List).isNotEmpty) {
              final mod = (result['data'] as List).first;
              _addLog('First mod status: ${mod['status']}');
              _addLog('Previous values: ${mod['previous_values']}');
              _addLog('New values: ${mod['new_values']}');
              _addLog('Diff: ${mod['diff']}');
            }
          }
        } else {
          _addLog('❌ No modified application found');
        }
      }
    } catch (e) {
      _addLog('❌ Error: $e');
    }
  }

  Future<void> _testApproveModification() async {
    _addLog('\n🔵 Testing POST /rental-applications/{id}/modifications/{modId}/approve...');
    try {
      _addLog('Fetching incoming applications with pending modifications...');
      final appsResult = await _apiService.getIncomingRentalApplications();
      if (appsResult['success'] && (appsResult['data'] as List).isNotEmpty) {
        final app = (appsResult['data'] as List).firstWhere(
          (a) => a['status'] == 'modified-pending',
          orElse: () => null,
        );
        if (app != null) {
          final appId = app['id'].toString();
          _addLog('Found pending modification for app: $appId');
          
          final modsResult = await _apiService.getModificationHistory(appId);
          if (modsResult['success'] && (modsResult['data'] as List).isNotEmpty) {
            final mod = (modsResult['data'] as List).firstWhere(
              (m) => m['status'] == 'pending',
              orElse: () => null,
            );
            if (mod != null) {
              final modId = mod['id'].toString();
              _addLog('Found pending modification: $modId');
              
              final result = await _apiService.approveModification(appId, modId);
              _addLog('✅ Success: ${result['success']}');
              _addLog('Message: ${result['message']}');
              if (result['data'] != null) {
                _addLog('Application status: ${result['data']['application']?['status']}');
                _addLog('Booking created: ${result['data']['booking'] != null}');
              }
            }
          }
        } else {
          _addLog('❌ No application with pending modification found');
        }
      }
    } catch (e) {
      _addLog('❌ Error: $e');
    }
  }

  Future<void> _testRejectModification() async {
    _addLog('\n🔵 Testing POST /rental-applications/{id}/modifications/{modId}/reject...');
    try {
      _addLog('Fetching incoming applications with pending modifications...');
      final appsResult = await _apiService.getIncomingRentalApplications();
      if (appsResult['success'] && (appsResult['data'] as List).isNotEmpty) {
        final app = (appsResult['data'] as List).firstWhere(
          (a) => a['status'] == 'modified-pending',
          orElse: () => null,
        );
        if (app != null) {
          final appId = app['id'].toString();
          _addLog('Found pending modification for app: $appId');
          
          final modsResult = await _apiService.getModificationHistory(appId);
          if (modsResult['success'] && (modsResult['data'] as List).isNotEmpty) {
            final mod = (modsResult['data'] as List).firstWhere(
              (m) => m['status'] == 'pending',
              orElse: () => null,
            );
            if (mod != null) {
              final modId = mod['id'].toString();
              _addLog('Found pending modification: $modId');
              
              final result = await _apiService.rejectModification(
                appId,
                modId,
                rejectionReason: 'Test rejection from debug screen',
              );
              _addLog('✅ Success: ${result['success']}');
              _addLog('Message: ${result['message']}');
              if (result['data'] != null) {
                _addLog('Application status: ${result['data']['status']}');
                _addLog('Previous status restored: ${result['data']['previous_status']}');
              }
            }
          }
        } else {
          _addLog('❌ No application with pending modification found');
        }
      }
    } catch (e) {
      _addLog('❌ Error: $e');
    }
  }

  void _clearLogs() {
    setState(() {
      _debugOutput = 'Press buttons to test API endpoints\n';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Debug Rental & Bookings API')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Text(
                    'Bookings API',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _testGetMyBookings,
                    child: const Text('GET /bookings'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _testGetMyApartmentBookings,
                    child: const Text('GET /my-apartment-bookings'),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Rental Applications API',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _testGetMyRentalApplications,
                    child: const Text('GET /my-applications'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _testGetIncomingApplications,
                    child: const Text('GET /incoming'),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Rental Modification API',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _testModifyRentalApplication,
                    child: const Text('POST /modify'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _testGetModificationHistory,
                    child: const Text('GET /modifications'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _testApproveModification,
                    child: const Text('POST /approve-modification'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _testRejectModification,
                    child: const Text('POST /reject-modification'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _clearLogs,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                    child: const Text('Clear Logs'),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                child: Text(
                  _debugOutput,
                  style: const TextStyle(fontFamily: 'Courier', fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
