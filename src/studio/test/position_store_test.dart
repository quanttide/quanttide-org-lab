import 'package:flutter_test/flutter_test.dart';
import 'package:quanttide_org_lab_studio/models/member.dart';
import 'package:quanttide_org_lab_studio/models/org_unit.dart';
import 'package:quanttide_org_lab_studio/models/position.dart';
import 'package:quanttide_org_lab_studio/sample_data.dart';
import 'package:quanttide_org_lab_studio/state/position_store.dart';

void main() {
  group('职位推导', () {
    test('空缺与冻结由任职事实派生', () {
      final store = buildSampleStore();

      expect(
        store.vacantPositions.map((p) => p.name),
        containsAll(['合伙人', '联盟司库']),
      );
      expect(store.frozenPositions.single.name, '联盟司库');
      expect(store.filledOf('p-campus-rep'), 3);
      expect(store.isOverstaffed(store.positionById('p-campus-rep')), isFalse);
    });

    test('「成员：职位、职位」主要职位列于首位', () {
      final store = buildSampleStore();

      expect(store.titleLineOf('m-lin'), '林澜：创始人、联盟代表、实训基地代表、联盟秘书长');
      expect(store.titleLineOf('m-shen'), '沈川：实训基地总裁、联盟代表、实训基地代表、联盟副秘书长、仲裁官');
    });

    test('一人一主职：同一成员至多一条主要职位', () {
      final store = buildSampleStore();

      for (final member in store.members) {
        final primaryCount = store
            .activeAppointmentsOfMember(member.id)
            .where((a) => a.primary)
            .length;
        expect(primaryCount, 1, reason: store.titleLineOf(member.id));
      }
      expect(store.membersWithoutPrimary, isEmpty);
    });
  });

  group('变更即登记', () {
    test('治理优先：公司体系治理职位为首要职位建议', () {
      final store = buildSampleStore();

      expect(store.suggestPrimaryAppointmentId('m-lin'), 'ap-1');
      expect(store.suggestPrimaryAppointmentId('m-zhou'), 'ap-15');
    });

    test('首次任职自动指定主要职位，不留悬空', () {
      final store = PositionStore(
        orgUnits: const [OrgUnit(id: 'ou', name: '机构')],
        positions: const [
          Position(
            id: 'p',
            orgUnitId: 'ou',
            name: '理事',
            responsibilities: '议事决策',
          ),
        ],
        members: const [Member(id: 'm', name: '测试成员')],
        appointments: const [],
        changeRecords: const [],
      );

      store.appoint(
        memberId: 'm',
        positionId: 'p',
        effectiveDate: '2026-10-16',
        basis: '测试决议',
      );

      expect(store.primaryAppointmentOf('m'), isNotNull);
      expect(store.changeRecords.single.detail, contains('自动指定为主要职位'));
    });

    test('免任主要职位时按序自动接续并登记', () {
      final store = buildSampleStore();

      store.dismiss(
        appointmentId: 'ap-1',
        effectiveDate: '2026-10-16',
        basis: '测试：卸任登记',
      );

      expect(store.primaryAppointmentOf('m-lin')!.positionId, 'p-alliance-rep');
      final record = store.changeRecords.first;
      expect(record.type.name, 'primaryChange');
      expect(record.basis, contains('自动接续'));
      expect(store.membersWithoutPrimary, isEmpty);
    });

    test('变更登记载明生效日期与变更依据', () {
      final store = buildSampleStore();
      final before = store.changeRecords.length;

      store.setPrimary(
        appointmentId: 'ap-12',
        effectiveDate: '2026-10-16',
        basis: '测试：主要职位调整',
      );

      expect(store.changeRecords.length, before + 1);
      final record = store.changeRecords.first;
      expect(record.effectiveDate, '2026-10-16');
      expect(record.basis, '测试：主要职位调整');
      expect(store.primaryAppointmentOf('m-su')!.positionId, 'p-alliance-sec');
      expect(
        store.activeAppointmentsOfMember('m-su').where((a) => a.primary).length,
        1,
      );
    });
  });

  group('槽位规则', () {
    test('冻结职位不再新任职', () {
      final store = buildSampleStore();

      expect(
        () => store.appoint(
          memberId: 'm-zhou',
          positionId: 'p-alliance-treasurer',
          effectiveDate: '2026-10-16',
          basis: '测试决议',
        ),
        throwsStateError,
      );
    });

    test('冻结解冻产生职位变更登记', () {
      final store = buildSampleStore();
      final before = store.changeRecords.length;

      store.toggleFreeze(
        positionId: 'p-alliance-treasurer',
        effectiveDate: '2026-10-16',
        basis: '测试：恢复编制',
      );

      expect(store.positionById('p-alliance-treasurer').isFrozen, isFalse);
      expect(store.changeRecords.length, before + 1);
      expect(store.changeRecords.first.detail, contains('解冻'));
    });
  });
}
