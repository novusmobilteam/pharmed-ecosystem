/// Dolum listesi durumu
enum FillingRecordStatus {
  toBeCollected(1), // Toplanacak
  collected(2), // Toplandı
  send(3); // Gönderildi

  final int id;

  const FillingRecordStatus(this.id);

  static FillingRecordStatus fromId(int? id) {
    return FillingRecordStatus.values.firstWhere(
      (e) => e.id == id,
      orElse: () => FillingRecordStatus.toBeCollected,
    );
  }

  String get label {
    switch (this) {
      case FillingRecordStatus.toBeCollected:
        return 'Toplanacak';
      case FillingRecordStatus.collected:
        return 'Toplandı';
      case FillingRecordStatus.send:
        return 'Gönderildi';
    }
  }

  FillingRecordStatus get nextStatus {
    switch (this) {
      case FillingRecordStatus.toBeCollected:
        return FillingRecordStatus.collected;
      case FillingRecordStatus.collected:
        return FillingRecordStatus.send;
      case FillingRecordStatus.send:
        return FillingRecordStatus.toBeCollected;
    }
  }
}
