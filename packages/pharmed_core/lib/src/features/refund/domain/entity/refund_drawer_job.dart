import 'package:pharmed_core/pharmed_core.dart';

class RefundDrawerJob implements DrawerJob<RefundTarget> {
  const RefundDrawerJob({
    required this.cabinDrawerId,
    required this.representativeTarget,
    required this.targets,
    this.status = CabinOperationJobStatus.pending,
    this.cabinId,
  });

  final int cabinDrawerId;
  final RefundTarget representativeTarget;
  @override
  final List<RefundTarget> targets;
  @override
  final CabinOperationJobStatus status;
  final int? cabinId;

  @override
  bool get isKubik => representativeTarget.isKubik;

  bool get isReturnDrawer => representativeTarget.isReturnDrawerTarget;

  @override
  bool get staysOpenAcrossTargets => isKubik || isReturnDrawer;

  @override
  MedicineAssignment get representativeAssignment => representativeTarget.assignment;

  bool get canComplete => targets.every((t) => t.isValid);

  RefundDrawerJob copyWith({List<RefundTarget>? targets, CabinOperationJobStatus? status}) {
    return RefundDrawerJob(
      cabinDrawerId: cabinDrawerId,
      representativeTarget: representativeTarget,
      targets: targets ?? this.targets,
      status: status ?? this.status,
      cabinId: cabinId,
    );
  }

  @override
  RefundDrawerJob copyWithStatus(CabinOperationJobStatus status) => copyWith(status: status);
}
