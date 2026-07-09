import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

enum CabinWorkingStatus {
  working(0),
  faulty(1),
  maintenance(2);

  final int id;

  const CabinWorkingStatus(this.id);

  static CabinWorkingStatus? fromId(int? id) {
    return CabinWorkingStatus.values.firstWhere((e) => e.id == id, orElse: () => CabinWorkingStatus.working);
  }
}

extension CabinWorkingStatusExtension on CabinWorkingStatus {
  String get label {
    final l10n = contextlessL10n();
    switch (this) {
      case CabinWorkingStatus.working:
        return l10n.cabin_statusWorking;
      case CabinWorkingStatus.faulty:
        return l10n.cabin_statusFaultRecord;
      case CabinWorkingStatus.maintenance:
        return l10n.cabin_statusMaintenanceRecord;
    }
  }

  Color get color {
    switch (this) {
      case CabinWorkingStatus.working:
        return Colors.green;
      case CabinWorkingStatus.faulty:
        return Colors.red;
      case CabinWorkingStatus.maintenance:
        return Colors.amber;
    }
  }
}
