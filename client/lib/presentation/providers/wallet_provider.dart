import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_service.dart';
import '../../data/models/wallet.dart';
import '../../data/models/wallet_transaction.dart';
import '../../data/models/deposit_withdrawal_request.dart';

class WalletState {
  final Wallet? wallet;
  final List<WalletTransaction> transactions;
  final List<DepositWithdrawalRequest> requests;
  final bool isLoading;
  final String? error;

  const WalletState({
    this.wallet,
    this.transactions = const [],
    this.requests = const [],
    this.isLoading = false,
    this.error,
  });

  WalletState copyWith({
    Wallet? wallet,
    List<WalletTransaction>? transactions,
    List<DepositWithdrawalRequest>? requests,
    bool? isLoading,
    String? error,
  }) {
    return WalletState(
      wallet: wallet ?? this.wallet,
      transactions: transactions ?? this.transactions,
      requests: requests ?? this.requests,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class WalletNotifier extends StateNotifier<WalletState> {
  final ApiService apiService;

  WalletNotifier(this.apiService) : super(const WalletState());

  Future<void> loadWallet() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await apiService.getWallet();
      if (response['success'] == true) {
        state = state.copyWith(
          wallet: Wallet.fromJson(response['data']),
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          error: response['message'] ?? 'Failed to load wallet',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Error loading wallet: $e',
        isLoading: false,
      );
    }
  }

  Future<void> loadTransactions({int page = 1}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await apiService.getWalletTransactions(page: page);
      if (response['success'] == true) {
        final List<dynamic> data = response['data'] as List<dynamic>;
        final transactions = data
            .map((item) => WalletTransaction.fromJson(item as Map<String, dynamic>))
            .toList();
        state = state.copyWith(
          transactions: transactions,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          error: response['message'] ?? 'Failed to load transactions',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Error loading transactions: $e',
        isLoading: false,
      );
    }
  }

  Future<bool> submitDepositRequest(double amountUsd) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await apiService.submitDepositRequest(amountUsd);
      if (response['success'] == true) {
        await loadWallet();
        await loadMyRequests();
        state = state.copyWith(isLoading: false);
        return true;
      } else {
        state = state.copyWith(
          error: response['message'] ?? 'Failed to submit deposit request',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Error submitting deposit: $e',
        isLoading: false,
      );
      return false;
    }
  }

  Future<void> loadMyRequests({int page = 1}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await apiService.getMyWalletRequests(page: page);
      if (response['success'] == true) {
        final List<dynamic> data = response['data'] as List<dynamic>;
        final requests = data
            .map((item) => DepositWithdrawalRequest.fromJson(item as Map<String, dynamic>))
            .toList();
        state = state.copyWith(
          requests: requests,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          error: response['message'] ?? 'Failed to load requests',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Error loading requests: $e',
        isLoading: false,
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final walletProvider = StateNotifierProvider<WalletNotifier, WalletState>((ref) {
  return WalletNotifier(ApiService());
});
