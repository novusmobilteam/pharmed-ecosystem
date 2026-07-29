// pharmed_core/features/cabin_operation/cabin_operation_medicine_params.dart
// [SWREQ-CORE-CABINOP-008] [IEC 62304 §5.5]
// Refill/Census/Unload'ın backend'e gönderdiği tek satırlık kayıt DTO'su.
// Üçü de aynı wire format'ı paylaşıyordu — tek fark: Census `quantity`
// alanını hiç göndermiyordu (sayımda "delta" kavramı yok, sadece fiziksel
// sayım kaydediliyor). Bu artık `quantity: null` ile ifade ediliyor VE
// toJson bu durumda key'i HİÇ eklemiyor — `"quantity": null` DEĞİL, key'in
// kendisi map'te yok. Backend kontratı böylece birebir korunuyor.
//
// materialId/cabinDrawerDetailId/countQuantity/miadDate/shelfNo/compartmentNo
// üç ekranda da HER ZAMAN dolu — bunlar nullable değil.
//
// Sınıf: Class B

class CabinOperationMedicineParams {
  const CabinOperationMedicineParams({
    required this.materialId,
    required this.cabinDrawerDetailId,
    required this.countQuantity,
    this.quantity,
    required this.miadDate,
    required this.shelfNo,
    required this.compartmentNo,
  });

  final int materialId;
  final int cabinDrawerDetailId;
  final double countQuantity;

  /// null → dolum/boşaltma miktarı yok (sayım kaydı).
  final double? quantity;

  final DateTime? miadDate;
  final int shelfNo;
  final int compartmentNo;

  Map<String, dynamic> toJson() {
    return {
      "materialId": materialId,
      "cabinDrawrDetailId": cabinDrawerDetailId,
      "censusQuantity": countQuantity,
      if (quantity != null) "quantity": quantity,
      "miadDate": miadDate?.toIso8601String(),
      "shelfNo": shelfNo,
      "corpartmentNo": compartmentNo,
    };
  }
}
