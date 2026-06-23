// [SWREQ-AUTH-MTX-002] Reçete aksiyonları için yetki snapshot.

import '../../../../../pharmed_core.dart';

class PrescriptionActionPermissions {
  const PrescriptionActionPermissions({required this.canApprove, required this.canReject, required this.canCancel});

  /// Hiçbir yetki yok — varsayılan güvenli durum.
  const PrescriptionActionPermissions.none() : canApprove = false, canReject = false, canCancel = false;

  factory PrescriptionActionPermissions.fromRole(RoleType? role) {
    if (role == null) return const PrescriptionActionPermissions.none();
    return PrescriptionActionPermissions(
      canApprove: role.canApprovePrescription,
      canReject: role.canRejectPrescription,
      canCancel: role.canCancelPrescription,
    );
  }

  final bool canApprove;
  final bool canReject;
  final bool canCancel;

  bool get hasAny => canApprove || canReject || canCancel;
}
