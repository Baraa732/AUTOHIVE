import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/wallet_provider.dart';

class BookingPaymentInfoWidget extends ConsumerWidget {
  final double rentalAmount;
  final String apartmentTitle;
  final DateTime checkIn;
  final DateTime checkOut;

  const BookingPaymentInfoWidget({
    Key? key,
    required this.rentalAmount,
    required this.apartmentTitle,
    required this.checkIn,
    required this.checkOut,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletState = ref.watch(walletProvider);
    final wallet = walletState.wallet;
    if (wallet == null) {
      return const SizedBox.shrink();
    }

    final rentalAmountSpy = (rentalAmount * 110).toInt();
    final currentBalanceSpy = wallet.balanceSpy;
    final hasEnoughBalance = currentBalanceSpy >= rentalAmountSpy;
    final remainingBalanceSpy = currentBalanceSpy - rentalAmountSpy;
    final remainingBalanceUsd = remainingBalanceSpy / 110;

    return Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: hasEnoughBalance ? Colors.green : Colors.red,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: hasEnoughBalance ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Payment Information',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: hasEnoughBalance ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Apartment Info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      apartmentTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Check-in: ${checkIn.toString().split(' ')[0]}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          'Check-out: ${checkOut.toString().split(' ')[0]}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Payment Breakdown
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _paymentRow(
                      'Rental Amount',
                      '\$${rentalAmount.toStringAsFixed(2)}',
                      '$rentalAmountSpy SPY',
                    ),
                    const Divider(height: 12),
                    _paymentRow(
                      'Current Balance',
                      '\$${wallet.balanceUsd.toStringAsFixed(2)}',
                      '${wallet.balanceSpy} SPY',
                      isBold: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Status
              if (hasEnoughBalance)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.withOpacity(0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.check_circle, color: Colors.green, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Sufficient Balance',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'After booking, your balance will be:',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${remainingBalanceUsd.toStringAsFixed(2)} ($remainingBalanceSpy SPY)',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.cancel, color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Insufficient Balance',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You need to deposit:',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${(rentalAmount - wallet.balanceUsd).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // Navigate to deposit screen
                            // Navigator.pushNamed(context, '/deposit');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text('Add Funds to Wallet'),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
  }

  Widget _paymentRow(String label, String usd, String spy, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              usd,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            Text(
              spy,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
