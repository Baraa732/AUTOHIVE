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
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.getBorderColor(isDark)),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.15)
                : Colors.grey.withValues(alpha: 0.12),
            blurRadius: 12,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.translate('apartment'),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.getSubtextColor(isDark),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        booking.apartment?['title']?.toString() ??
                            l10n.translate('apartment'),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.getTextColor(isDark),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _buildStatusBadge(booking.status),
              ],
            ),
            const SizedBox(height: 14),
            TenantProfilePreview(
              user: booking.user,
              isDark: isDark,
              padding: const EdgeInsets.all(0),
            ),
            const SizedBox(height: 14),
            Divider(
              color: isDark ? Colors.grey[800] : Colors.grey[200],
              height: 1,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.translate('check_in'),
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.getSubtextColor(isDark),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('MMM d, yyyy').format(booking.checkIn),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.getTextColor(isDark),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.translate('check_out'),
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.getSubtextColor(isDark),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('MMM d, yyyy').format(booking.checkOut),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.getTextColor(isDark),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.translate('duration'),
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.getSubtextColor(isDark),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$nights ${l10n.translate('nights')}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryOrange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Add countdown timer for ongoing bookings
            if (shouldShowTimer && countdown != 'Expired') ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.timer, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.translate('time_remaining'),
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.getSubtextColor(isDark),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            countdown,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.primaryOrange.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppTheme.primaryOrange.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.translate('price_per_night'),
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.getSubtextColor(isDark),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '\$$pricePerNight',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryOrange,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 1,
                    height: 32,
                    color: AppTheme.primaryOrange.withValues(alpha: 0.2),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        l10n.translate('total_amount'),
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.getSubtextColor(isDark),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '\$${booking.totalPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryOrange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (canApproveReject) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _handleApproveBooking(booking),
                      icon: const Icon(Icons.check_circle, size: 18),
                      label: Text(l10n.translate('approve')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _handleRejectBooking(booking),
                      icon: const Icon(Icons.cancel, size: 18),
                      label: Text(l10n.translate('reject')),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ] else if (canEditDelete) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _handleEditBooking(booking),
                      icon: const Icon(Icons.edit, size: 18),
                      label: Text(l10n.translate('edit')),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryOrange,
                        side: BorderSide(color: AppTheme.primaryOrange),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _handleDeleteBooking(booking),
                      icon: const Icon(Icons.delete, size: 18),
                      label: Text(l10n.translate('delete')),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
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
