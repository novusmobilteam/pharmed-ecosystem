enum RequestType {
  normal(1),
  emergency(2);

  final int id;

  const RequestType(this.id);

  static RequestType fromId(int? id) {
    return RequestType.values.firstWhere(
      (e) => e.id == id,
      orElse: () => RequestType.normal,
    );
  }

  String get label {
    switch (this) {
      case RequestType.normal:
        return 'Normal İstem';
      case RequestType.emergency:
        return 'Acil İstem';
    }
  }
}
