import 'package:flutter/material.dart';
import '../../../core/core.dart';

class TenantProfilePreview extends StatelessWidget {
  final Map<String, dynamic>? user;
  final bool isDark;
  final EdgeInsets padding;

  const TenantProfilePreview({
    super.key,
    required this.user,
    required this.isDark,
    this.padding = const EdgeInsets.all(12),
  });

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const SizedBox.shrink();
    }

    final firstName = user?['first_name'] ?? '';
    final lastName = user?['last_name'] ?? '';
    final fullName = '$firstName $lastName'.trim();
    final city = user?['city'] ?? '';
    final governorate = user?['governorate'] ?? '';
    final profileImage = user?['profile_image_url'];
    final isApproved = user?['is_approved'] ?? false;
    final phone = user?['phone'] ?? '';

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryOrange.withValues(alpha: 0.3),
                      AppTheme.primaryOrange.withValues(alpha: 0.1),
                    ],
                  ),
                  border: Border.all(
                    color: AppTheme.primaryOrange.withValues(alpha: 0.5),
                    width: 2,
                  ),
                ),
                child: profileImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: Image.network(
                          profileImage,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Center(
                            child: Icon(
                              Icons.person,
                              size: 32,
                              color: AppTheme.primaryOrange,
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Icon(
                          Icons.person,
                          size: 32,
                          color: AppTheme.primaryOrange,
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            fullName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.getTextColor(isDark),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isApproved)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.green.withValues(alpha: 0.5),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.verified_user,
                                  size: 12,
                                  color: Colors.green,
                                ),
                                SizedBox(width: 2),
                                Text(
                                  'Verified',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (city.isNotEmpty && governorate.isNotEmpty)
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 12,
                            color: AppTheme.primaryOrange,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '$city, $governorate',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.getSubtextColor(isDark),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    if (phone.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.phone,
                              size: 12,
                              color: AppTheme.getSubtextColor(isDark),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              phone,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.getSubtextColor(isDark),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
