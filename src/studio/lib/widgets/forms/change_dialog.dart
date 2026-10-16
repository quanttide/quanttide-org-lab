import 'package:flutter/material.dart';

/// ISO 8601 日期格式化（YYYY-MM-DD）。
String formatDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

/// 登记对话框的返回值：生效日期 + 变更依据（变更即登记的两项必备信息）。
class ChangeDraft {
  const ChangeDraft({required this.effectiveDate, required this.basis});

  final String effectiveDate;
  final String basis;
}

/// 通用登记对话框——所有变更共用「生效日期 + 变更依据」两项登记信息，
/// [trailing] 用于在登记字段前追加对象选择等字段（由调用方持有控制器）。
class ChangeDialog extends StatefulWidget {
  const ChangeDialog({
    super.key,
    required this.title,
    this.object,
    this.confirmLabel = '登记',
    this.trailing,
  });

  final String title;

  /// 变更对象说明（展示在表单顶部）。
  final String? object;

  final String confirmLabel;

  /// 登记字段之前的自定义字段。
  final Widget? trailing;

  @override
  State<ChangeDialog> createState() => _ChangeDialogState();
}

class _ChangeDialogState extends State<ChangeDialog> {
  late String _date = formatDate(DateTime.now());
  final TextEditingController _basis = TextEditingController();
  String? _basisError;

  @override
  void dispose() {
    _basis.dispose();
    super.dispose();
  }

  void _submit() {
    final basis = _basis.text.trim();
    if (basis.isEmpty) {
      setState(() => _basisError = '请填写变更依据');
      return;
    }
    Navigator.of(context).pop(ChangeDraft(effectiveDate: _date, basis: basis));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.object != null) ...[
              Text(
                widget.object!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
            ],
            if (widget.trailing != null) ...[
              widget.trailing!,
              const SizedBox(height: 16),
            ],
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
        FilledButton(onPressed: _submit, child: Text(widget.confirmLabel)),
      ],
    );
  }
}

/// 生效日期选择字段（默认今天）。
class EffectiveDateField extends StatelessWidget {
  const EffectiveDateField({
    super.key,
    required this.date,
    required this.onChanged,
  });

  final String date;
  final ValueChanged<String> onChanged;

  Future<void> _pick(BuildContext context) async {
    final parts = date.split('-');
    final initial = DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) onChanged(formatDate(picked));
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('生效日期', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(width: 12),
        OutlinedButton.icon(
          onPressed: () => _pick(context),
          icon: const Icon(Icons.calendar_today_outlined, size: 16),
          label: Text(date),
        ),
      ],
    );
  }
}
