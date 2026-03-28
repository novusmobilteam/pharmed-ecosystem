import '../../../../core/core.dart';
import '../../data/model/cabin_fault_dto.dart';

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

  CabinFaultDTO toDTO() {
    return CabinFaultDTO(
      id: id,
      cabinDrawrId: slotId,
      startDate: startDate,
      endDate: endDate,
      description: description,
      workingStatusId: workingStatus?.id,
      createdDate: createdDate,
    );
  }

  CabinWorkingStatus get effectiveStatus {
    if (endDate == null) {
      return CabinWorkingStatus.working;
    }
    return workingStatus ?? CabinWorkingStatus.working;
  }
}
