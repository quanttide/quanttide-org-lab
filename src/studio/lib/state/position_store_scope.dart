import 'package:flutter/widgets.dart';

import 'position_store.dart';

/// 内存事实源的作用域：包装在 `MaterialApp` 之上，
/// 登记后 `notifyListeners` 会重建所有依赖页面（读路径单向依赖）。
class PositionStoreScope extends InheritedNotifier<PositionStore> {
  const PositionStoreScope({
    super.key,
    required PositionStore store,
    required super.child,
  }) : super(notifier: store);

  static PositionStore of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<PositionStoreScope>()!
      .notifier!;
}
