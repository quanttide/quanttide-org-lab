import 'package:flutter/material.dart';

import '../../models/change_record.dart';
import '../../state/position_store_scope.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/data/status_badge.dart';

/// 变更登记页：新任、免任、兼任与主要职位变更的登记流水（变更即登记）。
class RecordsScreen extends StatelessWidget {
  const RecordsScreen({super.key});

  BadgeTone _tone(ChangeType type) => switch (type) {
    ChangeType.primaryChange => BadgeTone.primary,
    ChangeType.dismiss => BadgeTone.warning,
    _ => BadgeTone.normal,
  };

  @override
  Widget build(BuildContext context) {
    final store = PositionStoreScope.of(context);
    final theme = Theme.of(context);
    final records = store.changeRecords;
    return Scaffold(
      appBar: AppBar(title: const Text('变更登记')),
      body: records.isEmpty
          ? const EmptyState(
              icon: Icons.app_registration_outlined,
              title: '暂无变更登记',
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: records.length + 1,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                    child: Text(
                      '记录先行，告知随后——生效日期与变更依据逐条载明',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  );
                }
                final record = records[index - 1];
                return ListTile(
                  leading: StatusBadge(
                    tone: _tone(record.type),
                    label: record.type.label,
                  ),
                  title: Text(record.object),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('生效 ${record.effectiveDate} · 依据 ${record.basis}'),
                        if (record.detail != null) Text(record.detail!),
                        Text(
                          '登记于 ${record.registeredAt.split('T').first}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
