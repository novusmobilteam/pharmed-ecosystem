import '../../../../core/core.dart';
import '../../../prescription/domain/entity/prescription_item.dart';

class DirectedOrder implements TableData {
  final int? id;
  final Station? station;
  final PrescriptionItem? item;

  DirectedOrder({this.id, this.station, this.item});

  @override
  List get content => [station?.name, item?.barcode?.toCustomString(), item?.medicine?.name];

  @override
  List get rawContent => [station?.name, item?.barcode?.toCustomString(), item?.medicine?.name];

  @override
  List<String?> get titles => ['İstasyon', 'Barkod', 'Malzeme'];
}
