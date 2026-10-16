import 'package:flutter/material.dart';

import '../../models/member.dart';
import '../../models/position.dart';
import 'change_dialog.dart';

/// 登记任职的表单结果。
class AppointDraft {
  const AppointDraft({
    required this.memberId,
    required this.positionId,
    required this.effectiveDate,
    required this.basis,
    this.reportsToId,
  });

  final String memberId;
  final String positionId;
  final String effectiveDate;
  final String basis;

  /// 汇报对象（兼任边界显式：按职位分别登记，可为无）。
  final String? reportsToId;
}

/// 登记任职对话框：选择对象 + 生效日期 + 变更依据。
/// 新任与兼任同走此登记；对象可由调用方预设（只补登记信息）。
class AppointDialog extends StatefulWidget {
  const AppointDialog({
    super.key,
    required this.members,
    required this.positions,
    this.presetMemberId,
    this.presetPositionId,
  });

  final List<Member> members;
  final List<Position> positions;

  /// 预设成员/职位：预设的一侧不再展示下拉框。
  final String? presetMemberId;
  final String? presetPositionId;

  @override
  State<AppointDialog> createState() => _AppointDialogState();
}

class _AppointDialogState extends State<AppointDialog> {
  String? _memberId;
  String? _positionId;
  String? _reportsToId;
  late String _date = formatDate(DateTime.now());
  final TextEditingController _basis = TextEditingController();
  String? _basisError;

  @override
  void initState() {
    super.initState();
    _memberId = widget.presetMemberId;
    _positionId = widget.presetPositionId;
  }

  @override
  void dispose() {
    _basis.dispose();
    super.dispose();
  }

  void _submit() {
    final basis = _basis.text.trim();
    final missing =
        _memberId == null ||
        _positionId == null ||
        _positionId!.isEmpty ||
        basis.isEmpty;
    setState(() => _basisError = basis.isEmpty ? '请填写变更依据' : null);
    if (missing) {
      if (_memberId == null || _positionId == null || _positionId!.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('请选择成员与职位')));
      }
      return;
    }
    Navigator.of(context).pop(
      AppointDraft(
        memberId: _memberId!,
        positionId: _positionId!,
        effectiveDate: _date,
        basis: basis,
        reportsToId: _reportsToId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final frozen = _positionId == null
        ? false
        : widget.positions.firstWhere((p) => p.id == _positionId).isFrozen;
    return AlertDialog(
      title: const Text('登记任职'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.presetMemberId == null) ...[
              DropdownButtonFormField<String>(
                initialValue: _memberId,
                decoration: const InputDecoration(
                  labelText: '成员',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final m in widget.members)
                    DropdownMenuItem(value: m.id, child: Text(m.name)),
                ],
                onChanged: (v) => setState(() => _memberId = v),
              ),
              const SizedBox(height: 16),
            ],
            if (widget.presetPositionId == null) ...[
              DropdownButtonFormField<String>(
                initialValue: _positionId,
                decoration: const InputDecoration(
                  labelText: '职位',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final p in widget.positions)
                    DropdownMenuItem(
                      value: p.id,
                      child: Text(
                        p.isFrozen ? '${p.name}（已冻结）' : p.name,
                        style: p.isFrozen
                            ? TextStyle(
                                color: Theme.of(context).colorScheme.outline,
                              )
                            : null,
                      ),
                    ),
                ],
                onChanged: (v) => setState(() => _positionId = v),
              ),
              const SizedBox(height: 16),
            ],
            DropdownButtonFormField<String>(
              initialValue: _reportsToId,
              decoration: const InputDecoration(
                labelText: '汇报对象（按职位登记，可无）',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: '',
                  child: Text('无直接汇报对象'),
                ),
                for (final m in widget.members)
                  if (m.id != _memberId)
                    DropdownMenuItem(value: m.id, child: Text(m.name)),
              ],
              onChanged: (v) => setState(
                () => _reportsToId = (v == null || v.isEmpty) ? null : v,
              ),
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
            if (frozen) ...[
              const SizedBox(height: 12),
              Text(
                '该职位已冻结，不再新任职。',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: frozen ? null : _submit,
          child: const Text('登记'),
        ),
      ],
    );
  }
}
