class MobileIntakeParams {
  final int? prescriptionDetailId;
  final int? userId;
  final double? dosePiece;
  final String? epc;

  MobileIntakeParams({this.prescriptionDetailId, this.userId, this.dosePiece, this.epc});

  Map<String, dynamic> toJson() {
    return {'prescriptionDetailId': prescriptionDetailId, 'userId': userId, 'dosePiece': dosePiece, 'rfidCardTag': epc};
  }
}
