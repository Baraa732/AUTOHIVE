import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/deposit_withdrawal_request.dart';
import '../../../data/models/wallet_transaction.dart';
import '../../providers/wallet_provider.dart';
import 'transaction_history_screen.dart';
import 'deposit_request_screen.dart';
import 'withdrawal_request_screen.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(walletProvider.notifier).loadWallet();
    });
  }

  @override
  Widget build(BuildContext context) {
    final walletState = ref.watch(walletProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wallet'),
        elevation: 0,
        backgroundColor: const Color(0xFF0e1330),
      ),
      body: Builder(
        builder: (context) {
          if (walletState.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (walletState.error != null && walletState.wallet == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(walletState.error ?? 'Error loading wallet'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ref.read(walletProvider.notifier).loadWallet();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final wallet = walletState.wallet;
          if (wallet == null) {
            return const Center(
              child: Text('No wallet found'),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(walletProvider.notifier).loadWallet(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Wallet Balance Card
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0e1330), Color(0xFF17173a)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFff6f2d).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.account_balance_wallet,
                                  color: Color(0xFFff6f2d),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Total Balance',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            '\$${wallet.balanceUsd.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${wallet.balanceSpy.toString()} SPY',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF10B981), Color(0xFF059669)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF10B981).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const DepositRequestScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.add_circle_outline, size: 22),
                              label: const Text(
                                'Deposit',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFff6f2d), Color(0xFFe85d2a)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFff6f2d).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const WithdrawalRequestScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.remove_circle_outline, size: 22),
                              label: const Text(
                                'Withdraw',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Transaction History Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0e1330).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.history,
                                color: Color(0xFF0e1330),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Recent Transactions',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0e1330),
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const TransactionHistoryScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'View All',
                            style: TextStyle(
                              color: Color(0xFFff6f2d),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Recent Transactions List
                    Builder(
                      builder: (context) {
                        if (walletState.transactions.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.receipt_long_outlined,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No transactions yet',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: walletState.transactions.length,
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (context, index) {
                            final transaction = walletState.transactions[index];
                            final isOutgoing = transaction.type == TransactionType.rentalPayment ||
                                transaction.type == TransactionType.withdrawal;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[200]!),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                leading: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: isOutgoing
                                          ? [const Color(0xFFff6f2d), const Color(0xFFe85d2a)]
                                          : [const Color(0xFF10B981), const Color(0xFF059669)],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.all(10),
                                  child: Icon(
                                    isOutgoing ? Icons.arrow_upward : Icons.arrow_downward,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                title: Text(
                                  transaction.type.displayName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF0e1330),
                                  ),
                                ),
                                subtitle: Text(
                                  transaction.createdAt.toString().split('.')[0],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                trailing: Text(
                                  '${isOutgoing ? '-' : '+'}\$${transaction.amountUsd.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: isOutgoing ? const Color(0xFFff6f2d) : const Color(0xFF10B981),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    // My Requests Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0e1330).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.pending_actions,
                                color: Color(0xFF0e1330),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'My Requests',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0e1330),
                              ),
                            ),
                          ],
                        ),
                        TextButton.icon(
                          onPressed: () {
                            ref.read(walletProvider.notifier).loadMyRequests();
                          },
                          icon: const Icon(
                            Icons.refresh,
                            size: 18,
                            color: Color(0xFFff6f2d),
                          ),
                          label: const Text(
                            'Refresh',
                            style: TextStyle(
                              color: Color(0xFFff6f2d),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // My Requests List
                    Builder(
                      builder: (context) {
                        if (walletState.requests.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.inbox_outlined,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No requests yet',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: walletState.requests.length,
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (context, index) {
                            final request = walletState.requests[index];
                            Color statusColor;
                            switch (request.status) {
                              case RequestStatus.pending:
                                statusColor = Colors.orange;
                                break;
                              case RequestStatus.approved:
                                statusColor = Colors.green;
                                break;
                              case RequestStatus.rejected:
                                statusColor = Colors.red;
                                break;
                            }

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[200]!),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        request.type.displayName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          color: Color(0xFF0e1330),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '\$${request.amountUsd.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Color(0xFFff6f2d),
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: statusColor.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            request.status.displayName,
                                            style: TextStyle(
                                              color: statusColor,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (request.reason != null) ...[
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.red.withOpacity(0.05),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.red.withOpacity(0.2)),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.info_outline, size: 14, color: Colors.red),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                request.reason!,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
