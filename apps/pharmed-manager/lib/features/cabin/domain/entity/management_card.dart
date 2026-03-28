enum ControlCardType { standard, serum, unknown }

class ManagementCard {
  final int addressIndex; // 1-16

  ManagementCard({required this.addressIndex});

  // UI'da göstermek gerekirse 'a', 'b' harfini döndürür
  String get addressChar => String.fromCharCode('a'.codeUnitAt(0) + addressIndex - 1);
}

class ControlCard {
  final int rowAddress;
  final String rawTypeResponse; // Örn: .250, veya .33, veya .08,
  final ControlCardType type;

  ControlCard({
    required this.rowAddress,
    required this.rawTypeResponse,
  }) : type = _determineType(rawTypeResponse);

  /// REGEX ile ID Çıkarma
  /// .33,  -> 33
  /// .08,  -> 8
  /// .250, -> 250
  int get databaseTypeId {
    final regex = RegExp(r'\.(\d+),');

    final match = regex.firstMatch(rawTypeResponse);
    if (match != null) {
      final idStr = match.group(1) ?? '0';
      return int.tryParse(idStr) ?? 0;
    }

    return 0;
  }

  /// Tip Belirleme
  /// Eğer çıkarılan ID 250 ise bu bir SERUM KABİNİDİR.
  static ControlCardType _determineType(String response) {
    // Yine aynı regex ile kontrol edebiliriz veya contains kullanabiliriz.
    // Ancak regex daha garanti (başka sayıların içinde 250 geçme ihtimaline karşı)
    final regex = RegExp(r'\.(\d+),');
    final match = regex.firstMatch(response);

    if (match != null) {
      final idStr = match.group(1) ?? '0';
      final id = int.tryParse(idStr) ?? 0;

      // KURAL: ID 250 ise Serumdur.
      if (id == 250) {
        return ControlCardType.serum;
      }
    }

    return ControlCardType.standard;
  }
}
