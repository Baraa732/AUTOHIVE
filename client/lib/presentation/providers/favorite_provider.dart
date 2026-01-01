import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_service.dart';
import '../../data/models/favorite.dart';

final favoriteProvider = StateNotifierProvider<FavoriteNotifier, FavoriteState>((ref) {
  return FavoriteNotifier();
});

enum SortOption {
  dateNewest,
  dateOldest,
  priceLowest,
  priceHighest,
  ratingHighest,
  ratingLowest,
}

class FilterOptions {
  final double? minPrice;
  final double? maxPrice;
  final int? minBedrooms;
  final int? minBathrooms;
  final String? governorate;
  final String? city;

  const FilterOptions({
    this.minPrice,
    this.maxPrice,
    this.minBedrooms,
    this.minBathrooms,
    this.governorate,
    this.city,
  });

  bool isEmpty() {
    return minPrice == null &&
        maxPrice == null &&
        minBedrooms == null &&
        minBathrooms == null &&
        governorate == null &&
        city == null;
  }
}

class FavoriteState {
  final List<Favorite> favorites;
  final bool isLoading;
  final String? error;
  final FilterOptions filters;
  final SortOption sortOption;
  final int currentPage;
  final int totalPages;

  FavoriteState({
    this.favorites = const [],
    this.isLoading = false,
    this.error,
    this.filters = const FilterOptions(),
    this.sortOption = SortOption.dateNewest,
    this.currentPage = 1,
    this.totalPages = 1,
  });

  FavoriteState copyWith({
    List<Favorite>? favorites,
    bool? isLoading,
    String? error,
    FilterOptions? filters,
    SortOption? sortOption,
    int? currentPage,
    int? totalPages,
  }) {
    return FavoriteState(
      favorites: favorites ?? this.favorites,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      filters: filters ?? this.filters,
      sortOption: sortOption ?? this.sortOption,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
    );
  }

  List<Favorite> getFilteredAndSortedFavorites() {
    List<Favorite> result = List.from(favorites);

    // Apply filters
    if (!filters.isEmpty()) {
      result = result.where((fav) {
        final apt = fav.apartment;
        
        if (filters.minPrice != null && apt.price < filters.minPrice!) {
          return false;
        }
        if (filters.maxPrice != null && apt.price > filters.maxPrice!) {
          return false;
        }
        if (filters.minBedrooms != null && apt.bedrooms < filters.minBedrooms!) {
          return false;
        }
        if (filters.minBathrooms != null && apt.bathrooms < filters.minBathrooms!) {
          return false;
        }
        if (filters.governorate != null && apt.governorate != filters.governorate) {
          return false;
        }
        if (filters.city != null && apt.city != filters.city) {
          return false;
        }
        
        return true;
      }).toList();
    }

    // Apply sorting
    switch (sortOption) {
      case SortOption.dateNewest:
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortOption.dateOldest:
        result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case SortOption.priceLowest:
        result.sort((a, b) => a.apartment.price.compareTo(b.apartment.price));
        break;
      case SortOption.priceHighest:
        result.sort((a, b) => b.apartment.price.compareTo(a.apartment.price));
        break;
      case SortOption.ratingHighest:
        result.sort((a, b) {
          final ratingA = a.apartment.rating ?? 0;
          final ratingB = b.apartment.rating ?? 0;
          return ratingB.compareTo(ratingA);
        });
        break;
      case SortOption.ratingLowest:
        result.sort((a, b) {
          final ratingA = a.apartment.rating ?? 0;
          final ratingB = b.apartment.rating ?? 0;
          return ratingA.compareTo(ratingB);
        });
        break;
    }

    return result;
  }
}

class FavoriteNotifier extends StateNotifier<FavoriteState> {
  final ApiService _apiService = ApiService();

  FavoriteNotifier() : super(FavoriteState());

  Future<void> loadFavorites() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiService.getFavorites();
      
      if (response['success'] == true) {
        final data = response['data'];
        final List<Favorite> favorites = [];
        int totalPages = 1;
        
        if (data is Map && data['data'] is List) {
          for (var item in data['data']) {
            try {
              favorites.add(Favorite.fromJson(item));
            } catch (e) {
              print('Error parsing favorite: $e');
            }
          }
          totalPages = data['last_page'] ?? 1;
        } else if (data is List) {
          for (var item in data) {
            try {
              favorites.add(Favorite.fromJson(item));
            } catch (e) {
              print('Error parsing favorite: $e');
            }
          }
        }
        
        state = state.copyWith(
          favorites: favorites,
          isLoading: false,
          totalPages: totalPages,
          currentPage: 1,
        );
      } else {
        state = state.copyWith(
          error: response['message'] ?? 'Failed to load favorites',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to load favorites',
        isLoading: false,
      );
    }
  }

  Future<bool> addToFavorites(String apartmentId) async {
    try {
      final response = await _apiService.addToFavorites(apartmentId);
      if (response['success'] == true) {
        await loadFavorites();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeFromFavorites(String favoriteId) async {
    try {
      final response = await _apiService.removeFromFavorites(favoriteId);
      if (response['success'] == true) {
        state = state.copyWith(
          favorites: state.favorites.where((f) => f.id != favoriteId).toList(),
        );
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  void setFilters(FilterOptions filters) {
    state = state.copyWith(filters: filters);
  }

  void setSorting(SortOption sortOption) {
    state = state.copyWith(sortOption: sortOption);
  }

  void resetFilters() {
    state = state.copyWith(filters: const FilterOptions());
  }

  void resetAll() {
    state = FavoriteState();
  }

  bool isFavorite(String apartmentId) {
    return state.favorites.any((f) => f.apartmentId == apartmentId);
  }

  String? getFavoriteId(String apartmentId) {
    try {
      return state.favorites.firstWhere((f) => f.apartmentId == apartmentId).id;
    } catch (e) {
      return null;
    }
  }
}
