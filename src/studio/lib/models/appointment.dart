/// 任职——成员与职位的对应关系。
/// 一人可同时持有多个职位（兼任）；是否兼任以登记记录为准，不凭记忆或口头约定。
class Appointment {
  const Appointment({
    required this.id,
    required this.memberId,
    required this.positionId,
    required this.effectiveDate,
    required this.basis,
    this.primary = false,
    this.reportsToId,
    this.active = true,
  });

  final String id;
  final String memberId;
  final String positionId;

  /// 生效日期（ISO 8601 日期，YYYY-MM-DD）。
  final String effectiveDate;

  /// 变更依据（决议、章程或通知）。
  final String basis;

  /// 是否该成员的主要职位：一人一主职，同一成员的在任任职中至多一条为 true。
  final bool primary;

  /// 汇报对象成员 id：兼任边界显式——汇报关系按职位分别登记，无直接汇报对象为 null。
  final String? reportsToId;

  /// 免任后为 false；历史记录保留，可追溯。
  final bool active;
}
