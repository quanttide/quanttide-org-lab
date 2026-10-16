import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quanttide_org_lab_studio/main.dart';
import 'package:quanttide_org_lab_studio/sample_data.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      QuanttideOrgLabStudioApp(store: buildSampleStore()),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('总览聚合空缺与最近登记', (tester) async {
    await pumpApp(tester);

    expect(find.text('量潮职位'), findsOneWidget);
    expect(find.text('职位'), findsWidgets);
    expect(find.textContaining('职位空缺：合伙人'), findsOneWidget);
    expect(find.text('最近登记'), findsOneWidget);
    expect(find.text('周牧：联盟秘书'), findsOneWidget);
  });

  testWidgets('职位页按机构分组并可进入详情', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('职位').first);
    await tester.pumpAndSettle();

    expect(find.text('职位档案'), findsOneWidget);
    expect(find.textContaining('量潮创新联盟 · 5 个职位'), findsOneWidget);
    expect(find.textContaining('量潮实训基地 · 4 个职位'), findsOneWidget);
    expect(find.text('冻结'), findsWidgets);

    final target = find.text('实训基地总裁');
    await tester.scrollUntilVisible(target, 300);
    await tester.pumpAndSettle();
    await tester.tap(target);
    await tester.pumpAndSettle();

    expect(find.text('职责边界'), findsOneWidget);
    expect(find.text('登记任职'), findsOneWidget);
    expect(find.text('沈川'), findsOneWidget);
    expect(find.text('主要职位'), findsOneWidget);
  });

  testWidgets('成员页按「成员：主要职位、职位」罗列', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('成员').first);
    await tester.pumpAndSettle();

    expect(find.text('林澜：创始人、联盟代表、实训基地代表、联盟秘书长'), findsOneWidget);
    expect(find.text('沈川：实训基地总裁、联盟代表、实训基地代表、联盟副秘书长、仲裁官'), findsOneWidget);
  });

  testWidgets('成员详情可登记主要职位变更（变更即登记）', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('成员').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('苏晚：实训基地副总裁、实训基地代表、联盟秘书、仲裁官'));
    await tester.pumpAndSettle();

    expect(find.text('职务清单（主要职位列于首位）'), findsOneWidget);
    expect(find.text('设为主要职位'), findsWidgets);

    // 将「联盟秘书」设为主要职位：需登记生效日期与变更依据。
    final cards = find.ancestor(
      of: find.text('联盟秘书'),
      matching: find.byType(Card),
    );
    final setPrimaryButton = find
        .descendant(of: cards, matching: find.text('设为主要职位'))
        .first;
    await tester.scrollUntilVisible(setPrimaryButton, 200);
    await tester.pumpAndSettle();
    await tester.tap(setPrimaryButton);
    await tester.pumpAndSettle();
    expect(find.text('设为主要职位'), findsWidgets); // 对话框标题

    await tester.enterText(find.byType(TextField), '测试：主要职位调整');
    await tester.tap(find.widgetWithText(FilledButton, '登记'));
    await tester.pumpAndSettle();

    // 滚回顶部核对清单（主要职位列于首位）。
    await tester.drag(find.byType(ListView).first, const Offset(0, 800));
    await tester.pumpAndSettle();
    expect(find.text('苏晚：联盟秘书、实训基地代表、实训基地副总裁、仲裁官'), findsOneWidget);
  });

  testWidgets('登记页展示变更流水', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('登记').first);
    await tester.pumpAndSettle();

    expect(find.text('变更登记'), findsOneWidget);
    expect(find.text('新任'), findsWidgets);
    expect(find.text('免任'), findsWidgets);
    final primaryChange = find.text('主要职位变更');
    await tester.scrollUntilVisible(primaryChange, 300);
    expect(primaryChange, findsWidgets);
  });
}
