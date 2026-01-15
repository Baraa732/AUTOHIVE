import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/favorite_provider.dart';

class FilterBottomSheet extends ConsumerStatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  ConsumerState<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet> {
  late double _minPrice;
  late double _maxPrice;
  late int? _selectedBedrooms;
  late int? _selectedBathrooms;
  late String? _selectedGovernorate;
  late String? _selectedCity;
  late SortOption _selectedSort;

  final List<String> _governorates = [
    'Damascus',
    'Aleppo',
    'Homs',
    'Hama',
    'Latakia',
    'Tartus',
    'Idlib',
    'Daraa',
    'Deir ez-Zor',
    'Raqqa',
    'Al-Hasakah',
    'Quneitra',
    'As-Suwayda',
  ];

  final Map<String, List<String>> _cities = {
    'Damascus': ['Mezzeh', 'Kafr Sousa', 'Malki', 'Bab Touma', 'Qassaa', 'Yarmouk'],
    'Aleppo': ['Aziziyeh', 'Sulaymaniyah', 'Shahba', 'New Aleppo', 'Furqan'],
    'Homs': ['Khalidiya', 'Waer', 'Inshaat', 'Zahra'],
    'Hama': ['Mahatta', 'Kazo', 'Sabuniyeh'],
    'Latakia': ['Raml al-Janoubi', 'Raml al-Shamali', 'Sleibeh', 'Ziraa'],
    'Tartus': ['Corniche', 'Mina', 'Arwad'],
    'Idlib': ['Downtown'],
    'Daraa': ['Balad', 'Mahatta'],
    'Deir ez-Zor': ['Joura', 'Qusour'],
    'Raqqa': ['Downtown'],
    'Al-Hasakah': ['Downtown'],
    'Quneitra': ['Downtown'],
    'As-Suwayda': ['Downtown'],
  };

  @override
  void initState() {
    super.initState();
    final state = ref.read(favoriteProvider);
    _minPrice = state.filters.minPrice ?? 0;
    _maxPrice = state.filters.maxPrice ?? 500;
    _selectedBedrooms = state.filters.minBedrooms;
    _selectedBathrooms = state.filters.minBathrooms;
    _selectedGovernorate = state.filters.governorate;
    _selectedCity = state.filters.city;
    _selectedSort = state.sortOption;
  }

  void _applyFilters() {
    final filters = FilterOptions(
      minPrice: _minPrice > 0 ? _minPrice : null,
      maxPrice: _maxPrice < 500 ? _maxPrice : null,
      minBedrooms: _selectedBedrooms,
      minBathrooms: _selectedBathrooms,
      governorate: _selectedGovernorate,
      city: _selectedCity,
    );

    ref.read(favoriteProvider.notifier).setFilters(filters);
    ref.read(favoriteProvider.notifier).setSorting(_selectedSort);
    Navigator.pop(context);
  }

  void _resetFilters() {
    setState(() {
      _minPrice = 0;
      _maxPrice = 500;
      _selectedBedrooms = null;
      _selectedBathrooms = null;
      _selectedGovernorate = null;
      _selectedCity = null;
      _selectedSort = SortOption.dateNewest;
    });
    ref.read(favoriteProvider.notifier).resetFilters();
    ref.read(favoriteProvider.notifier).setSorting(SortOption.dateNewest);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = AppTheme.getBackgroundColor(isDark);
    
    return SingleChildScrollView(
      child: Container(
        color: bgColor,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filters',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSortingSection(isDark),
              const SizedBox(height: 24),
              _buildPriceRangeSection(isDark),
              const SizedBox(height: 24),
              _buildBedroomsSection(isDark),
              const SizedBox(height: 24),
              _buildBathroomsSection(isDark),
              const SizedBox(height: 24),
              _buildGovernorateSection(isDark),
              if (_selectedGovernorate != null)
                ...[
                  const SizedBox(height: 24),
                  _buildCitySection(isDark),
                ],
              const SizedBox(height: 32),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSortingSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sort By',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<SortOption>(
            value: _selectedSort,
            isExpanded: true,
            underline: const SizedBox(),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            items: [
              DropdownMenuItem(
                value: SortOption.dateNewest,
                child: const Text('Newest First'),
              ),
              DropdownMenuItem(
                value: SortOption.dateOldest,
                child: const Text('Oldest First'),
              ),
              DropdownMenuItem(
                value: SortOption.priceLowest,
                child: const Text('Price: Low to High'),
              ),
              DropdownMenuItem(
                value: SortOption.priceHighest,
                child: const Text('Price: High to Low'),
              ),
              DropdownMenuItem(
                value: SortOption.ratingHighest,
                child: const Text('Highest Rated'),
              ),
              DropdownMenuItem(
                value: SortOption.ratingLowest,
                child: const Text('Lowest Rated'),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedSort = value);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRangeSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Price Range',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Text(
                '\$${_minPrice.toInt()}/night',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
            Expanded(
              child: Text(
                '\$${_maxPrice.toInt()}/night',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        RangeSlider(
          values: RangeValues(_minPrice, _maxPrice),
          min: 0,
          max: 500,
          divisions: 50,
          activeColor: const Color(0xFFff6f2d),
          inactiveColor: Colors.grey.withOpacity(0.3),
          onChanged: (RangeValues values) {
            setState(() {
              _minPrice = values.start;
              _maxPrice = values.end;
            });
          },
        ),
      ],
    );
  }

  Widget _buildBedroomsSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Minimum Bedrooms',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          children: List.generate(
            5,
            (index) => FilterChip(
              label: Text('${index + 1}'),
              selected: _selectedBedrooms == index + 1,
              onSelected: (selected) {
                setState(() {
                  _selectedBedrooms = selected ? index + 1 : null;
                });
              },
              selectedColor: const Color(0xFFff6f2d),
              labelStyle: TextStyle(
                color: _selectedBedrooms == index + 1 ? Colors.white : null,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBathroomsSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Minimum Bathrooms',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          children: List.generate(
            5,
            (index) => FilterChip(
              label: Text('${index + 1}'),
              selected: _selectedBathrooms == index + 1,
              onSelected: (selected) {
                setState(() {
                  _selectedBathrooms = selected ? index + 1 : null;
                });
              },
              selectedColor: const Color(0xFFff6f2d),
              labelStyle: TextStyle(
                color: _selectedBathrooms == index + 1 ? Colors.white : null,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGovernorateSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Governorate',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String?>(
            value: _selectedGovernorate,
            isExpanded: true,
            underline: const SizedBox(),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            hint: const Text('Select Governorate'),
            items: [
              const DropdownMenuItem(
                value: null,
                child: Text('All Governorates'),
              ),
              ..._governorates.map((gov) => DropdownMenuItem(
                    value: gov,
                    child: Text(gov),
                  )),
            ],
            onChanged: (value) {
              setState(() {
                _selectedGovernorate = value;
                _selectedCity = null;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCitySection(bool isDark) {
    final cities = _selectedGovernorate != null ? _cities[_selectedGovernorate] ?? [] : [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'City',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String?>(
            value: _selectedCity,
            isExpanded: true,
            underline: const SizedBox(),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            hint: const Text('Select City'),
            items: [
              const DropdownMenuItem(
                value: null,
                child: Text('All Cities'),
              ),
              ...cities.map((city) => DropdownMenuItem(
                    value: city,
                    child: Text(city),
                  )),
            ],
            onChanged: (value) {
              setState(() => _selectedCity = value);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _resetFilters,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: const BorderSide(color: Color(0xFFff6f2d)),
            ),
            child: const Text(
              'Reset',
              style: TextStyle(color: Color(0xFFff6f2d), fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _applyFilters,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFff6f2d),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text(
              'Apply Filters',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}
