import 'package:flutter/material.dart';

class ApplicationStatusBadge extends StatelessWidget {
  final String status;
  final DateTime? timestamp;
  final bool showTimestamp;

  const ApplicationStatusBadge({
    Key? key,
    required this.status,
    this.timestamp,
    this.showTimestamp = true,
  }) : super(key: key);

  Color _getStatusColor() {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.yellow[700]!;
      case 'approved':
        return Colors.green[700]!;
      case 'rejected':
        return Colors.red[700]!;
      case 'modified-pending':
        return Colors.orange[700]!;
      case 'modified-approved':
        return Colors.teal[700]!;
      default:
        return Colors.grey[700]!;
    }
  }

  Color _getStatusBackgroundColor() {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.yellow[100]!;
      case 'approved':
        return Colors.green[100]!;
      case 'rejected':
        return Colors.red[100]!;
      case 'modified-pending':
        return Colors.orange[100]!;
      case 'modified-approved':
        return Colors.teal[100]!;
      default:
        return Colors.grey[100]!;
    }
  }

  IconData _getStatusIcon() {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule;
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'modified-pending':
        return Icons.edit;
      case 'modified-approved':
        return Icons.verified;
      default:
        return Icons.help;
    }
  }

  String _getDisplayStatus() {
    return status.replaceAll('-', ' ').split(' ').map((word) {
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getStatusBackgroundColor(),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _getStatusColor()),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getStatusIcon(),
                color: _getStatusColor(),
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                _getDisplayStatus(),
                style: TextStyle(
                  color: _getStatusColor(),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        if (showTimestamp && timestamp != null) ...[
          const SizedBox(height: 4),
          Text(
            _formatTimestamp(timestamp!),
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 10,
            ),
          ),
        ]
      ],
    );
  }

  String _formatTimestamp(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
