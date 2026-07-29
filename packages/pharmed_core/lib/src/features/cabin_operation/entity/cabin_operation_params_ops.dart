// pharmed_core/features/cabin_operation/cabin_operation_params_ops.dart
// [SWREQ-CORE-CABINOP-011] [IEC 62304 §5.5]
//
// Bir kabin işleminin, hedefteki miktarları backend'in beklediği alanlara
// (countQuantity/quantity) nasıl yerleştireceğini tanımlar. Tek amacı:
// medicine-unit-mode kuralına göre hangi alanın ölçü-birimli ilaçlarda
// (`medicine.isMeasureUnit`) ham/gösterim değeri arasında çevrileceğine
// karar vermek. Her kabin işlemi kendi ops sabitini tanımlar ve
// CabinOperationParamsMapper'a verir.
//
// Sınıf: Class B

class CabinOperationParamsOps {
  const CabinOperationParamsOps({
    required this.convertCountQuantity,
    required this.sendQuantityField,
    required this.convertQuantityField,
  });

  /// true → countQuantity, ölçü-birimli ilaçlarda backend birimine çevrilir
  /// (sayım). false → countQuantity olduğu gibi gönderilir (dolum: zaten
  /// gösterim değeri; boşaltma: hiç çevrim yok).
  final bool convertCountQuantity;

  /// true → quantity alanı hesaplanıp gönderilir (dolum/boşaltma). false →
  /// quantity hiç hesaplanmaz, backend'e hiç gitmez (sayım — "delta"
  /// kavramı yok).
  final bool sendQuantityField;

  /// true → quantity, ölçü-birimli ilaçlarda backend birimine çevrilir
  /// (dolum). false → olduğu gibi gönderilir (boşaltma — "ml girer" grubu,
  /// hiçbir zaman çevrilmez). sendQuantityField=false iken anlamsız.
  final bool convertQuantityField;
}

const refillParamsOps = CabinOperationParamsOps(
  convertCountQuantity: false,
  sendQuantityField: true,
  convertQuantityField: true,
);

const censusParamsOps = CabinOperationParamsOps(
  convertCountQuantity: true,
  sendQuantityField: false,
  convertQuantityField: false, // sendQuantityField false olduğu için okunmaz
);

const unloadParamsOps = CabinOperationParamsOps(
  convertCountQuantity: false,
  sendQuantityField: true,
  convertQuantityField: false,
);
