// [SWTEST-HW-CUBIC-001..] Kübik kart / göz adreslemesi — cihaz gerektirmeyen testler (#275).

import 'package:flutter_test/flutter_test.dart';
import 'package:pharmed_core/pharmed_core.dart';

DrawerUnit _unit(int card, int lid) => DrawerUnit(id: card * 10 + lid, compartmentNo: card, orderNo: lid);

List<DrawerUnit> _cubic(int cards, {int lids = 4}) => [
  for (var c = 1; c <= cards; c++)
    for (var l = 1; l <= lids; l++) _unit(c, l),
];

void main() {
  group('CommandBuilder.buildCubicCommand', () {
    test('a = sıra kartı, tt = göz; checksum Z ile', () {
      // Sahada eski test uygulamasının gönderdiği çerçeveler.
      expect(CommandBuilder.buildCubicCommand(action: DeviceAction.ping, port: 1, row: 1), ':ZM1019;');
      expect(CommandBuilder.buildCubicCommand(action: DeviceAction.ping, port: 5, row: 1), ':ZM5013;');
      expect(CommandBuilder.buildCubicCommand(action: DeviceAction.open, port: 5, row: 3), ':ZO5037;');
      expect(CommandBuilder.buildCubicCommand(action: DeviceAction.status, port: 4, row: 1), ':ZS4018;');
    });

    test('5. kart artık adreslenebilir, aralık dışı reddedilir', () {
      expect(() => CommandBuilder.buildCubicCommand(action: DeviceAction.open, port: 5, row: 4), returnsNormally);
      expect(() => CommandBuilder.buildCubicCommand(action: DeviceAction.open, port: 0, row: 1), throwsArgumentError);
      expect(() => CommandBuilder.buildCubicCommand(action: DeviceAction.open, port: 10, row: 1), throwsArgumentError);
      expect(() => CommandBuilder.buildCubicCommand(action: DeviceAction.open, port: 1, row: 100), throwsArgumentError);
    });
  });

  group('cubicCardForColumn (20 gözlüde 4 ↔ 5 çapraz)', () {
    test('20 gözlü kübik', () {
      expect([for (var c = 1; c <= 5; c++) cubicCardForColumn(c, compartmentCount: 20)], [1, 2, 3, 5, 4]);
    });

    test('16 gözlü ve tanımsız kübik değişmez', () {
      expect([for (var c = 1; c <= 4; c++) cubicCardForColumn(c, compartmentCount: 16)], [1, 2, 3, 4]);
      expect(cubicCardForColumn(4, compartmentCount: null), 4);
    });
  });

  group('kubikColumnCount', () {
    test('kayıtlı gözlerde en büyük compartmentNo', () {
      expect(kubikColumnCount(_cubic(4)), 4);
      expect(kubikColumnCount(_cubic(5)), 5);
    });

    test('orderNo olmayan (taranmış, kaydedilmemiş) gözlerde göz sayısından', () {
      expect(kubikColumnCount(List.generate(16, (i) => DrawerUnit(id: null, compartmentNo: i + 1))), 4);
      expect(kubikColumnCount(List.generate(20, (i) => DrawerUnit(id: null, compartmentNo: i + 1))), 5);
      expect(kubikColumnCount(const []), 4);
    });

    test('kubikColumnCountFor', () {
      expect(kubikColumnCountFor(16), 4);
      expect(kubikColumnCountFor(20), 5);
      expect(kubikColumnCountFor(8), 4);
    });
  });

  group('kubikVisualOrderIndexes (sütun = kart, satır = göz alttan üste)', () {
    test('20 gözlü: sol en alt = kart 1 · göz 1, sağ en üst = kart 5 · göz 4', () {
      final units = _cubic(5);
      final visual = kubikUnitsInVisualOrder(units);
      expect(visual.length, 20);
      // İlk satır (en üst) göz 4: kart 1…5
      expect([for (final u in visual.take(5)) (u.compartmentNo, u.orderNo)], [(1, 4), (2, 4), (3, 4), (4, 4), (5, 4)]);
      // Son satır (en alt) göz 1
      expect([for (final u in visual.skip(15)) (u.compartmentNo, u.orderNo)], [(1, 1), (2, 1), (3, 1), (4, 1), (5, 1)]);
    });

    test('16 gözlü eski davranışla aynı (4 sütun)', () {
      final units = _cubic(4);
      expect(kubikUnitsInVisualOrder(units).map((u) => u.id).toList(), kubikUnitsInVisualOrder(units, columnCount: 4).map((u) => u.id).toList());
    });
  });
}
