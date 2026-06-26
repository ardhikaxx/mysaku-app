import 'package:flutter/material.dart';

class DreamProgressBar extends StatelessWidget {
  final double percentage; // 0 to 100

  const DreamProgressBar({
    super.key,
    required this.percentage,
  });

  Color _getColor(double p) {
    if (p < 30) return Colors.redAccent;
    if (p <= 70) return Colors.amber;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final clamped = percentage.clamp(0.0, 100.0);
    final val = clamped / 100;
    final color = _getColor(clamped);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress Target',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            Text(
              '${clamped.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: val,
            minHeight: 8,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
