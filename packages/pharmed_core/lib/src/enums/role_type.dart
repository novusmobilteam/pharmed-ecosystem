// Sistem sabit rolleri. Backend'de salt-okunur, silinmez/değiştirilmez.
// Yetki matrisi bu enum üzerinden kurulur.
// Sınıf: Class B (yetki sınırlandırma)

enum RoleType {
  admin(3),
  doctor(1),
  pharmacist(4),
  nurse(2);

  const RoleType(this.id);

  final int id;

  /// Backend'den gelen [roleId]'yi enum'a çevirir.
  /// Bilinmeyen id'ler için [null] döner — UI tarafı "yetkisiz" varsayar.
  static RoleType? fromId(int? id) {
    if (id == null) return null;
    for (final r in RoleType.values) {
      if (r.id == id) return r;
    }
    return null;
  }
}

extension PrescriptionPermissions on RoleType {
  bool get canApprovePrescription => this == RoleType.pharmacist;
  bool get canRejectPrescription => this == RoleType.pharmacist;
  bool get canCancelPrescription => this == RoleType.doctor;
  bool get canOverrideRfidLock => this == RoleType.admin;
}
