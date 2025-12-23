import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/core.dart';
import '../../../core/state/state.dart';
import '../../../data/data.dart';
import '../../widgets/common/theme_toggle_button.dart';

class LandlordBookingsScreen extends ConsumerStatefulWidget {
  const LandlordBookingsScreen({super.key});

  @override
  ConsumerState<LandlordBookingsScreen> createState() => _LandlordBookingsScreenState();
}

class _LandlordBookingsScreenState extends ConsumerState<LandlordBookingsScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _bookings = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() => _isLoading = true);
    try {
      final result = await _apiService.getLandlordBookingRequests();
      if (result['success'] == true) {
        setState(() {
          _bookings = List<Map<String, dynamic>>.from(result['data']['data'] ?? []);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredBookings {
    if (_selectedFilter == 'all') return _bookings;
    return _bookings.where((booking) => booking['status'] == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.getBackgroundGradient(isDarkMode),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(isDarkMode),
              _buildFilterTabs(isDarkMode),
              Expanded(child: _buildBookingsList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(isDark),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.getBorderColor(isDark)),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, color: Color(0xFFff6f2d)),
          const SizedBox(width: 12),
          Text(
            'Booking Management',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.getTextColor(isDark),
            ),
          ),
          const Spacer(),
          Text(
            '${_filteredBookings.length} Bookings',
            style: TextStyle(
              color: AppTheme.getSubtextColor(isDark),
            ),
          ),
          const SizedBox(width: 8),
          const ThemeToggleButton(),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(bool isDark) {
    final filters = [
      {'key': 'all', 'label': 'All'},
      {'key': 'pending', 'label': 'Pending'},
      {'key': 'approved', 'label': 'Approved'},
      {'key': 'rejected', 'label': 'Rejected'},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((filter) {
            final isSelected = _selectedFilter == filter['key'];
            return GestureDetector(
              onTap: () => setState(() => _selectedFilter = filter['key']!),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: isSelected ? const LinearGradient(
                    colors: [Color(0xFF4a90e2), Color(0xFFff6f2d)],
                  ) : null,
                  color: isSelected ? null : AppTheme.getCardColor(isDark),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.getBorderColor(isDark)),
                ),
                child: Text(
                  filter['label']!,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.getTextColor(isDark),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildBookingsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFff6f2d)));
    }

    if (_filteredBookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No bookings found',
              style: TextStyle(color: Colors.grey[400], fontSize: 18),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredBookings.length,
      itemBuilder: (context, index) => _buildBookingCard(_filteredBookings[index]),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final isDarkMode = ref.watch(themeProvider);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(isDarkMode),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.getBorderColor(isDarkMode)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  booking['apartment']?['title'] ?? 'Apartment',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.getTextColor(isDarkMode),
                  ),
                ),
              ),
              _buildStatusBadge(booking['status']),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.person, size: 16, color: AppTheme.getSubtextColor(isDarkMode)),
              const SizedBox(width: 4),
              Text(
                '${booking['user']?['first_name']} ${booking['user']?['last_name']}',
                style: TextStyle(color: AppTheme.getSubtextColor(isDarkMode)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: AppTheme.getSubtextColor(isDarkMode)),
              const SizedBox(width: 4),
              Text(
                '${booking['check_in']} - ${booking['check_out']}',
                style: TextStyle(color: AppTheme.getSubtextColor(isDarkMode)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '\$${booking['total_price']}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFff6f2d),
                ),
              ),
              const Spacer(),
              if (booking['status'] == 'pending') ...[
                ElevatedButton(
                  onPressed: () => _approveBooking(booking['id']),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text('Approve', style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _rejectBooking(booking['id']),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Reject', style: TextStyle(color: Colors.white)),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'approved':
        color = Colors.green;
        break;
      case 'rejected':
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<void> _approveBooking(String bookingId) async {
    try {
      final result = await _apiService.approveBookingRequest(bookingId);
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking approved'), backgroundColor: Colors.green),
        );
        _loadBookings();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to approve booking'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _rejectBooking(String bookingId) async {
    try {
      final result = await _apiService.rejectBookingRequest(bookingId);
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking rejected'), backgroundColor: Colors.orange),
        );
        _loadBookings();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to reject booking'), backgroundColor: Colors.red),
      );
    }
  }
}