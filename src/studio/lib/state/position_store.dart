import 'package:flutter/foundation.dart';

import '../models/appointment.dart';
import '../models/change_record.dart';
import '../models/member.dart';
import '../models/org_unit.dart';
import '../models/position.dart';

/// 内存事实源——职位说明书与任职事实在此合一。
///
/// 原型阶段替代 git 数据层：模型保持不可变纯数据，所有写操作经登记方法落地，
/// 一次登记同时更新事实并产生 `ChangeRecord`（变更即登记），页面只做读取与呈现。
class PositionStore extends ChangeNotifier {
  PositionStore({
    required List<OrgUnit> orgUnits,
    required List<Position> positions,
    required List<Member> members,
    required List<Appointment> appointments,
    required List<ChangeRecord> changeRecords,
  }) : orgUnits = List<OrgUnit>.of(orgUnits),
       positions = List<Position>.of(positions),
       members = List<Member>.of(members),
       appointments = List<Appointment>.of(appointments),
       changeRecords = List<ChangeRecord>.of(changeRecords),
       _seq = 1000; // 新 id 从高位起，避免与示例数据的低位 id 冲突。

  final List<OrgUnit> orgUnits;
  final List<Position> positions;
  final List<Member> members;
  final List<Appointment> appointments;

  /// 变更登记，新记录在前。
  final List<ChangeRecord> changeRecords;

  int _seq;

  String _nextId(String prefix) => '$prefix-${_seq++}';

  // ---------- 查询（读路径：事实 → 推导 → 展示） ----------

  OrgUnit orgUnitById(String id) => orgUnits.firstWhere((o) => o.id == id);

  Position positionById(String id) => positions.firstWhere((p) => p.id == id);

  Member memberById(String id) => members.firstWhere((m) => m.id == id);

  /// 成员的在任任职。
  List<Appointment> activeAppointmentsOfMember(String memberId) => appointments
      .where((a) => a.memberId == memberId && a.active)
      .toList(growable: false);

  /// 职位的在任任职。
  List<Appointment> activeAppointmentsOfPosition(String positionId) =>
      appointments
          .where((a) => a.positionId == positionId && a.active)
          .toList(growable: false);

  /// 编制占用数（由任职事实派生）。
  int filledOf(String positionId) =>
      activeAppointmentsOfPosition(positionId).length;

  /// 空缺：无人占用。
  bool isVacant(Position position) => filledOf(position.id) == 0;

  /// 超编：占用超过编制。
  bool isOverstaffed(Position position) =>
      filledOf(position.id) > position.headcount;

  /// 职位的在任成员。
  List<Member> incumbentsOf(Position position) => activeAppointmentsOfPosition(
    position.id,
  ).map((a) => memberById(a.memberId)).toList(growable: false);

  /// 成员的主要职位（一人一主职：至多一条）。
  Appointment? primaryAppointmentOf(String memberId) {
    for (final a in activeAppointmentsOfMember(memberId)) {
      if (a.primary) return a;
    }
    return null;
  }

  /// 成员的在任职位清单，主要职位列于首位（主要职位列于首位，主次一眼可辨）。
  List<Appointment> appointmentsOfMemberOrdered(String memberId) {
    final active = activeAppointmentsOfMember(memberId);
    return [
      for (final a in active)
        if (a.primary) a,
      for (final a in active)
        if (!a.primary) a,
    ];
  }

  /// 「成员：主要职位、职位、职位」——职务单一事实源的罗列格式。
  String titleLineOf(String memberId) {
    final names = [
      for (final a in appointmentsOfMemberOrdered(memberId))
        positionById(a.positionId).name,
    ];
    return '${memberById(memberId).name}：${names.join('、')}';
  }

  /// 未指定主要职位的在任成员（登记流程保证不留悬空，此处为审计视图）。
  List<Member> get membersWithoutPrimary => members
      .where(
        (m) =>
            activeAppointmentsOfMember(m.id).isNotEmpty &&
            primaryAppointmentOf(m.id) == null,
      )
      .toList(growable: false);

  List<Position> get vacantPositions =>
      positions.where(isVacant).toList(growable: false);

  List<Position> get frozenPositions =>
      positions.where((p) => p.isFrozen).toList(growable: false);

  List<Position> get overstaffedPositions =>
      positions.where(isOverstaffed).toList(growable: false);

  /// 最近登记（列表本身新记录在前）。
  List<ChangeRecord> recentChanges(int count) =>
      changeRecords.take(count).toList(growable: false);

  /// 成员在任的机构集合（列表页摘要用）。
  List<OrgUnit> orgUnitsOf(String memberId) {
    final ids = <String>{};
    for (final a in activeAppointmentsOfMember(memberId)) {
      ids.add(positionById(a.positionId).orgUnitId);
    }
    return [for (final id in ids) orgUnitById(id)];
  }

  // ---------- 主要职位规则 ----------

  /// 主要职位建议：治理优先——公司体系下治理职位为先，未任治理职位者以经营职位为先。
  /// 同序列内按登记先后取第一条。
  String suggestPrimaryAppointmentId(String memberId) {
    final active = activeAppointmentsOfMember(memberId);
    if (active.isEmpty) {
      throw StateError('成员暂无在任职位，无法指定主要职位');
    }
    final governance = active
        .where(
          (a) =>
              positionById(a.positionId).category ==
              PositionCategory.governance,
        )
        .toList(growable: false);
    final pool = governance.isNotEmpty ? governance : active;
    return pool.first.id;
  }

  // ---------- 写路径（变更即登记） ----------

  Appointment _appointmentById(String id) =>
      appointments.firstWhere((a) => a.id == id);

  /// 槽位先于人头：先设职位、写明职责边界，再登记任职。
  void addPosition({
    required String orgUnitId,
    required String name,
    required String responsibilities,
    required int headcount,
    required PositionCategory category,
    required List<Power> powers,
    required String effectiveDate,
    required String basis,
  }) {
    positions.add(
      Position(
        id: _nextId('p'),
        orgUnitId: orgUnitId,
        name: name,
        responsibilities: responsibilities,
        headcount: headcount,
        category: category,
        powers: powers,
      ),
    );
    _record(
      ChangeType.positionSetup,
      object: name,
      effectiveDate: effectiveDate,
      basis: basis,
      detail: '${orgUnitById(orgUnitId).name} · 编制 $headcount 名',
    );
    notifyListeners();
  }

  /// 冻结/解冻：冻结后不再新任职，已有任职不受影响。
  void toggleFreeze({
    required String positionId,
    required String effectiveDate,
    required String basis,
  }) {
    final index = positions.indexWhere((p) => p.id == positionId);
    final position = positions[index];
    final frozen = !position.isFrozen;
    positions[index] = Position(
      id: position.id,
      orgUnitId: position.orgUnitId,
      name: position.name,
      responsibilities: position.responsibilities,
      headcount: position.headcount,
      category: position.category,
      powers: position.powers,
      status: frozen ? PositionStatus.frozen : PositionStatus.active,
    );
    _record(
      ChangeType.positionChange,
      object: position.name,
      effectiveDate: effectiveDate,
      basis: basis,
      detail: frozen ? '冻结，不再新任职' : '解冻，恢复登记任职',
    );
    notifyListeners();
  }

  /// 登记新任（兼任同样走此登记）；首次任职者自动指定主要职位，不留悬空。
  void appoint({
    required String memberId,
    required String positionId,
    required String effectiveDate,
    required String basis,
    String? reportsToId,
  }) {
    final position = positionById(positionId);
    if (position.isFrozen) {
      throw StateError('职位「${position.name}」已冻结，不再新任职');
    }
    final isFirstOfMember = primaryAppointmentOf(memberId) == null;
    appointments.add(
      Appointment(
        id: _nextId('ap'),
        memberId: memberId,
        positionId: positionId,
        effectiveDate: effectiveDate,
        basis: basis,
        reportsToId: reportsToId,
      ),
    );
    final detail = StringBuffer(
      '任职编制 ${filledOf(positionId)}/${position.headcount}',
    );
    if (isFirstOfMember) {
      final id = appointments.last.id;
      _applyPrimary(id);
      detail.write('；自动指定为主要职位');
    }
    _record(
      ChangeType.appoint,
      object: '${memberById(memberId).name}：${position.name}',
      effectiveDate: effectiveDate,
      basis: basis,
      detail: detail.toString(),
    );
    notifyListeners();
  }

  /// 登记免任：槽位让出，任职历史保留。
  /// 被免任者若持主要职位，按治理优先自动接续（一人一主职，不留悬空）。
  void dismiss({
    required String appointmentId,
    required String effectiveDate,
    required String basis,
  }) {
    final appointment = _appointmentById(appointmentId);
    if (!appointment.active) {
      throw StateError('该任职已免任，无需重复登记');
    }
    final index = appointments.indexWhere((a) => a.id == appointmentId);
    appointments[index] = Appointment(
      id: appointment.id,
      memberId: appointment.memberId,
      positionId: appointment.positionId,
      effectiveDate: appointment.effectiveDate,
      basis: appointment.basis,
      reportsToId: appointment.reportsToId,
      active: false,
    );
    final member = memberById(appointment.memberId);
    final position = positionById(appointment.positionId);
    _record(
      ChangeType.dismiss,
      object: '${member.name}：${position.name}',
      effectiveDate: effectiveDate,
      basis: basis,
      detail: '槽位让出，编制 ${filledOf(position.id)}/${position.headcount}',
    );
    if (appointment.primary &&
        activeAppointmentsOfMember(member.id).isNotEmpty) {
      final successorId = suggestPrimaryAppointmentId(member.id);
      _applyPrimary(successorId);
      _record(
        ChangeType.primaryChange,
        object: titleLineOf(member.id),
        effectiveDate: effectiveDate,
        basis: '$basis（一人一主职自动接续）',
        detail: '接替 ${position.name} 的主要职位',
      );
    }
    notifyListeners();
  }

  /// 登记主要职位变更：任一时刻主要职位有且仅有一个。
  void setPrimary({
    required String appointmentId,
    required String effectiveDate,
    required String basis,
  }) {
    final appointment = _appointmentById(appointmentId);
    if (!appointment.active) {
      throw StateError('已免任的任职不能设为主要职位');
    }
    if (appointment.primary) {
      throw StateError('该任职已是主要职位');
    }
    _applyPrimary(appointmentId);
    final member = memberById(appointment.memberId);
    final position = positionById(appointment.positionId);
    _record(
      ChangeType.primaryChange,
      object: '${member.name}：${position.name}',
      effectiveDate: effectiveDate,
      basis: basis,
      detail: titleLineOf(member.id),
    );
    notifyListeners();
  }

  /// 执行主要职位指定：同成员其余在任任职一律降为普通职位。
  void _applyPrimary(String appointmentId) {
    final target = _appointmentById(appointmentId);
    for (var i = 0; i < appointments.length; i++) {
      final a = appointments[i];
      if (a.memberId != target.memberId || !a.active) continue;
      final shouldBePrimary = a.id == appointmentId;
      if (a.primary != shouldBePrimary) {
        appointments[i] = Appointment(
          id: a.id,
          memberId: a.memberId,
          positionId: a.positionId,
          effectiveDate: a.effectiveDate,
          basis: a.basis,
          primary: shouldBePrimary,
          reportsToId: a.reportsToId,
          active: a.active,
        );
      }
    }
  }

  void _record(
    ChangeType type, {
    required String object,
    required String effectiveDate,
    required String basis,
    String? detail,
  }) {
    changeRecords.insert(
      0,
      ChangeRecord(
        id: _nextId('c'),
        type: type,
        object: object,
        effectiveDate: effectiveDate,
        basis: basis,
        registeredAt: DateTime.now().toIso8601String(),
        detail: detail,
      ),
    );
  }
}
