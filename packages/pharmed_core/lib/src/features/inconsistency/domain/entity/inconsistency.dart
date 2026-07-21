import 'package:pharmed_core/pharmed_core.dart';

class Inconsistency {
  final int? id;
  final DrawerCell? cabinDrawerDetail;
  final Medicine? medicine;
  final num? quantity;
  final num? stockEntryQuantity;
  final num? stockExitQuantity;
  final num? requiredQuantity;
  final DateTime? miadDate;
  final int? shelfNo;
  final int? corpartmentNo;
  final List<String>? activeIngredients;

  const Inconsistency({
    this.id,
    this.cabinDrawerDetail,
    this.medicine,
    this.quantity,
    this.stockEntryQuantity,
    this.stockExitQuantity,
    this.requiredQuantity,
    this.miadDate,
    this.shelfNo,
    this.corpartmentNo,
    this.activeIngredients,
  });

  Inconsistency copyWith({int? id, Station? station, List<Cabin>? cabins}) {
    return Inconsistency(id: id ?? this.id);
  }
}
