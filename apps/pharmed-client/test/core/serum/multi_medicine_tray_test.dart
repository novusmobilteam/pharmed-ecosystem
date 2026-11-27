import 'package:flutter_test/flutter_test.dart';
import 'package:pharmed_core/pharmed_core.dart';

// [#295] Kilitsiz raftaki avadanlıklara çoklu ilaç ataması.
void main() {
  const locked = SerumShelfLayout(
    id: 1,
    orderNo: 1,
    lockType: SerumShelfLockType.locked,
    trays: [SerumTray(id: 10, size: SerumTraySize.small), SerumTray(id: 11, size: SerumTraySize.medium)],
  );
  const unlocked = SerumShelfLayout(
    id: 2,
    orderNo: 2,
    trays: [SerumTray(id: 20, size: SerumTraySize.large), SerumTray(id: 21, size: SerumTraySize.small)],
  );
  const openShelf = SerumShelfLayout(id: 3, orderNo: 3, trays: [SerumTray(id: 30, size: SerumTraySize.openShelf)]);

  group('allowsMultipleMedicines', () {
    test('kilitli rafta tek ilaç, kilitsiz rafta ve Açık Raf\'ta çoklu', () {
      expect(locked.allowsMultipleMedicines, isFalse);
      expect(unlocked.allowsMultipleMedicines, isTrue);
      expect(openShelf.allowsMultipleMedicines, isTrue);
    });
  });

  group('serumTrayLocation', () {
    final group = DrawerGroup(
      slot: const DrawerSlot(
        id: 5,
        drawerConfig: DrawerConfig(drawerTypeId: 14, numberOfSteps: 1, deviceTypeNo: 250),
      ),
      units: const [],
      serumShelves: const [locked, unlocked, openShelf],
    );

    test('avadanlığın rafı ve sağdan sırası bulunur', () {
      final location = group.serumTrayLocation(21);
      expect(location?.shelf.id, 2);
      expect(location?.stepNo, 2);
      expect(location?.tray.size, SerumTraySize.small);
      expect(group.serumTrayLocation(99), isNull);
    });

    test('çekmece listesi üzerinden çoklu ilaç kuralı', () {
      final groups = [group];
      expect(groups.allowsMultipleMedicines(10), isFalse);
      expect(groups.allowsMultipleMedicines(20), isTrue);
      expect(groups.allowsMultipleMedicines(30), isTrue);
      expect(groups.allowsMultipleMedicines(99), isFalse);
    });
  });
}
