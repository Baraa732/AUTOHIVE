import 'package:flutter/material.dart';
import '../../../data/models/apartment.dart';
import '../../widgets/rating_widget.dart';
import 'rating_screen.dart';
import '../../../core/core.dart';
import '../../../core/localization/app_localizations.dart';
import '../../providers/favorite_provider.dart';
import '../../widgets/common/cached_network_image.dart';
import '../../widgets/common/theme_toggle_button.dart';
import 'apartment_details_screen.dart';

class EnhancedHomeScreen extends ConsumerStatefulWidget {
  const EnhancedHomeScreen({super.key});

  @override
  ConsumerState<EnhancedHomeScreen> createState() => _EnhancedHomeScreenState();
}

class _EnhancedHomeScreenState extends ConsumerState<EnhancedHomeScreen>
    with TickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchTextController = TextEditingController();
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

  final Map<String, Map<String, String>> _governoratesTranslations = {
    'Damascus': {'en': 'Damascus', 'ar': 'دمشق'},
    'Aleppo': {'en': 'Aleppo', 'ar': 'حلب'},
    'Homs': {'en': 'Homs', 'ar': 'حمص'},
    'Hama': {'en': 'Hama', 'ar': 'حماة'},
    'Latakia': {'en': 'Latakia', 'ar': 'اللاذقية'},
    'Tartus': {'en': 'Tartus', 'ar': 'طرطوس'},
    'Idlib': {'en': 'Idlib', 'ar': 'إدلب'},
    'Daraa': {'en': 'Daraa', 'ar': 'درعا'},
    'Deir ez-Zor': {'en': 'Deir ez-Zor', 'ar': 'دير الزور'},
    'Raqqa': {'en': 'Raqqa', 'ar': 'الرقة'},
    'Al-Hasakah': {'en': 'Al-Hasakah', 'ar': 'الحسكة'},
    'Quneitra': {'en': 'Quneitra', 'ar': 'القنيطرة'},
    'As-Suwayda': {'en': 'As-Suwayda', 'ar': 'السويداء'},
  };

  String _getTranslatedGovernorate(String key) {
    final locale = Localizations.localeOf(context).languageCode;
    return _governoratesTranslations[key]?[locale] ?? key;
  }

  String _translateLocation(BuildContext context, String location) {
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

    // Try exact match first
    if (locationMap.containsKey(location)) {
      return locationMap[location]!;
    }

    // Try case-insensitive match
    final key = locationMap.keys.firstWhere(
      (k) => k.toLowerCase() == location.toLowerCase(),
      orElse: () => '',
    );

    return key.isNotEmpty ? locationMap[key]! : location;
  }

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
    _scrollController.addListener(_onScroll);
    Future.microtask(() => ref.read(favoriteProvider.notifier).loadFavorites());
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
            _searchTextController.text.isEmpty ||
            apartment.title.toLowerCase().contains(
              _searchTextController.text.toLowerCase(),
            ) ||
            apartment.city.toLowerCase().contains(
              _searchTextController.text.toLowerCase(),
            ) ||
            apartment.governorate.toLowerCase().contains(
              _searchTextController.text.toLowerCase(),
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
      _searchTextController.clear();
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
                controller: _searchTextController,
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
                  suffixIcon: _searchTextController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchTextController.clear();
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
    final l10n = AppLocalizations.of(context);
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 3,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildDropdownFilter(
          l10n.translate('location'),
          _selectedGovernorate,
          ['All', ..._governoratesTranslations.keys],
          (v) {
            setState(() => _selectedGovernorate = v!);
            _applyFilters();
          },
          translateValue: (v) =>
              v == 'All' ? l10n.translate('all') : _getTranslatedGovernorate(v),
        ),
        _buildDropdownFilter(
          l10n.translate('price_range'),
          _selectedPriceRange,
          _priceRanges,
          (v) {
            setState(() => _selectedPriceRange = v!);
            _applyFilters();
          },
        ),
        _buildDropdownFilter(
          l10n.translate('bedrooms'),
          _selectedBedrooms,
          _bedroomOptions,
          (v) {
            setState(() => _selectedBedrooms = v!);
            _applyFilters();
          },
        ),
        _buildDropdownFilter(
          l10n.translate('bathrooms'),
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
    Function(String?) onChanged, {
    String Function(String)? translateValue,
  }) {
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
                  child: Text(
                    translateValue != null
                        ? (option == 'All' ? label : translateValue(option))
                        : (option == 'All' ? label : option),
                  ),
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
                'Available Only',
                style: TextStyle(
                  color: AppTheme.getTextColor(ref.watch(themeProvider)),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _buildDropdownFilter(
            AppLocalizations.of(context).translate('sort_by'),
            _selectedSortBy,
            _sortOptions,
            (v) {
              setState(() => _selectedSortBy = v!);
              _applyFilters();
            },
            translateValue: (v) {
              final l10n = AppLocalizations.of(context);
              return l10n.translate(v);
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
              '${_filteredApartments.length} apartments found',
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
    final l10n = AppLocalizations.of(context);
    switch (_selectedSortBy) {
      case 'newest':
        return l10n.translate('newest');
      case 'oldest':
        return l10n.translate('oldest');
      case 'price_low':
        return l10n.translate('price_low');
      case 'price_high':
        return l10n.translate('price_high');
      case 'area_small':
        return l10n.translate('area_small');
      case 'area_large':
        return l10n.translate('area_large');
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
                'No apartments found',
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
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 300 + (index * 50)),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Transform.scale(
          scale: 0.95 + (0.05 * value),
          child: Opacity(
            opacity: value,
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ApartmentDetailsScreen(apartmentId: apartment.id),
                ),
              ),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: isDarkMode
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.getCardColor(isDarkMode),
                            AppTheme.getCardColor(isDarkMode).withOpacity(0.8),
                          ],
                        )
                      : null,
                  color: isDarkMode ? null : AppTheme.getCardColor(isDarkMode),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppTheme.getBorderColor(isDarkMode).withOpacity(0.5),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDarkMode
                          ? Colors.black.withOpacity(0.3)
                          : const Color(0xFFff6f2d).withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: isDarkMode
                          ? Colors.black.withOpacity(0.2)
                          : Colors.grey.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Hero(
                          tag: 'apartment_${apartment.id}',
                          child: SizedBox(
                            width: double.infinity,
                            height: 220,
                            child: _buildApartmentImage(apartment),
                          ),
                        ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Consumer(
                            builder: (context, ref, _) {
                              final favoriteState = ref.watch(favoriteProvider);
                              final isFav = favoriteState.favorites.any(
                                (f) => f.apartmentId == apartment.id.toString(),
                              );
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.95),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.15),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    isFav ? Icons.favorite : Icons.favorite_border,
                                    color: isFav ? Colors.red : Colors.grey[700],
                                    size: 22,
                                  ),
                                  onPressed: () async {
                                    if (isFav) {
                                      final favId = favoriteState.favorites
                                          .firstWhere(
                                            (f) => f.apartmentId == apartment.id.toString(),
                                          )
                                          .id;
                                      await ref
                                          .read(favoriteProvider.notifier)
                                          .removeFromFavorites(favId);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              AppLocalizations.of(context)
                                                  .translate('removed_from_favorites'),
                                            ),
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                        );
                                      }
                                    } else {
                                      await ref
                                          .read(favoriteProvider.notifier)
                                          .addToFavorites(apartment.id.toString());
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              AppLocalizations.of(context)
                                                  .translate('added_to_favorites'),
                                            ),
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                        Positioned(
                          top: 12,
                          left: 12,
                          child: _buildStatusBadge(apartment.isAvailable),
                        ),
                        if (apartment.images.length > 1)
                          Positioned(
                            bottom: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.photo_library,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${apartment.images.length}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            apartment.title,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.getTextColor(isDarkMode),
                              letterSpacing: -0.5,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFff6f2d).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.location_on,
                                  color: Color(0xFFff6f2d),
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${_translateLocation(context, apartment.city)}, ${_translateLocation(context, apartment.governorate)}',
                                  style: TextStyle(
                                    color: AppTheme.getSubtextColor(isDarkMode),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              _buildFeatureChip(
                                Icons.bed_outlined,
                                '${apartment.bedrooms}',
                                isDarkMode,
                              ),
                              const SizedBox(width: 8),
                              _buildFeatureChip(
                                Icons.bathtub_outlined,
                                '${apartment.bathrooms}',
                                isDarkMode,
                              ),
                              const SizedBox(width: 8),
                              _buildFeatureChip(
                                Icons.square_foot,
                                '${apartment.area}m²',
                                isDarkMode,
                              ),
                            ],
                          ),
                          if (apartment.hasRating) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.amber.shade400,
                                        Colors.orange.shade400,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        apartment.averageRating!.toStringAsFixed(1),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '(${apartment.totalRatings ?? 0} reviews)',
                                  style: TextStyle(
                                    color: AppTheme.getSubtextColor(isDarkMode),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFFff6f2d).withOpacity(0.1),
                                  const Color(0xFF4a90e2).withOpacity(0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFff6f2d).withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Price per night',
                                        style: TextStyle(
                                          color: AppTheme.getSubtextColor(isDarkMode),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '\$${apartment.price}',
                                        style: const TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFff6f2d),
                                          letterSpacing: -1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                _buildOwnerProfile(apartment),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeatureChip(IconData icon, String label, bool isDarkMode) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isDarkMode
              ? Colors.white.withOpacity(0.05)
              : Colors.grey.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.getBorderColor(isDarkMode).withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: const Color(0xFFff6f2d),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: AppTheme.getTextColor(isDarkMode),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApartmentImage(Apartment apartment) {
    return apartment.images.isNotEmpty
        ? SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: AppCachedNetworkImage(
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
            ),
          )
        : Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.grey,
            child: const Icon(Icons.image, color: Colors.white, size: 50),
          );
  }

  Widget _buildStatusBadge(bool isAvailable) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isAvailable
              ? [Colors.green.shade400, Colors.green.shade600]
              : [Colors.red.shade400, Colors.red.shade600],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isAvailable ? Colors.green : Colors.red).withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAvailable ? Icons.check_circle : Icons.event_busy,
            color: Colors.white,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            isAvailable ? l10n.translate('available') : l10n.translate('booked'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOwnerProfile(Apartment apartment) {
    if (apartment.owner == null) return const SizedBox();

    return GestureDetector(
      onTap: () => _showOwnerInfo(apartment.owner!),
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFFff6f2d), Color(0xFF4a90e2)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFff6f2d).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          padding: const EdgeInsets.all(2),
          child: CircleAvatar(
            radius: 20,
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
                      fontSize: 16,
                    ),
                  )
                : null,
          ),
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
    _searchTextController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
