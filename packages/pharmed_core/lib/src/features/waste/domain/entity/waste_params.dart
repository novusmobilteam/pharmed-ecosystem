class WasteParams {
  final int prescriptionItemId;
  final int? witnessId;
  final double quantity;

  WasteParams({required this.prescriptionItemId, this.witnessId, required this.quantity});

  Map<String, dynamic> toJson() {
    return {"prescriptionDetailId": prescriptionItemId, "userId": witnessId, "dosePiece": quantity};
  }
}
