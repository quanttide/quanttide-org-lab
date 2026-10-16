import 'package:flutter/material.dart';

import '../../models/change_record.dart';
import '../../state/position_store_scope.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/data/status_badge.dart';

/// 总览：职位/成员/空缺/冻结聚合 + 需要处理的登记缺口 + 最近登记。
class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = PositionStoreScope.of(context);
    final theme = Theme.of(context);
    final activeMembers = store.members
        .where((m) => store.activeAppointmentsOfMember(m.id).isNotEmpty)
        .toList(growable: false);
    final vacant = store.vacantPositions;
    final frozen = store.frozenPositions;
    final overstaffed = store.overstaffedPositions;
    final unassigned = store.membersWithoutPrimary;
    final recent = store.recentChanges(5);
    final alerts = <Widget>[
      for (final p in vacant)
        _AlertTile(
          icon: Icons.person_off_outlined,
          text: '职位空缺：${p.name}（编制 ${p.headcount} 名，无人占用）',
        ),
      for (final p in overstaffed)
        _AlertTile(
          icon: Icons.warning_amber_rounded,
          text: '超编：${p.name}（占用 ${store.filledOf(p.id)}/${p.headcount}）',
        ),
      for (final m in unassigned)
        _AlertTile(
          icon: Icons.star_border,
          text: '${m.name} 尚未指定主要职位（一人一主职，不留悬空）',
        ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('量潮职位')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('职位系统一览', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            '槽位先于人头——空缺与登记缺口在此聚合，每次变更即登记',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatTile(label: '职位', value: store.positions.length),
              _StatTile(label: '在任成员', value: activeMembers.length),
              _StatTile(label: '空缺', value: vacant.length),
              _StatTile(label: '冻结', value: frozen.length),
            ],
          ),
          const SizedBox(height: 24),
          Text('需要处理', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          if (alerts.isEmpty)
            const EmptyState(
              icon: Icons.check_circle_outline,
              title: '无空缺、无超编，主要职位均已登记',
            )
          else
            Card(
              margin: EdgeInsets.zero,
              child: Column(children: alerts),
            ),
          const SizedBox(height: 24),
          Text('最近登记', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          if (recent.isEmpty)
            const EmptyState(
              icon: Icons.app_registration_outlined,
              title: '暂无变更登记',
            )
          else
            Card(
              margin: EdgeInsets.zero,
              child: Column(
                children: [
                  for (final record in recent)
                    ListTile(
                      dense: true,
                      leading: StatusBadge(
                        tone: record.type.name == 'primaryChange'
                            ? BadgeTone.primary
                            : BadgeTone.normal,
                        label: record.type.label,
                      ),
                      title: Text(record.object),
                      subtitle: Text('生效 ${record.effectiveDate}'),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            children: [
              Text(
                '$value',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(label, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  const _AlertTile({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: Icon(icon, color: Theme.of(context).colorScheme.outline),
      title: Text(text, style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}
