import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../../widgets/common/cached_network_image.dart';
import '../../widgets/common/theme_toggle_button.dart';
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
  String _selectedGovernorate = 'All';
  String _selectedPriceRange = 'All';
  final String _selectedBedrooms = 'All';


  late AnimationController _headerAnimationController;
  late AnimationController _cardAnimationController;
  late AnimationController _backgroundController;
  late Animation<double> _headerAnimation;
  late Animation<double> _rotationAnimation;

  final List<String> _governorates = ['All', 'Cairo', 'Giza', 'Alexandria', 'Luxor', 'Aswan'];
  final List<String> _priceRanges = ['All', '0-500', '500-1000', '1000-2000', '2000+'];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadData();
  }

  void _initAnimations() {  
    _headerAnimationController = AnimationController(duration: const Duration(milliseconds: 1200), vsync: this);
    _cardAnimationController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _backgroundController = AnimationController(duration: const Duration(seconds: 20), vsync: this)..repeat();

    _headerAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _headerAnimationController, curve: Curves.easeOutCubic));
    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(_backgroundController);

    _headerAnimationController.forward();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await _loadApartments();
    _cardAnimationController.forward();
  }

  Future<void> _loadApartments() async {
    try {
      final result = await _apiService.getApartments();
      if (!mounted) return;
      if (result['success'] == true) {
        final data = result['data'];
        List<Apartment> apartments = [];
        
        if (data is Map && data['data'] != null) {
          apartments = (data['data'] as List).map((json) => Apartment.fromJson(json)).toList();
        } else if (data is List) {
          apartments = data.map((json) => Apartment.fromJson(json)).toList();
        }
        
        if (mounted) {
          setState(() {
            _apartments = apartments;
            _filteredApartments = apartments;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
          ErrorHandler.showError(context, null, customMessage: result['message'] ?? 'Failed to load apartments');
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
        bool matchesSearch = _searchController.text.isEmpty ||
            apartment.title.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            apartment.city.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            apartment.governorate.toLowerCase().contains(_searchController.text.toLowerCase());

        bool matchesGovernorate = _selectedGovernorate == 'All' || apartment.governorate == _selectedGovernorate;
        bool matchesPrice = _selectedPriceRange == 'All' || _checkPriceRange(apartment.price);
        bool matchesBedrooms = _selectedBedrooms == 'All' || _checkBedrooms(apartment.bedrooms);

        return matchesSearch && matchesGovernorate && matchesPrice && matchesBedrooms;
      }).toList();
    });
  }

  bool _checkPriceRange(double price) {
    switch (_selectedPriceRange) {
      case '0-500': return price <= 500;
      case '500-1000': return price > 500 && price <= 1000;
      case '1000-2000': return price > 1000 && price <= 2000;
      case '2000+': return price > 2000;
      default: return true;
    }
  }

  bool _checkBedrooms(int bedrooms) {
    switch (_selectedBedrooms) {
      case '1': return bedrooms == 1;
      case '2': return bedrooms == 2;
      case '3': return bedrooms == 3;
      case '4+': return bedrooms >= 4;
      default: return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.getBackgroundGradient(isDarkMode),
        ),
        child: Stack(
          children: [
            _buildAnimatedBackground(),
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(child: _buildApartmentsList()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _headerAnimation,
      builder: (context, child) {
        final isDarkMode = ref.watch(themeProvider);
        return Transform.translate(
          offset: Offset(0, -30 * (1 - _headerAnimation.value)),
          child: Opacity(
            opacity: _headerAnimation.value,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.getCardColor(isDarkMode),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.getBorderColor(isDarkMode)),
                boxShadow: [BoxShadow(color: isDarkMode ? Colors.black.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.12), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFFff6f2d), Color(0xFF4a90e2)]),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('AUTOHIVE', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                      const Spacer(),
                      Consumer(
                        builder: (context, ref, child) {
                          final isDarkMode = ref.watch(themeProvider);
                          return Text(
                            '${_filteredApartments.length}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.getTextColor(isDarkMode),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      const ThemeToggleButton(),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildAdvancedSearchBar(),
                  const SizedBox(height: 12),
                  _buildQuickFilters(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAdvancedSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(ref.watch(themeProvider)),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.getBorderColor(ref.watch(themeProvider))),
      ),
      child: TextField(
        controller: _searchController,
        style: TextStyle(color: AppTheme.getTextColor(ref.watch(themeProvider)), fontSize: 16),
        decoration: InputDecoration(
          hintText: 'Search apartments...',
          hintStyle: TextStyle(color: AppTheme.getSubtextColor(ref.watch(themeProvider))),
          prefixIcon: const Icon(Icons.search, color: Color(0xFFff6f2d)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onChanged: (value) => _applyFilters(),
      ),
    );
  }

  Widget _buildQuickFilters() {
    return Row(
      children: [
        Expanded(child: _buildCompactFilter('Location', _selectedGovernorate, _governorates, (v) { setState(() => _selectedGovernorate = v!); _applyFilters(); })),
        const SizedBox(width: 8),
        Expanded(child: _buildCompactFilter('Price', _selectedPriceRange, _priceRanges, (v) { setState(() => _selectedPriceRange = v!); _applyFilters(); })),
      ],
    );
  }

  Widget _buildCompactFilter(String label, String value, List<String> options, Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(ref.watch(themeProvider)),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.getBorderColor(ref.watch(themeProvider))),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: AppTheme.getCardColor(ref.watch(themeProvider)),
          style: TextStyle(color: AppTheme.getTextColor(ref.watch(themeProvider)), fontSize: 12),
          items: options.map((option) => DropdownMenuItem(value: option, child: Text(option, style: const TextStyle(fontSize: 12)))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildApartmentsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFff6f2d)));
    }
    if (_filteredApartments.isEmpty) {
      return Center(child: Text('No apartments found', style: TextStyle(color: AppTheme.getTextColor(ref.watch(themeProvider)))));
    }
    return RefreshIndicator(
      onRefresh: _loadData,
      color: const Color(0xFFff6f2d),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(20),
        itemCount: _filteredApartments.length,
        itemBuilder: (context, index) => _buildModernApartmentCard(_filteredApartments[index], index),
      ),
    );
  }

  Widget _buildModernApartmentCard(Apartment apartment, int index) {
    final isDarkMode = ref.watch(themeProvider);
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ApartmentDetailsScreen(apartmentId: apartment.id)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(isDarkMode),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.getBorderColor(isDarkMode)),
          boxShadow: [BoxShadow(color: isDarkMode ? Colors.black.withValues(alpha: 0.15) : Colors.grey.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 4))],
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
                            color: AppTheme.getTextColor(ref.watch(themeProvider)),
                          ),
                        ),
                      ),
                      _buildStatusBadge(apartment.isAvailable),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Color(0xFFff6f2d), size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${apartment.city}, ${apartment.governorate}',
                        style: TextStyle(color: AppTheme.getSubtextColor(ref.watch(themeProvider))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.bed, size: 16, color: AppTheme.getSubtextColor(ref.watch(themeProvider))),
                      Text(' ${apartment.bedrooms}', style: TextStyle(color: AppTheme.getSubtextColor(ref.watch(themeProvider)))),
                      const SizedBox(width: 16),
                      Icon(Icons.bathtub, size: 16, color: AppTheme.getSubtextColor(ref.watch(themeProvider))),
                      Text(' ${apartment.bathrooms}', style: TextStyle(color: AppTheme.getSubtextColor(ref.watch(themeProvider)))),
                      const SizedBox(width: 16),
                      Icon(Icons.square_foot, size: 16, color: AppTheme.getSubtextColor(ref.watch(themeProvider))),
                      Text(' ${apartment.area}m²', style: TextStyle(color: AppTheme.getSubtextColor(ref.watch(themeProvider)))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        '\$${apartment.price}/night',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFff6f2d),
                        ),
                      ),
                      const Spacer(),
                      _buildOwnerProfile(apartment),
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

  Widget _buildAnimatedBackground() {
    final isDarkMode = ref.watch(themeProvider);
    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned(
              right: -50,
              top: 100,
              child: Transform.rotate(
                angle: _rotationAnimation.value * 2 * 3.14159,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFff6f2d).withValues(alpha: isDarkMode ? 0.3 : 0.1),
                        const Color(0xFF4a90e2).withValues(alpha: isDarkMode ? 0.2 : 0.05),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: -20,
              top: 300,
              child: Transform.rotate(
                angle: -_rotationAnimation.value * 1.5 * 3.14159,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF4a90e2).withValues(alpha: isDarkMode ? 0.4 : 0.1),
                        const Color(0xFFff6f2d).withValues(alpha: isDarkMode ? 0.3 : 0.08),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
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
                  child: const Center(child: CircularProgressIndicator(color: Color(0xFFff6f2d))),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isAvailable ? Colors.green : Colors.red,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isAvailable ? 'Available' : 'Booked',
        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
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
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
            if (owner['governorate'] != null) Text('Governorate: ${owner['governorate']}'),
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
    _headerAnimationController.dispose();
    _cardAnimationController.dispose();
    _backgroundController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
