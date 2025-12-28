import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/network/api_service.dart';
import '../../../data/models/apartment.dart';

class RentalApplicationFormScreen extends StatefulWidget {
  final Apartment apartment;
  final DateTime? suggestedCheckIn;
  final DateTime? suggestedCheckOut;

  const RentalApplicationFormScreen({
    Key? key,
    required this.apartment,
    this.suggestedCheckIn,
    this.suggestedCheckOut,
  }) : super(key: key);

  @override
  State<RentalApplicationFormScreen> createState() => _RentalApplicationFormScreenState();
}

class _RentalApplicationFormScreenState extends State<RentalApplicationFormScreen> {
  late ApiService _apiService;
  late DateTime _checkIn;
  late DateTime _checkOut;
  final TextEditingController _messageController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _checkIn = widget.suggestedCheckIn ?? DateTime.now();
    _checkOut = widget.suggestedCheckOut ?? DateTime.now().add(const Duration(days: 7));
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _selectCheckInDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _checkIn,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _checkIn) {
      setState(() => _checkIn = picked);
      if (_checkOut.isBefore(_checkIn)) {
        _checkOut = _checkIn.add(const Duration(days: 1));
      }
    }
  }

  Future<void> _selectCheckOutDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _checkOut,
      firstDate: _checkIn.add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _checkOut) {
      setState(() => _checkOut = picked);
    }
  }

  Future<void> _submitApplication() async {
    if (_checkOut.isBefore(_checkIn)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Check-out date must be after check-in date')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final response = await _apiService.submitRentalApplication(
        apartmentId: widget.apartment.id,
        checkIn: _checkIn.toString().split(' ')[0],
        checkOut: _checkOut.toString().split(' ')[0],
        message: _messageController.text.isEmpty ? null : _messageController.text,
      );

      if (mounted) {
        if (response['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Application submitted successfully!')),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'] ?? 'Failed to submit application')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rental Application'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.apartment.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.apartment.address,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.attach_money, size: 16, color: Colors.green),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.apartment.pricePerNight ?? widget.apartment.price} per night',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Rental Dates',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Check-in'),
                subtitle: Text(dateFormat.format(_checkIn)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: _selectCheckInDate,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Check-out'),
                subtitle: Text(dateFormat.format(_checkOut)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: _selectCheckOutDate,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, size: 18, color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${_checkOut.difference(_checkIn).inDays} night(s)',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Optional Message',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _messageController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Tell the landlord about yourself, your needs, or ask any questions...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitApplication,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Submit Application',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
