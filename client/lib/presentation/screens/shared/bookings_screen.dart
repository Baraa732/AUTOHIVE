import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/core.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';

class BookingsScreen extends ConsumerStatefulWidget {
  const BookingsScreen({super.key});

  @override
  ConsumerState<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends ConsumerState<BookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final bookingNotifier = ref.read(bookingProvider.notifier);
    await bookingNotifier.loadAllBookingsData();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bookingState = ref.watch(bookingProvider);
    
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
      body: bookingState.error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error loading bookings',
                    style: TextStyle(
                      color: AppTheme.getTextColor(isDark),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    bookingState.error ?? 'Unknown error',
                    style: TextStyle(
                      color: AppTheme.getSubtextColor(isDark),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildBookingsList(bookingState.bookings, 'No bookings yet'),
                _buildBookingsList(bookingState.apartmentBookings, 'No received bookings'),
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
      onRefresh: _loadData,
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
    final userName = booking.user?['first_name'] != null
        ? '${booking.user?['first_name']} ${booking.user?['last_name'] ?? ''}'
        : 'User';
    final nights = booking.checkOut.difference(booking.checkIn).inDays;
    final pricePerNight = nights > 0 ? (booking.totalPrice / nights).toStringAsFixed(2) : '0.00';
    
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                _buildStatusBadge(booking.status),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.person,
                  size: 16,
                  color: AppTheme.getSubtextColor(isDark),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    userName,
                    style: TextStyle(
                      color: AppTheme.getSubtextColor(isDark),
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: AppTheme.getSubtextColor(isDark),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${DateFormat('MMM d, y').format(booking.checkIn)} - ${DateFormat('MMM d, y').format(booking.checkOut)} ($nights nights)',
                    style: TextStyle(
                      color: AppTheme.getSubtextColor(isDark),
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.attach_money,
                      size: 16,
                      color: AppTheme.primaryOrange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '\$${pricePerNight}/night',
                      style: TextStyle(
                        color: AppTheme.getSubtextColor(isDark),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Total: \$${booking.totalPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: AppTheme.primaryOrange,
                    fontSize: 15,
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
