import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/wallet_provider.dart';

class DepositRequestScreen extends ConsumerStatefulWidget {
  const DepositRequestScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DepositRequestScreen> createState() => _DepositRequestScreenState();
}

class _DepositRequestScreenState extends ConsumerState<DepositRequestScreen> {
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _submitDeposit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final amount = double.parse(_amountController.text);
    setState(() {
      _isSubmitting = true;
    });

    final success = await ref.read(walletProvider.notifier).submitDepositRequest(amount);

    setState(() {
      _isSubmitting = false;
    });

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Deposit request submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        final error = ref.read(walletProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Failed to submit deposit request'),
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
        title: const Text('Deposit Money'),
        elevation: 0,
        backgroundColor: const Color(0xFF1e5631),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                // Info Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Enter the amount you want to deposit. Your request will be reviewed by admin.',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Amount Input
                const Text(
                  'Amount (USD)',
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
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                // SPY Equivalent
                Builder(
                  builder: (context) {
                    if (_amountController.text.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    final amount = double.tryParse(_amountController.text) ?? 0;
                    final spy = (amount * 110).toInt();
                    return Container(
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
                            '$spy SPY',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1e5631),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 48),

                // Submit Button
                Builder(
                  builder: (context) {
                    final walletState = ref.watch(walletProvider);
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting || walletState.isLoading
                            ? null
                            : _submitDeposit,
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
                                'Submit Deposit Request',
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
          ),
        ),
      ),
    );
  }
}
