import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_service.dart';

class DebugBookingsScreen extends ConsumerStatefulWidget {
  const DebugBookingsScreen({super.key});

  @override
  ConsumerState<DebugBookingsScreen> createState() => _DebugBookingsScreenState();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Bookings API'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: _testGetMyBookings,
                  child: const Text('Test GET /bookings'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _testGetMyApartmentBookings,
                  child: const Text('Test GET /my-apartment-bookings'),
                ),
              ],
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
                  style: const TextStyle(
                    fontFamily: 'Courier',
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
