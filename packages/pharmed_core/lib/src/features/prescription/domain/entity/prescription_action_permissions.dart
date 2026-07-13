// [SWREQ-AUTH-MTX-002] Reçete aksiyonları için yetki snapshot.

import '../../../../../pharmed_core.dart';

class PrescriptionActionPermissions {
  const PrescriptionActionPermissions({
    required this.canApprove,
    required this.canReject,
    required this.canCancel,
    required this.canRejectAfterApprove,
  });

  /// Hiçbir yetki yok — varsayılan güvenli durum.
  const PrescriptionActionPermissions.none()
    : canApprove = false,
      canReject = false,
      canCancel = false,
      canRejectAfterApprove = false;

  factory PrescriptionActionPermissions.fromRole(RoleType? role) {
    if (role == null) return const PrescriptionActionPermissions.none();
    return PrescriptionActionPermissions(
      canApprove: role.canApprovePrescription,
      canReject: role.canRejectPrescription,
      canCancel: role.canCancelPrescription,
      canRejectAfterApprove: role.canRejectPrescription,
    );
  }

  final bool canApprove;
  final bool canReject;
  final bool canCancel;
  final bool canRejectAfterApprove;

  bool get hasAny => canApprove || canReject || canCancel || canRejectAfterApprove;
}
