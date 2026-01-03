import 'package:flutter/material.dart';

class TenantProfileCard extends StatelessWidget {
  final Map<String, dynamic>? user;
  final bool horizontal;
  final VoidCallback? onTap;
  final bool showRating;

  const TenantProfileCard({
    Key? key,
    required this.user,
    this.horizontal = true,
    this.onTap,
    this.showRating = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Text('Unknown Tenant');
    }

    final firstName = user!['first_name'] as String? ?? '';
    final lastName = user!['last_name'] as String? ?? '';
    final email = user!['email'] as String? ?? '';
    final phone = user!['phone'] as String? ?? '';
    final tenantName = '$firstName $lastName'.trim();
    final initials = _getInitials(tenantName);

    if (horizontal) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue[100],
                radius: 28,
                child: Text(
                  initials,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
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
                            tenantName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (showRating && user!['average_rating'] != null && user!['average_rating'] > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.amber[50],
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.amber[200]!),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star, size: 12, color: Colors.amber[700]),
                                const SizedBox(width: 2),
                                Text(
                                  user!['average_rating'].toString(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (email.isNotEmpty)
                      Text(
                        email,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (phone.isNotEmpty)
                      Text(
                        phone,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
              ),
              if (onTap != null) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[400],
                ),
              ]
            ],
          ),
        ),
      );
    } else {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue[100],
                radius: 40,
                child: Text(
                  initials,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                tenantName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              if (email.isNotEmpty) ...[
                Text(
                  email,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
              ],
              if (phone.isNotEmpty)
                Text(
                  phone,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      );
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return name[0].toUpperCase();
  }
}
