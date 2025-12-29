import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/core.dart';

class CreateBookingScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> apartment;

  const CreateBookingScreen({super.key, required this.apartment});

  @override
  ConsumerState<CreateBookingScreen> createState() =>
      _CreateBookingScreenState();
}

class _CreateBookingScreenState extends ConsumerState<CreateBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  final _guestsController = TextEditingController(text: '1');

  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  bool _isLoading = false;

  @override
  void dispose() {
    _messageController.dispose();
    _guestsController.dispose();
    super.dispose();
  }

  Future<void> _selectCheckInDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryOrange,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _checkInDate) {
      if (mounted) {
        setState(() {
          _checkInDate = picked;
          if (_checkOutDate != null && _checkOutDate!.isBefore(_checkInDate!)) {
            _checkOutDate = null;
          }
        });
      }
    }
  }

  Future<void> _selectCheckOutDate() async {
    if (_checkInDate == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select check-in date first'),
            backgroundColor: AppTheme.primaryOrange,
          ),
        );
      }
      return;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _checkInDate!.add(const Duration(days: 1)),
      firstDate: _checkInDate!.add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryOrange,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _checkOutDate) {
      if (mounted) {
        setState(() => _checkOutDate = picked);
      }
    }
  }

  double _calculateTotalPrice() {
    if (_checkInDate == null || _checkOutDate == null) return 0.0;

    final nights = _checkOutDate!.difference(_checkInDate!).inDays;
    var pricePerNight =
        widget.apartment['price_per_night'] ?? widget.apartment['price'] ?? 0.0;

    if (pricePerNight is String) {
      pricePerNight = double.tryParse(pricePerNight) ?? 0.0;
    } else if (pricePerNight is int) {
      pricePerNight = pricePerNight.toDouble();
    }

    return (nights * (pricePerNight as double)).toDouble();
  }

  Future<void> _submitBooking() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_checkInDate == null || _checkOutDate == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select check-in and check-out dates'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      if (mounted) {
        setState(() => _isLoading = true);
      }

      try {
        final apiService = ApiService();
        final result = await apiService.createBookingRequest(
          apartmentId: widget.apartment['id'].toString(),
          checkIn: DateFormat('yyyy-MM-dd').format(_checkInDate!),
          checkOut: DateFormat('yyyy-MM-dd').format(_checkOutDate!),
          guests: int.tryParse(_guestsController.text) ?? 1,
          message: _messageController.text.isEmpty
              ? null
              : _messageController.text,
        );

        if (mounted) {
          setState(() => _isLoading = false);

          if (result['success'] == true) {
            Navigator.pop(context, true);
          } else {
            String errorMessage = result['message'] ?? 'Failed to create booking request';
            String? errorDetails = result['details'];
            
            // Combine message and details if details exist
            if (errorDetails != null && errorDetails.isNotEmpty) {
              errorMessage = '$errorMessage\n\n$errorDetails';
            }
            
            print('❌ Booking creation failed: $errorMessage');
            
            ErrorHandler.showError(
              context,
              null,
              customMessage: errorMessage,
            );
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          print('❌ Exception caught in _submitBooking: $e');
          ErrorHandler.showError(context, e);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalPrice = _calculateTotalPrice();
    final nights = _checkInDate != null && _checkOutDate != null
        ? _checkOutDate!.difference(_checkInDate!).inDays
        : 0;

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(isDark),
      appBar: AppBar(
        backgroundColor: AppTheme.getCardColor(isDark),
        elevation: 0,
        title: Text(
          'Book Apartment',
          style: TextStyle(
            color: AppTheme.getTextColor(isDark),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.getTextColor(isDark)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.getCardColor(isDark),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.getBorderColor(isDark)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.apartment['title'] ?? 'Apartment',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.getTextColor(isDark),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${widget.apartment['city'] ?? ''}, ${widget.apartment['governorate'] ?? ''}',
                        style: TextStyle(
                          color: AppTheme.getSubtextColor(isDark),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Booking Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.getTextColor(isDark),
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _selectCheckInDate,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.getCardColor(isDark),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.getBorderColor(isDark),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: AppTheme.primaryOrange,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Check-in Date',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.getSubtextColor(isDark),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _checkInDate != null
                                    ? DateFormat(
                                        'MMM dd, yyyy',
                                      ).format(_checkInDate!)
                                    : 'Select date',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppTheme.getTextColor(isDark),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: AppTheme.getSubtextColor(isDark),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: _selectCheckOutDate,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.getCardColor(isDark),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.getBorderColor(isDark),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: AppTheme.primaryOrange,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Check-out Date',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.getSubtextColor(isDark),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _checkOutDate != null
                                    ? DateFormat(
                                        'MMM dd, yyyy',
                                      ).format(_checkOutDate!)
                                    : 'Select date',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppTheme.getTextColor(isDark),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: AppTheme.getSubtextColor(isDark),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _guestsController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: AppTheme.getTextColor(isDark)),
                  decoration: InputDecoration(
                    labelText: 'Number of Guests',
                    labelStyle: TextStyle(
                      color: AppTheme.getSubtextColor(isDark),
                    ),
                    prefixIcon: Icon(
                      Icons.people,
                      color: AppTheme.primaryOrange,
                    ),
                    filled: true,
                    fillColor: AppTheme.getCardColor(isDark),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppTheme.getBorderColor(isDark),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppTheme.getBorderColor(isDark),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppTheme.primaryOrange,
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter number of guests';
                    }
                    final guests = int.tryParse(value);
                    if (guests == null || guests < 1) {
                      return 'Please enter a valid number';
                    }
                    final maxGuests = widget.apartment['max_guests'] ?? 999;
                    if (guests > maxGuests) {
                      return 'Maximum $maxGuests guests allowed';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _messageController,
                  maxLines: 4,
                  style: TextStyle(color: AppTheme.getTextColor(isDark)),
                  decoration: InputDecoration(
                    labelText: 'Message (Optional)',
                    labelStyle: TextStyle(
                      color: AppTheme.getSubtextColor(isDark),
                    ),
                    hintText: 'Add any special requests or notes...',
                    hintStyle: TextStyle(
                      color: AppTheme.getSubtextColor(isDark),
                    ),
                    alignLabelWithHint: true,
                    filled: true,
                    fillColor: AppTheme.getCardColor(isDark),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppTheme.getBorderColor(isDark),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppTheme.getBorderColor(isDark),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppTheme.primaryOrange,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (nights > 0)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryOrange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.primaryOrange.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '$nights night${nights > 1 ? 's' : ''}',
                              style: TextStyle(
                                color: AppTheme.getTextColor(isDark),
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '\$${widget.apartment['price_per_night'] ?? widget.apartment['price'] ?? 0} × $nights',
                              style: TextStyle(
                                color: AppTheme.getSubtextColor(isDark),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.getTextColor(isDark),
                              ),
                            ),
                            Text(
                              '\$${totalPrice.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryOrange,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitBooking,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryOrange,
                      disabledBackgroundColor: AppTheme.primaryOrange
                          .withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Submit Booking Request',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
