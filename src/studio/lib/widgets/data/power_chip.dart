import 'package:flutter/material.dart';

import '../../models/position.dart';

/// 权能标签——展示职位承载的权能组合（决策/执行/仲裁）。
class PowerChip extends StatelessWidget {
  const PowerChip({super.key, required this.power});

  final Power power;

  @override
  Widget build(BuildContext context) {
    final color = switch (power) {
      Power.decision => Colors.indigo.shade700,
      Power.execution => Colors.teal.shade700,
      Power.arbitration => Colors.deepPurple.shade600,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(power.label, style: TextStyle(fontSize: 12, color: color)),
    );
  }
}
