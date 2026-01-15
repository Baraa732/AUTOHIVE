import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../../../core/localization/app_localizations.dart';
import '../../widgets/common/cached_network_image.dart';
import '../../widgets/common/theme_toggle_button.dart';
import '../../providers/favorite_provider.dart';
import 'apartment_details_screen.dart';

class ModernHomeScreen extends ConsumerStatefulWidget {
  const ModernHomeScreen({super.key});

  @override
  ConsumerState<ModernHomeScreen> createState() => _ModernHomeScreenState();
}

class _ModernHomeScreenState extends ConsumerState<ModernHomeScreen>
    with TickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Apartment> _apartments = [];
  List<Apartment> _filteredApartments = [];
  bool _isLoading = true;
  bool _isSearchExpanded = false;
  bool _isFilterExpanded = false;

  // Filter states
  String _selectedGovernorate = 'All';
  String _selectedPriceRange = 'All';
  String _selectedBedrooms = 'All';
  String _selectedBathrooms = 'All';
  String _selectedSortBy = 'newest';
  double _minArea = 0;
  double _maxArea = 500;
  bool _availableOnly = false;

  late AnimationController _headerController;
  late AnimationController _searchAnimationController;
  late AnimationController _filterController;
  late Animation<double> _headerAnimation;
  late Animation<double> _searchAnimation;
  late Animation<double> _filterAnimation;

  final List<String> _governorates = [
    'All',
    'Cairo',
    'Giza',
    'Alexandria',
    'Luxor',
    'Aswan',
  ];
  final List<String> _priceRanges = [
    'All',
    '0-500',
    '500-1000',
    '1000-2000',
    '2000+',
  ];
  final List<String> _bedroomOptions = ['All', '1', '2', '3', '4+'];
  final List<String> _bathroomOptions = ['All', '1', '2', '3', '4+'];
  final List<String> _sortOptions = [
    'newest',
    'oldest',
    'price_low',
    'price_high',
    'area_small',
    'area_large',
  ];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadData();
  }

  void _initAnimations() {
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _filterController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _headerAnimation = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutCubic,
    );
    _searchAnimation = CurvedAnimation(
      parent: _searchAnimationController,
      curve: Curves.easeInOut,
    );
    _filterAnimation = CurvedAnimation(
      parent: _filterController,
      curve: Curves.easeInOut,
    );

    _headerController.forward();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    if (offset > 100 && _isSearchExpanded) {
      _toggleSearch();
    }
    if (offset > 100 && _isFilterExpanded) {
      _toggleFilters();
    }
  }

  void _toggleSearch() {
    setState(() => _isSearchExpanded = !_isSearchExpanded);
    _isSearchExpanded
        ? _searchAnimationController.forward()
        : _searchAnimationController.reverse();
  }

  void _toggleFilters() {
    setState(() => _isFilterExpanded = !_isFilterExpanded);
    _isFilterExpanded
        ? _filterController.forward()
        : _filterController.reverse();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await _loadApartments();
  }

  Future<void> _loadApartments() async {
    try {
      final result = await _apiService.getApartments();
      if (!mounted) return;
      if (result['success'] == true) {
        final data = result['data'];
        List<Apartment> apartments = [];

        if (data is Map && data['data'] != null) {
          apartments = (data['data'] as List)
              .map((json) => Apartment.fromJson(json))
              .toList();
        } else if (data is List) {
          apartments = data.map((json) => Apartment.fromJson(json)).toList();
        }

        if (mounted) {
          setState(() {
            _apartments = apartments;
            _filteredApartments = apartments;
            _isLoading = false;
          });
          _applyFilters();
        }
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
          ErrorHandler.showError(
            context,
            null,
            customMessage: result['message'] ?? 'Failed to load apartments',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ErrorHandler.showError(context, e);
      }
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredApartments = _apartments.where((apartment) {
        bool matchesSearch =
            _searchController.text.isEmpty ||
            apartment.title.toLowerCase().contains(
              _searchController.text.toLowerCase(),
            ) ||
            apartment.city.toLowerCase().contains(
              _searchController.text.toLowerCase(),
            ) ||
            apartment.governorate.toLowerCase().contains(
              _searchController.text.toLowerCase(),
            );

        bool matchesGovernorate =
            _selectedGovernorate == 'All' ||
            apartment.governorate == _selectedGovernorate;
        bool matchesPrice =
            _selectedPriceRange == 'All' || _checkPriceRange(apartment.price);
        bool matchesBedrooms =
            _selectedBedrooms == 'All' || _checkBedrooms(apartment.bedrooms);
        bool matchesBathrooms =
            _selectedBathrooms == 'All' || _checkBathrooms(apartment.bathrooms);
        bool matchesArea =
            apartment.area >= _minArea && apartment.area <= _maxArea;
        bool matchesAvailability = !_availableOnly || apartment.isAvailable;

        return matchesSearch &&
            matchesGovernorate &&
            matchesPrice &&
            matchesBedrooms &&
            matchesBathrooms &&
            matchesArea &&
            matchesAvailability;
      }).toList();

      _sortApartments();
    });
  }

  void _sortApartments() {
    switch (_selectedSortBy) {
      case 'newest':
        _filteredApartments.sort((a, b) => b.id.compareTo(a.id));
        break;
      case 'oldest':
        _filteredApartments.sort((a, b) => a.id.compareTo(b.id));
        break;
      case 'price_low':
        _filteredApartments.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_high':
        _filteredApartments.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'area_small':
        _filteredApartments.sort((a, b) => a.area.compareTo(b.area));
        break;
      case 'area_large':
        _filteredApartments.sort((a, b) => b.area.compareTo(a.area));
        break;
    }
  }

  bool _checkPriceRange(double price) {
    switch (_selectedPriceRange) {
      case '0-500':
        return price <= 500;
      case '500-1000':
        return price > 500 && price <= 1000;
      case '1000-2000':
        return price > 1000 && price <= 2000;
      case '2000+':
        return price > 2000;
      default:
        return true;
    }
  }

  bool _checkBedrooms(int bedrooms) {
    switch (_selectedBedrooms) {
      case '1':
        return bedrooms == 1;
      case '2':
        return bedrooms == 2;
      case '3':
        return bedrooms == 3;
      case '4+':
        return bedrooms >= 4;
      default:
        return true;
    }
  }

  bool _checkBathrooms(int bathrooms) {
    switch (_selectedBathrooms) {
      case '1':
        return bathrooms == 1;
      case '2':
        return bathrooms == 2;
      case '3':
        return bathrooms == 3;
      case '4+':
        return bathrooms >= 4;
      default:
        return true;
    }
  }

  void _resetFilters() {
    setState(() {
      _selectedGovernorate = 'All';
      _selectedPriceRange = 'All';
      _selectedBedrooms = 'All';
      _selectedBathrooms = 'All';
      _selectedSortBy = 'newest';
      _minArea = 0;
      _maxArea = 500;
      _availableOnly = false;
      _searchController.clear();
    });
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.getBackgroundGradient(isDarkMode),
        ),
        child: RefreshIndicator(
          onRefresh: _loadData,
          color: const Color(0xFFff6f2d),
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              _buildSliverAppBar(),
              _buildSearchSliver(),
              _buildFilterSliver(),
              _buildResultsHeader(),
              _buildApartmentsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    final isDarkMode = ref.watch(themeProvider);
    return SliverAppBar(
      floating: true,
      snap: true,
      pinned: false,
      expandedHeight: 120,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: AnimatedBuilder(
          animation: _headerAnimation,
          builder: (context, child) {
            return Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.getCardColor(isDarkMode).withOpacity(0.95),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.getBorderColor(isDarkMode)),
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode
                        ? Colors.black.withOpacity(0.3)
                        : Colors.grey.withOpacity(0.15),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFff6f2d), Color(0xFF4a90e2)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      'AUTOHIVE',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Spacer(),
                  _buildActionButton(
                    Icons.search,
                    _toggleSearch,
                    _isSearchExpanded,
                  ),
                  const SizedBox(width: 8),
                  _buildActionButton(
                    Icons.tune,
                    _toggleFilters,
                    _isFilterExpanded,
                  ),
                  const SizedBox(width: 8),
                  const ThemeToggleButton(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, VoidCallback onTap, bool isActive) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFff6f2d) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? const Color(0xFFff6f2d)
                : AppTheme.getBorderColor(ref.watch(themeProvider)),
          ),
        ),
        child: Icon(
          icon,
          color: isActive
              ? Colors.white
              : AppTheme.getTextColor(ref.watch(themeProvider)),
          size: 20,
        ),
      ),
    );
  }

  Widget _buildSearchSliver() {
    return SliverToBoxAdapter(
      child: AnimatedBuilder(
        animation: _searchAnimation,
        builder: (context, child) {
          return SizeTransition(
            sizeFactor: _searchAnimation,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.getCardColor(ref.watch(themeProvider)),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.getBorderColor(ref.watch(themeProvider)),
                ),
              ),
              child: TextField(
                controller: _searchController,
                style: TextStyle(
                  color: AppTheme.getTextColor(ref.watch(themeProvider)),
                ),
                decoration: InputDecoration(
                  hintText: 'Search by title, city, or governorate...',
                  hintStyle: TextStyle(
                    color: AppTheme.getSubtextColor(ref.watch(themeProvider)),
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFFff6f2d),
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _applyFilters();
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppTheme.getBorderColor(ref.watch(themeProvider)),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFff6f2d)),
                  ),
                ),
                onChanged: (value) => _applyFilters(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterSliver() {
    return SliverToBoxAdapter(
      child: AnimatedBuilder(
        animation: _filterAnimation,
        builder: (context, child) {
          return SizeTransition(
            sizeFactor: _filterAnimation,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.getCardColor(ref.watch(themeProvider)),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.getBorderColor(ref.watch(themeProvider)),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Advanced Filters',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.getTextColor(
                            ref.watch(themeProvider),
                          ),
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: _resetFilters,
                        child: const Text(
                          'Reset',
                          style: TextStyle(color: Color(0xFFff6f2d)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildFilterGrid(),
                  const SizedBox(height: 16),
                  _buildAreaSlider(),
                  const SizedBox(height: 16),
                  _buildToggleFilters(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 3,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildDropdownFilter('Location', _selectedGovernorate, _governorates, (
          v,
        ) {
          setState(() => _selectedGovernorate = v!);
          _applyFilters();
        }),
        _buildDropdownFilter('Price Range', _selectedPriceRange, _priceRanges, (
          v,
        ) {
          setState(() => _selectedPriceRange = v!);
          _applyFilters();
        }),
        _buildDropdownFilter('Bedrooms', _selectedBedrooms, _bedroomOptions, (
          v,
        ) {
          setState(() => _selectedBedrooms = v!);
          _applyFilters();
        }),
        _buildDropdownFilter(
          'Bathrooms',
          _selectedBathrooms,
          _bathroomOptions,
          (v) {
            setState(() => _selectedBathrooms = v!);
            _applyFilters();
          },
        ),
      ],
    );
  }

  Widget _buildDropdownFilter(
    String label,
    String value,
    List<String> options,
    Function(String?) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppTheme.getBorderColor(ref.watch(themeProvider)),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Text(
            label,
            style: TextStyle(
              color: AppTheme.getSubtextColor(ref.watch(themeProvider)),
            ),
          ),
          dropdownColor: AppTheme.getCardColor(ref.watch(themeProvider)),
          style: TextStyle(
            color: AppTheme.getTextColor(ref.watch(themeProvider)),
            fontSize: 14,
          ),
          items: options
              .map(
                (option) => DropdownMenuItem(
                  value: option,
                  child: Text(option == 'All' ? label : option),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildAreaSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Area Range: ${_minArea.round()}m² - ${_maxArea.round()}m²',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: AppTheme.getTextColor(ref.watch(themeProvider)),
          ),
        ),
        RangeSlider(
          values: RangeValues(_minArea, _maxArea),
          min: 0,
          max: 500,
          divisions: 50,
          activeColor: const Color(0xFFff6f2d),
          inactiveColor: AppTheme.getBorderColor(ref.watch(themeProvider)),
          onChanged: (values) {
            setState(() {
              _minArea = values.start;
              _maxArea = values.end;
            });
            _applyFilters();
          },
        ),
      ],
    );
  }

  Widget _buildToggleFilters() {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Switch(
                value: _availableOnly,
                activeColor: const Color(0xFFff6f2d),
                onChanged: (value) {
                  setState(() => _availableOnly = value);
                  _applyFilters();
                },
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context).translate('available_only'),
                style: TextStyle(
                  color: AppTheme.getTextColor(ref.watch(themeProvider)),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _buildDropdownFilter(
            'Sort By',
            _selectedSortBy,
            _sortOptions,
            (v) {
              setState(() => _selectedSortBy = v!);
              _applyFilters();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildResultsHeader() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(
            ref.watch(themeProvider),
          ).withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(
              '${_filteredApartments.length} ${AppLocalizations.of(context).translate('apartments_found')}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextColor(ref.watch(themeProvider)),
              ),
            ),
            const Spacer(),
            if (_filteredApartments.isNotEmpty)
              Text(
                _getSortLabel(),
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.getSubtextColor(ref.watch(themeProvider)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getSortLabel() {
    switch (_selectedSortBy) {
      case 'newest':
        return 'Newest first';
      case 'oldest':
        return 'Oldest first';
      case 'price_low':
        return 'Price: Low to High';
      case 'price_high':
        return 'Price: High to Low';
      case 'area_small':
        return 'Area: Small to Large';
      case 'area_large':
        return 'Area: Large to Small';
      default:
        return '';
    }
  }

  Widget _buildApartmentsList() {
    if (_isLoading) {
      return const SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFFff6f2d)),
        ),
      );
    }
    if (_filteredApartments.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 64,
                color: AppTheme.getSubtextColor(ref.watch(themeProvider)),
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context).translate('no_apartments'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.getTextColor(ref.watch(themeProvider)),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try adjusting your filters',
                style: TextStyle(
                  color: AppTheme.getSubtextColor(ref.watch(themeProvider)),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) =>
            _buildApartmentCard(_filteredApartments[index], index),
        childCount: _filteredApartments.length,
      ),
    );
  }

  Widget _buildApartmentCard(Apartment apartment, int index) {
    final isDarkMode = ref.watch(themeProvider);
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ApartmentDetailsScreen(apartmentId: apartment.id),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(isDarkMode),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.getBorderColor(isDarkMode)),
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? Colors.black.withOpacity(0.15)
                  : Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildApartmentImage(apartment),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          apartment.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.getTextColor(isDarkMode),
                          ),
                        ),
                      ),
                      _buildStatusBadge(apartment.isAvailable),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Color(0xFFff6f2d),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${apartment.city}, ${apartment.governorate}',
                        style: TextStyle(
                          color: AppTheme.getSubtextColor(isDarkMode),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.bed,
                        size: 16,
                        color: AppTheme.getSubtextColor(isDarkMode),
                      ),
                      Text(
                        ' ${apartment.bedrooms}',
                        style: TextStyle(
                          color: AppTheme.getSubtextColor(isDarkMode),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.bathtub,
                        size: 16,
                        color: AppTheme.getSubtextColor(isDarkMode),
                      ),
                      Text(
                        ' ${apartment.bathrooms}',
                        style: TextStyle(
                          color: AppTheme.getSubtextColor(isDarkMode),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.square_foot,
                        size: 16,
                        color: AppTheme.getSubtextColor(isDarkMode),
                      ),
                      Text(
                        ' ${apartment.area}m²',
                        style: TextStyle(
                          color: AppTheme.getSubtextColor(isDarkMode),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        '\$${apartment.price}/${AppLocalizations.of(context).translate('night')}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFff6f2d),
                        ),
                      ),
                      const Spacer(),
                      _buildOwnerProfile(apartment),
                      const SizedBox(width: 8),
                      Consumer(
                        builder: (context, ref, _) {
                          final favoriteState = ref.watch(favoriteProvider);
                          final isFav = favoriteState.favorites.any((f) => f.apartmentId == apartment.id.toString());
                          return IconButton(
                            icon: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: Colors.red,
                            ),
                            onPressed: () async {
                              if (isFav) {
                                final favId = favoriteState.favorites.firstWhere((f) => f.apartmentId == apartment.id.toString()).id;
                                await ref.read(favoriteProvider.notifier).removeFromFavorites(favId);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Removed from favorites')),
                                  );
                                }
                              } else {
                                await ref.read(favoriteProvider.notifier).addToFavorites(apartment.id.toString());
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Added to favorites')),
                                  );
                                }
                              }
                            },
                          );
                        },
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

  Widget _buildApartmentImage(Apartment apartment) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: apartment.images.isNotEmpty
            ? AppCachedNetworkImage(
                imageUrl: AppConfig.getImageUrlSync(apartment.images.first),
                fit: BoxFit.cover,
                placeholder: Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: CircularProgressIndicator(color: Color(0xFFff6f2d)),
                  ),
                ),
                errorWidget: Container(
                  color: Colors.grey,
                  child: const Icon(Icons.image, color: Colors.white, size: 50),
                ),
              )
            : Container(
                color: Colors.grey,
                child: const Icon(Icons.image, color: Colors.white, size: 50),
              ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isAvailable) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isAvailable ? Colors.green : Colors.red,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isAvailable ? l10n.translate('available') : l10n.translate('booked'),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildOwnerProfile(Apartment apartment) {
    if (apartment.owner == null) return const SizedBox();

    return GestureDetector(
      onTap: () => _showOwnerInfo(apartment.owner!),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFff6f2d), width: 2),
        ),
        child: CircleAvatar(
          radius: 16,
          backgroundImage: apartment.owner!['profile_image_url'] != null
              ? NetworkImage(apartment.owner!['profile_image_url'])
              : null,
          backgroundColor: const Color(0xFFff6f2d),
          child: apartment.owner!['profile_image_url'] == null
              ? Text(
                  apartment.owner!['first_name']?[0]?.toUpperCase() ?? 'O',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
      ),
    );
  }

  void _showOwnerInfo(Map<String, dynamic> owner) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${owner['first_name']} ${owner['last_name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (owner['phone'] != null) Text('Phone: ${owner['phone']}'),
            if (owner['city'] != null) Text('City: ${owner['city']}'),
            if (owner['governorate'] != null)
              Text('Governorate: ${owner['governorate']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _headerController.dispose();
    _searchAnimationController.dispose();
    _filterController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
