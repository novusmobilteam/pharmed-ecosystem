import 'package:pharmed_core/pharmed_core.dart';

class Room extends Selectable {
  final int? id;
  final int? serviceId;
  final String? name;
  final List<Bed> beds;

  int get bedCount => beds.length;

  Room({this.id, this.name, this.serviceId, this.beds = const []}) : super(title: name.toString());

  Room copyWith({int? id, String? name, int? serviceId, List<Bed>? beds}) {
    return Room(
      id: id ?? this.id,
      name: name ?? this.name,
      serviceId: serviceId ?? this.serviceId,
      beds: beds ?? this.beds,
    );
  }
}
