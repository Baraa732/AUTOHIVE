import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/wallet_provider.dart';

class WithdrawalRequestScreen extends ConsumerStatefulWidget {
  const WithdrawalRequestScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<WithdrawalRequestScreen> createState() => _WithdrawalRequestScreenState();
}

class _WithdrawalRequestScreenState extends ConsumerState<WithdrawalRequestScreen> {
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(walletProvider.notifier).loadWallet();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _submitWithdrawal() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final amount = double.parse(_amountController.text);
    setState(() {
      _isSubmitting = true;
    });

    final success = await ref.read(walletProvider.notifier).submitWithdrawalRequest(amount);

    setState(() {
      _isSubmitting = false;
    });

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Withdrawal request submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        final error = ref.read(walletProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Failed to submit withdrawal request'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Withdraw Money'),
        elevation: 0,
        backgroundColor: const Color(0xFF1e5631),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Consumer(
            builder: (context, ref, _) {
              final walletState = ref.watch(walletProvider);
              final wallet = walletState.wallet;
              final balanceUsd = wallet?.balanceUsd ?? 0;

              return Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),

                    // Balance Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1e5631).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF1e5631).withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Available Balance',
                            style: TextStyle(
                              color: Color(0xFF1e5631),
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '\$${balanceUsd.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Color(0xFF1e5631),
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Amount Input
                    const Text(
                      'Withdrawal Amount (USD)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        hintText: 'Enter amount in USD',
                        prefixText: '\$ ',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF1e5631),
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an amount';
                        }
                        final amount = double.tryParse(value);
                        if (amount == null || amount <= 0) {
                          return 'Please enter a valid amount greater than 0';
                        }
                        if (amount > balanceUsd) {
                          return 'Insufficient balance (Max: \$${balanceUsd.toStringAsFixed(2)})';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 32),

                    // SPY Equivalent
                    if (_amountController.text.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Equivalent in SPY:',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            Text(
                              '${(double.parse(_amountController.text) * 110).toInt()} SPY',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1e5631),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 32),

                    // Info Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.withOpacity(0.3)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.orange),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Your withdrawal request will be reviewed by admin before processing.',
                              style: TextStyle(
                                color: Colors.orange,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Submit Button
                    Consumer(
                      builder: (context, ref, _) {
                        final walletState = ref.watch(walletProvider);
                        return SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSubmitting || walletState.isLoading
                                ? null
                                : _submitWithdrawal,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1e5631),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isSubmitting || walletState.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Submit Withdrawal Request',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // Cancel Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
