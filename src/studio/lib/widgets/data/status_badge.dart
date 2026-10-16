import 'package:flutter/material.dart';

/// 状态徽章（正常/警示/冻结/主要）。
enum BadgeTone { normal, warning, frozen, primary }

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.tone, required this.label});

  final BadgeTone tone;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = switch (tone) {
      BadgeTone.normal => Colors.grey.shade600,
      BadgeTone.warning => Colors.orange.shade800,
      BadgeTone.frozen => Colors.blueGrey.shade600,
      BadgeTone.primary => Colors.indigo.shade700,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
