import 'package:flutter_test/flutter_test.dart';
import 'package:pharmed_core/pharmed_core.dart';

void main() {
  group('Açık Raf yerleşimi', () {
    test('toolSize 4 açık raf olarak tanınır ve tüm rafı kaplar', () {
      expect(SerumTraySize.fromId(4), SerumTraySize.openShelf);
      expect(SerumTraySize.openShelf.areaSize, SerumShelfLayout.totalArea);
      expect(SerumTraySize.trayValues, isNot(contains(SerumTraySize.openShelf)));
    });

    test('açık rafa çevirme: avadanlıklar kalkar, kilit ve Al-Ver kapanır', () {
      const shelf = SerumShelfLayout(
        id: 1,
        orderNo: 1,
        lockType: SerumShelfLockType.locked,
        isTakeGiveEnabled: true,
        trays: [SerumTray(id: 10, size: SerumTraySize.small), SerumTray(id: 11, size: SerumTraySize.large)],
      );

      final open = shelf.toOpenShelf();
      expect(open.isOpenShelf, isTrue);
      expect(open.trays, const [SerumTray(size: SerumTraySize.openShelf)]);
      expect(open.isLocked, isFalse);
      expect(open.isTakeGiveEnabled, isFalse);
      expect(open.remainingArea, 0);
      expect(open.canAdd(SerumTraySize.small), isFalse);

      final back = open.toTrayShelf();
      expect(back.isOpenShelf, isFalse);
      expect(back.trays, isEmpty);
      expect(back.canAdd(SerumTraySize.large), isTrue);
    });

    test('açık rafta kilit adresi üretilmez (kilitli kayıt gelse bile)', () {
      const shelves = [
        SerumShelfLayout(
          id: 1,
          orderNo: 1,
          lockType: SerumShelfLockType.locked,
          trays: [SerumTray(id: 30, size: SerumTraySize.openShelf)],
        ),
      ];
      expect(SerumTrayAddress.resolve(shelves: shelves, cellId: 30), isNull);
    });
  });

  group('Açık Raf seçimi', () {
    final a = MedicineAssignment(id: 1, cabinDrawerDetailId: 30);
    final b = MedicineAssignment(id: 2, cabinDrawerDetailId: 30);
    final other = MedicineAssignment(id: 3, cabinDrawerDetailId: 31);

    test('aynı avadanlıktaki ilaçlar ayrı seçilir', () {
      final selection = AssignmentSelection()..add(a);

      expect(selection.contains(a), isTrue);
      expect(selection.contains(b), isFalse);
      expect(selection.serumCellIds, {30});
      expect(selection.selectedFrom([a, b, other]), [a]);

      selection.toggle(b);
      expect(selection.selectedFrom([a, b, other]), [a, b]);

      selection.remove(a);
      expect(selection.contains(a), isFalse);
      expect(selection.serumCellIds, {30}); // b hâlâ seçili

      selection.remove(b);
      expect(selection.serumCellIds, isEmpty);
      expect(selection.isEmpty, isTrue);
    });

    test('avadanlığın tüm atamaları', () {
      expect(AssignmentSelection.serumAssignments(30, [a, b, other]), [a, b]);
      expect(AssignmentSelection.serumAssignments(31, [a, b, other]), [other]);
    });
  });
}
