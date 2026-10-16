import 'package:flutter/material.dart';

/// 应用导航骨架：宽屏左侧导航栏，窄屏底部导航栏。
class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.pages});

  final List<Widget> pages;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  static const _labels = ['总览', '职位', '成员', '登记'];

  static const _icons = [
    Icons.dashboard_outlined,
    Icons.badge_outlined,
    Icons.people_outline,
    Icons.app_registration_outlined,
  ];

  static const _selectedIcons = [
    Icons.dashboard,
    Icons.badge,
    Icons.people,
    Icons.app_registration,
  ];

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 720;
    if (wide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              labelType: NavigationRailLabelType.all,
              destinations: [
                for (var i = 0; i < _labels.length; i++)
                  NavigationRailDestination(
                    icon: Icon(_icons[i]),
                    selectedIcon: Icon(_selectedIcons[i]),
                    label: Text(_labels[i]),
                  ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: widget.pages[_index]),
          ],
        ),
      );
    }
    return Scaffold(
      body: widget.pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          for (var i = 0; i < _labels.length; i++)
            NavigationDestination(
              icon: Icon(_icons[i]),
              selectedIcon: Icon(_selectedIcons[i]),
              label: _labels[i],
            ),
        ],
      ),
    );
  }
}
