import 'package:flutter/material.dart';

import '../../models/position.dart';
import '../../state/position_store_scope.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/data/power_chip.dart';
import '../../widgets/data/status_badge.dart';
import '../../widgets/forms/appoint_dialog.dart';
import '../../widgets/forms/change_dialog.dart';

/// 成员详情：完整职务清单（主要职位列于首位）+ 逐职位的兼任边界与登记入口。
class MemberDetailScreen extends StatelessWidget {
  const MemberDetailScreen({super.key, required this.memberId});

  final String memberId;

  Future<void> _setPrimary(BuildContext context, String appointmentId) async {
    final store = PositionStoreScope.of(context);
    final draft = await showDialog<ChangeDraft>(
      context: context,
      builder: (_) => ChangeDialog(
        title: '设为主要职位',
        object: store.titleLineOf(memberId),
        confirmLabel: '登记',
      ),
    );
    if (draft == null) return;
    store.setPrimary(
      appointmentId: appointmentId,
      effectiveDate: draft.effectiveDate,
      basis: draft.basis,
    );
  }

  Future<void> _dismiss(BuildContext context, String appointmentId) async {
    final store = PositionStoreScope.of(context);
    final appointment = store.appointments.firstWhere(
      (a) => a.id == appointmentId,
    );
    final position = store.positionById(appointment.positionId);
    final draft = await showDialog<ChangeDraft>(
      context: context,
      builder: (_) => ChangeDialog(
        title: '免任',
        object: '${store.memberById(memberId).name}：${position.name}',
        confirmLabel: '登记',
      ),
    );
    if (draft == null) return;
    store.dismiss(
      appointmentId: appointmentId,
      effectiveDate: draft.effectiveDate,
      basis: draft.basis,
    );
  }

  Future<void> _appoint(BuildContext context) async {
    final store = PositionStoreScope.of(context);
    final draft = await showDialog<AppointDraft>(
      context: context,
      builder: (_) => AppointDialog(
        members: store.members,
        positions: store.positions,
        presetMemberId: memberId,
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

  @override
  Widget build(BuildContext context) {
    final store = PositionStoreScope.of(context);
    final member = store.memberById(memberId);
    final theme = Theme.of(context);
    final appointments = store.appointmentsOfMemberOrdered(memberId);
    final active = store.activeAppointmentsOfMember(memberId);

    return Scaffold(
      appBar: AppBar(title: Text(member.name)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _appoint(context),
        icon: const Icon(Icons.person_add_alt_1_outlined),
        label: const Text('登记新任职'),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 88),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('职务清单（主要职位列于首位）', style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      store.titleLineOf(memberId),
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  '在任任职（${active.length}）',
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          if (appointments.isEmpty)
            const EmptyState(
              icon: Icons.person_off_outlined,
              title: '尚无在任职位——先设职位，再登记任职',
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  for (final appointment in appointments)
                    _AppointmentCard(
                      appointmentId: appointment.id,
                      onSetPrimary: () => _setPrimary(context, appointment.id),
                      onDismiss: () => _dismiss(context, appointment.id),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({
    required this.appointmentId,
    required this.onSetPrimary,
    required this.onDismiss,
  });

  final String appointmentId;
  final VoidCallback onSetPrimary;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final store = PositionStoreScope.of(context);
    final theme = Theme.of(context);
    final appointment = store.appointments.firstWhere(
      (a) => a.id == appointmentId,
    );
    final position = store.positionById(appointment.positionId);
    final orgUnit = store.orgUnitById(position.orgUnitId);
    final reportsTo = appointment.reportsToId == null
        ? null
        : store.memberById(appointment.reportsToId!);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    position.name,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                if (appointment.primary)
                  const StatusBadge(tone: BadgeTone.primary, label: '主要职位'),
              ],
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  '${orgUnit.name} · ${position.category.label}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                for (final power in position.powers) PowerChip(power: power),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              reportsTo == null ? '无直接汇报对象' : '汇报：${reportsTo.name}',
              style: theme.textTheme.bodyMedium,
            ),
            Text(
              '生效 ${appointment.effectiveDate} · 依据 ${appointment.basis}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (!appointment.primary)
                  TextButton(
                    onPressed: onSetPrimary,
                    child: const Text('设为主要职位'),
                  ),
                const Spacer(),
                TextButton(
                  onPressed: onDismiss,
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                  ),
                  child: const Text('免任'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
