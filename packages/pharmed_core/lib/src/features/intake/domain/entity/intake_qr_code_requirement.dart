class IntakeQrCodeRequirement {
  const IntakeQrCodeRequirement({
    required this.prescriptionDetailId,
    required this.medicineName,
    required this.requiredCount,
    this.expectedGtin,
  });

  final int prescriptionDetailId;
  final String medicineName;
  final int requiredCount;
  final String? expectedGtin;
}
