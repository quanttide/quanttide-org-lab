# quanttide_org_studio

量潮职位管理系统——按《职位》手册实现的职位记录工作台原型。

- **领域口径**：`docs/tutorial/role/title.md`（职位/任职/主要职位的定义与工作习惯）
- **设计文档**：[doc/index.md](doc/index.md)（定位、架构分解、数据规则），另有 [models](doc/models.md) / [screens](doc/screens.md) / [widgets](doc/widgets.md)

## 运行

```bash
flutter pub get
flutter run            # 本地运行
flutter test           # 规则单测 + 页面测试
flutter analyze        # 静态检查
flutter build web      # Web 构建
```

## 分层

`models`（不可变纯数据）→ `state`（内存事实源与登记操作）→ `screens`（页面）→ `widgets`（通用组件），
单向依赖，页面内容全部由登记事实推导（事实源唯一）。
