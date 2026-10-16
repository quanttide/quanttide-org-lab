/// 机构——职位的归属单位（联盟、实训基地、公司等）。
class OrgUnit {
  const OrgUnit({required this.id, required this.name, this.parentId});

  final String id;
  final String name;

  /// 上级机构（null = 顶级）。
  final String? parentId;
}
