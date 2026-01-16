import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../../../core/core.dart';
import '../../../core/localization/app_localizations.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/tenant_profile_preview.dart';

class BookingsScreen extends ConsumerStatefulWidget {
  const BookingsScreen({super.key});

  @override
  ConsumerState<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends ConsumerState<BookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Timer? _timer;
  Map<String, Map<String, int>> _bookingCountdowns = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadData();
    _startTimer();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    final bookingNotifier = ref.read(bookingProvider.notifier);
    await bookingNotifier.loadAllCategorizedBookings();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateCountdowns();
    });
  }

  void _updateCountdowns() {
    final bookingState = ref.read(bookingProvider);
    final now = DateTime.now();

    final newCountdowns = <String, Map<String, int>>{};

    // Update countdowns for ongoing bookings
    for (final booking in bookingState.myOngoingBookings) {
      final remaining = booking.checkOut.difference(now);
      if (remaining.isNegative) {
        // Booking has expired, move it to expired section
        _moveBookingToExpired(booking);
      } else {
        newCountdowns[booking.id] = {
          'days': remaining.inDays,
          'hours': remaining.inHours % 24,
          'minutes': remaining.inMinutes % 60,
          'seconds': remaining.inSeconds % 60,
        };
      }
    }

    // Also update for upcoming apartment bookings
    for (final booking in bookingState.upcomingApartmentBookings) {
      final remaining = booking.checkOut.difference(now);
      if (!remaining.isNegative) {
        newCountdowns[booking.id] = {
          'days': remaining.inDays,
          'hours': remaining.inHours % 24,
          'minutes': remaining.inMinutes % 60,
          'seconds': remaining.inSeconds % 60,
        };
      }
    }

    if (mounted) {
      setState(() {
        _bookingCountdowns = newCountdowns;
      });
    }
  }

  void _moveBookingToExpired(Booking booking) {
    // Mark the booking as expired locally and trigger a refresh
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  String _formatCountdown(String bookingId) {
    final countdown = _bookingCountdowns[bookingId];
    if (countdown == null) return 'Expired';

    final days = countdown['days'] ?? 0;
    final hours = countdown['hours'] ?? 0;
    final minutes = countdown['minutes'] ?? 0;

    if (days > 0) {
      return '${days}d ${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bookingState = ref.watch(bookingProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(isDark),
      appBar: AppBar(
        backgroundColor: AppTheme.getCardColor(isDark),
        elevation: 0,
        title: Text(
          l10n.translate('my_bookings'),
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
          isScrollable: true,
          tabs: [
            Tab(text: l10n.translate('upcoming_on_apartments')),
            Tab(text: l10n.translate('my_pending')),
            Tab(text: l10n.translate('my_ongoing')),
            Tab(text: l10n.translate('my_expired')),
            Tab(text: l10n.translate('my_cancelled_rejected')),
          ],
        ),
      ),
      body: bookingState.error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.translate('error_loading_bookings'),
                    style: TextStyle(
                      color: AppTheme.getTextColor(isDark),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    bookingState.error ?? l10n.translate('unknown_error'),
                    style: TextStyle(
                      color: AppTheme.getSubtextColor(isDark),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: Text(l10n.translate('retry')),
                  ),
                ],
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildBookingsList(
                  bookingState.upcomingApartmentBookings,
                  l10n.translate('no_upcoming_bookings'),
                  isReceivedBooking: true,
                ),
                _buildBookingsList(
                  bookingState.myPendingBookings,
                  l10n.translate('no_pending_bookings'),
                  isReceivedBooking: false,
                ),
                _buildBookingsList(
                  bookingState.myOngoingBookings,
                  l10n.translate('no_ongoing_bookings'),
                  isReceivedBooking: false,
                ),
                _buildBookingsList(
                  bookingState.myCancelledRejectedBookings
                      .where(
                        (b) =>
                            b.status.toLowerCase() == 'expired' ||
                            DateTime.now().isAfter(b.checkOut),
                      )
                      .toList(),
                  l10n.translate('no_expired_bookings'),
                  isReceivedBooking: false,
                ),
                _buildBookingsList(
                  bookingState.myCancelledRejectedBookings
                      .where(
                        (b) =>
                            b.status.toLowerCase() != 'expired' &&
                            !DateTime.now().isAfter(b.checkOut),
                      )
                      .toList(),
                  l10n.translate('no_cancelled_rejected_bookings'),
                  isReceivedBooking: false,
                ),
              ],
            ),
    );
  }

  Widget _buildBookingsList(
    List<Booking> bookings,
    String emptyMessage, {
    required bool isReceivedBooking,
  }) {
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
          return _buildBookingCard(
            booking,
            isReceivedBooking: isReceivedBooking,
          );
        },
      ),
    );
  }

  Widget _buildBookingCard(Booking booking, {required bool isReceivedBooking}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final nights = booking.checkOut.difference(booking.checkIn).inDays;
    final pricePerNight = nights > 0
        ? (booking.totalPrice / nights).toStringAsFixed(2)
        : '0.00';
    final isPending = booking.status == 'pending';
    final isConfirmed = booking.status == 'confirmed';
    final isOngoing =
        booking.status == 'confirmed' || booking.status == 'ongoing';
    final canApproveReject = isReceivedBooking && isPending;
    final canEditDelete = !isReceivedBooking && (isPending || isConfirmed);
    final shouldShowTimer = isOngoing && !isReceivedBooking;
    final countdown = _formatCountdown(booking.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.getBorderColor(isDark).withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.grey.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.1)
                : Colors.grey.withValues(alpha: 0.04),
            blurRadius: 40,
            offset: const Offset(0, 16),
            spreadRadius: -10,
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark
                  ? AppTheme.getCardColor(isDark).withValues(alpha: 0.8)
                  : Colors.white.withValues(alpha: 0.9),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // Apartment Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.translate('apartment'),
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.getSubtextColor(isDark),
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            booking.apartment?['title']?.toString() ??
                                l10n.translate('apartment'),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.getTextColor(isDark),
                              height: 1.2,
                              letterSpacing: -0.5,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Status Badge
                    _buildModernStatusBadge(booking.status),
                  ],
                ),
                const SizedBox(height: 16),
                // User Info
                TenantProfilePreview(
                  user: booking.user,
                  isDark: isDark,
                  padding: const EdgeInsets.all(0),
                ),
              ],
            ),
          ),
          // Divider
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            color: isDark ? Colors.grey[800] : Colors.grey[200],
          ),
          // Date & Duration Section
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildDateCard(
                      l10n.translate('check_in'),
                      DateFormat('MMM d').format(booking.checkIn),
                      DateFormat('yyyy').format(booking.checkIn),
                      isDark,
                    ),
                    const SizedBox(width: 12),
                    _buildDateCard(
                      l10n.translate('check_out'),
                      DateFormat('MMM d').format(booking.checkOut),
                      DateFormat('yyyy').format(booking.checkOut),
                      isDark,
                    ),
                    const SizedBox(width: 12),
                    _buildDurationCard(nights, l10n, isDark),
                  ],
                ),
                const SizedBox(height: 16),
                // Countdown Timer
                if (shouldShowTimer && countdown != 'Expired')
                  _buildCountdownCard(countdown, l10n, isDark),
              ],
            ),
          ),
          // Price Section
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            decoration: BoxDecoration(
              color: AppTheme.primaryOrange.withValues(alpha: 0.04),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildPriceInfo(
                    l10n.translate('price_per_night'),
                    '\$$pricePerNight',
                    isDark,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AppTheme.primaryOrange.withValues(alpha: 0.2),
                ),
                Expanded(
                  child: _buildPriceInfo(
                    l10n.translate('total_amount'),
                    '\$${booking.totalPrice.toStringAsFixed(2)}',
                    isDark,
                    isTotal: true,
                  ),
                ),
              ],
            ),
          ),
          // Action Buttons
          if (canApproveReject || canEditDelete)
            Container(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: _buildActionButtons(
                booking,
                canApproveReject,
                canEditDelete,
                l10n,
                isDark,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildModernStatusBadge(String status) {
    Color backgroundColor;
    Color textColor;
    Color borderColor;
    IconData iconData;

    switch (status.toLowerCase()) {
      case 'approved':
      case 'confirmed':
        backgroundColor = Colors.green.withValues(alpha: 0.1);
        textColor = Colors.green;
        borderColor = Colors.green.withValues(alpha: 0.3);
        iconData = Icons.check_circle;
        break;
      case 'pending':
        backgroundColor = Colors.orange.withValues(alpha: 0.1);
        textColor = Colors.orange;
        borderColor = Colors.orange.withValues(alpha: 0.3);
        iconData = Icons.access_time;
        break;
      case 'rejected':
      case 'cancelled':
        backgroundColor = Colors.red.withValues(alpha: 0.1);
        textColor = Colors.red;
        borderColor = Colors.red.withValues(alpha: 0.3);
        iconData = Icons.cancel;
        break;
      default:
        backgroundColor = Colors.grey.withValues(alpha: 0.1);
        textColor = Colors.grey;
        borderColor = Colors.grey.withValues(alpha: 0.3);
        iconData = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, color: textColor, size: 16),
          const SizedBox(width: 6),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateCard(String label, String date, String year, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark
              ? AppTheme.getCardColor(isDark).withValues(alpha: 0.6)
              : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: AppTheme.getSubtextColor(isDark),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              date,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.getTextColor(isDark),
              ),
            ),
            Text(
              year,
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.getSubtextColor(isDark),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationCard(int nights, AppLocalizations l10n, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryOrange.withValues(alpha: 0.1),
              AppTheme.primaryOrange.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.primaryOrange.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.translate('duration'),
              style: TextStyle(
                fontSize: 10,
                color: AppTheme.getSubtextColor(isDark),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  '$nights',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryOrange,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  l10n.translate('nights'),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryOrange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountdownCard(
    String countdown,
    AppLocalizations l10n,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.red.withValues(alpha: 0.08),
            Colors.red.withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.timer_outlined, color: Colors.red, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.translate('time_remaining'),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.getSubtextColor(isDark),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  countdown,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.red,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceInfo(
    String label,
    String amount,
    bool isDark, {
    bool isTotal = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppTheme.getSubtextColor(isDark),
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: FontWeight.w800,
            color: AppTheme.primaryOrange,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    Booking booking,
    bool canApproveReject,
    bool canEditDelete,
    AppLocalizations l10n,
    bool isDark,
  ) {
    if (canApproveReject) {
      return Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green, Colors.green.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () => _handleApproveBooking(booking),
                icon: const Icon(Icons.check_circle, size: 18),
                label: Text(l10n.translate('approve')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: OutlinedButton.icon(
                onPressed: () => _handleRejectBooking(booking),
                icon: const Icon(Icons.cancel, size: 18),
                label: Text(l10n.translate('reject')),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    } else if (canEditDelete) {
      return Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryOrange.withValues(alpha: 0.3),
                ),
              ),
              child: OutlinedButton.icon(
                onPressed: () => _handleEditBooking(booking),
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: Text(l10n.translate('edit')),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryOrange,
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: OutlinedButton.icon(
                onPressed: () => _handleDeleteBooking(booking),
                icon: const Icon(Icons.delete_outline, size: 18),
                label: Text(l10n.translate('delete')),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Future<void> _handleApproveBooking(Booking booking) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppTheme.getCardColor(isDark),
            title: Text(
              l10n.translate('approve_booking'),
              style: TextStyle(color: AppTheme.getTextColor(isDark)),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.translate('are_you_sure_approve'),
                  style: TextStyle(color: AppTheme.getTextColor(isDark)),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryOrange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.primaryOrange.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${l10n.translate('apartment')}: ${booking.apartment?['title']}',
                        style: TextStyle(
                          color: AppTheme.getTextColor(isDark),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${l10n.translate('amount')}: \$${booking.totalPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: AppTheme.primaryOrange,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.translate('payment_transfer_message'),
                        style: TextStyle(
                          color: AppTheme.getSubtextColor(isDark),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  l10n.translate('cancel'),
                  style: TextStyle(color: AppTheme.getSubtextColor(isDark)),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: Text(l10n.translate('approve_process_payment')),
              ),
            ],
          ),
        ) ??
        false;

    if (confirmed && mounted) {
      final notifier = ref.read(bookingProvider.notifier);
      final success = await notifier.approveBooking(booking.id);

      if (mounted) {
        final state = ref.read(bookingProvider);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.translate('booking_approved_success')),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.error ?? l10n.translate('failed_approve_booking'),
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    }
  }

  Future<void> _handleRejectBooking(Booking booking) async {
    final l10n = AppLocalizations.of(context);
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.translate('reject_booking')),
            content: Text(
              '${l10n.translate('are_you_sure_reject')} ${booking.apartment?['title']}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.translate('cancel')),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text(l10n.translate('reject')),
              ),
            ],
          ),
        ) ??
        false;

    if (confirmed && mounted) {
      final notifier = ref.read(bookingProvider.notifier);
      final success = await notifier.rejectBooking(booking.id);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.translate('booking_rejected_success')),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.translate('failed_reject_booking')),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleEditBooking(Booking booking) async {
    final l10n = AppLocalizations.of(context);
    DateTime? selectedCheckIn = booking.checkIn;
    DateTime? selectedCheckOut = booking.checkOut;

    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => StatefulBuilder(
            builder: (context, setState) => AlertDialog(
              title: Text(l10n.translate('edit_booking_dates')),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text(l10n.translate('check_in_date')),
                    subtitle: Text(
                      DateFormat('MMM d, yyyy').format(selectedCheckIn!),
                    ),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedCheckIn!,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() => selectedCheckIn = date);
                      }
                    },
                  ),
                  ListTile(
                    title: Text(l10n.translate('check_out_date')),
                    subtitle: Text(
                      DateFormat('MMM d, yyyy').format(selectedCheckOut!),
                    ),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedCheckOut!,
                        firstDate: selectedCheckIn!.add(
                          const Duration(days: 1),
                        ),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() => selectedCheckOut = date);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(l10n.translate('cancel')),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                  ),
                  child: Text(l10n.translate('save')),
                ),
              ],
            ),
          ),
        ) ??
        false;

    if (confirmed && mounted) {
      final notifier = ref.read(bookingProvider.notifier);
      final success = await notifier.updateBooking(
        booking.id,
        checkIn: selectedCheckIn!.toIso8601String().split('T')[0],
        checkOut: selectedCheckOut!.toIso8601String().split('T')[0],
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.translate('booking_updated_success')),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.translate('failed_update_booking')),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleDeleteBooking(Booking booking) async {
    final l10n = AppLocalizations.of(context);
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.translate('delete_booking')),
            content: Text(
              '${l10n.translate('are_you_sure_delete')} ${booking.apartment?['title']}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.translate('cancel')),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text(l10n.translate('delete')),
              ),
            ],
          ),
        ) ??
        false;

    if (confirmed && mounted) {
      final notifier = ref.read(bookingProvider.notifier);
      final success = await notifier.deleteBooking(booking.id);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.translate('booking_deleted_success')),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.translate('failed_delete_booking')),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
