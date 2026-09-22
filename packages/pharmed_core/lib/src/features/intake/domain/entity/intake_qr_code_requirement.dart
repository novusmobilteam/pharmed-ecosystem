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
    final medicine = target.item.medicine;
    final drug = medicine?.when(drug: (Drug d) => d, consumable: (_) => null);
    if (drug == null || !drug.isQrCode) continue;

    final totalDose = target.details.fold<double>(0, (sum, d) => sum + d.dosePiece);
    // dosePiece backend değeri (ml/mg) — fromFillingBackendValue ile paket/
    // flakon adedine (kullanıcı-yüzü "adet") çeviriyoruz. isMeasureUnit=false
    // olan ilaçlarda fillingMultiplier=1, yani totalDose zaten adet demektir.
    final requiredCount = medicine!.fromFillingBackendValue(totalDose).ceil();
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
