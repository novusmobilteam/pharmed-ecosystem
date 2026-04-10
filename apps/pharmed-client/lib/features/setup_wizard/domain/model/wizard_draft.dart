// [SWREQ-SETUP-002] [IEC 62304 §5.5]
// Wizard boyunca biriken kısmi veri.
// Her adım kendi alanını günceller; tamamda CabinSetupConfig'e dönüşür.
// Sınıf: Class B

import 'package:equatable/equatable.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'cabin_setup_config.dart';
import 'wizard_mobile_layout.dart';

class WizardDraft extends Equatable {
  const WizardDraft({this.cabinetType, this.basicInfo, this.serviceScope, this.scannedLayout, this.mobileLayout});

  const WizardDraft.empty() : this();

  final CabinType? cabinetType;
  final WizardBasicInfo? basicInfo;
  final StationScope? serviceScope;

  /// Standart kabin — scan sonucu
  final List<DrawerGroup>? scannedLayout;

  /// Mobil kabin — manuel tanım
  final WizardMobileLayout? mobileLayout;

  // ── Adım doğrulama ──────────────────────────────────────────────

  bool get step1Complete => cabinetType != null;

  bool get step2Complete {
    final info = basicInfo;
    if (info == null || info.cabinName.isEmpty) return false;
    if (cabinetType == CabinType.mobile) return true;
    return info.ipAddress.isNotEmpty;
  }

  bool get step3Complete => serviceScope != null;

  bool get step4Complete {
    return switch (cabinetType) {
      CabinType.mobile => mobileLayout != null && mobileLayout!.drawerCount > 0,
      _ => scannedLayout != null && scannedLayout!.isNotEmpty,
    };
  }

  bool get isComplete => step1Complete && step2Complete && step3Complete && step4Complete;

  // ── CabinSetupConfig'e dönüştür ─────────────────────────────────
  // [SWREQ-SETUP-003] Yalnızca tüm adımlar tamamlandığında çağrılabilir.

  CabinSetupConfig toConfig() {
    assert(isComplete, 'WizardDraft.toConfig() — eksik adımlar mevcut');
    return CabinSetupConfig(
      cabinetType: cabinetType!,
      basicInfo: basicInfo!,
      stationScope: serviceScope!,
      scannedLayout: scannedLayout,
      mobileLayout: mobileLayout,
    );
  }

  // ── copyWith ─────────────────────────────────────────────────────

  WizardDraft copyWith({
    CabinType? cabinetType,
    WizardBasicInfo? basicInfo,
    StationScope? serviceScope,
    List<DrawerGroup>? scannedLayout,
    WizardMobileLayout? mobileLayout,
  }) {
    return WizardDraft(
      cabinetType: cabinetType ?? this.cabinetType,
      basicInfo: basicInfo ?? this.basicInfo,
      serviceScope: serviceScope ?? this.serviceScope,
      scannedLayout: scannedLayout ?? this.scannedLayout,
      mobileLayout: mobileLayout ?? this.mobileLayout,
    );
  }

  @override
  List<Object?> get props => [cabinetType, basicInfo, serviceScope, scannedLayout, mobileLayout];
}
