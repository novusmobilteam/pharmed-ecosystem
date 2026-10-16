// [SWTEST-HW-TRAY-001..] Serum avadanlık kilit kartı — cihaz gerektirmeyen testler.

import 'package:flutter_test/flutter_test.dart';
import 'package:pharmed_client/core/services/tray_lock/mock_tray_lock_service.dart';
import 'package:pharmed_core/pharmed_core.dart';

TrayLockFailure? _failureOf(TrayLockResponse r) => r is TrayLockErrorResponse ? r.failure : null;

Future<TrayLockFailure?> _thrown(Future<void> Function() f) async {
  try {
    await f();
    return null;
  } on TrayLockException catch (e) {
    return e.failure;
  }
}

void main() {
  group('TrayLockProtocol.build', () {
    test('port komutu', () {
      expect(TrayLockProtocol.build(deviceId: 1, action: TrayLockAction.open, port: 3), '<i01:3o>');
      expect(TrayLockProtocol.build(deviceId: 12, action: TrayLockAction.keypadValue, port: 8), '<i12:8t>');
    });

    test('kart geneli komutlarda port 0 yazılır', () {
      expect(TrayLockProtocol.build(deviceId: 1, action: TrayLockAction.lockAll), '<i01:0k>');
      expect(TrayLockProtocol.build(deviceId: 1, action: TrayLockAction.unlockAll, port: 5), '<i01:0x>');
    });

    test('geçersiz parametre', () {
      expect(() => TrayLockProtocol.build(deviceId: 0, action: TrayLockAction.status, port: 1), throwsArgumentError);
      expect(() => TrayLockProtocol.build(deviceId: 100, action: TrayLockAction.status, port: 1), throwsArgumentError);
      expect(() => TrayLockProtocol.build(deviceId: 1, action: TrayLockAction.open, port: 9), throwsArgumentError);
      expect(() => TrayLockProtocol.build(deviceId: 1, action: TrayLockAction.open), throwsArgumentError);
    });
  });

  group('TrayLockProtocol.parse', () {
    test('başarı ve durumlar', () {
      expect(TrayLockProtocol.parse(r'/okkk\'), isA<TrayLockOk>());
      expect((TrayLockProtocol.parse(r'/s:01\') as TrayLockStatusResponse).status, TrayLockStatus.unlocked);
      expect((TrayLockProtocol.parse(r'/s:02\') as TrayLockStatusResponse).status, TrayLockStatus.pulled);
      expect((TrayLockProtocol.parse(r'/s:03\') as TrayLockStatusResponse).status, TrayLockStatus.idle);
      expect((TrayLockProtocol.parse(r'/t:07\') as TrayLockKeypadResponse).value, 7);
    });

    test('hata kodları', () {
      expect(_failureOf(TrayLockProtocol.parse(r'/noo1\')), TrayLockFailure.invalidDeviceId);
      expect(_failureOf(TrayLockProtocol.parse(r'/noo2\')), TrayLockFailure.trayOpen);
      expect(_failureOf(TrayLockProtocol.parse(r'/noo3\')), TrayLockFailure.invalidPort);
      expect(_failureOf(TrayLockProtocol.parse(r'/noo4\')), TrayLockFailure.busy);
      expect(_failureOf(TrayLockProtocol.parse(r'/noo5\')), TrayLockFailure.alreadyPulled);
      expect(_failureOf(TrayLockProtocol.parse(r'/noo6\')), TrayLockFailure.unknownCommand);
    });

    test('yanıt yok / tanınmayan / gürültülü', () {
      expect(_failureOf(TrayLockProtocol.parse(null)), TrayLockFailure.noResponse);
      expect(_failureOf(TrayLockProtocol.parse('  ')), TrayLockFailure.noResponse);
      expect(_failureOf(TrayLockProtocol.parse('+ok-')), TrayLockFailure.protocolError);
      expect(_failureOf(TrayLockProtocol.parse(r'/nooo\')), TrayLockFailure.protocolError);
      expect(TrayLockProtocol.parse('\x00' r'/okkk\' '\r\n'), isA<TrayLockOk>());
    });
  });

  group('MockTrayLockService durum makinesi', () {
    late MockTrayLockService svc;
    setUp(() => svc = MockTrayLockService(autoSimulate: false, commandDelay: Duration.zero));

    test('aç → çek → geri it', () async {
      await svc.lockAll(deviceId: 1);
      await svc.unlock(deviceId: 1, port: 3);
      expect(await svc.getStatus(deviceId: 1, port: 3), TrayLockStatus.unlocked);
      expect(await svc.getStatus(deviceId: 1, port: 4), TrayLockStatus.idle);

      svc.simulatePull(deviceId: 1);
      expect(await svc.getStatus(deviceId: 1, port: 3), TrayLockStatus.pulled);

      svc.simulateReturn(deviceId: 1);
      expect(await svc.getStatus(deviceId: 1, port: 3), TrayLockStatus.idle);
    });

    test('açıkken başka port → busy', () async {
      await svc.unlock(deviceId: 1, port: 3);
      expect(await _thrown(() => svc.unlock(deviceId: 1, port: 5)), TrayLockFailure.busy);
    });

    test('çekiliyken k / x / c reddedilir', () async {
      await svc.unlock(deviceId: 1, port: 3);
      svc.simulatePull(deviceId: 1);
      expect(await _thrown(() => svc.lockAll(deviceId: 1)), TrayLockFailure.trayOpen);
      expect(await _thrown(() => svc.unlockAll(deviceId: 1)), TrayLockFailure.trayOpen);
      expect(await _thrown(() => svc.cancelUnlock(deviceId: 1, port: 3)), TrayLockFailure.alreadyPulled);
    });

    test('çekilmeden iptal → idle', () async {
      await svc.unlock(deviceId: 1, port: 3);
      await svc.cancelUnlock(deviceId: 1, port: 3);
      expect(await svc.getStatus(deviceId: 1, port: 3), TrayLockStatus.idle);
    });

    test('kartlar birbirinden bağımsız', () async {
      await svc.unlock(deviceId: 1, port: 3);
      await svc.unlock(deviceId: 2, port: 3);
      expect(await svc.getStatus(deviceId: 2, port: 3), TrayLockStatus.unlocked);
    });

    test('tuş değeri', () async {
      svc.simulateKeypad(deviceId: 1, port: 2, value: 12);
      expect(await svc.getKeypadValue(deviceId: 1, port: 2), 12);
      expect(await svc.getKeypadValue(deviceId: 1, port: 3), 0);
    });
  });

  group('SerumTrayAddress.resolve', () {
    // Raf 2 kilitli: sağdan sola [büyük(4), orta(2), küçük(1)] → port 1, 5, 7.
    final shelves = [
      const SerumShelfLayout(orderNo: 1, trays: [SerumTray(id: 10, size: SerumTraySize.small)]),
      const SerumShelfLayout(
        orderNo: 2,
        lockType: SerumShelfLockType.locked,
        trays: [
          SerumTray(id: 20, size: SerumTraySize.large),
          SerumTray(id: 21, size: SerumTraySize.medium),
          SerumTray(id: 22, size: SerumTraySize.small),
        ],
      ),
      const SerumShelfLayout(orderNo: 3),
    ];

    test('port = en sağdaki alan, cihaz = raf sırası', () {
      expect(SerumTrayAddress.resolve(shelves: shelves, cellId: 20), const SerumTrayAddress(deviceId: 2, port: 1, cellId: 20));
      expect(SerumTrayAddress.resolve(shelves: shelves, cellId: 21)?.port, 5);
      expect(SerumTrayAddress.resolve(shelves: shelves, cellId: 22)?.port, 7);
    });

    test('kilitsiz raf ya da bilinmeyen avadanlık → null', () {
      expect(SerumTrayAddress.resolve(shelves: shelves, cellId: 10), isNull);
      expect(SerumTrayAddress.resolve(shelves: shelves, cellId: 999), isNull);
    });
  });

  group('OpenSerumTrayUseCase', () {
    const address = SerumTrayAddress(deviceId: 1, port: 3, cellId: 1);

    test('tümünü kilitler, hedefi açar', () async {
      final svc = MockTrayLockService(autoSimulate: false, commandDelay: Duration.zero);
      await OpenSerumTrayUseCase(svc)(address: address);
      expect(await svc.getStatus(deviceId: 1, port: 3), TrayLockStatus.unlocked);
    });

    test('rafta başka avadanlık çekiliyse trayBusy', () async {
      final svc = MockTrayLockService(autoSimulate: false, commandDelay: Duration.zero);
      await svc.unlock(deviceId: 1, port: 5);
      svc.simulatePull(deviceId: 1);

      MasterDrawerFailure? failure;
      try {
        await OpenSerumTrayUseCase(svc)(address: address);
      } on MasterDrawerException catch (e) {
        failure = e.failure;
      }
      expect(failure, MasterDrawerFailure.trayBusy);
    });
  });

  group('Serum kuyruğu', () {
    const slot = DrawerSlot(
      id: 346,
      orderNumber: 4,
      drawerConfig: DrawerConfig(drawerTypeId: 1, numberOfSteps: 1, deviceTypeNo: 250),
    );
    const shelf1 = DrawerUnit(id: 1701, orderNo: 1, drawerSlot: slot);
    const shelf2 = DrawerUnit(id: 1702, orderNo: 2, drawerSlot: slot);
    final groups = [
      DrawerGroup(
        slot: slot,
        units: const [shelf1, shelf2],
        serumShelves: const [
          SerumShelfLayout(id: 1701, orderNo: 1, trays: [SerumTray(id: 10, size: SerumTraySize.small)]),
          SerumShelfLayout(
            id: 1702,
            orderNo: 2,
            lockType: SerumShelfLockType.locked,
            trays: [
              SerumTray(id: 20, size: SerumTraySize.large),
              SerumTray(id: 21, size: SerumTraySize.medium),
            ],
          ),
          SerumShelfLayout(orderNo: 3),
        ],
      ),
    ];

    MedicineAssignment trayAssignment(int cellId, DrawerUnit shelf, int stepNo) => MedicineAssignment(
      cabinDrawerId: shelf.id,
      cabinDrawerDetailId: cellId,
      drawerUnit: shelf,
      cabinDrawerDetail: [DrawerCell(id: cellId, stepNo: stepNo)],
    );

    final locked21 = trayAssignment(21, shelf2, 2);
    final locked20 = trayAssignment(20, shelf2, 1);
    final unlocked10 = trayAssignment(10, shelf1, 1);

    test('forAssignment yalnızca kilitli raftaki avadanlığı çözer', () {
      expect(SerumTrayAddress.forAssignment(locked21, groups), const SerumTrayAddress(deviceId: 2, port: 5, cellId: 21));
      expect(SerumTrayAddress.forAssignment(unlocked10, groups), isNull);
      expect(SerumTrayAddress.forAssignment(MedicineAssignment(cabinDrawerId: 1701), groups), isNull);
    });

    test('kilitli ve kilitsiz avadanlıklar tek job, raf ve avadanlık sırasıyla', () {
      final result = CabinOperationQueueBuilder.build(
        items: [locked21, unlocked10, locked20],
        assignmentOf: (a) => a,
        targetOf: (_, a) => CabinOperationTarget.fromAssignment(a, CabinOperationMode.refill),
        groups: groups,
      );

      expect(result.skipped, isEmpty);
      expect(result.jobs, hasLength(1));

      final job = result.jobs.single;
      expect(job.isSerumTrayJob, isTrue);
      expect(job.staysOpenAcrossTargets, isTrue);
      expect(job.targets.map((t) => t.assignment.cabinDrawerDetailId), [10, 20, 21]);
      expect(job.targets.map((t) => t.serumTray?.port), [null, 1, 5]);
    });

    test('seçim: serum avadanlığı raf değil avadanlık bazında', () {
      final normal = MedicineAssignment(cabinDrawerId: 1701);
      final all = [locked20, locked21, unlocked10, normal];
      final selection = AssignmentSelection()..add(locked20);

      expect(selection.contains(locked20), isTrue);
      expect(selection.contains(locked21), isFalse); // aynı raf, farklı avadanlık
      expect(selection.contains(normal), isFalse); // raf id'si normal göz sayılmaz
      expect(selection.selectedFrom(all), [locked20]);

      expect(AssignmentSelection.inGroup(groups.single, all).toSet(), {locked20, locked21, unlocked10});
      selection.toggleAll(AssignmentSelection.inGroup(groups.single, all));
      expect(selection.serumCellIds, {10, 20, 21});
      expect(selection.unitIds, isEmpty);
    });

    test('serum kapak adresi raftan bağımsız (raf no port sanılmaz)', () {
      const slotWithAddress = DrawerSlot(
        id: 346,
        address: '05',
        drawerConfig: DrawerConfig(drawerTypeId: 14, numberOfSteps: 1, deviceTypeNo: 250),
      );
      for (final shelfNo in [1, 2, 3]) {
        final address = calculateAddressFromAssignment(
          MedicineAssignment(
            drawerUnit: DrawerUnit(id: 1700 + shelfNo, compartmentNo: shelfNo, orderNo: shelfNo, drawerSlot: slotWithAddress),
          ),
        );
        expect(address.row, 5);
        expect(address.port, 1);
      }
    });

    test('avadanlık hedefi tek girişli, kayıt avadanlık göz kaydına gider', () {
      final target = CabinOperationTarget.fromAssignment(
        locked21,
        CabinOperationMode.refill,
      ).withCubicSecondary(5).withCubicMiad(DateTime.now().add(const Duration(days: 365)));

      expect(target.isKubik, isTrue);
      final rows = CabinOperationParamsMapper.cellRows(target);
      expect(rows, hasLength(1));
      expect(rows.single.detailId, 21);
      expect(rows.single.shelfNo, 2);
      expect(rows.single.compartmentNo, 2);
    });
  });

  group('Al-Ver doğrulaması', () {
    test('kart değeri sıfırlamaz — ilk okuma referans, dokunulmadan eşleşmez', () {
      var reading = const TrayKeypadReading(value: 3, baseline: 3, hasChanged: false);
      expect(reading.matches(3), isFalse);

      reading = reading.withValue(2);
      expect(reading.matches(3), isFalse);

      reading = reading.withValue(3);
      expect(reading.matches(3), isTrue);
    });

    test('beklenen adet yalnızca raf + ilaç açıkken ve alım/iadede', () {
      const slot = DrawerSlot(
        id: 346,
        drawerConfig: DrawerConfig(drawerTypeId: 14, numberOfSteps: 1, deviceTypeNo: 250),
      );
      const shelf = DrawerUnit(id: 1698, orderNo: 1, drawerSlot: slot);

      CabinOperationTarget targetFor({
        required bool drugFlag,
        required bool shelfFlag,
        CabinOperationMode mode = CabinOperationMode.intake,
      }) {
        final assignment = MedicineAssignment(
          cabinDrawerDetailId: 6836,
          drawerUnit: shelf,
          medicine: Drug(isTakeGiveButtonActive: drugFlag),
          cabinDrawerDetail: const [DrawerCell(id: 6836, stepNo: 2)],
        );
        return CabinOperationTarget.fromAssignment(assignment, mode)
            .withSerumTray(SerumTrayAddress(deviceId: 1, port: 2, cellId: 6836, isTakeGiveEnabled: shelfFlag))
            .withCubicSecondary(3);
      }

      expect(targetFor(drugFlag: true, shelfFlag: true).takeGiveExpectedQuantity, 3);
      expect(targetFor(drugFlag: true, shelfFlag: true, mode: CabinOperationMode.refund).takeGiveExpectedQuantity, 3);
      expect(targetFor(drugFlag: false, shelfFlag: true).takeGiveExpectedQuantity, isNull);
      expect(targetFor(drugFlag: true, shelfFlag: false).takeGiveExpectedQuantity, isNull);
      expect(
        targetFor(drugFlag: true, shelfFlag: true, mode: CabinOperationMode.refill).takeGiveExpectedQuantity,
        isNull,
      );
    });

    test('Al-Ver yalnızca kilitli rafta geçerli', () {
      const unlocked = SerumShelfLayout(orderNo: 1, isTakeGiveEnabled: true);
      const locked = SerumShelfLayout(orderNo: 1, lockType: SerumShelfLockType.locked, isTakeGiveEnabled: true);
      expect(unlocked.isTakeGiveVerified, isFalse);
      expect(locked.isTakeGiveVerified, isTrue);
    });
  });
}
