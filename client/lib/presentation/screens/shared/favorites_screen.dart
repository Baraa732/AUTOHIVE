import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/favorite_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_config.dart';
import '../../../core/localization/app_localizations.dart';
import '../../widgets/common/cached_network_image.dart';
import '../../widgets/rating_widget.dart';
import 'apartment_details_screen.dart';
import 'filter_bottom_sheet.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(favoriteProvider.notifier).loadFavorites());
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const FilterBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final favoriteState = ref.watch(favoriteProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final filteredFavorites = favoriteState.getFilteredAndSortedFavorites();
    final hasActiveFilters = !favoriteState.filters.isEmpty();

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(isDark),
      appBar: AppBar(
        title: Text(l10n.translate('favorites')),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: const Icon(Icons.tune),
                onPressed: _showFilterSheet,
              ),
              if (hasActiveFilters)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFff6f2d),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: favoriteState.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFff6f2d)),
            )
          : favoriteState.error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: isDark ? Colors.red[300] : Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      favoriteState.error!,
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        ref.read(favoriteProvider.notifier).loadFavorites(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFff6f2d),
                    ),
                    child: Text(l10n.translate('retry')),
                  ),
                ],
              ),
            )
          : favoriteState.favorites.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: isDark ? Colors.white24 : Colors.black12,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.translate('no_favorites'),
                    style: TextStyle(
                      fontSize: 18,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.translate('start_adding_favorites'),
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                  ),
                ],
              ),
            )
          : filteredFavorites.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.filter_list_off,
                    size: 80,
                    color: isDark ? Colors.white24 : Colors.black12,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.translate('no_match_filters'),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () =>
                        ref.read(favoriteProvider.notifier).resetFilters(),
                    child: Text(l10n.translate('clear_filters')),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () =>
                  ref.read(favoriteProvider.notifier).loadFavorites(),
              color: const Color(0xFFff6f2d),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (hasActiveFilters)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${filteredFavorites.length} ${l10n.translate('apartments_found')}',
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.black54,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => ref
                                .read(favoriteProvider.notifier)
                                .resetFilters(),
                            icon: const Icon(Icons.close, size: 16),
                            label: Text(l10n.translate('clear_filters')),
                          ),
                        ],
                      ),
                    ),
                  ...List.generate(filteredFavorites.length, (index) {
                    final favorite = filteredFavorites[index];
                    final apartment = favorite.apartment;

                    return _buildApartmentCard(
                      context,
                      favorite,
                      apartment,
                      isDark,
                    );
                  }),
                ],
              ),
            ),
    );
  }

  Widget _buildApartmentCard(
    BuildContext context,
    dynamic favorite,
    dynamic apartment,
    bool isDark,
  ) {
    final l10n = AppLocalizations.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: isDark ? 0 : 2,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ApartmentDetailsScreen(apartmentId: apartment.id),
          ),
        ),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: apartment.images.isNotEmpty
                      ? AppCachedNetworkImage(
                          imageUrl: AppConfig.getImageUrlSync(
                            apartment.images.first,
                          ),
                          height: 220,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: Container(
                            height: 220,
                            color: Colors.grey[300],
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFFff6f2d),
                              ),
                            ),
                          ),
                          errorWidget: Container(
                            height: 220,
                            color: Colors.grey[300],
                            child: const Icon(Icons.apartment, size: 80),
                          ),
                        )
                      : Container(
                          height: 220,
                          color: Colors.grey[300],
                          child: const Icon(Icons.apartment, size: 80),
                        ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: const Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 28,
                    ),
                    onPressed: () async {
                      final success = await ref
                          .read(favoriteProvider.notifier)
                          .removeFromFavorites(favorite.id);
                      if (success && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              l10n.translate('removed_from_favorites'),
                            ),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  ),
                ),
                if (apartment.hasRating)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: RatingPercentageWidget(
                      averageRating: apartment.averageRating!,
                      totalRatings: apartment.totalRatings ?? 0,
                      size: 12,
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    apartment.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${_translateLocation(apartment.city)}, ${_translateLocation(apartment.governorate)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildFeatureChip(Icons.bed, '${apartment.bedrooms}'),
                      const SizedBox(width: 8),
                      _buildFeatureChip(
                        Icons.bathtub,
                        '${apartment.bathrooms}',
                      ),
                      const SizedBox(width: 8),
                      _buildFeatureChip(
                        Icons.aspect_ratio,
                        '${apartment.area.toStringAsFixed(0)}m²',
                      ),
                      const Spacer(),
                      Text(
                        '\$${apartment.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFff6f2d),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '/${l10n.translate('night')}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  String _translateLocation(String location) {
    final l10n = AppLocalizations.of(context);
    final locationMap = {
      'Damascus': l10n.translate('damascus'),
      'Aleppo': l10n.translate('aleppo'),
      'Homs': l10n.translate('homs'),
      'Hama': l10n.translate('hama'),
      'Latakia': l10n.translate('latakia'),
      'Tartus': l10n.translate('tartus'),
      'Idlib': l10n.translate('idlib'),
      'Daraa': l10n.translate('daraa'),
      'Deir ez-Zor': l10n.translate('deir_ez_zor'),
      'Raqqa': l10n.translate('raqqa'),
      'Al-Hasakah': l10n.translate('al_hasakah'),
      'Quneitra': l10n.translate('quneitra'),
      'As-Suwayda': l10n.translate('as_suwayda'),
      'Jaramana': l10n.translate('jaramana'),
      'Sahnaya': l10n.translate('sahnaya'),
      'Afrin': l10n.translate('afrin'),
      'Al-Bab': l10n.translate('al_bab'),
      'Palmyra': l10n.translate('palmyra'),
      'Qusayr': l10n.translate('qusayr'),
      'Salamiyah': l10n.translate('salamiyah'),
      'Suqaylabiyah': l10n.translate('suqaylabiyah'),
      'Jableh': l10n.translate('jableh'),
      'Qardaha': l10n.translate('qardaha'),
      'Banias': l10n.translate('banias'),
      'Safita': l10n.translate('safita'),
    };
    return locationMap[location] ?? location;
  }
}
