// lib/features/setup_wizard/presentation/steps/step4_drawer_config.dart
//
// [SWREQ-SETUP-UI-014] [IEC 62304 §5.5]
// Wizard Adım 4 — Çekmece Yapılandırması.
// Standart kabin: seri port üzerinden cihaz taraması.
// Mobil kabin: çekmece sayısı + her çekmece için satır/sütun girişi.
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import '../../../../domain/model/scan_log_entry.dart';
import '../../../../domain/model/wizard_mobile_layout.dart';
import '../../../state/setup_wizard_ui_state.dart';
import '../../widgets/step_shared_widgets.dart';

part 'mobile_config_view.dart';
part 'standart_config_view.dart';

class Step4DrawerConfig extends StatelessWidget {
  const Step4DrawerConfig({
    super.key,
    required this.cabinetType,
    required this.scanState,
    required this.scanLogs,
    required this.scannedLayout,
    required this.mobileLayout,
    required this.onScanDevice,
    required this.onResetScan,
    required this.onDrawerCountChanged,
    required this.onDrawerConfigChanged,
    required this.onSameConfigToggled,
    required this.onNext,
    required this.onBack,
    this.stationType,
  });

  final CabinType cabinetType;
  final StationType? stationType;

  // Standart kabin
  final DrawerScanState scanState;
  final List<ScanLogEntry> scanLogs;
  final List<DrawerGroup> scannedLayout;

  // Mobil kabin
  final WizardMobileLayout? mobileLayout;

  final VoidCallback onScanDevice;
  final VoidCallback onResetScan;
  final ValueChanged<int> onDrawerCountChanged;
  final void Function(int drawerIndex, List<int> rowColumns) onDrawerConfigChanged;
  final ValueChanged<bool> onSameConfigToggled;

  final VoidCallback? onNext;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final subtitle = cabinetType == CabinType.mobile
        ? 'Mobil kabinin çekmece sayısını ve iç bölümlerini tanımlayın.'
        : 'Cihazdan kabin iç yapısı otomatik okunacaktır.';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StepHeader(badge: 'ADIM 4 / 5', title: 'Çekmece Yapılandırması', subtitle: subtitle),

        // ── Body ────────────────────────────────────────────────
        Expanded(
          child: cabinetType == CabinType.mobile && stationType == StationType.patientBased
              ? MobileConfigView(
                  layout: mobileLayout ?? WizardMobileLayout.defaultLayout(),
                  onDrawerCountChanged: onDrawerCountChanged,
                  onDrawerConfigChanged: onDrawerConfigChanged,
                  onSameConfigToggled: onSameConfigToggled,
                )
              : _StandardScanBody(
                  scanState: scanState,
                  scanLogs: scanLogs,
                  scannedLayout: scannedLayout,
                  onScan: onScanDevice,
                  onReset: onResetScan,
                ),
        ),

        StepFooter(onBack: onBack, onNext: onNext),
      ],
    );
  }
}
