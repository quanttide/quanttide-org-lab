/// 变更类型：职位设立、职位变更、新任、免任、主要职位变更。
enum ChangeType {
  positionSetup,
  positionChange,
  appoint,
  dismiss,
  primaryChange,
}

extension ChangeTypeLabel on ChangeType {
  String get label => switch (this) {
    ChangeType.positionSetup => '职位设立',
    ChangeType.positionChange => '职位变更',
    ChangeType.appoint => '新任',
    ChangeType.dismiss => '免任',
    ChangeType.primaryChange => '主要职位变更',
  };
}

/// 变更登记——变更即登记：一经发生即登记，注明生效日期与变更依据。
/// 记录先行，告知随后；补记与口说不能作为协作与考核的依据。
class ChangeRecord {
  const ChangeRecord({
    required this.id,
    required this.type,
    required this.object,
    required this.effectiveDate,
    required this.basis,
    required this.registeredAt,
    this.detail,
  });

  final String id;
  final ChangeType type;

  /// 变更对象（职位名，或「成员：职位」）。
  final String object;

  /// 生效日期（YYYY-MM-DD）。
  final String effectiveDate;

  /// 变更依据。
  final String basis;

  /// 登记时间（ISO 8601）。
  final String registeredAt;

  /// 补充说明（编制占用、接续关系等）。
  final String? detail;
}
