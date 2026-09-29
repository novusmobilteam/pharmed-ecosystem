import 'package:pharmed_core/pharmed_core.dart';

class IntakeParams {
  final IntakeType type;
  final int? hospitalizationId;
  final int? prescriptionDetailId;
  final int? userId;
  final List<IntakeDetail> details;

  /// Uygulama saati geçmiş kalem için gecikme açıklaması (yalnızca ordered).
  final String? overdueDescription;

  IntakeParams({
    required this.type,
    this.hospitalizationId,
    this.prescriptionDetailId,
    this.userId,
    required this.details,
    this.overdueDescription,
  });

  Map<String, dynamic> toJson() {
    var paramKey = type != IntakeType.ordered ? "patientHospitalizationId" : "prescriptionDetailId";
    var paramVal = type != IntakeType.ordered ? hospitalizationId : prescriptionDetailId;
    final description = overdueDescription?.trim();
    return {
      paramKey: paramVal,
      "userId": userId,
      if (description != null && description.isNotEmpty) "delayDescription": description,
      "detail": details.map((x) => x.toJson()).toList(),
    };
  }
}

class IntakeDetail {
  final int stockId;
  final double dosePiece;
  double? censusQuantity; // Sayım miktarı

  IntakeDetail({required this.stockId, required this.dosePiece, this.censusQuantity});

  Map<String, dynamic> toJson() => {
    "cabinDrawrStockId": stockId,
    "dosePiece": dosePiece,
    "censusQuantity": censusQuantity,
  };
}
