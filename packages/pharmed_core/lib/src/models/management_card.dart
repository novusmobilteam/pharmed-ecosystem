// apps/pharmed-client/lib/core/hardware/model/management_card.dart

/// YÖNETIM KARTI MODELİ
/// --------------------
/// Kabinin ana yönetim kartını temsil eder.
/// Seri port üzerinden 1-16 arası adreslerden biri taranarak bulunur.
///
/// [addressIndex]: Kartın fiziksel adresi (1-16)
/// [addressChar]: UI gösterimi için harf karşılığı ('a'-'p')
class ManagementCard {
  const ManagementCard({required this.addressIndex});

  /// Fiziksel adres indeksi (1-16)
  final int addressIndex;

  /// Adresin harf karşılığı: 1→'a', 2→'b', ... 16→'p'
  String get addressChar => String.fromCharCode('a'.codeUnitAt(0) + addressIndex - 1);

  /// 'a'/'A' → 1, 'b'/'B' → 2, ... 'p'/'P' → 16.
  /// Geçersiz/boş girişte null döner.
  static int? indexFromAddressChar(String? addressChar) {
    if (addressChar == null || addressChar.trim().isEmpty) return null;
    final normalized = addressChar.trim().toLowerCase();
    if (normalized.length != 1) return null;

    final code = normalized.codeUnitAt(0);
    final aCode = 'a'.codeUnitAt(0);
    final pCode = 'p'.codeUnitAt(0);
    if (code < aCode || code > pCode) return null;

    return code - aCode + 1;
  }

  @override
  String toString() => 'ManagementCard(address: $addressIndex/$addressChar)';
}
