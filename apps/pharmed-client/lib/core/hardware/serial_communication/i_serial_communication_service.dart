/// Seri port üzerinden cihazlarla haberleşmeyi yöneten servis.
///
/// Bu servis, kartlarla olan tüm seri port iletişimini soyutlar ve
/// tekrar kullanılabilir metodlar sunar. Timeout yönetimi, hata kontrolü
/// ve bağlantı yönetimi otomatik olarak yapılır.
abstract class ISerialCommunicationService {
  bool get isConnected;

  /// Sistemdeki mevcut ve aktif seri portların isimlerini listeler.
  List<String> getAvailablePorts();

  /// Belirtilen seri porta bağlanır.
  ///
  /// Bağlantı başarılı olmazsa [SerialPortException] fırlatır.
  ///
  /// - [portName]: Bağlanılacak portun adı (Ör: 'COM3', '/dev/ttyUSB0')
  /// - [onStatusChanged]: Bağlantı işlemi sırasında kullanıcıya bilgi vermek için
  ///   kullanılan loglar.
  ///
  /// ## Örnek
  /// ```dart
  /// await connectToPort('COM3');
  /// ```
  ///
  Future<void> connectToPort(String portName, {Function(String message)? onStatusChanged});

  /// Seri porta komut gönderir ve cevap bekler.
  ///
  /// Belirtilen timeout süresi içinde cevap alınamazsa `null` döndürür.
  /// Aynı anda birden fazla komut gönderilmesi durumunda hata fırlatır.
  ///
  /// - [command]: Gönderilecek komut stringi
  /// - [timeout]: Maksimum bekleme süresi (varsayılan: 1000ms)
  ///
  /// ## Dönüş Değeri
  /// Cihazdan gelen cevap stringi veya timeout durumunda `null`
  ///
  /// ## Hatalar
  /// - [SerialPortException]: Önceki komut tamamlanmamışsa
  ///
  /// ## Örnek
  /// ```dart
  /// final response = await sendAndReceive(
  ///   ':Ya010;',
  ///   timeout: Duration(milliseconds: 500),
  /// );
  /// ```
  ///
  Future<String?> sendAndReceive(String command, {Duration? timeout});

  /// Seri port bağlantısını kapatır ve kaynakları serbest bırakır.
  ///
  /// Bu metod, servis kullanımı bittiğinde mutlaka çağrılmalıdır.
  ///
  /// ## Örnek
  /// ```dart
  /// await disconnect();
  /// ```
  Future<void> disconnect();
}
