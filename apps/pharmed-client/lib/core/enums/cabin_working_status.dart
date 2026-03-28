import 'package:flutter/material.dart';

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
    switch (this) {
      case CabinWorkingStatus.working:
        return 'Çalışıyor';
      case CabinWorkingStatus.faulty:
        return 'Arıza Kaydı';
      case CabinWorkingStatus.maintenance:
        return 'Bakım Kaydı';
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
