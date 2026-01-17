import 'package:flutter/material.dart';

class StarRatingWidget extends StatefulWidget {
  final int initialRating;
  final int maxRating;
  final double size;
  final Color filledColor;
  final Color unfilledColor;
  final bool enabled;
  final Function(int) onRatingChanged;
  final bool showPercentage;

  const StarRatingWidget({
    Key? key,
    this.initialRating = 0,
    this.maxRating = 5,
    this.size = 24.0,
    this.filledColor = Colors.amber,
    this.unfilledColor = Colors.grey,
    this.enabled = true,
    required this.onRatingChanged,
    this.showPercentage = false,
  }) : super(key: key);

  @override
  State<StarRatingWidget> createState() => _StarRatingWidgetState();
}

class _StarRatingWidgetState extends State<StarRatingWidget> {
  late int _currentRating;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(widget.maxRating, (index) {
            return GestureDetector(
              onTap: widget.enabled
                  ? () {
                      setState(() {
                        _currentRating = index + 1;
                      });
                      widget.onRatingChanged(_currentRating);
                    }
                  : null,
              child: MouseRegion(
                onEnter: widget.enabled
                    ? (_) {
                        setState(() {
                          _currentRating = index + 1;
                        });
                      }
                    : null,
                onExit: widget.enabled
                    ? (_) {
                        setState(() {
                          _currentRating = widget.initialRating;
                        });
                      }
                    : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    index < _currentRating ? Icons.star : Icons.star_border,
                    color: index < _currentRating
                        ? widget.filledColor
                        : widget.unfilledColor,
                    size: widget.size,
                  ),
                ),
              ),
            );
          }),
        ),
        if (widget.showPercentage) ...[
          const SizedBox(width: 8),
          Text(
            '${((_currentRating / widget.maxRating) * 100).toInt()}%',
            style: TextStyle(
              fontSize: widget.size * 0.6,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }
}

class RatingDisplayWidget extends StatelessWidget {
  final double averageRating;
  final int totalRatings;
  final double size;
  final bool showCount;

  const RatingDisplayWidget({
    Key? key,
    required this.averageRating,
    this.totalRatings = 0,
    this.size = 16.0,
    this.showCount = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            return Icon(
              index < averageRating.round() ? Icons.star : Icons.star_border,
              color: index < averageRating.round()
                  ? Colors.amber
                  : Colors.grey[300],
              size: size,
            );
          }),
        ),
        if (showCount) ...[
          const SizedBox(width: 4),
          Text(
            averageRating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: size * 0.875,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          if (totalRatings > 0) ...[
            const SizedBox(width: 2),
            Text(
              '($totalRatings)',
              style: TextStyle(fontSize: size * 0.75, color: Colors.grey[500]),
            ),
          ],
        ],
      ],
    );
  }
}

class RatingPercentageWidget extends StatelessWidget {
  final double averageRating;
  final int totalRatings;
  final double size;

  const RatingPercentageWidget({
    Key? key,
    required this.averageRating,
    this.totalRatings = 0,
    this.size = 16.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final percentage = (averageRating / 5) * 100;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getRatingColor(percentage).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getRatingColor(percentage).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, color: _getRatingColor(percentage), size: size),
          const SizedBox(width: 4),
          Text(
            '${percentage.toInt()}%',
            style: TextStyle(
              fontSize: size * 0.875,
              fontWeight: FontWeight.w600,
              color: _getRatingColor(percentage),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRatingColor(double percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.amber;
    if (percentage >= 40) return Colors.orange;
    return Colors.red;
  }
}
