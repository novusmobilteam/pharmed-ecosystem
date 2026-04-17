import 'package:pharmed_core/pharmed_core.dart';

class MobileFault implements IFaultRecord {
  const MobileFault({
    this.id,
    this.cabinDesignId,
    this.startDate,
    this.endDate,
    this.description,
    this.workingStatus,
    this.createdDate,
  });

  final int? id;
  final int? cabinDesignId; // MobileSlotVisual.slotId
  final DateTime? startDate;
  final DateTime? endDate;
  final String? description;
  final CabinWorkingStatus? workingStatus;
  final DateTime? createdDate;

  bool get isActive => endDate == null;

  MobileFault copyWith({
    int? id,
    int? cabinDesignId,
    DateTime? startDate,
    DateTime? endDate,
    String? description,
    CabinWorkingStatus? workingStatus,
    DateTime? createdDate,
  }) {
    return MobileFault(
      id: id ?? this.id,
      cabinDesignId: cabinDesignId ?? this.cabinDesignId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      description: description ?? this.description,
      workingStatus: workingStatus ?? this.workingStatus,
      createdDate: createdDate ?? this.createdDate,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is MobileFault && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'MobileFault(id: $id, cabinDesignId: $cabinDesignId)';
}
