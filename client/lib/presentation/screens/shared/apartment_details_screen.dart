import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../../widgets/common/cached_network_image.dart';
import 'create_booking_screen.dart';
import 'add_apartment_screen.dart';

class ApartmentDetailsScreen extends ConsumerStatefulWidget {
  final String apartmentId;
  const ApartmentDetailsScreen({super.key, required this.apartmentId});

  @override
  ConsumerState<ApartmentDetailsScreen> createState() =>
      _ApartmentDetailsScreenState();
}

class _ApartmentDetailsScreenState extends ConsumerState<ApartmentDetailsScreen>
    with TickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _apartment;
  Map<String, dynamic>? _currentUser;
  bool _isLoading = true;

  late AnimationController _backgroundController;
  late Animation<double> _rotationAnimation;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadDetails();
    _loadUser();
  }

  void _initAnimations() {
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_backgroundController);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _animationController.forward();
  }

  Future<void> _loadUser() async {
    try {
      final user = await _authService.getUser();
      if (mounted && user != null) {
        setState(() {
          _currentUser = user;
        });
      }
    } catch (e) {
      print('Error loading user: $e');
    }
  }

  Future<void> _loadDetails() async {
    try {
      final result = await _apiService.getApartmentDetails(widget.apartmentId);
      if (!mounted) return;

      if (result['success'] == true && result['data'] != null) {
        if (mounted) {
          setState(() {
            _apartment = result['data'];
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
          ErrorHandler.showError(
            context,
            null,
            customMessage:
                result['message'] ?? 'Failed to load apartment details',
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

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);
    return Scaffold(
      body: _isLoading
          ? Container(
              decoration: BoxDecoration(
                gradient: AppTheme.getBackgroundGradient(isDarkMode),
              ),
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFFff6f2d)),
              ),
            )
          : _apartment == null
          ? Container(
              decoration: BoxDecoration(
                gradient: AppTheme.getBackgroundGradient(isDarkMode),
              ),
              child: const Center(
                child: Text(
                  'Apartment not found',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            )
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 300,
                  pinned: true,
                  backgroundColor: AppTheme.getBackgroundColor(isDarkMode),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      children: [
                        _buildAnimatedBackground(),
                        _buildImageGallery(),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppTheme.getBackgroundGradient(isDarkMode),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ScaleTransition(
                                scale: _scaleAnimation,
                                child: Text(
                                  _apartment!['title'] ?? 'Apartment',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.getTextColor(isDarkMode),
                                  ),
                                ),
                              ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: AppTheme.primaryOrange,
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${_apartment!['city'] ?? ''}, ${_apartment!['governorate'] ?? ''}',
                                style: TextStyle(
                                  color: AppTheme.getSubtextColor(isDarkMode),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                              ScaleTransition(
                                scale: _scaleAnimation,
                                child: Text(
                                  '\$${_apartment!['price_per_night'] ?? _apartment!['price'] ?? 0}/night',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFff6f2d),
                                  ),
                                ),
                              ),
                          const SizedBox(height: 24),
                              ScaleTransition(
                                scale: _scaleAnimation,
                                child: Row(
                                  children: [
                                    _buildInfoCard(
                                      Icons.bed,
                                      '${_apartment!['bedrooms'] ?? 0} Beds',
                                    ),
                                    const SizedBox(width: 12),
                                    _buildInfoCard(
                                      Icons.bathtub,
                                      '${_apartment!['bathrooms'] ?? 0} Baths',
                                    ),
                                    const SizedBox(width: 12),
                                    _buildInfoCard(
                                      Icons.square_foot,
                                      '${_apartment!['area'] ?? 0} m²',
                                    ),
                                  ],
                                ),
                              ),
                          const SizedBox(height: 24),
                              ScaleTransition(
                                scale: _scaleAnimation,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Description',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.getTextColor(isDarkMode),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _apartment!['description'] ??
                                          'No description available',
                                      style: TextStyle(
                                        color: AppTheme.getSubtextColor(isDarkMode),
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          const SizedBox(height: 24),
                          if (_apartment!['features'] != null && (_apartment!['features'] as List).isNotEmpty)
                            ScaleTransition(
                              scale: _scaleAnimation,
                              child: _buildFeaturesSection(),
                            ),
                          if (_apartment!['features'] != null && (_apartment!['features'] as List).isNotEmpty)
                            const SizedBox(height: 24),
                          ScaleTransition(
                            scale: _scaleAnimation,
                            child: _buildLocationSection(),
                          ),
                          const SizedBox(height: 24),
                          ScaleTransition(
                            scale: _scaleAnimation,
                            child: _buildOwnerSection(),
                          ),
                          const SizedBox(height: 24),
                          ScaleTransition(
                            scale: _scaleAnimation,
                            child: _currentUser != null
                                ? _buildBookingButton()
                                : _buildLoginPrompt(),
                          ),
                          SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildImageGallery() {
    if (_apartment == null) {
      return Container(
        color: Colors.grey,
        child: const Center(
          child: Icon(Icons.image, color: Colors.white, size: 50),
        ),
      );
    }

    final images = List<String>.from(_apartment!['images'] ?? []);

    if (images.isEmpty) {
      return Container(
        color: Colors.grey,
        child: const Center(
          child: Icon(Icons.image, color: Colors.white, size: 50),
        ),
      );
    }

    return PageView.builder(
      itemCount: images.length,
      itemBuilder: (context, index) {
        final imageUrl = AppConfig.getImageUrlSync(images[index]);
        return AppCachedNetworkImage(
          imageUrl: imageUrl,
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
        );
      },
    );
  }

  Widget _buildBookingButton() {
    final isOwner = _currentUser != null && 
      _apartment != null &&
      (_currentUser!['id'].toString() == _apartment!['user_id']?.toString() || 
       _currentUser!['id'].toString() == _apartment!['user']?['id']?.toString());
    
    if (isOwner) {
      return _buildOwnerActionButton();
    }
    
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryOrange, AppTheme.primaryBlue],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryOrange.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CreateBookingScreen(apartment: _apartment!),
            ),
          );
          if (result == true && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Booking request sent successfully!'),
                backgroundColor: Color(0xFF10B981),
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          'Book Now',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildOwnerActionButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryBlue, AppTheme.primaryOrange],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddApartmentScreen(apartment: _apartment!),
            ),
          );
          if (result == true && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Apartment updated successfully!'),
                backgroundColor: Color(0xFF10B981),
              ),
            );
            await _loadDetails();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          'Edit Apartment',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginPrompt() {
    final isDarkMode = ref.watch(themeProvider);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isDarkMode
          ? LinearGradient(
              colors: [
                AppTheme.primaryOrange.withValues(alpha: 0.15),
                AppTheme.primaryBlue.withValues(alpha: 0.1),
              ],
            )
          : LinearGradient(
              colors: [
                AppTheme.primaryOrange.withValues(alpha: 0.08),
                AppTheme.primaryBlue.withValues(alpha: 0.05),
              ],
            ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.getBorderColor(isDarkMode)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryOrange.withValues(alpha: isDarkMode ? 0.2 : 0.1),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.login, color: AppTheme.primaryOrange, size: 48),
          const SizedBox(height: 8),
          Text(
            'Login Required',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.getTextColor(isDarkMode),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Please login to book this apartment',
            style: TextStyle(color: AppTheme.getSubtextColor(isDarkMode)),
            textAlign: TextAlign.center,
          ),
        ],
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
                        AppTheme.primaryOrange.withValues(alpha: isDarkMode ? 0.3 : 0.1),
                        AppTheme.primaryBlue.withValues(alpha: isDarkMode ? 0.2 : 0.05),
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
                        AppTheme.primaryBlue.withValues(alpha: isDarkMode ? 0.4 : 0.1),
                        AppTheme.primaryOrange.withValues(alpha: isDarkMode ? 0.3 : 0.08),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 50,
              bottom: 200,
              child: Transform.rotate(
                angle: _rotationAnimation.value * 0.8 * 3.14159,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryOrange.withValues(alpha: isDarkMode ? 0.5 : 0.12),
                        AppTheme.primaryBlue.withValues(alpha: isDarkMode ? 0.3 : 0.08),
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

  Widget _buildFeaturesSection() {
    final isDarkMode = ref.watch(themeProvider);
    final features = List<String>.from(_apartment!['features'] ?? []);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Features & Amenities',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.getTextColor(isDarkMode),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: features.map((feature) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryOrange.withValues(alpha: 0.1),
                  AppTheme.primaryBlue.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.primaryOrange.withValues(alpha: 0.3)),
            ),
            child: Text(
              feature,
              style: TextStyle(
                color: AppTheme.primaryOrange,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    final isDarkMode = ref.watch(themeProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.getTextColor(isDarkMode),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: isDarkMode
              ? LinearGradient(
                  colors: [
                    AppTheme.primaryBlue.withValues(alpha: 0.15),
                    AppTheme.primaryOrange.withValues(alpha: 0.1),
                  ],
                )
              : LinearGradient(
                  colors: [
                    AppTheme.primaryOrange.withValues(alpha: 0.08),
                    AppTheme.primaryBlue.withValues(alpha: 0.05),
                  ],
                ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.getBorderColor(isDarkMode)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.location_city, color: AppTheme.primaryOrange, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'City: ${_apartment!['city'] ?? 'N/A'}',
                    style: TextStyle(color: AppTheme.getTextColor(isDarkMode)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.map, color: AppTheme.primaryOrange, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Governorate: ${_apartment!['governorate'] ?? 'N/A'}',
                    style: TextStyle(color: AppTheme.getTextColor(isDarkMode)),
                  ),
                ],
              ),
              if (_apartment!['address'] != null && _apartment!['address'].toString().isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.location_on, color: AppTheme.primaryOrange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Address: ${_apartment!['address']}',
                        style: TextStyle(color: AppTheme.getTextColor(isDarkMode)),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOwnerSection() {
    final isDarkMode = ref.watch(themeProvider);
    final owner = _apartment!['user'] ?? _apartment!['owner'];
    
    if (owner == null) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Property Owner',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.getTextColor(isDarkMode),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: isDarkMode
              ? LinearGradient(
                  colors: [
                    AppTheme.primaryBlue.withValues(alpha: 0.15),
                    AppTheme.primaryOrange.withValues(alpha: 0.1),
                  ],
                )
              : LinearGradient(
                  colors: [
                    AppTheme.primaryOrange.withValues(alpha: 0.08),
                    AppTheme.primaryBlue.withValues(alpha: 0.05),
                  ],
                ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.getBorderColor(isDarkMode)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: AppTheme.primaryOrange.withValues(alpha: 0.2),
                child: Text(
                  '${owner['first_name']?[0] ?? ''}${owner['last_name']?[0] ?? ''}',
                  style: TextStyle(
                    color: AppTheme.primaryOrange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${owner['first_name'] ?? ''} ${owner['last_name'] ?? ''}',
                      style: TextStyle(
                        color: AppTheme.getTextColor(isDarkMode),
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    if (owner['phone'] != null)
                      Text(
                        owner['phone'],
                        style: TextStyle(
                          color: AppTheme.getSubtextColor(isDarkMode),
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(IconData icon, String text) {
    final isDarkMode = ref.watch(themeProvider);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isDarkMode 
            ? LinearGradient(
                colors: [
                  AppTheme.primaryBlue.withValues(alpha: 0.15),
                  AppTheme.primaryOrange.withValues(alpha: 0.1),
                ],
              )
            : LinearGradient(
                colors: [
                  AppTheme.primaryOrange.withValues(alpha: 0.08),
                  AppTheme.primaryBlue.withValues(alpha: 0.05),
                ],
              ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.getBorderColor(isDarkMode)),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryOrange.withValues(alpha: isDarkMode ? 0.2 : 0.1),
              blurRadius: 12,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primaryOrange),
            const SizedBox(height: 8),
            Text(
              text,
              style: TextStyle(
                color: AppTheme.getTextColor(isDarkMode),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }
}
