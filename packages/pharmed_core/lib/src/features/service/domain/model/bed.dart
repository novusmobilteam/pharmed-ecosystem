class Bed {
  final int? id;
  final int? roomId;
  final String? name;

  Bed({this.id, this.name, this.roomId});

  Bed copyWith({int? id, String? name, int? roomId}) {
    return Bed(id: id ?? this.id, name: name ?? this.name, roomId: roomId ?? this.roomId);
  }
}
