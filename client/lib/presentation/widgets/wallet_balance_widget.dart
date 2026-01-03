import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/wallet_provider.dart';
import '../screens/wallet/wallet_screen.dart';

class WalletBalanceWidget extends ConsumerWidget {
  final bool compact;

  const WalletBalanceWidget({
    Key? key,
    this.compact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletState = ref.watch(walletProvider);
    final wallet = walletState.wallet;

    if (wallet == null) {
      return const SizedBox.shrink();
    }

    if (compact) {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const WalletScreen()),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF1e5631).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFF1e5631).withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.account_balance_wallet,
                color: Color(0xFF1e5631),
                size: 16,
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Wallet',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    '\$${wallet.balanceUsd.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1e5631),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const WalletScreen()),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1e5631), Color(0xFF2d7a3a)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Your Wallet',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white.withOpacity(0.5),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '\$${wallet.balanceUsd.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${wallet.balanceSpy} SPY',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
