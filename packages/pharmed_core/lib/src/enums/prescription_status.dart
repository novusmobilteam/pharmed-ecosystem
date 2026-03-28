import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

enum PrescriptionStatus {
  /// Onay Bekliyor
  pendingApproval(1),

  /// Alım Bekliyor
  purchasePending(2),

  /// Uygulandı
  applied(3),

  /// İade Edildi
  returned(4),

  /// Fire Edildi
  wastaged(5),

  /// İmha Edildi
  destructed(6),

  /// İptal Edildi
  cancelled(7),

  rejected(8);

  final int id;

  const PrescriptionStatus(this.id);

  static PrescriptionStatus fromId(int? id) {
    return PrescriptionStatus.values.firstWhere(
      (e) => e.id == id,
      orElse: () => PrescriptionStatus.pendingApproval,
    );
  }

  String get label {
    switch (this) {
      case PrescriptionStatus.pendingApproval:
        return 'Onay Bekliyor';
      case PrescriptionStatus.purchasePending:
        return 'Alım Bekliyor';
      case PrescriptionStatus.applied:
        return 'Uygulandı';
      case PrescriptionStatus.returned:
        return 'İade Edildi';
      case PrescriptionStatus.wastaged:
        return 'Fire Edildi';
      case PrescriptionStatus.destructed:
        return 'İmha Edildi';
      case PrescriptionStatus.cancelled:
        return 'İptal Edildi';
      case PrescriptionStatus.rejected:
        return 'Reddedildi';
    }
  }
}

/// PrescriptionStatus için UI renk ve ikon bilgisi.
extension PrescriptionStatusStyle on PrescriptionStatus {
  Color get color => switch (this) {
        PrescriptionStatus.pendingApproval => Colors.orange,
        PrescriptionStatus.purchasePending => Colors.blue,
        PrescriptionStatus.applied => Colors.green,
        PrescriptionStatus.returned => Colors.teal,
        PrescriptionStatus.wastaged => Colors.deepOrange,
        PrescriptionStatus.destructed => Colors.red,
        PrescriptionStatus.cancelled => Colors.amber,
        PrescriptionStatus.rejected => Colors.red,
      };

  Color get backgroundColor => color.withValues(alpha: 0.12);
  Color get borderColor => color.withValues(alpha: 0.3);

  IconData get icon => switch (this) {
        PrescriptionStatus.pendingApproval => PhosphorIcons.hourglass(PhosphorIconsStyle.fill),
        PrescriptionStatus.purchasePending => PhosphorIcons.shoppingBag(PhosphorIconsStyle.fill),
        PrescriptionStatus.applied => PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
        PrescriptionStatus.returned => PhosphorIcons.arrowCounterClockwise(PhosphorIconsStyle.fill),
        PrescriptionStatus.wastaged => PhosphorIcons.warning(PhosphorIconsStyle.fill),
        PrescriptionStatus.destructed => PhosphorIcons.trash(PhosphorIconsStyle.fill),
        PrescriptionStatus.cancelled => PhosphorIcons.prohibit(PhosphorIconsStyle.fill),
        PrescriptionStatus.rejected => PhosphorIcons.xCircle(PhosphorIconsStyle.fill),
      };

  /// Reçete onay/reddet kısmında sadece bu statuse sahip olanlarla işlem yapılabilir.
  bool get isSelectable =>
      this == PrescriptionStatus.pendingApproval ||
      this == PrescriptionStatus.purchasePending ||
      this == PrescriptionStatus.cancelled ||
      this == PrescriptionStatus.rejected;
}
