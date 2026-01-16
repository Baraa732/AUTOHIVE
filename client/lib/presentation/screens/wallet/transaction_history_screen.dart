import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/core.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../data/models/wallet_transaction.dart';
import '../../providers/wallet_provider.dart';

class TransactionHistoryScreen extends ConsumerStatefulWidget {
  const TransactionHistoryScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState
    extends ConsumerState<TransactionHistoryScreen> {
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(walletProvider.notifier).loadTransactions(page: _currentPage);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(isDark),
      appBar: AppBar(
        title: Text(
          l10n.translate('transaction_history'),
          style: AppTheme.getTitle(isDark),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: AppTheme.getTextColor(isDark)),
      ),
      body: Consumer(
        builder: (context, ref, _) {
          final walletState = ref.watch(walletProvider);
          if (walletState.isLoading && walletState.transactions.isEmpty) {
            return Center(
              child: CircularProgressIndicator(color: AppTheme.primaryOrange),
            );
          }

          if (walletState.error != null && walletState.transactions.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 64,
                      color: AppTheme.getSubtextColor(isDark),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      walletState.error ??
                          l10n.translate('error_loading_transactions'),
                      style: TextStyle(
                        color: AppTheme.getTextColor(isDark),
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        ref
                            .read(walletProvider.notifier)
                            .loadTransactions(page: _currentPage);
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: Text(l10n.translate('retry')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (walletState.transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 64,
                    color: AppTheme.getSubtextColor(isDark),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.translate('no_transactions_found'),
                    style: TextStyle(
                      color: AppTheme.getTextColor(isDark),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref
                .read(walletProvider.notifier)
                .loadTransactions(page: _currentPage),
            color: AppTheme.primaryOrange,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: walletState.transactions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final transaction = walletState.transactions[index];
                return _buildTransactionTile(transaction, isDark);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildTransactionTile(WalletTransaction transaction, bool isDark) {
    // Hide withdrawal transactions from user view
    if (transaction.type == TransactionType.withdrawal) {
      return const SizedBox.shrink();
    }

    final isOutgoing =
        transaction.type == TransactionType.rentalPayment ||
        transaction.type == TransactionType.withdrawal;

    IconData icon;
    Color color;
    switch (transaction.type) {
      case TransactionType.deposit:
        icon = Icons.arrow_upward;
        color = Colors.green;
        break;
      case TransactionType.withdrawal:
        icon = Icons.arrow_downward;
        color = Colors.red;
        break;
      case TransactionType.rentalPayment:
        icon = Icons.home;
        color = Colors.red;
        break;
      case TransactionType.rentalReceived:
        icon = Icons.attach_money;
        color = Colors.green;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.getBorderColor(isDark), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.type.displayName,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: AppTheme.getTextColor(isDark),
                  ),
                ),
                const SizedBox(height: 6),
                if (transaction.description != null &&
                    transaction.description!.isNotEmpty)
                  Text(
                    transaction.description!,
                    style: TextStyle(
                      color: AppTheme.getSubtextColor(isDark),
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 14,
                      color: AppTheme.getSubtextColor(isDark),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      transaction.createdAt.toString().split('.')[0],
                      style: TextStyle(
                        color: AppTheme.getSubtextColor(isDark),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isOutgoing ? '-' : '+'}\$${transaction.amountUsd.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: isOutgoing
                      ? AppTheme.primaryOrange
                      : AppTheme.primaryGreen,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${transaction.amountSpy} SPY',
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
