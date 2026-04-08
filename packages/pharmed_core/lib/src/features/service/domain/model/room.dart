import 'bed.dart';

class Room {
  final int? id;
  final int? serviceId;
  final String? name;
  final List<Bed> beds;

  int get bedCount => beds.length;

  Room({this.id, this.name, this.serviceId, this.beds = const []});

  Room copyWith({int? id, String? name, int? serviceId, List<Bed>? beds}) {
    return Room(
      id: id ?? this.id,
      name: name ?? this.name,
      serviceId: serviceId ?? this.serviceId,
      beds: beds ?? this.beds,
    );
  }
}
