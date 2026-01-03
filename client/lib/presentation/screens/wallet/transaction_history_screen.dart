import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        elevation: 0,
        backgroundColor: const Color(0xFF1e5631),
      ),
      body: Consumer(
        builder: (context, ref, _) {
          final walletState = ref.watch(walletProvider);
          if (walletState.isLoading && walletState.transactions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (walletState.error != null && walletState.transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(walletState.error ?? 'Error loading transactions'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ref
                          .read(walletProvider.notifier)
                          .loadTransactions(page: _currentPage);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (walletState.transactions.isEmpty) {
            return const Center(child: Text('No transactions found'));
          }

          return RefreshIndicator(
            onRefresh: () => ref
                .read(walletProvider.notifier)
                .loadTransactions(page: _currentPage),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: walletState.transactions.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final transaction = walletState.transactions[index];
                return _buildTransactionTile(transaction);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildTransactionTile(WalletTransaction transaction) {
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(8),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.type.displayName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      transaction.description ?? '',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Text(
                '${isOutgoing ? '-' : '+'}\$${transaction.amountUsd.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isOutgoing ? Colors.red : Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                transaction.createdAt.toString().split('.')[0],
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
              Text(
                '${transaction.amountSpy} SPY',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
