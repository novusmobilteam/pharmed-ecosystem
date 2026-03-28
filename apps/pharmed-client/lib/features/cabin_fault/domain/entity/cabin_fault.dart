import '../../../../core/enums/cabin_working_status.dart';

class CabinFault {
  final int? id;

  /// DrawerSlot ile birleştiren id.
  final int? slotId;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? description;
  final CabinWorkingStatus? workingStatus;
  final DateTime? createdDate;

  CabinFault({
    this.id,
    this.slotId,
    this.startDate,
    this.endDate,
    this.description,
    this.workingStatus,
    this.createdDate,
  });

  CabinFault copyWith({
    int? id,
    int? slotId,
    DateTime? startDate,
    DateTime? endDate,
    String? description,
    CabinWorkingStatus? workingStatus,
    DateTime? createdDate,
  }) {
    return CabinFault(
      id: id ?? this.id,
      slotId: slotId ?? this.slotId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      description: description ?? this.description,
      workingStatus: workingStatus ?? this.workingStatus,
      createdDate: createdDate ?? this.createdDate,
    );
  }

  CabinWorkingStatus get effectiveStatus {
    if (endDate == null) {
      return CabinWorkingStatus.working;
    }
    return workingStatus ?? CabinWorkingStatus.working;
  }
}
