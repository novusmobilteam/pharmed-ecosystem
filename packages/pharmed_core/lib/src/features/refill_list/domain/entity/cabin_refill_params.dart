abstract class CabinRefillParams {
  final int cabinDrawerDetailId;
  final double quantity; // Dolum Miktarı
  final double censusQuantity; // Sayım Miktarı
  final DateTime? miadDate;

  CabinRefillParams({
    required this.cabinDrawerDetailId,
    required this.quantity,
    required this.censusQuantity,
    this.miadDate,
  });

  Map<String, dynamic> toJson();
}
