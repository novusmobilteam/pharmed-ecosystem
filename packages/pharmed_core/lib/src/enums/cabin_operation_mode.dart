// lib/features/cabin/presentation/state/cabin_operation_mode.dart

import 'dart:ui';

import 'package:pharmed_ui/pharmed_ui.dart';

/// Kabin işlem ekranının aktif modunu belirler.
///
/// Her mod sağ paneli, hover renklerini ve legend'ı değiştirir.
/// [CabinWorkingStatus.faulty] olan gözlerde hiçbir modda işlem yapılamaz.
enum CabinOperationMode {
  /// İlaç Atama — gözlere ilaç veya hasta atanır, [CabinAssignment] oluşturulur.
  assign,

  /// İlaç Dolum — atanmış gözlere ilaç doldurulur, miktar + miad girilir.
  refill,

  /// İlaç Sayım — mevcut stok sayılır ve sisteme girilir.
  census,

  /// İlaç Alım
  intake,

  /// Çekmece Arıza — arıza/bakım kaydı oluşturulur, göz kilitlenir.
  fault,

  /// İlaç Boşaltma
  unload,
}

extension CabinOperationModeX on CabinOperationMode {
  String get label => switch (this) {
    CabinOperationMode.assign => contextlessL10n().enumCore_cabinOpModeAssignDrug,
    CabinOperationMode.refill => contextlessL10n().enumCore_cabinOpModeRefill,
    CabinOperationMode.census => contextlessL10n().enumCore_cabinOpModeCensus,
    CabinOperationMode.intake => contextlessL10n().enumCore_cabinOpModeIntake,
    CabinOperationMode.fault => contextlessL10n().enumCore_cabinOpModeFault,
    CabinOperationMode.unload => contextlessL10n().enumCore_cabinOpModeUnload,
  };

  /// Mod'a özgü vurgu rengi — hover, banner, chip rengi için
  Color get accentColor => switch (this) {
    CabinOperationMode.assign => MedColors.blue,
    CabinOperationMode.refill => MedColors.green,
    CabinOperationMode.census => MedColors.amber,
    CabinOperationMode.intake => MedColors.blueDark,
    CabinOperationMode.fault => MedColors.red,
    CabinOperationMode.unload => MedColors.shadowDark,
  };
}
