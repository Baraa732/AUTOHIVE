import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/rental_application.dart';
import '../../core/network/api_service.dart';

class RentalApplicationState {
  final List<RentalApplication> incomingApplications;
  final List<RentalApplication> myApplications;
  final RentalApplication? selectedApplication;
  final List<dynamic> modifications;
  final bool isLoading;
  final bool isProcessing;
  final String? error;
  final String? successMessage;

  const RentalApplicationState({
    this.incomingApplications = const [],
    this.myApplications = const [],
    this.selectedApplication,
    this.modifications = const [],
    this.isLoading = false,
    this.isProcessing = false,
    this.error,
    this.successMessage,
  });

  RentalApplicationState copyWith({
    List<RentalApplication>? incomingApplications,
    List<RentalApplication>? myApplications,
    RentalApplication? selectedApplication,
    List<dynamic>? modifications,
    bool? isLoading,
    bool? isProcessing,
    String? error,
    String? successMessage,
  }) {
    return RentalApplicationState(
      incomingApplications: incomingApplications ?? this.incomingApplications,
      myApplications: myApplications ?? this.myApplications,
      selectedApplication: selectedApplication ?? this.selectedApplication,
      modifications: modifications ?? this.modifications,
      isLoading: isLoading ?? this.isLoading,
      isProcessing: isProcessing ?? this.isProcessing,
      error: error,
      successMessage: successMessage,
    );
  }
}

class RentalApplicationNotifier extends StateNotifier<RentalApplicationState> {
  final ApiService _apiService;

  RentalApplicationNotifier(this._apiService) : super(const RentalApplicationState());

  Future<void> loadIncomingApplications() async {
    print('🔵 Loading incoming rental applications...');
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _apiService.getIncomingRentalApplications();
      print('✅ Incoming applications response: ${result['success']}');

      if (result['success'] == true) {
        final data = result['data'];
        List<RentalApplication> appsList = [];

        if (data is List) {
          appsList = (data as List)
              .map((json) {
                try {
                  return RentalApplication.fromJson(json as Map<String, dynamic>);
                } catch (e) {
                  print('⚠️ Error parsing application: $e');
                  return null;
                }
              })
              .whereType<RentalApplication>()
              .toList();
        }

        print('✅ Loaded ${appsList.length} incoming applications');
        state = state.copyWith(
          incomingApplications: appsList,
          isLoading: false,
        );
      } else {
        final errorMsg = result['message'] ?? 'Failed to load applications';
        print('❌ API error: $errorMsg');
        state = state.copyWith(
          error: errorMsg,
          isLoading: false,
        );
      }
    } catch (e, stackTrace) {
      print('❌ Exception loading incoming applications: $e');
      print('Stack: $stackTrace');
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> loadMyApplications() async {
    print('🔵 Loading my rental applications...');
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _apiService.getMyRentalApplications();
      print('✅ My applications response: ${result['success']}');

      if (result['success'] == true) {
        final data = result['data'];
        List<RentalApplication> appsList = [];

        if (data is List) {
          appsList = (data as List)
              .map((json) {
                try {
                  return RentalApplication.fromJson(json as Map<String, dynamic>);
                } catch (e) {
                  print('⚠️ Error parsing application: $e');
                  return null;
                }
              })
              .whereType<RentalApplication>()
              .toList();
        }

        print('✅ Loaded ${appsList.length} my applications');
        state = state.copyWith(
          myApplications: appsList,
          isLoading: false,
        );
      } else {
        final errorMsg = result['message'] ?? 'Failed to load applications';
        print('❌ API error: $errorMsg');
        state = state.copyWith(
          error: errorMsg,
          isLoading: false,
        );
      }
    } catch (e, stackTrace) {
      print('❌ Exception loading my applications: $e');
      print('Stack: $stackTrace');
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> loadModifications(String applicationId) async {
    print('🔵 Loading modifications for application: $applicationId');
    state = state.copyWith(isLoading: true);
    try {
      final result = await _apiService.getModificationHistory(applicationId);

      if (result['success'] == true) {
        final modifications = result['data'] as List<dynamic>? ?? [];
        print('✅ Loaded ${modifications.length} modifications');
        state = state.copyWith(
          modifications: modifications,
          isLoading: false,
        );
      } else {
        print('❌ Failed to load modifications');
        state = state.copyWith(
          modifications: [],
          isLoading: false,
        );
      }
    } catch (e, stackTrace) {
      print('❌ Exception loading modifications: $e');
      state = state.copyWith(
        modifications: [],
        isLoading: false,
      );
    }
  }

  Future<bool> approveApplication(String applicationId) async {
    print('🔵 Approving application: $applicationId');
    state = state.copyWith(isProcessing: true, error: null);
    try {
      final result = await _apiService.approveRentalApplication(applicationId);

      if (result['success'] == true) {
        print('✅ Application approved successfully');
        state = state.copyWith(
          successMessage: 'Application approved successfully',
          isProcessing: false,
        );
        await loadIncomingApplications();
        return true;
      } else {
        final errorMsg = result['message'] ?? 'Failed to approve application';
        print('❌ API error: $errorMsg');
        state = state.copyWith(
          error: errorMsg,
          isProcessing: false,
        );
        return false;
      }
    } catch (e, stackTrace) {
      print('❌ Exception approving application: $e');
      state = state.copyWith(
        error: e.toString(),
        isProcessing: false,
      );
      return false;
    }
  }

  Future<bool> rejectApplication(String applicationId, {String? reason}) async {
    print('🔵 Rejecting application: $applicationId with reason: $reason');
    state = state.copyWith(isProcessing: true, error: null);
    try {
      final result = await _apiService.rejectRentalApplication(
        applicationId,
        rejectedReason: reason,
      );

      if (result['success'] == true) {
        print('✅ Application rejected successfully');
        state = state.copyWith(
          successMessage: 'Application rejected successfully',
          isProcessing: false,
        );
        await loadIncomingApplications();
        return true;
      } else {
        final errorMsg = result['message'] ?? 'Failed to reject application';
        print('❌ API error: $errorMsg');
        state = state.copyWith(
          error: errorMsg,
          isProcessing: false,
        );
        return false;
      }
    } catch (e, stackTrace) {
      print('❌ Exception rejecting application: $e');
      state = state.copyWith(
        error: e.toString(),
        isProcessing: false,
      );
      return false;
    }
  }

  Future<bool> approveModification(String applicationId, String modificationId) async {
    print('🔵 Approving modification: $modificationId for app: $applicationId');
    state = state.copyWith(isProcessing: true, error: null);
    try {
      final result = await _apiService.approveModification(applicationId, modificationId);

      if (result['success'] == true) {
        print('✅ Modification approved successfully');
        state = state.copyWith(
          successMessage: 'Modification approved successfully',
          isProcessing: false,
        );
        await loadIncomingApplications();
        return true;
      } else {
        final errorMsg = result['message'] ?? 'Failed to approve modification';
        print('❌ API error: $errorMsg');
        state = state.copyWith(
          error: errorMsg,
          isProcessing: false,
        );
        return false;
      }
    } catch (e, stackTrace) {
      print('❌ Exception approving modification: $e');
      state = state.copyWith(
        error: e.toString(),
        isProcessing: false,
      );
      return false;
    }
  }

  Future<bool> rejectModification(String applicationId, String modificationId, {String? reason}) async {
    print('🔵 Rejecting modification: $modificationId for app: $applicationId with reason: $reason');
    state = state.copyWith(isProcessing: true, error: null);
    try {
      final result = await _apiService.rejectModification(
        applicationId,
        modificationId,
        rejectionReason: reason,
      );

      if (result['success'] == true) {
        print('✅ Modification rejected successfully');
        state = state.copyWith(
          successMessage: 'Modification rejected successfully',
          isProcessing: false,
        );
        await loadIncomingApplications();
        return true;
      } else {
        final errorMsg = result['message'] ?? 'Failed to reject modification';
        print('❌ API error: $errorMsg');
        state = state.copyWith(
          error: errorMsg,
          isProcessing: false,
        );
        return false;
      }
    } catch (e, stackTrace) {
      print('❌ Exception rejecting modification: $e');
      state = state.copyWith(
        error: e.toString(),
        isProcessing: false,
      );
      return false;
    }
  }

  void clearMessages() {
    state = state.copyWith(error: null, successMessage: null);
  }
}

final rentalApplicationProvider = StateNotifierProvider<RentalApplicationNotifier, RentalApplicationState>((ref) {
  return RentalApplicationNotifier(ApiService());
});
