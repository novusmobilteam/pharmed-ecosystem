import 'dart:ui';

import 'package:pharmed_ui/pharmed_ui.dart';

/// Kabin işlem ekranının aktif modunu belirler.
///
/// Her mod sağ paneli, hover renklerini ve legend'ı değiştirir.
/// [CabinWorkingStatus.faulty] olan gözlerde hiçbir modda işlem yapılamaz.
///
/// Giriş alanları (hasCountField/hasSecondaryField) yalnızca
/// [usesEntryTarget] true olan modlarda anlamlıdır — bu modlar
/// CabinOperationTarget ile çalışır. Tüm girişler ADET cinsindendir ve
/// girildiği gibi gönderilir; ölçü birimli ilaçlarda ml yalnızca gösterimde
/// türetilir ("4 adet × 100 ml").
///
/// DİKKAT: Değerlerin sırası değiştirilmemeli — index'e bağlı kullanımlar olabilir.
enum CabinOperationMode {
  /// İlaç Atama — gözlere ilaç veya hasta atanır, [CabinAssignment] oluşturulur.
  assign(),

  /// İlaç Dolum — sayım + konulacak miktar. Dolum listesi de bu modu kullanır.
  refill(usesEntryTarget: true, hasCountField: true, hasSecondaryField: true, requiresMiad: true),

  /// İlaç Sayım — yalnızca fiziksel sayım.
  census(usesEntryTarget: true, hasCountField: true, requiresMiad: true),

  /// İlaç Alım — sayım (ilacın sayım tipine göre) + alınacak miktar (plandan,
  /// salt okunur). Stoktan çıkaran işlem: SKT girilmez.
  intake(usesEntryTarget: true, hasCountField: true, hasSecondaryField: true, removesFromStock: true),

  /// Çekmece Arıza — arıza/bakım kaydı oluşturulur, göz kilitlenir.
  fault(),

  /// İlaç Boşaltma — yalnızca çıkarılacak miktar.
  unload(usesEntryTarget: true, hasSecondaryField: true),

  /// İlaç İmha — yalnızca imha edilecek miktar. Boşaltmayla aynı alan yapısı.
  destruction(usesEntryTarget: true, hasSecondaryField: true, removesFromStock: true);

  /// Bu mod CabinOperationTarget ile mi çalışır.
  final bool usesEntryTarget;

  /// Fiziksel sayım alanı var mı.
  final bool hasCountField;

  /// Sayımın yanında ikinci bir miktar alanı var mı (dolum: konulacak,
  /// boşaltma: çıkarılacak). Varsa "girdi" bu alandan okunur, yoksa sayımdan.
  final bool hasSecondaryField;

  /// SKT girilir ve girdi olan gözde zorunludur (geçmiş tarih kabul edilmez).
  /// Stoktan ÇIKARAN işlemlerde false — süresi geçmiş ilaç çıkarılabilmeli.
  final bool requiresMiad;

  /// İkincil miktar stoktan düşülür; gözdeki mevcut miktarı aşamaz.
  final bool removesFromStock;

  const CabinOperationMode({
    this.usesEntryTarget = false,
    this.hasCountField = false,
    this.hasSecondaryField = false,
    this.requiresMiad = false,
    this.removesFromStock = false,
  });
}

extension CabinOperationModeX on CabinOperationMode {
  String get label => switch (this) {
    CabinOperationMode.assign => contextlessL10n().enumCore_cabinOpModeAssignDrug,
    CabinOperationMode.refill => contextlessL10n().enumCore_cabinOpModeRefill,
    CabinOperationMode.census => contextlessL10n().enumCore_cabinOpModeCensus,
    CabinOperationMode.intake => contextlessL10n().enumCore_cabinOpModeIntake,
    CabinOperationMode.fault => contextlessL10n().enumCore_cabinOpModeFault,
    CabinOperationMode.unload => contextlessL10n().enumCore_cabinOpModeUnload,
    CabinOperationMode.destruction => contextlessL10n().enumCore_cabinInventoryTypeDisposalTitle,
  };

  /// Mod'a özgü vurgu rengi — hover, banner, chip rengi için
  Color get accentColor => switch (this) {
    CabinOperationMode.assign => MedColors.blue,
    CabinOperationMode.refill => MedColors.green,
    CabinOperationMode.census => MedColors.amber,
    CabinOperationMode.intake => MedColors.blueDark,
    CabinOperationMode.fault => MedColors.red,
    CabinOperationMode.unload => MedColors.shadowDark,
    CabinOperationMode.destruction => MedColors.red,
  };

  /// İşlem sonrası gözde olacak miktar (adet). Sayımda ve target
  /// kullanmayan modlarda null.
  double? resultQuantity({required double count, required double secondary, required double recorded}) =>
      switch (this) {
        CabinOperationMode.refill => count + secondary,
        CabinOperationMode.unload || CabinOperationMode.destruction => recorded - secondary,
        _ => null,
      };
}
