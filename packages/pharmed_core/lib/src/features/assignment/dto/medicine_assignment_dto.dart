import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

/// Eski Adı: CabinDrawerQuantityDTO
class MedicineAssignmentDto {
  final int? id;
  final int? cabinId;
  final int? cabinDrawerId;

  /// Yalnızca serum avadanlığı ataması — null ise JSON'a yazılmaz.
  final int? cabinDrawerDetailId;
  final num? minQuantity;
  final num? criticalQuantity;
  final num? maxQuantity;
  final CabinDTO? cabin;
  final MedicineDto? medicine;
  final DrawerUnitDTO? cabinDrawer;
  final List<DrawerCellDTO>? cabinDrawerDetail;

  /// Dolum yaparken geliyor sadece bu veri, yeni model açmaktansa burada handle edildi..
  final List<CabinStockDTO>? stocks;

  MedicineAssignmentDto({
    this.id,
    this.cabinId,
    this.cabinDrawerId,
    this.cabinDrawerDetailId,
    this.minQuantity,
    this.criticalQuantity,
    this.maxQuantity,
    this.cabin,
    this.medicine,
    this.cabinDrawer,
    this.cabinDrawerDetail,
    this.stocks,
  });

  /// Servis bazı endpoint'lerde (alım — `cabinDrawrQuantity`) serum
  /// avadanlığı atamasını farklı şekilde döner: `cabinDrawr` null,
  /// `cabinDrawrDetail` LİSTE değil tek nesne ve raf (`cabinDrawr`) onun
  /// içinde. İki şekil de kabul edilir; raf avadanlıktan tamamlanır.
  factory MedicineAssignmentDto.fromJson(Map<String, dynamic> json) {
    final cells = _listOf(json['cabinDrawrDetail']);
    final rawDrawer = json['cabinDrawr'] ?? _nestedDrawerOf(cells, json['cabinDrawrDetailId']);

    return MedicineAssignmentDto(
      id: json['id'] as int?,
      cabinId: json['cabinId'] as int?,
      cabinDrawerId: json['cabinDrawrId'] as int?,
      cabinDrawerDetailId: json['cabinDrawrDetailId'] as int?,
      minQuantity: json['minQuantity'] as int?,
      criticalQuantity: json['criticalQuantity'] as int?,
      maxQuantity: json['maxQuantity'] as int?,
      cabin: json['cabin'] != null ? CabinDTO.fromJson(json['cabin']) : null,
      medicine: json['material'] != null ? MedicineDto.fromJson(json['material']) : null,
      cabinDrawer: rawDrawer != null ? DrawerUnitDTO.fromJson(rawDrawer as Map<String, dynamic>) : null,
      cabinDrawerDetail: cells?.map(DrawerCellDTO.fromJson).toList(),
      stocks: _listOf(json['cabinDrawrStock'])?.map(CabinStockDTO.fromJson).toList(),
    );
  }

  /// null → null, tek nesne → tek elemanlı liste, liste → aynen.
  static List<Map<String, dynamic>>? _listOf(Object? raw) => switch (raw) {
    null => null,
    final List<dynamic> list => [for (final e in list) e as Map<String, dynamic>],
    final Map<String, dynamic> map => [map],
    _ => throw FormatException('Beklenmeyen JSON tipi: ${raw.runtimeType}'),
  };

  /// Atamanın avadanlığına gömülü raf (serum) — üst seviye `cabinDrawr` yoksa.
  static Object? _nestedDrawerOf(List<Map<String, dynamic>>? cells, Object? detailId) {
    if (cells == null) return null;
    for (final cell in cells) {
      if (detailId == null || cell['id'] == detailId) {
        final drawer = cell['cabinDrawr'];
        if (drawer != null) return drawer;
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      // Serum avadanlığı ataması yalnızca cabinDrawrDetailId ile gönderilir,
      // cabinDrawrId GÖNDERİLMEZ. Diğer çekmecelerde yalnızca cabinDrawrId.
      if (cabinDrawerDetailId != null) 'cabinDrawrDetailId': cabinDrawerDetailId else 'cabinDrawrId': cabinDrawerId,
      'materialId': MedicineMapper().toEntityOrNull(medicine)?.id,
      'minQuantity': minQuantity,
      'criticalQuantity': criticalQuantity,
      'maxQuantity': maxQuantity,
    };
  }

  MedicineAssignmentDto copyWith({
    int? id,
    int? cabinDrawerId,
    int? cabinDrawerDetailId,
    int? minQuantity,
    int? criticalQuantity,
    int? maxQuantity,
    CabinDTO? cabin,
    MedicineDto? medicine,
    DrawerUnitDTO? cabinDrawer,
  }) {
    return MedicineAssignmentDto(
      id: id ?? this.id,
      cabinDrawerId: cabinDrawerId ?? this.cabinDrawerId,
      cabinDrawerDetailId: cabinDrawerDetailId ?? this.cabinDrawerDetailId,
      minQuantity: minQuantity ?? this.minQuantity,
      criticalQuantity: criticalQuantity ?? this.criticalQuantity,
      maxQuantity: maxQuantity ?? this.maxQuantity,
      cabin: cabin ?? this.cabin,
      medicine: medicine ?? this.medicine,
      cabinDrawer: cabinDrawer ?? this.cabinDrawer,
    );
  }
}
