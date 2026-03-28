import 'dart:convert';
// ignore_for_file: unintended_html_in_doc_comment

/// Komut tiplerini belirleyen Enum
/// Hata yapma riskini (örn: 'O' yerine '0' yazmak) ortadan kaldırır.
enum DeviceAction {
  open('O'),
  close('C'),
  status('S'),
  ping('M'),
  type('V'),
  reset('R');

  final String code;
  const DeviceAction(this.code);
}

/// Kart haberleşme komutları oluşturucu
class CommandBuilder {
  // Sabitler
  static const _managementPrefix = 'Y';
  static const _drawerPrefix = 'T';
  static const _cubicPrefix = 'Z';

  /// Yönetim kartı komutu oluşturur
  ///
  /// [addressIndex]: 1 ile 16 arası (1='a', 16='p')
  /// [row]: 0 ile 26 arası satır no
  ///
  /// Örn: addressIndex: 1, row: 1 -> :Ya017;
  static String buildManagementCommand({
    required int addressIndex,
    required int row,
  }) {
    // 1. Validasyonlar
    if (addressIndex < 1 || addressIndex > 16) {
      throw ArgumentError('Adres indeksi 1-16 arasında olmalı (a-p)');
    }
    if (row < 0 || row > 26) {
      throw ArgumentError('Satır 0-26 arasında olmalı');
    }

    // 2. Dönüşümler
    // 1 -> 'a', 2 -> 'b' dönüşümü
    final int addressCharParams = 'a'.codeUnitAt(0) + addressIndex - 1;
    final String addressChar = String.fromCharCode(addressCharParams);

    // 1 -> "01" dönüşümü
    final String rowStr = row.toString().padLeft(2, '0');

    // 3. Checksum Hesaplama
    // Protokol: c = (Y ascii + a ascii + tt) % 10
    // Not: tt direkt sayısal değer olarak toplanır.
    final int yAscii = _managementPrefix.codeUnitAt(0);
    final int sum = yAscii + addressCharParams + row;
    final int checksum = sum % 10;

    // 4. Paketleme
    return ':$_managementPrefix$addressChar$rowStr$checksum;';
  }

  /// Çekmece kontrol komutu oluşturur
  ///
  /// [action]: Enum olarak işlem tipi (Aç, Kapat, Durum...)
  /// [port]: 1-8 arası port
  /// [drawer]: 1-16 arası çekmece veya 20 (Döner motor)
  static String buildDrawerCommand({
    required DeviceAction action,
    required int port,
    required int drawer,
  }) {
    // Validasyonlar
    if (port < 1 || port > 8) {
      throw ArgumentError('Port 1-8 arasında olmalı');
    }

    // Çekmece 0-16 arası VEYA 20 olabilir. (0 genellikle dolaptır)
    final bool isValidDrawer = (drawer >= 0 && drawer <= 16) || drawer == 20 || drawer == 30;
    if (!isValidDrawer) {
      throw ArgumentError('Çekmece 00-16 arası veya 20 olmalı');
    }

    final String portStr = port.toString(); // Tek haneli port (1-8)
    final String drawerStr = drawer.toString().padLeft(2, '0'); // Çift haneli (01)

    // Checksum Hesaplama
    // Protokol: c = (T ascii + k ascii + a + tt) % 10
    // T: Prefix, k: Action code, a: port (int), tt: drawer (int)
    final int tAscii = _drawerPrefix.codeUnitAt(0);
    final int kAscii = action.code.codeUnitAt(0);
    final int sum = tAscii + kAscii + port + drawer;
    final int checksum = sum % 10;

    return ':$_drawerPrefix${action.code}$portStr$drawerStr$checksum;';
  }

  /// Kübik kontrol komutu oluşturur
  static String buildCubicCommand({
    required DeviceAction action,
    required int port,
    required int row,
  }) {
    if (port < 1 || port > 4) {
      throw ArgumentError('Kübik portu 1-4 arasında olmalı');
    }
    if (row < 0 || row > 4) {
      throw ArgumentError('Kübik sıra no 0-4 arasında olmalı');
    }

    final String portStr = port.toString();
    final String rowStr = row.toString().padLeft(2, '0');

    // Checksum Hesaplama
    // Protokol: c = (Z ascii + k ascii + a + tt) % 10
    // Not: Protokol metninde formülde T yazıyor olabilir ama Z komutu için Z ascii kullanılır.
    final int zAscii = _cubicPrefix.codeUnitAt(0);
    final int kAscii = action.code.codeUnitAt(0);
    final int sum = zAscii + kAscii + port + row;
    final int checksum = sum % 10;

    return ':$_cubicPrefix${action.code}$portStr$rowStr$checksum;';
  }

  /// C# 'SogukZincirConvertMessage' metodunun BİREBİR karşılığı

  /// Yapı: <t{Adres}{Komut}{Checksum}>
  /// Örnek: Adres 1, Komut 'a' için -> <t1a5>
  static String buildSerumCommand({
    required int addressIndex,
    required String commandChar,
  }) {
    // 1. Prefix ve Adres (C# kodunda "t1" kısmı)
    final String prefix = "t";
    final String addressStr = addressIndex.toString();

    // 2. Mesaj Gövdesi: "t1a"
    // C#: ConvertedMessage = "t1" + Islem;
    String payload = "$prefix$addressStr$commandChar";

    // 3. Checksum Hesabı
    // C#: for (int i = 0; i < 2; i++) -> Sadece ilk 2 byte toplanıyor (t ve 1)
    // Komut karakteri (a, b) toplama dahil DEĞİL.
    int sum = 0;

    // 't' harfinin ASCII değeri
    sum += ascii.encode(prefix)[0];

    // Adres stringinin ilk karakterinin ASCII değeri (Örn: '1')
    // C# kodu sadece tek haneli adresler için 'i < 2' mantığıyla çalışıyor gibi görünüyor.
    // Biz de ilk haneyi alalım.
    if (addressStr.isNotEmpty) {
      sum += ascii.encode(addressStr.substring(0, 1))[0];
    }

    // Toplamın son hanesi
    String sSum = sum.toString();
    String checksumDigit = sSum.substring(sSum.length - 1);

    // 4. Paketle: <t1a5>
    // C#: ConvertedMessage += sSum; -> t1a5
    // C#: ConvertedMessage = "<" + ... + ">";
    return "<$payload$checksumDigit>";
  }
}
