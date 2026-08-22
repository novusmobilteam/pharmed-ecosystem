import 'package:pharmed_core/pharmed_core.dart';

class RefundDrawerJob {
  const RefundDrawerJob({
    required this.cabinDrawerId,
    required this.representativeTarget,
    required this.targets,
    this.status = CabinOperationJobStatus.pending,
    this.cabinId,
  });

  final int cabinDrawerId;
  final RefundTarget representativeTarget;
  final List<RefundTarget> targets;
  final CabinOperationJobStatus status;
  final int? cabinId;

  bool get isKubik => representativeTarget.isKubik;

  /// İade çekmecesi hedefi mi — fiziksel lid'i yok, tek açılışta çoklu item.
  bool get isReturnDrawer => representativeTarget.isReturnDrawerTarget;

  /// true ise: çekmece TEK açılışta kalır, targetlar arası kapat/aç
  /// döngüsüne girilmez (kübik lid komutu isKubik'e göre ayrıca kontrol
  /// edilir — isReturnDrawer'da hiç gönderilmez).
  bool get staysOpenAcrossTargets => isKubik || isReturnDrawer;

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
}
