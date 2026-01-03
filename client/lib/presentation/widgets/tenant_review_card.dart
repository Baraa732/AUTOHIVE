import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TenantReviewCard extends StatelessWidget {
  final int rating;
  final String? comment;
  final String? apartmentTitle;
  final DateTime? createdAt;

  const TenantReviewCard({
    Key? key,
    required this.rating,
    this.comment,
    this.apartmentTitle,
    this.createdAt,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Colors.grey[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStars(rating),
                if (createdAt != null)
                  Text(
                    DateFormat('MMM dd, yyyy').format(createdAt!),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
              ],
            ),
            if (comment != null && comment!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                comment!,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (apartmentTitle != null && apartmentTitle!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.home, size: 12, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      apartmentTitle!,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStars(int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_outline,
          color: index < rating ? Colors.amber : Colors.grey[400],
          size: 16,
        );
      }),
    );
  }
}
