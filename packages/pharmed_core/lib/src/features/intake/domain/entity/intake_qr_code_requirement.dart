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
