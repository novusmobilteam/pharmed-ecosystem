// [SWREQ-SETUP-UI-003] [IEC 62304 §5.5]
// Setup Wizard Adım 1 — kabin tipi seçimi state yöneticisi.
// Sınıf: Class B

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

final step1NotifierProvider = NotifierProvider<Step1Notifier, CabinType?>(Step1Notifier.new);

class Step1Notifier extends Notifier<CabinType?> {
  @override
  CabinType? build() => null;

  void select(CabinType type) {
    MedLogger.info(
      unit: 'SW-UNIT-SETUP',
      swreq: 'SWREQ-SETUP-UI-003',
      message: 'Kabin tipi seçildi',
      context: {'type': type.name},
    );
    state = type;
  }
}
