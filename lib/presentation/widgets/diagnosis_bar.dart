import 'package:flutter/material.dart';
import 'package:diagnose_app/core/constants/app_colors.dart';

class DiagnosisBar extends StatelessWidget {
  final String label;
  final int count;
  final double ratio;
  final int total;
  final Color color;
  final Color trackColor;

  const DiagnosisBar({
    super.key,
    required this.label,
    required this.count,
    required this.ratio,
    required this.total,
    this.color = AppColors.benignColor,
    this.trackColor = AppColors.benignTrack,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? '—' : '${(ratio * 100).toStringAsFixed(1)}%';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              total == 0 ? '—' : '$count  ($pct)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LayoutBuilder(
          builder: (_, constraints) => Stack(
            children: [
              Container(
                height: 8,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: trackColor,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              Container(
                height: 8,
                width: constraints.maxWidth * ratio,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
