import 'package:flutter/material.dart';

import '../../models/position.dart';
import '../../state/position_store_scope.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/data/power_chip.dart';
import '../../widgets/data/status_badge.dart';
import '../../widgets/forms/appoint_dialog.dart';
import '../../widgets/forms/change_dialog.dart';
import '../members/member_detail_screen.dart';

/// 职位详情：槽位属性 + 任职者清单（主要职位标注、兼任边界按职位登记）。
class PositionDetailScreen extends StatelessWidget {
  const PositionDetailScreen({super.key, required this.positionId});

  final String positionId;

  Future<void> _appoint(BuildContext context) async {
    final store = PositionStoreScope.of(context);
    final position = store.positionById(positionId);
    final draft = await showDialog<AppointDraft>(
      context: context,
      builder: (_) => AppointDialog(
        members: store.members,
        positions: store.positions,
        presetPositionId: position.id,
      ),
    );
    if (draft == null) return;
    store.appoint(
      memberId: draft.memberId,
      positionId: draft.positionId,
      effectiveDate: draft.effectiveDate,
      basis: draft.basis,
      reportsToId: draft.reportsToId,
    );
  }

  Future<void> _toggleFreeze(BuildContext context) async {
    final store = PositionStoreScope.of(context);
    final position = store.positionById(positionId);
    final frozen = position.isFrozen;
    final draft = await showDialog<ChangeDraft>(
      context: context,
      builder: (_) => ChangeDialog(
        title: frozen ? '解冻职位' : '冻结职位',
        object: position.name,
        confirmLabel: '登记',
      ),
    );
    if (draft == null) return;
    store.toggleFreeze(
      positionId: position.id,
      effectiveDate: draft.effectiveDate,
      basis: draft.basis,
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = PositionStoreScope.of(context);
    final position = store.positionById(positionId);
    final theme = Theme.of(context);
    final filled = store.filledOf(position.id);
    final incumbents = store.incumbentsOf(position);
    final orgUnit = store.orgUnitById(position.orgUnitId);

    return Scaffold(
      appBar: AppBar(title: Text(position.name)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Row(
            children: [
              StatusBadge(
                tone: position.isFrozen ? BadgeTone.frozen : BadgeTone.normal,
                label: position.isFrozen ? '冻结' : '启用',
              ),
              if (!position.isFrozen && store.isVacant(position)) ...[
                const SizedBox(width: 8),
                const StatusBadge(tone: BadgeTone.warning, label: '空缺'),
              ],
              if (store.isOverstaffed(position)) ...[
                const SizedBox(width: 8),
                const StatusBadge(tone: BadgeTone.warning, label: '超编'),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '归属：${orgUnit.name} · 类别：${position.category.label}',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final power in position.powers) PowerChip(power: power),
              Text(
                '编制 $filled/${position.headcount}',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('职责边界', style: theme.textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(position.responsibilities, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: position.isFrozen ? null : () => _appoint(context),
                  icon: const Icon(Icons.person_add_alt_1_outlined),
                  label: const Text('登记任职'),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () => _toggleFreeze(context),
                child: Text(position.isFrozen ? '解冻' : '冻结'),
              ),
            ],
          ),
          if (position.isFrozen) ...[
            const SizedBox(height: 8),
            Text(
              '冻结中：不再新任职，已有任职不受影响。',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
          const SizedBox(height: 24),
          Text('任职者（${incumbents.length}）', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          if (incumbents.isEmpty)
            const EmptyState(icon: Icons.person_off_outlined, title: '空缺：尚无人任职')
          else
            Card(
              margin: EdgeInsets.zero,
              child: Column(
                children: [
                  for (final appointment in store.activeAppointmentsOfPosition(
                    position.id,
                  ))
                    ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: Row(
                        children: [
                          Flexible(
                            child: Text(
                              store.memberById(appointment.memberId).name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (appointment.primary) ...[
                            const SizedBox(width: 8),
                            const StatusBadge(
                              tone: BadgeTone.primary,
                              label: '主要职位',
                            ),
                          ],
                        ],
                      ),
                      subtitle: Text(
                        appointment.reportsToId == null
                            ? '无直接汇报对象 · 生效 ${appointment.effectiveDate}'
                            : '汇报：${store.memberById(appointment.reportsToId!).name}'
                                  ' · 生效 ${appointment.effectiveDate}',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => MemberDetailScreen(
                            memberId: appointment.memberId,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
