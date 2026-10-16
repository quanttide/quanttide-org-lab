import 'package:flutter/material.dart';

import '../../state/position_store_scope.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/data/status_badge.dart';
import 'member_detail_screen.dart';

/// 成员页：职务清单按「成员：主要职位、职位、职位」罗列，主要职位列于首位。
class MembersScreen extends StatelessWidget {
  const MembersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = PositionStoreScope.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('成员职务清单')),
      body: store.members.isEmpty
          ? const EmptyState(icon: Icons.people_outline, title: '尚无成员登记')
          : ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 4),
                  child: Text(
                    '事实源唯一：清单由任职登记推导，主要职位列于首位',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ),
                for (final member in store.members)
                  Builder(
                    builder: (context) {
                      final primary = store.primaryAppointmentOf(member.id);
                      final orgUnits = store.orgUnitsOf(member.id);
                      final missingPrimary =
                          primary == null &&
                          store
                              .activeAppointmentsOfMember(member.id)
                              .isNotEmpty;
                      return ListTile(
                        title: Text(
                          store.titleLineOf(member.id),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  orgUnits.map((o) => o.name).join(' · '),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (missingPrimary) ...[
                                const SizedBox(width: 8),
                                const StatusBadge(
                                  tone: BadgeTone.warning,
                                  label: '缺主要职位',
                                ),
                              ],
                            ],
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                MemberDetailScreen(memberId: member.id),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
    );
  }
}
