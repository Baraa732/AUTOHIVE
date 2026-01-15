import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/core.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../data/models/deposit_withdrawal_request.dart';
import '../../../data/models/wallet_transaction.dart';
import '../../providers/wallet_provider.dart';
import 'transaction_history_screen.dart';
import 'deposit_request_screen.dart';

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
      final notifier = ref.read(walletProvider.notifier);
      notifier.loadWallet();
      notifier.loadTransactions();
      notifier.loadMyRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    final walletState = ref.watch(walletProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(isDark),
      appBar: AppBar(
        title: Text(
          l10n.translate('my_wallet'),
          style: AppTheme.getTitle(isDark),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: AppTheme.getTextColor(isDark)),
      ),
      body: Builder(
        builder: (context) {
          if (walletState.isLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryOrange,
              ),
            );
          }

          if (walletState.error != null && walletState.wallet == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppTheme.getSubtextColor(isDark),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      walletState.error ?? l10n.translate('error_loading_wallet'),
                      style: TextStyle(
                        color: AppTheme.getTextColor(isDark),
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        ref.read(walletProvider.notifier).loadWallet();
                      },
                      icon: const Icon(Icons.refresh),
                      label: Text(l10n.translate('retry')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
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

          final wallet = walletState.wallet;
          if (wallet == null) {
            return Center(
              child: Text(
                l10n.translate('no_wallet_found'),
                style: TextStyle(color: AppTheme.getTextColor(isDark)),
              ),
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
                        gradient: LinearGradient(
                          colors: isDark
                              ? [AppTheme.darkCard, AppTheme.darkSecondary]
                              : [AppTheme.primaryBlue, const Color(0xFF3B82F6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: (isDark ? AppTheme.primaryBlue : AppTheme.primaryOrange).withOpacity(0.3),
                            blurRadius: 24,
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
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(isDark ? 0.15 : 0.25),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  Icons.account_balance_wallet_rounded,
                                  color: Colors.white,
                                  size: 26,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                l10n.translate('total_balance'),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Text(
                            '\$${wallet.balanceUsd.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 52,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -1.5,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.monetization_on_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${wallet.balanceSpy.toString()} SPY',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
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
                          child: _ActionButton(
                            label: l10n.translate('deposit'),
                            icon: Icons.add_circle_outline_rounded,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF10B981), Color(0xFF059669)],
                            ),
                            isDark: isDark,
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const DepositRequestScreen(),
                                ),
                              );
                              if (result == true && mounted) {
                                ref.read(walletProvider.notifier).loadWallet();
                                ref.read(walletProvider.notifier).loadTransactions();
                                ref.read(walletProvider.notifier).loadMyRequests();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Transaction History Section
                    _SectionHeader(
                      icon: Icons.history_rounded,
                      title: l10n.translate('recent_transactions'),
                      isDark: isDark,
                      actionLabel: l10n.translate('view_all'),
                      onAction: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TransactionHistoryScreen(),
                          ),
                        );
                        if (mounted) {
                          ref.read(walletProvider.notifier).loadTransactions();
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Recent Transactions List
                    Builder(
                      builder: (context) {
                        if (walletState.transactions.isEmpty) {
                          return _EmptyState(
                            icon: Icons.receipt_long_outlined,
                            message: l10n.translate('no_transactions_yet'),
                            isDark: isDark,
                          );
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: walletState.transactions.take(5).length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final transaction = walletState.transactions[index];
                            final isOutgoing = transaction.type == TransactionType.rentalPayment ||
                                transaction.type == TransactionType.withdrawal;

                            return _TransactionCard(
                              transaction: transaction,
                              isOutgoing: isOutgoing,
                              isDark: isDark,
                            );
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    // My Requests Section
                    _SectionHeader(
                      icon: Icons.pending_actions_rounded,
                      title: l10n.translate('my_requests'),
                      isDark: isDark,
                      actionLabel: l10n.translate('refresh'),
                      actionIcon: Icons.refresh_rounded,
                      onAction: () {
                        ref.read(walletProvider.notifier).loadMyRequests();
                      },
                    ),
                    const SizedBox(height: 16),

                    // My Requests List
                    Builder(
                      builder: (context) {
                        if (walletState.requests.isEmpty) {
                          return _EmptyState(
                            icon: Icons.inbox_outlined,
                            message: l10n.translate('no_requests_yet'),
                            isDark: isDark,
                          );
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: walletState.requests.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final request = walletState.requests[index];
                            return _RequestCard(
                              request: request,
                              isDark: isDark,
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


// Action Button Widget
class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final LinearGradient gradient;
  final bool isDark;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.gradient,
    required this.isDark,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: gradient.colors.first.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Section Header Widget
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isDark;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.isDark,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryOrange.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: AppTheme.primaryOrange,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: AppTheme.getTextColor(isDark),
              ),
            ),
          ],
        ),
        if (actionLabel != null && onAction != null)
          TextButton.icon(
            onPressed: onAction,
            icon: Icon(
              actionIcon ?? Icons.arrow_forward_rounded,
              size: 18,
              color: AppTheme.primaryOrange,
            ),
            label: Text(
              actionLabel!,
              style: TextStyle(
                color: AppTheme.primaryOrange,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
      ],
    );
  }
}

// Empty State Widget
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final bool isDark;

  const _EmptyState({
    required this.icon,
    required this.message,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.getBorderColor(isDark),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 56,
            color: AppTheme.getSubtextColor(isDark),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: AppTheme.getSubtextColor(isDark),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// Transaction Card Widget
class _TransactionCard extends StatelessWidget {
  final WalletTransaction transaction;
  final bool isOutgoing;
  final bool isDark;

  const _TransactionCard({
    required this.transaction,
    required this.isOutgoing,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    switch (transaction.type) {
      case TransactionType.deposit:
        icon = Icons.arrow_downward_rounded;
        color = AppTheme.primaryGreen;
        break;
      case TransactionType.withdrawal:
        icon = Icons.arrow_upward_rounded;
        color = AppTheme.primaryOrange;
        break;
      case TransactionType.rentalPayment:
        icon = Icons.home_rounded;
        color = AppTheme.primaryOrange;
        break;
      case TransactionType.rentalReceived:
        icon = Icons.attach_money_rounded;
        color = AppTheme.primaryGreen;
        break;
    }

    // Hide withdrawal transactions from user view
    if (transaction.type == TransactionType.withdrawal) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.getBorderColor(isDark),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
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
                    fontSize: 15,
                    color: AppTheme.getTextColor(isDark),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  transaction.createdAt.toString().split('.')[0],
                  style: TextStyle(
                    color: AppTheme.getSubtextColor(isDark),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isOutgoing ? '-' : '+'}\\${transaction.amountUsd.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isOutgoing ? AppTheme.primaryOrange : AppTheme.primaryGreen,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${transaction.amountSpy} SPY',
                style: TextStyle(
                  color: AppTheme.getSubtextColor(isDark),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Request Card Widget
class _RequestCard extends StatelessWidget {
  final DepositWithdrawalRequest request;
  final bool isDark;

  const _RequestCard({
    required this.request,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;
    switch (request.status) {
      case RequestStatus.pending:
        statusColor = const Color(0xFFF59E0B);
        statusIcon = Icons.schedule_rounded;
        break;
      case RequestStatus.approved:
        statusColor = AppTheme.primaryGreen;
        statusIcon = Icons.check_circle_rounded;
        break;
      case RequestStatus.rejected:
        statusColor = const Color(0xFFEF4444);
        statusIcon = Icons.cancel_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.getBorderColor(isDark),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  request.type.displayName,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: AppTheme.getTextColor(isDark),
                  ),
                ),
              ),
              Text(
                '\\${request.amountUsd.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: AppTheme.primaryOrange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, size: 16, color: statusColor),
                const SizedBox(width: 6),
                Text(
                  request.status.displayName,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (request.reason != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFEF4444).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFFEF4444)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      request.reason!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
