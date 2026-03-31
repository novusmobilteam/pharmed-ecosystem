// pharmed_core/src/cabin/entity/drawer_cell.dart

import 'package:pharmed_core/pharmed_core.dart';

/// ÇEKMECE GÖZÜ / CEBİ ENTITY'Sİ
/// ------------------------------
/// Bir çekmece ünitesinin (DrawerUnit) içindeki en küçük depolama birimidir.
/// İlaçlar veya malzemeler doğrudan bu gözlere tanımlanır.
///
/// - Birim doz çekmecelerde: motorun hangi adımda (stepNo) duracağını belirler
/// - Kübik çekmecelerde: her bir bağımsız kapaklı bölmeyi temsil eder
///
/// İLİŞKİLER:
///   DrawerCell.drawerUnit → DrawerUnit (ait olduğu çekmece birimi)
///
/// KULLANIM:
///   - Stok takibi ve malzeme eşleştirmesi bu seviyede yapılır
///   - Motor step hesaplamaları stepNo üzerinden
class DrawerCell {
  const DrawerCell({this.id, this.stepNo, this.drawerUnit});

  final int? id;
  final int? stepNo; // Çekmece açılış kademesi veya bölme sırası
  final DrawerUnit? drawerUnit; // Ait olduğu çekmece birimi

  DrawerCell copyWith({int? id, int? stepNo, DrawerUnit? drawerUnit}) {
    return DrawerCell(id: id ?? this.id, stepNo: stepNo ?? this.stepNo, drawerUnit: drawerUnit ?? this.drawerUnit);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is DrawerCell && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'DrawerCell(id: $id, stepNo: $stepNo)';
}
