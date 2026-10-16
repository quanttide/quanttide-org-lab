import 'package:flutter/material.dart';

import '../../models/org_unit.dart';
import '../../models/position.dart';
import '../../state/position_store_scope.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/data/power_chip.dart';
import '../../widgets/data/status_badge.dart';
import '../../widgets/forms/change_dialog.dart';
import 'position_detail_screen.dart';

/// 职位页（岗位档案）：按机构分组浏览职位槽位，槽位先于人头。
class PositionsScreen extends StatelessWidget {
  const PositionsScreen({super.key});

  Future<void> _createPosition(BuildContext context) async {
    final store = PositionStoreScope.of(context);
    final draft = await showDialog<PositionDraft>(
      context: context,
      builder: (_) => PositionSetupDialog(orgUnits: store.orgUnits),
    );
    if (draft == null || !context.mounted) return;
    store.addPosition(
      orgUnitId: draft.orgUnitId,
      name: draft.name,
      responsibilities: draft.responsibilities,
      headcount: draft.headcount,
      category: draft.category,
      powers: draft.powers,
      effectiveDate: draft.effectiveDate,
      basis: draft.basis,
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = PositionStoreScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('职位档案')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createPosition(context),
        icon: const Icon(Icons.add),
        label: const Text('新建职位'),
      ),
      body: store.positions.isEmpty
          ? const EmptyState(
              icon: Icons.badge_outlined,
              title: '尚无职位——先设职位，再派任职',
            )
          : ListView(
              padding: const EdgeInsets.only(bottom: 88),
              children: [
                for (final unit in store.orgUnits)
                  _OrgUnitSection(unitId: unit.id, unitName: unit.name),
              ],
            ),
    );
  }
}

class _OrgUnitSection extends StatelessWidget {
  const _OrgUnitSection({required this.unitId, required this.unitName});

  final String unitId;
  final String unitName;

  @override
  Widget build(BuildContext context) {
    final store = PositionStoreScope.of(context);
    final theme = Theme.of(context);
    final unitPositions = store.positions
        .where((p) => p.orgUnitId == unitId)
        .toList(growable: false);
    if (unitPositions.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
          child: Text(
            '$unitName · ${unitPositions.length} 个职位',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ),
        for (final position in unitPositions) _PositionTile(position: position),
      ],
    );
  }
}

class _PositionTile extends StatelessWidget {
  const _PositionTile({required this.position});

  final Position position;

  @override
  Widget build(BuildContext context) {
    final store = PositionStoreScope.of(context);
    final theme = Theme.of(context);
    final filled = store.filledOf(position.id);
    return ListTile(
      title: Row(
        children: [
          Flexible(
            child: Text(
              position.name,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium,
            ),
          ),
          const SizedBox(width: 8),
          if (position.isFrozen)
            const StatusBadge(tone: BadgeTone.frozen, label: '冻结')
          else if (store.isVacant(position))
            const StatusBadge(tone: BadgeTone.warning, label: '空缺')
          else if (store.isOverstaffed(position))
            const StatusBadge(tone: BadgeTone.warning, label: '超编'),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              position.responsibilities,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                for (final power in position.powers) PowerChip(power: power),
                Text(
                  '编制 $filled/${position.headcount}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => PositionDetailScreen(positionId: position.id),
        ),
      ),
    );
  }
}

/// 新建职位草稿：槽位属性 + 登记信息（变更即登记）。
class PositionDraft {
  const PositionDraft({
    required this.orgUnitId,
    required this.name,
    required this.responsibilities,
    required this.headcount,
    required this.category,
    required this.powers,
    required this.effectiveDate,
    required this.basis,
  });

  final String orgUnitId;
  final String name;
  final String responsibilities;
  final int headcount;
  final PositionCategory category;
  final List<Power> powers;
  final String effectiveDate;
  final String basis;
}

/// 新建职位对话框：先设职位——名称、归属、职责边界、编制、类别与权能，
/// 并随同登记生效日期与变更依据。
class PositionSetupDialog extends StatefulWidget {
  const PositionSetupDialog({super.key, required this.orgUnits});

  final List<OrgUnit> orgUnits;

  @override
  State<PositionSetupDialog> createState() => _PositionSetupDialogState();
}

class _PositionSetupDialogState extends State<PositionSetupDialog> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _responsibilities = TextEditingController();
  final TextEditingController _basis = TextEditingController();
  String? _orgUnitId;
  int _headcount = 1;
  PositionCategory _category = PositionCategory.operations;
  final Set<Power> _powers = {Power.execution};
  late String _date = formatDate(DateTime.now());
  bool _nameError = false;
  String? _basisError;

  @override
  void dispose() {
    _name.dispose();
    _responsibilities.dispose();
    _basis.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _name.text.trim();
    final basis = _basis.text.trim();
    final nameMissing = name.isEmpty;
    final basisMissing = basis.isEmpty;
    setState(() {
      _nameError = nameMissing;
      _basisError = basisMissing ? '请填写变更依据' : null;
    });
    if (nameMissing || basisMissing || _orgUnitId == null) {
      if (_orgUnitId == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('请选择归属机构')));
      }
      return;
    }
    Navigator.of(context).pop(
      PositionDraft(
        orgUnitId: _orgUnitId!,
        name: name,
        responsibilities: _responsibilities.text.trim(),
        headcount: _headcount,
        category: _category,
        powers: _powers.toList(growable: false),
        effectiveDate: _date,
        basis: basis,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('新建职位'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _name,
              decoration: InputDecoration(
                labelText: '职位名称',
                errorText: _nameError ? '请填写职位名称' : null,
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) {
                if (_nameError) setState(() => _nameError = false);
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _orgUnitId,
              decoration: const InputDecoration(
                labelText: '归属机构',
                border: OutlineInputBorder(),
              ),
              items: [
                for (final unit in widget.orgUnits)
                  DropdownMenuItem(value: unit.id, child: Text(unit.name)),
              ],
              onChanged: (v) => setState(() => _orgUnitId = v),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _responsibilities,
              decoration: const InputDecoration(
                labelText: '职责边界',
                hintText: '管什么、对什么负责（只描述槽位，不写任职者）',
                border: OutlineInputBorder(),
              ),
              minLines: 2,
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: _headcount,
                    decoration: const InputDecoration(
                      labelText: '编制数',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      for (var n = 1; n <= 5; n++)
                        DropdownMenuItem(value: n, child: Text('$n')),
                    ],
                    onChanged: (v) => setState(() => _headcount = v ?? 1),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<PositionCategory>(
                    initialValue: _category,
                    decoration: const InputDecoration(
                      labelText: '类别',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      for (final c in PositionCategory.values)
                        DropdownMenuItem(value: c, child: Text(c.label)),
                    ],
                    onChanged: (v) => setState(
                      () => _category = v ?? PositionCategory.operations,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('权能', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              children: [
                for (final power in Power.values)
                  FilterChip(
                    label: Text(power.label),
                    selected: _powers.contains(power),
                    onSelected: (selected) => setState(() {
                      if (selected) {
                        _powers.add(power);
                      } else {
                        _powers.remove(power);
                      }
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            EffectiveDateField(
              date: _date,
              onChanged: (value) => setState(() => _date = value),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _basis,
              decoration: InputDecoration(
                labelText: '变更依据',
                hintText: '决议、章程或通知',
                errorText: _basisError,
                border: const OutlineInputBorder(),
              ),
              minLines: 1,
              maxLines: 2,
              onChanged: (_) {
                if (_basisError != null) setState(() => _basisError = null);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(onPressed: _submit, child: const Text('设立')),
      ],
    );
  }
}
