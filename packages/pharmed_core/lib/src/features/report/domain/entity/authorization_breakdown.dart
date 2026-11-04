import 'package:pharmed_core/pharmed_core.dart';

/// Yetki Kırım raporu satırı.
///
/// Normal order akışı dışında (ordersız veya serbest erişimle) yapılan bir
/// malzeme alımını temsil eder.
class AuthorizationBreakdown {
  final int? id;
  final int? prescriptionDetailId;
  final String? patientFullName;
  final int? materialId;
  final Medicine? medicine;
  final String? materialName;
  final double? quantity;
  final DateTime? applicationDate;
  final int? userId;
  final String? userFullName;
  final int? stationId;
  final String? stationName;
  final bool isOrderlessCollect;
  final bool isFreeAccessCollect;

  const AuthorizationBreakdown({
    this.id,
    this.prescriptionDetailId,
    this.patientFullName,
    this.materialId,
    this.medicine,
    this.materialName,
    this.quantity,
    this.applicationDate,
    this.userId,
    this.userFullName,
    this.stationId,
    this.stationName,
    this.isOrderlessCollect = false,
    this.isFreeAccessCollect = false,
  });
}
