import 'package:pharmed_core/pharmed_core.dart';

class PrescriptionItemMovement {
  final int id;
  final int? prescriptionItemId;
  final int? cabinDrawerDetailId;
  final PrescriptionMovementType type;
  final DateTime? createdAt;
  final User? performedBy;
  final double? quantity;
  final int? stationId;
  final PrescriptionItem? prescriptionItem;

  /// İadeyi talep eden kullanıcının adı soyadı (backend: `returnRequestUser`).
  final int? returnRequestUserId;
  final String? returnRequestUserName;

  /// İadeyi onaylayan kullanıcının adı soyadı (backend: `returnApprovalUser`).
  final int? returnApprovalUserId;
  final String? returnApprovalUserName;

  const PrescriptionItemMovement({
    required this.id,
    this.prescriptionItemId,
    this.cabinDrawerDetailId,
    required this.type,
    this.createdAt,
    this.performedBy,
    this.quantity,
    this.stationId,
    this.prescriptionItem,
    this.returnRequestUserId,
    this.returnRequestUserName,
    this.returnApprovalUserId,
    this.returnApprovalUserName,
  });

  /// Hareketi "yapan" olarak gösterilecek kullanıcı adı.
  ///
  /// `returned` hareketinde backend `user` alanına iadeyi ONAYLAYAN kullanıcıyı
  /// yazar; aktivite listelerinde ise iadeyi YAPAN (talep eden) kullanıcı
  /// gösterilmelidir. Talep eden bilgisi yoksa (eski kayıtlar) `performedBy`'a düşer.
  String? get actorName {
    final requester = returnRequestUserName;
    if (type == PrescriptionMovementType.returned && requester != null && requester.trim().isNotEmpty) {
      return requester;
    }
    return performedBy?.fullName;
  }
}
