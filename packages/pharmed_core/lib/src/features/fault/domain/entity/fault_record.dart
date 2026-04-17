import 'package:pharmed_core/pharmed_core.dart';

abstract interface class IFaultRecord {
  int? get id;
  DateTime? get startDate;
  DateTime? get endDate;
  String? get description;
  CabinWorkingStatus? get workingStatus;

  bool get isActive => endDate == null;
}
