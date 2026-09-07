import 'package:pharmed_core/pharmed_core.dart';

class Inconsistency {
  final int? id;
  final int? stationId;
  final DrawerCell? cabinDrawerDetail;
  final Medicine? medicine;
  final num? quantity;
  final num? requiredQuantity;
  final DateTime? miadDate;
  final int? shelfNo;
  final int? corpartmentNo;
  final List<String>? activeIngredients;
  final User? user;
  final bool isSolved;

  const Inconsistency({
    this.id,
    this.stationId,
    this.cabinDrawerDetail,
    this.medicine,
    this.quantity,
    this.requiredQuantity,
    this.miadDate,
    this.shelfNo,
    this.corpartmentNo,
    this.activeIngredients,
    this.user,
    this.isSolved = false,
  });

  Inconsistency copyWith({int? id, Station? station, List<Cabin>? cabins}) {
    return Inconsistency(id: id ?? this.id);
  }
}
