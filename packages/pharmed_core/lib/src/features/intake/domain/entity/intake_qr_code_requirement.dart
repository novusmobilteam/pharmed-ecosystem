import 'package:pharmed_core/pharmed_core.dart';

class IntakeQrCodeRequirement {
  const IntakeQrCodeRequirement({
    required this.prescriptionDetailId,
    required this.medicineName,
    required this.requiredCount,
  });

  final int prescriptionDetailId;
  final String medicineName;
  final int requiredCount;
}

/// [job] içindeki qrCode-zorunlu (Drug.isQrCode) hedefleri prescriptionDetailId
/// bazında gruplar; aynı ilaç job içinde birden fazla step/detail'e (farklı
/// stockId) dağılmış olsa bile TEK bir gereksinime toplanır.
List<IntakeQrCodeRequirement> intakeQrCodeRequirementsOf(IntakeDrawerJob job) {
  final byPrescriptionDetailId = <int, IntakeQrCodeRequirement>{};

  for (final target in job.targets) {
    final drug = target.item.medicine?.when(drug: (Drug d) => d, consumable: (_) => null);
    if (drug == null || !drug.isQrCode) continue;

    final requiredCount = target.details.fold<int>(0, (sum, d) => sum + d.dosePiece.round());
    if (requiredCount <= 0) continue;

    final existing = byPrescriptionDetailId[target.item.id];
    byPrescriptionDetailId[target.item.id] = IntakeQrCodeRequirement(
      prescriptionDetailId: target.item.id,
      medicineName: drug.name ?? existing?.medicineName ?? '—',
      requiredCount: (existing?.requiredCount ?? 0) + requiredCount,
    );
  }

  return byPrescriptionDetailId.values.toList();
}
