import '../../domain/entity/drawer_cell.dart';
import 'drawer_unit_dto.dart';

/// [ESKİ İSİM: CabinDrawerDetailDTO]
///
/// ÇEKMECE GÖZÜ / CEBİ
/// ----------------------------------------
/// Bir çekmece ünitesinin (DrawerUnit) içindeki en küçük depolama birimidir.
/// İlaçlar veya malzemeler doğrudan bu "gözlerin" içine tanımlanır.
///
/// BU MODEL NE İŞE YARAR?
/// 1. Birim doz çekmecelerde motorun hangi adımda (stepNo) duracağını belirler.
/// 2. Kübik (grid) çekmecelerde her bir bağımsız kapaklı bölmeyi temsil eder.
/// 3. Stok takibi ve malzeme eşleştirmesi bu seviyede yapılır.
///
/// ANAHTAR ALANLAR:
/// - stepNo: Çekmecenin derinlik eksenindeki sıra numarası.
/// - cabinDrawr (Yeni: drawerUnit): Bu gözün ait olduğu fiziksel çekmece parçası.
class DrawerCellDTO {
  final int? id;
  final int? stepNo; // Çekmece açılış kademesi veya bölme sırası
  final DrawerUnitDTO? drawerUnit; // Eski: cabinDrawer
  final bool? isDeleted;
  final DateTime? createdDate;

  DrawerCellDTO({this.id, this.stepNo, this.drawerUnit, this.isDeleted, this.createdDate});

  factory DrawerCellDTO.fromJson(Map<String, dynamic> json) {
    return DrawerCellDTO(
      id: json['id'] as int?,
      stepNo: json['stepNo'] as int?,
      drawerUnit: json['cabinDrawr'] != null ? DrawerUnitDTO.fromJson(json['cabinDrawr']) : null,
      createdDate: json['createdDate'] != null ? DateTime.parse(json['createdDate'] as String) : null,
      isDeleted: json['isDeleted'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'stepNo': stepNo,
      'cabinDrawr': drawerUnit?.toJson(),
      'isDeleted': isDeleted,
      'createdDate': createdDate?.toIso8601String(),
    };
  }

  DrawerCell toEntity() {
    return DrawerCell(
      id: id,
      stepNo: stepNo,
      cabinDrawer: drawerUnit?.toEntity(),
      isDeleted: isDeleted,
      createdDate: createdDate,
    );
  }
}
