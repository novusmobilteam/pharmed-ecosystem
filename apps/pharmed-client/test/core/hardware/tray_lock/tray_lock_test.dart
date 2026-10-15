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
}
