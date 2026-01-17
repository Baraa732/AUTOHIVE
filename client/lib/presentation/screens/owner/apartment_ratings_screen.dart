import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/core.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../data/models/rating.dart';
import '../../widgets/rating_widget.dart';
import '../../../core/network/api_service.dart';

class ApartmentRatingsScreen extends ConsumerStatefulWidget {
  final String apartmentId;
  final String apartmentTitle;

  const ApartmentRatingsScreen({
    Key? key,
    required this.apartmentId,
    required this.apartmentTitle,
  }) : super(key: key);

  @override
  ConsumerState<ApartmentRatingsScreen> createState() =>
      _ApartmentRatingsScreenState();
}

class _ApartmentRatingsScreenState extends ConsumerState<ApartmentRatingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _apiService = ApiService();

  List<Rating> _reviews = [];
  Map<String, dynamic> _ratingStats = {};
  bool _isLoading = true;
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadRatings();
    _loadRatingStats();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRatings() async {
    setState(() => _isLoading = true);

    try {
      final response = await _apiService.getApartmentReviews(
        int.parse(widget.apartmentId),
      );

      if (response['success'] == true && response['data'] != null) {
        final reviewsData = response['data'];
        List<Rating> reviews = [];

        if (reviewsData['data'] != null) {
          reviews = (reviewsData['data'] as List)
              .map((json) => Rating.fromJson(json))
              .toList();
        }

        if (mounted) {
          setState(() {
            _reviews = reviews;
            _isLoading = false;
          });
        }
      } else {
        throw Exception(response['message'] ?? 'Failed to load reviews');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading reviews: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadRatingStats() async {
    setState(() => _isLoadingStats = true);

    try {
      final response = await _apiService.getApartmentRatingStats(
        int.parse(widget.apartmentId),
      );

      if (response['success'] == true && response['data'] != null) {
        if (mounted) {
          setState(() {
            _ratingStats = response['data'];
            _isLoadingStats = false;
          });
        }
      } else {
        throw Exception(
          response['message'] ?? 'Failed to load rating statistics',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingStats = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading rating stats: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(false),
      appBar: AppBar(
        title: Text(
          '${l10n.translate('ratings')} - ${widget.apartmentTitle}',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppTheme.primaryOrange,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          tabs: [
            Tab(
              icon: const Icon(Icons.reviews),
              text: l10n.translate('reviews'),
            ),
            Tab(
              icon: const Icon(Icons.bar_chart),
              text: l10n.translate('statistics'),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildReviewsTab(), _buildStatisticsTab()],
      ),
    );
  }

  Widget _buildReviewsTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFff6f2d)),
      );
    }

    if (_reviews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star_border, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No reviews yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to share your experience!',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRatings,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _reviews.length,
        itemBuilder: (context, index) {
          final review = _reviews[index];
          return _buildReviewCard(review);
        },
      ),
    );
  }

  Widget _buildStatisticsTab() {
    if (_isLoadingStats) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFff6f2d)),
      );
    }

    final averageRating = (_ratingStats['average_rating'] ?? 0.0).toDouble();
    final totalReviews = _ratingStats['total_reviews'] ?? 0;
    final ratingPercentage = (_ratingStats['rating_percentage'] ?? 0.0)
        .toDouble();
    final ratingDistribution =
        _ratingStats['rating_distribution'] as Map<String, dynamic>? ?? {};
    final categoryAverages =
        _ratingStats['category_averages'] as Map<String, dynamic>? ?? {};

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overall Rating Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 32),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Average Rating',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                averageRating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFff6f2d),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'out of 5',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Rating Percentage
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFFff6f2d).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Rating Score',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${ratingPercentage.toInt()}%',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFff6f2d),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Based on $totalReviews ${totalReviews == 1 ? 'review' : 'reviews'}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Rating Distribution
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rating Distribution',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFff6f2d),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...[5, 4, 3, 2, 1].map((rating) {
                    final count = ratingDistribution[rating.toString()] ?? 0;
                    final percentage = totalReviews > 0
                        ? (count / totalReviews) * 100
                        : 0.0;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Row(
                                children: List.generate(5, (index) {
                                  return Icon(
                                    index < rating
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.amber,
                                    size: 16,
                                  );
                                }),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '$rating stars',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '$count (${percentage.toStringAsFixed(0)}%)',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: FractionallySizedBox(
                              widthFactor: percentage / 100,
                              alignment: Alignment.centerLeft,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.amber,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),

          if (categoryAverages.isNotEmpty) ...[
            const SizedBox(height: 20),

            // Category Ratings
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Category Ratings',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFff6f2d),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildCategoryRating(
                      'Cleanliness',
                      categoryAverages['cleanliness']?.toDouble() ?? 0.0,
                    ),
                    const SizedBox(height: 12),
                    _buildCategoryRating(
                      'Location',
                      categoryAverages['location']?.toDouble() ?? 0.0,
                    ),
                    const SizedBox(height: 12),
                    _buildCategoryRating(
                      'Value',
                      categoryAverages['value']?.toDouble() ?? 0.0,
                    ),
                    const SizedBox(height: 12),
                    _buildCategoryRating(
                      'Communication',
                      categoryAverages['communication']?.toDouble() ?? 0.0,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryRating(String label, double rating) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Row(
            children: [
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < rating.round() ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 16,
                  );
                }),
              ),
              const SizedBox(width: 8),
              Text(
                rating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFff6f2d),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewCard(Rating review) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with user info and rating
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.user?['first_name'] != null
                            ? '${review.user!['first_name']} ${review.user!['last_name'] ?? ''}'
                            : 'Anonymous',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(review.createdAt),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                RatingDisplayWidget(
                  averageRating: review.rating.toDouble(),
                  size: 16,
                ),
              ],
            ),

            if (review.comment != null && review.comment!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                review.comment!,
                style: const TextStyle(fontSize: 14, height: 1.4),
              ),
            ],

            // Detailed ratings if available
            if (review.cleanlinessRating != null ||
                review.locationRating != null ||
                review.valueRating != null ||
                review.communicationRating != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              if (review.cleanlinessRating != null)
                _buildDetailedRating('Cleanliness', review.cleanlinessRating!),
              if (review.locationRating != null)
                _buildDetailedRating('Location', review.locationRating!),
              if (review.valueRating != null)
                _buildDetailedRating('Value', review.valueRating!),
              if (review.communicationRating != null)
                _buildDetailedRating(
                  'Communication',
                  review.communicationRating!,
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedRating(String label, int rating) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
          const SizedBox(width: 12),
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < rating ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 12,
              );
            }),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
