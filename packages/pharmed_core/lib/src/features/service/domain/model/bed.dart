import 'package:pharmed_core/pharmed_core.dart';

class Bed extends Selectable {
  final int? id;
  final int? roomId;
  final String? name;

  Bed({this.id, this.name, this.roomId}) : super(title: name.toString());

  Bed copyWith({int? id, String? name, int? roomId}) {
    return Bed(id: id ?? this.id, name: name ?? this.name, roomId: roomId ?? this.roomId);
  }
}
