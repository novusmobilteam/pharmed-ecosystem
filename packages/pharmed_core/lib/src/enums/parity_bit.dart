enum ParityBit {
  none(id: 1, label: 'Hiçbiri'),
  even(id: 2, label: 'Çift'),
  odd(id: 3, label: 'Tek');

  const ParityBit({required this.id, required this.label});

  final int id;
  final String label;

  static ParityBit? fromId(int? id) {
    return ParityBit.values.firstWhere(
      (e) => e.id == id,
      orElse: () => ParityBit.none,
    );
  }
}
