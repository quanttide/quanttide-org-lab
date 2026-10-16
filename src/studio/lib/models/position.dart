/// 职权权能：决策权决定做什么，执行权负责做成，仲裁权裁决执行中发生的争议。
/// 三种权能可单独成职，也可打包组合（详见《职位》手册）。
enum Power { decision, execution, arbitration }

extension PowerLabel on Power {
  String get label => switch (this) {
    Power.decision => '决策',
    Power.execution => '执行',
    Power.arbitration => '仲裁',
  };
}

/// 职位类别：治理职位承载组织名分（创始人、合伙人、股东代表、公司代表等），
/// 经营职位承载管理职权。主要职位选定的「治理优先」规则按手册限定在公司体系下，
/// 联盟与实训基地的议会代表、行政与司法职务登记为经营序列，其主要职位由登记显式指定。
enum PositionCategory { governance, operations }

extension PositionCategoryLabel on PositionCategory {
  String get label => switch (this) {
    PositionCategory.governance => '治理',
    PositionCategory.operations => '经营',
  };
}

/// 职位状态：冻结后不再新任职；空缺为派生状态（无人占用），由任职事实推导。
enum PositionStatus { active, frozen }

/// 职位——组织分工的槽位：有名称、有归属、有职责边界。
/// 槽位先于人头：职位先于任职者存在，说明书只描述槽位本身，不写现任职者。
class Position {
  const Position({
    required this.id,
    required this.orgUnitId,
    required this.name,
    required this.responsibilities,
    this.headcount = 1,
    this.category = PositionCategory.operations,
    this.powers = const [Power.execution],
    this.status = PositionStatus.active,
  });

  final String id;

  /// 归属机构 id。
  final String orgUnitId;

  final String name;

  /// 职责边界：管什么、对什么负责。
  final String responsibilities;

  /// 编制数（占用情况由任职事实派生）。
  final int headcount;

  final PositionCategory category;

  /// 该职位承载的权能组合。
  final List<Power> powers;

  final PositionStatus status;

  bool get isFrozen => status == PositionStatus.frozen;
}
