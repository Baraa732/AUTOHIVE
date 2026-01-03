import 'package:flutter/material.dart';

class TenantRatingSummary extends StatelessWidget {
  final double? averageRating;
  final int reviewCount;

  const TenantRatingSummary({
    Key? key,
    this.averageRating,
    required this.reviewCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        children: [
          if (averageRating != null && averageRating! > 0) ...[
            Row(
              children: [
                _buildStarRating(averageRating!),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${averageRating!.toStringAsFixed(1)}/5.0',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      '$reviewCount ${reviewCount == 1 ? 'review' : 'reviews'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ] else ...[
            Row(
              children: [
                Icon(Icons.info_outline, size: 18, color: Colors.grey[600]),
                const SizedBox(width: 12),
                Text(
                  'No reviews yet',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStarRating(double rating) {
    int fullStars = rating.toInt();
    bool hasHalfStar = (rating % 1) >= 0.5;
    int emptyStars = 5 - fullStars - (hasHalfStar ? 1 : 0);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(fullStars, (_) {
          return const Icon(Icons.star, color: Colors.amber, size: 18);
        }),
        if (hasHalfStar)
          const Icon(Icons.star_half, color: Colors.amber, size: 18),
        ...List.generate(emptyStars, (_) {
          return Icon(Icons.star_outline, color: Colors.grey[400], size: 18);
        }),
      ],
    );
  }
}
