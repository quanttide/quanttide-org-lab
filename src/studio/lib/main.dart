import 'package:flutter/material.dart';

import 'screens/members/members_screen.dart';
import 'screens/overview/overview_screen.dart';
import 'screens/positions/positions_screen.dart';
import 'screens/records/records_screen.dart';
import 'sample_data.dart';
import 'state/position_store.dart';
import 'state/position_store_scope.dart';
import 'widgets/navigation/app_shell.dart';

void main() {
  runApp(const QuanttideOrgLabStudioApp());
}

class QuanttideOrgLabStudioApp extends StatefulWidget {
  const QuanttideOrgLabStudioApp({super.key, this.store});

  /// 传入自定义事实源（测试用）；缺省时用内存示例数据。
  final PositionStore? store;

  @override
  State<QuanttideOrgLabStudioApp> createState() =>
      _QuanttideOrgLabStudioAppState();
}

class _QuanttideOrgLabStudioAppState extends State<QuanttideOrgLabStudioApp> {
  late final PositionStore _store;
  late final bool _ownsStore;

  @override
  void initState() {
    super.initState();
    _ownsStore = widget.store == null;
    _store = widget.store ?? buildSampleStore();
  }

  @override
  void dispose() {
    if (_ownsStore) _store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PositionStoreScope(
      store: _store,
      child: MaterialApp(
        title: '量潮职位',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        home: const AppShell(
          pages: [
            OverviewScreen(),
            PositionsScreen(),
            MembersScreen(),
            RecordsScreen(),
          ],
        ),
      ),
    );
  }
}
