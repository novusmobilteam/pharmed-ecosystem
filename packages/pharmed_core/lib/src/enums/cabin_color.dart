enum CabinColor {
  blue(label: 'Mavi', hex: '#007bff'),
  turquoise(label: 'Turkuaz', hex: '#17a2b8'),
  green(label: 'Yeşil', hex: '#28a745'),
  red(label: 'Kırmızı', hex: '#dc3545'),
  orange(label: 'Turuncu', hex: '#fd7e14'),
  purple(label: 'Mor', hex: '#6f42c1'),
  grey(label: 'Gri', hex: '#6c757d'),
  black(label: 'Siyah', hex: '#343a40'),
  white(label: 'Beyaz', hex: '#f8f9fa');

  final String label;
  final String hex;

  const CabinColor({required this.label, required this.hex});

  static CabinColor? fromHex(String? hex) {
    return CabinColor.values.firstWhere(
      (e) => e.hex == hex,
      orElse: () => CabinColor.blue,
    );
  }
}
