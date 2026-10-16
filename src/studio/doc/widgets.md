# 通用组件设计（widgets/）

对应 `index.md` 架构分解中的 `widgets/` 层。组件只依赖 `models/`（表单组件额外接收普通数据列表），
页面私有组件留在 `screens/<page>/` 子目录。提升规则：两个以上页面复用才进入本层。

## navigation/

| 组件 | 属性 | 行为 | 使用页面 |
|---|---|---|---|
| `AppShell` | `pages: List<Widget>` | 四页导航：总览/职位/成员/登记；宽屏 `NavigationRail`（≥720px），窄屏 `NavigationBar` | 全部页面（由 `main.dart` 装配） |

## data/

| 组件 | 属性 | 行为 | 使用页面 |
|---|---|---|---|
| `StatusBadge` | `tone`（normal/warning/frozen/primary）、`label` | 圆角胶囊徽章：中性/警示/冻结/主要职位四种色调 | 总览、职位页与详情、成员详情、登记页 |
| `PowerChip` | `power`（决策/执行/仲裁） | 描边标签，按权能着色（靛蓝/青/深紫） | 职位页与详情、成员详情 |

`BadgeTone` 枚举语义：`normal` 中性事实、`warning` 需要处理（空缺/超编/缺主要职位/免任）、
`frozen` 冻结、`primary` 主要职位。

## common/

| 组件 | 属性 | 行为 | 使用页面 |
|---|---|---|---|
| `EmptyState` | `icon`、`title`、`actionLabel?`、`onAction?` | 居中图标 + 引导文案 + 可选操作按钮 | 总览、职位页与详情、成员页与详情、登记页 |

## forms/

表单组件承载「变更即登记」的统一入口：生效日期 + 变更依据。

| 组件 | 属性 | 行为 |
|---|---|---|
| `ChangeDialog` | `title`、`object?`、`confirmLabel?`、`trailing?` | 通用登记对话框；缺依据时行内报错不放行；`trailing` 由调用方插入对象选择等自定义字段；返回 `ChangeDraft(effectiveDate, basis)` |
| `EffectiveDateField` | `date`、`onChanged` | 生效日期选择（`showDatePicker`，默认今天，格式化 `YYYY-MM-DD`） |
| `AppointDialog` | `members`、`positions`、`presetMemberId?`、`presetPositionId?` | 登记任职：对象选择（可预设单侧）+ 汇报对象 + 生效日期 + 依据；冻结职位禁用提交；返回 `AppointDraft` |
| `formatDate(DateTime)` | — | 日期 → `YYYY-MM-DD` 工具函数 |

**边界说明**：`AppointDialog` 与 `ChangeDialog` 只依赖 `models/`——成员/职位列表由页面从 store 取出后传入，
组件不感知事实源；收集到的 `AppointDraft` / `ChangeDraft` 交回页面调用 store 登记方法。

## 页面私有组件（不提升）

| 组件 | 所属页面 | 用途 |
|---|---|---|
| `_PositionTile`、`_OrgUnitSection`、`PositionSetupDialog`、`PositionDraft` | 职位页 | 分组列表与新建职位对话框 |
| `PositionDetailScreen` | 职位页 | 职位详情与登记入口 |
| `_AppointmentCard`、`MemberDetailScreen` | 成员页 | 任职卡片与成员详情 |
| `_StatTile`、`_AlertTile` | 总览 | 聚合卡与缺口提示 |
