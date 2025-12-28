import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/core.dart';
import '../../providers/auth_provider.dart';

class BookingsScreen extends ConsumerStatefulWidget {
  const BookingsScreen({super.key});

  @override
  ConsumerState<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends ConsumerState<BookingsScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  
  List<Booking> _bookings = [];
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBookings() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final result = await _apiService.getMyBookings();
      if (!mounted) return;
      if (result['success'] == true) {
        final data = result['data'];
        List<Booking> bookings = [];
        
        if (data is Map && data['data'] != null) {
          bookings = (data['data'] as List)
              .map((json) => Booking.fromJson(json))
              .toList();
        } else if (data is List) {
          bookings = data.map((json) => Booking.fromJson(json)).toList();
        }
        
        if (mounted) {
          setState(() {
            _bookings = bookings;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
          ErrorHandler.showError(context, null,
              customMessage: result['message'] ?? 'Failed to load bookings');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ErrorHandler.showError(context, e);
      }
    }
  }

  List<Booking> get _myBookings => _bookings
      .where((b) => b.userId == ref.read(authProvider).user?.id)
      .toList();

  List<Booking> get _receivedBookings => _bookings
      .where((b) {
        final apartmentOwnerId = b.apartment?['user_id']?.toString();
        return apartmentOwnerId == ref.read(authProvider).user?.id;
      })
      .toList();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(isDark),
      appBar: AppBar(
        backgroundColor: AppTheme.getCardColor(isDark),
        elevation: 0,
        title: Text(
          'My Bookings',
          style: TextStyle(
            color: AppTheme.getTextColor(isDark),
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryOrange,
          unselectedLabelColor: AppTheme.getSubtextColor(isDark),
          indicatorColor: AppTheme.primaryOrange,
          tabs: const [
            Tab(text: 'My Requests'),
            Tab(text: 'Received'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFff6f2d)))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildBookingsList(_myBookings, 'No bookings yet'),
                _buildBookingsList(_receivedBookings, 'No received bookings'),
              ],
            ),
    );
  }

  Widget _buildBookingsList(List<Booking> bookings, String emptyMessage) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (bookings.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          style: TextStyle(
            color: AppTheme.getSubtextColor(isDark),
            fontSize: 16,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBookings,
      color: AppTheme.primaryOrange,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return _buildBookingCard(booking);
        },
      ),
    );
  }

  Widget _buildBookingCard(Booking booking) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.getBorderColor(isDark)),
        boxShadow: [
          BoxShadow(
            color: isDark 
              ? Colors.black.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    booking.apartment?['title']?.toString() ?? 'Apartment',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.getTextColor(isDark),
                    ),
                  ),
                ),
                _buildStatusBadge(booking.status),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: AppTheme.getSubtextColor(isDark),
                ),
                const SizedBox(width: 8),
                Text(
                  '${DateFormat('MMM d, y').format(booking.checkIn)} - ${DateFormat('MMM d, y').format(booking.checkOut)}',
                  style: TextStyle(
                    color: AppTheme.getSubtextColor(isDark),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.attach_money,
                  size: 16,
                  color: AppTheme.getSubtextColor(isDark),
                ),
                const SizedBox(width: 8),
                Text(
                  '\$${booking.totalPrice}',
                  style: TextStyle(
                    color: AppTheme.primaryOrange,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'approved':
      case 'confirmed':
        color = Colors.green;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'rejected':
      case 'cancelled':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
