import '../../../../core/core.dart';

class WithdrawParams {
  final WithdrawType type;
  final int? hospitalizationId;
  final int? prescriptionDetailId;
  final int? userId;
  final List<WithdrawDetail> details;

  WithdrawParams({
    required this.type,
    this.hospitalizationId,
    this.prescriptionDetailId,
    this.userId,
    required this.details,
  });

  Map<String, dynamic> toJson() {
    var paramKey = type != WithdrawType.ordered ? "patientHospitalizationId" : "prescriptionDetailId";
    var paramVal = type != WithdrawType.ordered ? hospitalizationId : prescriptionDetailId;
    return {paramKey: paramVal, "userId": userId, "detail": details.map((x) => x.toJson()).toList()};
  }
}

class WithdrawDetail {
  final int stockId;
  final double dosePiece;
  double? censusQuantity; // Sayım miktarı

  WithdrawDetail({required this.stockId, required this.dosePiece, this.censusQuantity});

  Map<String, dynamic> toJson() => {
    "cabinDrawrStockId": stockId,
    "dosePiece": dosePiece,
    "censusQuantity": censusQuantity,
  };
}
