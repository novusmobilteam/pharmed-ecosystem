// lib/features/setup_wizard/domain/model/wizard_draft.dart
//
// [SWREQ-SETUP-002]
// Wizard boyunca biriken kısmi veri.
// Her adım kendi alanını günceller; tamamda CabinSetupConfig'e dönüşür.
// Sınıf: Class B

import 'package:equatable/equatable.dart';
import 'cabin_setup_config.dart';

class WizardDraft extends Equatable {
  const WizardDraft({
    this.cabinetType,
    this.basicInfo,
    this.serviceScope,
    this.drawerConfig,
  });

  const WizardDraft.empty() : this();

  final CabinetType? cabinetType;
  final WizardBasicInfo? basicInfo;
  final ServiceScope? serviceScope;
  final DrawerConfig? drawerConfig;

  // ── Adım doğrulama ──────────────────────────────────────────────

  bool get step1Complete => cabinetType != null;

  bool get step2Complete =>
      basicInfo != null &&
      basicInfo!.cabinName.isNotEmpty &&
      basicInfo!.ipAddress.isNotEmpty;

  bool get step3Complete => serviceScope != null;

  bool get step4Complete => drawerConfig != null;

  bool get isComplete =>
      step1Complete && step2Complete && step3Complete && step4Complete;

  // ── CabinSetupConfig'e dönüştür ─────────────────────────────────
  // [SWREQ-SETUP-003] Yalnızca tüm adımlar tamamlandığında çağrılabilir.

  CabinSetupConfig toConfig() {
    assert(isComplete, 'WizardDraft.toConfig() — eksik adımlar mevcut');
    return CabinSetupConfig(
      cabinetType: cabinetType!,
      basicInfo: basicInfo!,
      serviceScope: serviceScope!,
      drawerConfig: drawerConfig!,
    );
  }

  // ── copyWith ─────────────────────────────────────────────────────

  WizardDraft copyWith({
    CabinetType? cabinetType,
    WizardBasicInfo? basicInfo,
    ServiceScope? serviceScope,
    DrawerConfig? drawerConfig,
  }) {
    return WizardDraft(
      cabinetType: cabinetType ?? this.cabinetType,
      basicInfo: basicInfo ?? this.basicInfo,
      serviceScope: serviceScope ?? this.serviceScope,
      drawerConfig: drawerConfig ?? this.drawerConfig,
    );
  }

  @override
  List<Object?> get props =>
      [cabinetType, basicInfo, serviceScope, drawerConfig];
}
