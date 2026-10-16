# 数据模型设计（models/）

对应 `index.md` 架构分解中的 `models/` 层。字段、规则、示例数据逐项定义，是实现的直接依据。

## 通用约定

- **不可变纯数据**：所有模型为 `final` 字段的不可变对象，零依赖（不 import flutter）
- **标识**：`id` 全局唯一；跨模型引用一律用 `id`，不用名称
- **时间**：日期用 `YYYY-MM-DD` 字符串，登记时间用 ISO 8601；文本形式便于将来的数据层做 git diff
- **写操作**：模型不提供修改方法；一切变更经 `PositionStore` 的登记方法整体替换/追加
- **推导不落库**：占用数、空缺、清单排序等由 `PositionStore` 从任职事实推导，模型不存冗余字段

## 机构（models/org_unit.dart）

### OrgUnit — 机构

| 字段 | 类型 | 说明 |
|---|---|---|
| `id` | String | 机构标识（如 `ou-alliance`） |
| `name` | String | 机构名称（量潮创新联盟 / 量潮实训基地 / 量潮公司） |
| `parentId` | String? | 上级机构（null = 顶级） |

**规则**：职位归属的唯一权威源——职位页按机构分组展示，归属不清时以此为准。

## 职位（models/position.dart）

### Position — 职位（槽位）

| 字段 | 类型 | 说明 |
|---|---|---|
| `id` | String | 职位标识（如 `p-campus-president`） |
| `orgUnitId` | String | 归属机构 |
| `name` | String | 职位名称 |
| `responsibilities` | String | 职责边界：管什么、对什么负责 |
| `headcount` | int | 编制数（默认 1） |
| `category` | enum | `governance` 治理 / `operations` 经营 |
| `powers` | List\<Power\> | 权能组合（决策/执行/仲裁，可多选） |
| `status` | enum | `active` 启用 / `frozen` 冻结 |

**枚举**：

- `Power`：`decision` 决策（决定做什么）、`execution` 执行（负责做成）、`arbitration` 仲裁（裁决争议）；
- `PositionCategory`：手册「治理优先」规则限定在公司体系——创始人、合伙人、股东代表、公司代表登记为 `governance`，
  联盟与实训基地的议会代表、行政与司法职务登记为 `operations`；
- `PositionStatus`：`frozen` 后不再新任职（`appoint` 拦截 + 详情页入口置灰），已有任职不受影响。

**规则**：

- 槽位先于人头——职位说明书只描述槽位本身，不写现任职者；
- 空缺与超编为**派生状态**：`filled == 0` 空缺、`filled > headcount` 超编，不设字段；
- `isFrozen` 是唯一的状态便捷访问器。

## 成员与任职（models/member.dart、models/appointment.dart）

### Member — 成员

| 字段 | 类型 | 说明 |
|---|---|---|
| `id` | String | 成员标识 |
| `name` | String | 姓名 |

### Appointment — 任职

| 字段 | 类型 | 说明 |
|---|---|---|
| `id` | String | 任职标识 |
| `memberId` | String | 任职成员 |
| `positionId` | String | 所任职位 |
| `effectiveDate` | String | 生效日期（YYYY-MM-DD） |
| `basis` | String | 变更依据（决议、章程或通知） |
| `primary` | bool | 是否主要职位 |
| `reportsToId` | String? | 汇报对象（按职位登记，可为 null） |
| `active` | bool | 免任后为 false，历史保留 |

**规则**：

- 兼任 = 同 `memberId` 多条 `active` 记录；
- **一人一主职**：同一 `memberId` 的在任记录中至多一条 `primary = true`，由 `_applyPrimary` 统一维护；
- **主要职位列于首位**：排序不改存储顺序，由 `appointmentsOfMemberOrdered` 在读路径重排；
- **兼任边界显式**：`reportsToId` 属于单条任职，不挂在成员上；
- 免任不删除记录（`active = false`），任职历史可追溯。

## 变更登记（models/change_record.dart）

### ChangeRecord — 变更登记

| 字段 | 类型 | 说明 |
|---|---|---|
| `id` | String | 登记标识 |
| `type` | enum | `positionSetup` 职位设立 / `positionChange` 职位变更 / `appoint` 新任 / `dismiss` 免任 / `primaryChange` 主要职位变更 |
| `object` | String | 变更对象（职位名，或「成员：职位」） |
| `effectiveDate` | String | 生效日期 |
| `basis` | String | 变更依据 |
| `registeredAt` | String | 登记时间（ISO 8601，运行时写入） |
| `detail` | String? | 补充说明（编制占用、自动指定、接续关系） |

**规则**：变更即登记——每个登记方法在写事实的同时 `insert(0, ...)` 一条记录，
新记录在前；生效日期与依据缺一不可（对话框校验，缺依据不能提交）。

## 示例数据（lib/sample_data.dart）

- 11 个职位：公司 2（创始人、合伙人）+ 联盟 5（联盟代表、联盟秘书长、联盟副秘书长、联盟秘书、联盟司库）+ 基地 4（实训基地总裁、实训基地副总裁、实训基地代表、仲裁官）；
- 4 名成员：林澜（4 职）、沈川（5 职）、苏晚（4 在任 + 1 已免任）、周牧（1 职）；
- 主要职位：林澜=创始人（治理优先）、沈川=实训基地总裁、苏晚=实训基地副总裁、周牧=联盟秘书（量潮惯例以标识性职务指代）；
- 派生状态：空缺=合伙人、联盟司库；冻结=联盟司库；
- 9 条变更登记（新任 5、免任 1、主要职位变更 1、职位设立 1、职位变更 1），新记录在前。
