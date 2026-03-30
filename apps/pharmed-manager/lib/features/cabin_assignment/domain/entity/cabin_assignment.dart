import '../../../../core/core.dart';
import '../../../cabin_stock/domain/entity/cabin_stock.dart';
import '../../data/model/cabin_assignment_dto.dart';

class CabinAssignment implements TableData {
  final int? id;
  final int? cabinDrawerId;
  final num? minQuantity;
  final num? criticalQuantity;
  final num? maxQuantity;
  final num? quantity;
  final num? fillingQuantity;
  final Cabin? cabin;
  final Medicine? medicine;
  final DrawerUnit? drawerUnit;
  final List<DrawerCell>? cabinDrawerDetail;
  final List<CabinStock>? stocks;

  CabinAssignment({
    this.id,
    this.cabinDrawerId,
    this.minQuantity,
    this.criticalQuantity,
    this.maxQuantity,
    this.quantity,
    this.cabin,
    this.medicine,
    this.drawerUnit,
    this.cabinDrawerDetail,
    this.stocks,
    this.fillingQuantity,
  });

  // ---------------------------------------------------------------------------
  // Birim etiketleri
  // ---------------------------------------------------------------------------

  String get operationUnit => medicine?.operationUnit ?? 'Adet';
  String get fillingUnit => medicine?.fillingUnit ?? 'Adet';

  // ---------------------------------------------------------------------------
  // Backend ↔ Adet dönüşümleri
  //
  // Kural: Atama ve Dolum (stok artıran işlemler) backend ile ml üzerinden
  // konuşur. Diğer tüm işlemler (sayım, boşaltma, imha) değeri olduğu gibi
  // kullanır — dönüşüm yalnızca gösterim için yapılır.
  //
  // isMeasureUnit=false veya MedicalConsumable → fillingMultiplier=1,
  // dönüşüm formülleri değeri olduğu gibi döndürür.
  // ---------------------------------------------------------------------------

  /// Backend değerini kullanıcıya gösterilecek adete çevirir.
  /// Atama ve Dolum ekranlarında kullanılır.
  /// Örn: 40.000ml → 400 adet (dose=100ml ise)
  double toDisplayQuantity(num? backendValue) =>
      medicine?.fromFillingBackendValue(backendValue ?? 0) ?? (backendValue ?? 0).toDouble();

  /// Kullanıcının girdiği adeti backend'e gönderilecek değere çevirir.
  /// Örn: 400 adet → 40.000ml (dose=100ml ise)
  int _toBackendValue(num? adet) => medicine?.toFillingBackendValue(adet ?? 0).toInt() ?? (adet ?? 0).toInt();

  // ---------------------------------------------------------------------------
  // İlaç Atama — min/max/kritik
  // ---------------------------------------------------------------------------

  /// Kullanıcıya gösterilecek adet (backend ml'den çevrilir)
  double get minQuantityFromBackend => toDisplayQuantity(minQuantity);
  double get maxQuantityFromBackend => toDisplayQuantity(maxQuantity);
  double get critQuantityFromBackend => toDisplayQuantity(criticalQuantity);

  /// Atama ekranında backend'e gönderilecek değer (adet → ml)
  int get minQuantityToBackend => _toBackendValue(minQuantity);
  int get maxQuantityToBackend => _toBackendValue(maxQuantity);
  int get critQuantityToBackend => _toBackendValue(criticalQuantity);

  // ---------------------------------------------------------------------------
  // Stok miktarı
  // ---------------------------------------------------------------------------

  /// Stocks listesinden toplanan ham backend değeri (ml veya adet).
  /// Atama/Dolum: ml cinsinden → _toDisplayQuantity ile adete çevrilir.
  /// Sayım/Boşaltma/İmha: olduğu gibi kullanılır.
  double get totalQuantity => (stocks ?? []).fold(0.0, (sum, s) => sum + (s.quantity ?? 0).toDouble());

  // ---------------------------------------------------------------------------
  // QuantityInfoCard label'ları
  // ---------------------------------------------------------------------------

  /// Min/Max/Kritik değerleri her tipte adet olarak gösterilir.
  /// Backend'den ml geliyorsa adete çevrilir.
  String minQuantityLabel(CabinInventoryType type) => formatWithUnit(minQuantityFromBackend, type);
  String maxQuantityLabel(CabinInventoryType type) => formatWithUnit(maxQuantityFromBackend, type);
  String critQuantityLabel(CabinInventoryType type) => formatWithUnit(critQuantityFromBackend, type);
  String totalQuantityLabel(CabinInventoryType type) => formatWithUnit(toDisplayQuantity(totalQuantity), type);

  String formatWithUnit(double adet, CabinInventoryType type) {
    if (type == CabinInventoryType.refill || type == CabinInventoryType.refillList) {
      return '${adet.formatFractional} Adet';
    }
    if (medicine is Drug && (medicine as Drug).isMeasureUnit) {
      return '${adet.formatFractional} Adet x ${medicine!.fillingMultiplier.formatFractional} $operationUnit';
    }
    return '${adet.formatFractional} Adet';
  }

  // ---------------------------------------------------------------------------
  // Yardımcılar
  // ---------------------------------------------------------------------------

  String get quantityText =>
      'Min: ${minQuantityFromBackend.formatFractional} Adet - '
      'Maks: ${maxQuantityFromBackend.formatFractional} Adet - '
      'Kritik: ${critQuantityFromBackend.formatFractional} Adet';

  bool get isKubikType => drawerUnit?.drawerSlot?.drawerConfig?.drawerType?.isKubik ?? true;

  // ---------------------------------------------------------------------------
  // copyWith / toDTO / TableData
  // ---------------------------------------------------------------------------

  CabinAssignment copyWith({
    int? id,
    int? cabinDrawerId,
    num? minQuantity,
    num? criticalQuantity,
    num? maxQuantity,
    num? quantity,
    num? fillingQuantity,
    Cabin? cabin,
    Medicine? medicine,
    DrawerUnit? drawerUnit,
    List<DrawerCell>? cabinDrawerDetail,
    List<CabinStock>? stocks,
  }) {
    return CabinAssignment(
      id: id ?? this.id,
      cabinDrawerId: cabinDrawerId ?? this.cabinDrawerId,
      minQuantity: minQuantity ?? this.minQuantity,
      criticalQuantity: criticalQuantity ?? this.criticalQuantity,
      maxQuantity: maxQuantity ?? this.maxQuantity,
      quantity: quantity ?? this.quantity,
      cabin: cabin ?? this.cabin,
      medicine: medicine ?? this.medicine,
      drawerUnit: drawerUnit ?? this.drawerUnit,
      cabinDrawerDetail: cabinDrawerDetail ?? this.cabinDrawerDetail,
      fillingQuantity: fillingQuantity ?? this.fillingQuantity,
      stocks: stocks ?? this.stocks,
    );
  }

  CabinAssignmentDTO toDTO() {
    return CabinAssignmentDTO(
      id: id,
      cabinDrawerId: cabinDrawerId,
      maxQuantity: maxQuantity,
      minQuantity: minQuantity,
      criticalQuantity: criticalQuantity,
      cabin: CabinMapper().toDtoOrNull(cabin),
      medicine: MedicineMapper().toDtoOrNull(medicine),
      cabinDrawer: DrawerUnitMapper().toDtoOrNull(drawerUnit),
    );
  }

  factory CabinAssignment.empty({required int cabinId, required int cabinDrawerId}) {
    return CabinAssignment(
      id: null,
      cabinDrawerId: cabinDrawerId,
      cabin: null,
      medicine: null,
      minQuantity: null,
      criticalQuantity: null,
      maxQuantity: null,
    );
  }

  @override
  List get content => [
    medicine?.barcode,
    medicine?.name,
    minQuantity?.toCustomString(),
    maxQuantity?.toCustomString(),
    criticalQuantity?.toCustomString(),
  ];

  @override
  List<String?> get titles => ['Barkod', 'Malzeme', 'Minimum', 'Maksimum', 'Kritik'];

  @override
  List<dynamic> get rawContent => [medicine?.barcode, medicine?.name, minQuantity, maxQuantity, criticalQuantity];
}
