// lib/features/cabin/presentation/state/cabin_operation_mode.dart

import 'dart:ui';

import 'package:pharmed_client/shared/widgets/atoms/med_tokens.dart';

/// Kabin işlem ekranının aktif modunu belirler.
///
/// Her mod sağ paneli, hover renklerini ve legend'ı değiştirir.
/// [CabinWorkingStatus.faulty] olan gözlerde hiçbir modda işlem yapılamaz.
enum CabinOperationMode {
  /// İlaç Atama — gözlere ilaç veya hasta atanır, [CabinAssignment] oluşturulur.
  assign,

  /// İlaç Dolum — atanmış gözlere ilaç doldurulur, miktar + miad girilir.
  fill,

  /// İlaç Sayım — mevcut stok sayılır ve sisteme girilir.
  count,

  /// Çekmece Arıza — arıza/bakım kaydı oluşturulur, göz kilitlenir.
  fault,
}

extension CabinOperationModeX on CabinOperationMode {
  String get label => switch (this) {
    CabinOperationMode.assign => 'İlaç Atama',
    CabinOperationMode.fill => 'İlaç Dolum',
    CabinOperationMode.count => 'İlaç Sayım',
    CabinOperationMode.fault => 'Çekmece Arıza',
  };

  /// Mod'a özgü vurgu rengi — hover, banner, chip rengi için
  Color get accentColor => switch (this) {
    CabinOperationMode.assign => MedColors.blue,
    CabinOperationMode.fill => MedColors.green,
    CabinOperationMode.count => MedColors.amber,
    CabinOperationMode.fault => MedColors.red,
  };
}
