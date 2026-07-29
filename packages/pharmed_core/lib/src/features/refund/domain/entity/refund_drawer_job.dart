import 'package:pharmed_core/pharmed_core.dart';

class RefundDrawerJob {
  const RefundDrawerJob({
    required this.cabinDrawerId,
    required this.representativeTarget,
    required this.targets,
    this.status = CabinOperationJobStatus.pending,
  });

  final int cabinDrawerId;
  final RefundTarget representativeTarget;
  final List<RefundTarget> targets;
  final CabinOperationJobStatus status;

  bool get isKubik => representativeTarget.isKubik;

  bool get canComplete => targets.every((t) => t.isValid);

  RefundDrawerJob copyWith({List<RefundTarget>? targets, CabinOperationJobStatus? status}) {
    return RefundDrawerJob(
      cabinDrawerId: cabinDrawerId,
      representativeTarget: representativeTarget,
      targets: targets ?? this.targets,
      status: status ?? this.status,
    );
  }
}
