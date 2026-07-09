import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';

class Inconsistency implements TableData {
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

  @override
  List<String?> get content => [
    cabinDrawerDetail?.drawerUnit?.drawerSlot?.cabin?.name,
    corpartmentNo?.toCustomString(),
    shelfNo?.toCustomString(),
    medicine?.name,
    // activeIngredients?.first,
    (requiredQuantity ?? 0).toInt().toCustomString(),
    (quantity ?? 0).toInt().toCustomString(),
    //user?.fullName,
  ];

  @override
  List<String?> get titles => [
    contextlessL10n().tableCore_inconsistencyCabinColumn,
    contextlessL10n().tableCore_inconsistencyRowNoColumn,
    contextlessL10n().tableCore_inconsistencyCellColumn,
    contextlessL10n().tableCore_materialColumn,
    //'Etken Madde',
    contextlessL10n().tableCore_inconsistencyExpectedColumn,
    contextlessL10n().tableCore_inconsistencyCountedColumn,
    //'Kullanıcı',
  ];

  @override
  List get rawContent => [
    cabinDrawerDetail?.drawerUnit?.drawerSlot?.cabin?.name,
    corpartmentNo,
    shelfNo,
    medicine?.name,
    requiredQuantity,
    quantity,
    //user?.fullName,
  ];

  Inconsistency copyWith({int? id, Station? station, List<Cabin>? cabins}) {
    return Inconsistency(id: id ?? this.id);
  }
}
