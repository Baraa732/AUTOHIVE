import 'package:flutter/material.dart';

class DiffViewWidget extends StatelessWidget {
  final Map<String, dynamic> diff;
  final Map<String, dynamic>? previousValues;
  final Map<String, dynamic>? newValues;

  const DiffViewWidget({
    Key? key,
    required this.diff,
    this.previousValues,
    this.newValues,
  }) : super(key: key);

  String _formatValue(dynamic value) {
    if (value == null) return 'N/A';
    if (value is DateTime) return value.toString().split(' ')[0];
    return value.toString();
  }

  String _formatFieldName(String field) {
    return field
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    if (diff.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'No Changes',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: diff.entries.map((entry) {
        final fieldName = _formatFieldName(entry.key);
        final oldValue = _formatValue(entry.value['old']);
        final newValue = _formatValue(entry.value['new']);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fieldName,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Previous',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            oldValue,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.red[700],
                              decoration: TextDecoration.lineThrough,
                              decorationColor: Colors.red[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.arrow_forward,
                      size: 18,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'New',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            newValue,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
