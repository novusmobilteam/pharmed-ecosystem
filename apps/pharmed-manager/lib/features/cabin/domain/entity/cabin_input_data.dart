import 'package:pharmed_core/pharmed_core.dart';

class CabinInputData {
  final int materialId;
  final int? cabinDrawerDetailId; // Hangi detay ID'ye kayıt atılacak
  final int? cabinDrawerId;
  final double quantity; // Girilen Dolum Miktarı
  final double censusQuantity; // Girilen Sayım Miktarı
  final DateTime? miadDate; // Seçilen Tarih (boş göz için null)
  final int? shelfNo; // Raf/Sıra No (Standart çekmeceler için 1,2,3...)
  final int? compartmentNo;
  final int? stockId;
  final MedicineAssignment? assignment;

  CabinInputData({
    required this.materialId,
    required this.cabinDrawerDetailId,
    required this.quantity,
    required this.censusQuantity,
    this.miadDate,
    this.cabinDrawerId,
    this.shelfNo,
    this.compartmentNo,
    this.stockId,
    this.assignment,
  });

  Map<String, dynamic> toJson() {
    return {
      "materialId": materialId,
      "cabinDrawerDetailId": cabinDrawerDetailId,
      "quantity": quantity,
      "censusQuantity": censusQuantity,
      "miadDate": miadDate,
      "shelfNo": shelfNo,
      "compartmentNo": compartmentNo,
      "stockId": stockId,
      "cabinDrawerId": cabinDrawerId,
      //"assignment": assignment?.toDTO(),
    };
  }
}
