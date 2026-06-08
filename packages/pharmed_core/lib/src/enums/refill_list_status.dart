/// Dolum listesi durumu
enum RefillListStatus {
  toBeCollected(1), // Toplanacak
  collected(2), // Toplandı
  send(3); // Gönderildi

  final int id;

  const RefillListStatus(this.id);

  static RefillListStatus fromId(int? id) {
    return RefillListStatus.values.firstWhere((e) => e.id == id, orElse: () => RefillListStatus.toBeCollected);
  }

  String get label {
    switch (this) {
      case RefillListStatus.toBeCollected:
        return 'Toplanacak';
      case RefillListStatus.collected:
        return 'Toplandı';
      case RefillListStatus.send:
        return 'Gönderildi';
    }
  }

  RefillListStatus get nextStatus {
    switch (this) {
      case RefillListStatus.toBeCollected:
        return RefillListStatus.collected;
      case RefillListStatus.collected:
        return RefillListStatus.send;
      case RefillListStatus.send:
        return RefillListStatus.toBeCollected;
    }
  }
}
