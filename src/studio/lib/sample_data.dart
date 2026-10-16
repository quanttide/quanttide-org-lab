import 'models/appointment.dart';
import 'models/change_record.dart';
import 'models/member.dart';
import 'models/org_unit.dart';
import 'models/position.dart';
import 'state/position_store.dart';

/// 内存示例数据（原型阶段替代数据层；事实源唯一，页面内容全部由登记推导）。
///
/// 职位与成员取自《职位》手册与量潮职位实践文档中的真实清单结构：
/// 联盟代表/联盟副秘书长/联盟秘书、总裁/副总裁/实训基地代表/仲裁官。
PositionStore buildSampleStore() {
  final orgUnits = [
    const OrgUnit(id: 'ou-alliance', name: '量潮创新联盟'),
    const OrgUnit(id: 'ou-campus', name: '量潮实训基地'),
    const OrgUnit(id: 'ou-company', name: '量潮公司'),
  ];

  final positions = [
    const Position(
      id: 'p-founder',
      orgUnitId: 'ou-company',
      name: '创始人',
      responsibilities: '出资与组织设计的最终决定权；职位分解与授予的批准。',
      headcount: 1,
      category: PositionCategory.governance,
      powers: [Power.decision, Power.execution],
    ),
    const Position(
      id: 'p-partner',
      orgUnitId: 'ou-company',
      name: '合伙人',
      responsibilities: '参与公司治理决策，共担经营责任。',
      headcount: 2,
      category: PositionCategory.governance,
      powers: [Power.decision],
    ),
    const Position(
      id: 'p-alliance-rep',
      orgUnitId: 'ou-alliance',
      name: '联盟代表',
      responsibilities: '行使联盟立法权：审议联盟规则、预算与成员资格。',
      headcount: 4,
      powers: [Power.decision],
    ),
    const Position(
      id: 'p-alliance-sec-gen',
      orgUnitId: 'ou-alliance',
      name: '联盟秘书长',
      responsibilities: '主持联盟秘书处：执行联盟决议，统筹日常事务与信息发布。',
      powers: [Power.execution],
    ),
    const Position(
      id: 'p-alliance-vice-sec',
      orgUnitId: 'ou-alliance',
      name: '联盟副秘书长',
      responsibilities: '协助秘书长执行联盟事务，组建并运作执行班子。',
      powers: [Power.execution],
    ),
    const Position(
      id: 'p-alliance-sec',
      orgUnitId: 'ou-alliance',
      name: '联盟秘书',
      responsibilities: '承担秘书处执行线的具体事务：会务、记录与联络。',
      headcount: 2,
      powers: [Power.execution],
    ),
    const Position(
      id: 'p-alliance-treasurer',
      orgUnitId: 'ou-alliance',
      name: '联盟司库',
      responsibilities: '管理联盟资产与经费收支（编制待恢复）。',
      status: PositionStatus.frozen,
    ),
    const Position(
      id: 'p-campus-president',
      orgUnitId: 'ou-campus',
      name: '实训基地总裁',
      responsibilities: '行政首长：决策权与执行权集于一身，主持基地全面工作。',
      category: PositionCategory.operations,
      powers: [Power.decision, Power.execution],
    ),
    const Position(
      id: 'p-campus-vice-president',
      orgUnitId: 'ou-campus',
      name: '实训基地副总裁',
      responsibilities: '协助总裁主持基地工作，总裁缺位时代行其职。',
      category: PositionCategory.operations,
      powers: [Power.decision, Power.execution],
    ),
    const Position(
      id: 'p-campus-rep',
      orgUnitId: 'ou-campus',
      name: '实训基地代表',
      responsibilities: '行使基地代表大会的立法与审议权。',
      headcount: 3,
      category: PositionCategory.operations,
      powers: [Power.decision],
    ),
    const Position(
      id: 'p-arbiter',
      orgUnitId: 'ou-campus',
      name: '仲裁官',
      responsibilities: '司法长官形态：裁决执行中发生的争议，独立行使仲裁权。',
      headcount: 2,
      category: PositionCategory.operations,
      powers: [Power.arbitration],
    ),
  ];

  final members = [
    const Member(id: 'm-lin', name: '林澜'),
    const Member(id: 'm-shen', name: '沈川'),
    const Member(id: 'm-su', name: '苏晚'),
    const Member(id: 'm-zhou', name: '周牧'),
  ];

  final appointments = [
    // 林澜：治理优先 → 主要职位为创始人
    const Appointment(
      id: 'ap-1',
      memberId: 'm-lin',
      positionId: 'p-founder',
      effectiveDate: '2026-01-01',
      basis: '《量潮公司章程》第二章：设立登记',
      primary: true,
    ),
    const Appointment(
      id: 'ap-2',
      memberId: 'm-lin',
      positionId: 'p-alliance-rep',
      effectiveDate: '2026-03-01',
      basis: '联盟第一次成员大会决议',
    ),
    const Appointment(
      id: 'ap-3',
      memberId: 'm-lin',
      positionId: 'p-campus-rep',
      effectiveDate: '2026-03-01',
      basis: '实训基地第一次代表大会决议',
    ),
    const Appointment(
      id: 'ap-4',
      memberId: 'm-lin',
      positionId: 'p-alliance-sec-gen',
      effectiveDate: '2026-03-15',
      basis: '联盟秘书处工作规则〔2026〕1 号',
    ),
    // 沈川：现任实训基地总裁的完整职务清单（五职，主要职位为总裁）
    const Appointment(
      id: 'ap-5',
      memberId: 'm-shen',
      positionId: 'p-alliance-rep',
      effectiveDate: '2026-03-01',
      basis: '联盟第一次成员大会决议',
    ),
    const Appointment(
      id: 'ap-6',
      memberId: 'm-shen',
      positionId: 'p-campus-rep',
      effectiveDate: '2026-03-01',
      basis: '实训基地第一次代表大会决议',
    ),
    const Appointment(
      id: 'ap-7',
      memberId: 'm-shen',
      positionId: 'p-campus-president',
      effectiveDate: '2026-04-01',
      basis: '理事会决议〔2026〕3 号',
      primary: true,
      reportsToId: 'm-lin',
    ),
    const Appointment(
      id: 'ap-8',
      memberId: 'm-shen',
      positionId: 'p-alliance-vice-sec',
      effectiveDate: '2026-04-01',
      basis: '联盟秘书处工作规则〔2026〕1 号',
      reportsToId: 'm-lin',
    ),
    const Appointment(
      id: 'ap-9',
      memberId: 'm-shen',
      positionId: 'p-arbiter',
      effectiveDate: '2026-04-01',
      basis: '仲裁官任命书〔2026〕1 号',
    ),
    // 苏晚：现任实训基地副总裁的清单结构（正副之别只体现在行政与秘书两条线上）
    const Appointment(
      id: 'ap-10',
      memberId: 'm-su',
      positionId: 'p-campus-rep',
      effectiveDate: '2026-03-01',
      basis: '实训基地第一次代表大会决议',
    ),
    const Appointment(
      id: 'ap-11',
      memberId: 'm-su',
      positionId: 'p-campus-vice-president',
      effectiveDate: '2026-04-01',
      basis: '理事会决议〔2026〕3 号',
      primary: true,
      reportsToId: 'm-shen',
    ),
    const Appointment(
      id: 'ap-12',
      memberId: 'm-su',
      positionId: 'p-alliance-sec',
      effectiveDate: '2026-04-01',
      basis: '联盟秘书处工作规则〔2026〕1 号',
      reportsToId: 'm-shen',
    ),
    const Appointment(
      id: 'ap-13',
      memberId: 'm-su',
      positionId: 'p-arbiter',
      effectiveDate: '2026-04-01',
      basis: '仲裁官任命书〔2026〕1 号',
    ),
    // 苏晚的原联盟副秘书长任职：已免任，历史保留
    const Appointment(
      id: 'ap-14',
      memberId: 'm-su',
      positionId: 'p-alliance-vice-sec',
      effectiveDate: '2026-01-15',
      basis: '联盟秘书处工作规则〔2025〕4 号',
      reportsToId: 'm-lin',
      active: false,
    ),
    const Appointment(
      id: 'ap-15',
      memberId: 'm-zhou',
      positionId: 'p-alliance-sec',
      effectiveDate: '2026-05-01',
      basis: '秘书处聘用通知〔2026〕2 号',
      primary: true,
      reportsToId: 'm-shen',
    ),
  ];

  // 变更登记：新记录在前（变更即登记——生效日期与变更依据逐条载明）。
  final changeRecords = [
    const ChangeRecord(
      id: 'c-1',
      type: ChangeType.appoint,
      object: '周牧：联盟秘书',
      effectiveDate: '2026-05-01',
      basis: '秘书处聘用通知〔2026〕2 号',
      registeredAt: '2026-05-01T09:30:00.000',
      detail: '任职编制 2/2；自动指定为主要职位',
    ),
    const ChangeRecord(
      id: 'c-2',
      type: ChangeType.positionChange,
      object: '联盟司库',
      effectiveDate: '2026-04-15',
      basis: '联盟秘书处岗位设置方案',
      registeredAt: '2026-04-15T14:00:00.000',
      detail: '冻结，不再新任职',
    ),
    const ChangeRecord(
      id: 'c-3',
      type: ChangeType.appoint,
      object: '沈川：实训基地总裁',
      effectiveDate: '2026-04-01',
      basis: '理事会决议〔2026〕3 号',
      registeredAt: '2026-04-01T10:00:00.000',
      detail: '任职编制 1/1',
    ),
    const ChangeRecord(
      id: 'c-4',
      type: ChangeType.appoint,
      object: '苏晚：实训基地副总裁',
      effectiveDate: '2026-04-01',
      basis: '理事会决议〔2026〕3 号',
      registeredAt: '2026-04-01T10:00:00.000',
      detail: '任职编制 1/1',
    ),
    const ChangeRecord(
      id: 'c-5',
      type: ChangeType.dismiss,
      object: '苏晚：联盟副秘书长',
      effectiveDate: '2026-03-20',
      basis: '联盟秘书处人事调整〔2026〕1 号',
      registeredAt: '2026-03-20T16:20:00.000',
      detail: '槽位让出，编制 1/1；由沈川接任',
    ),
    const ChangeRecord(
      id: 'c-6',
      type: ChangeType.primaryChange,
      object: '林澜：创始人',
      effectiveDate: '2026-03-15',
      basis: '《量潮公司章程》：治理职位优先',
      registeredAt: '2026-03-15T11:00:00.000',
      detail: '林澜：创始人、联盟代表、实训基地代表、联盟秘书长',
    ),
    const ChangeRecord(
      id: 'c-7',
      type: ChangeType.appoint,
      object: '林澜：联盟代表',
      effectiveDate: '2026-03-01',
      basis: '联盟第一次成员大会决议',
      registeredAt: '2026-03-01T15:00:00.000',
      detail: '任职编制 2/4',
    ),
    const ChangeRecord(
      id: 'c-8',
      type: ChangeType.positionSetup,
      object: '实训基地总裁',
      effectiveDate: '2026-01-10',
      basis: '实训基地机构设置方案',
      registeredAt: '2026-01-10T09:00:00.000',
      detail: '量潮实训基地 · 编制 1 名',
    ),
    const ChangeRecord(
      id: 'c-9',
      type: ChangeType.appoint,
      object: '林澜：创始人',
      effectiveDate: '2026-01-01',
      basis: '《量潮公司章程》第二章：设立登记',
      registeredAt: '2026-01-01T08:00:00.000',
      detail: '任职编制 1/1；自动指定为主要职位',
    ),
  ];

  return PositionStore(
    orgUnits: orgUnits,
    positions: positions,
    members: members,
    appointments: appointments,
    changeRecords: changeRecords,
  );
}
