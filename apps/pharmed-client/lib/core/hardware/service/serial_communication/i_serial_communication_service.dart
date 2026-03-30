// apps/pharmed-client/lib/core/hardware/service/i_serial_communication_service.dart

/// SERİ PORT HABERLEŞMESİ INTERFACE'İ
/// -----------------------------------
/// Kartlarla olan tüm seri port iletişimini soyutlar.
/// Timeout yönetimi, hata kontrolü ve bağlantı yönetimi
/// implementasyonda ele alınır.
///
/// İKİ İMPLEMENTASYON:
///   - SerialCommunicationService: Gerçek seri port (flutter_libserialport)
///   - MockSerialCommunicationService: Simülasyon (mock flavor)
abstract interface class ISerialCommunicationService {
  /// Port bağlı mı?
  bool get isConnected;

  /// Sistemde kullanılabilir COM portlarını listeler.
  List<String> getAvailablePorts();

  /// Belirtilen seri porta bağlanır.
  ///
  /// İlk olarak [portName] denenir, başarısız olursa diğer mevcut
  /// portlar otomatik taranır.
  ///
  /// [onStatusChanged]: Bağlantı aşamalarını UI'a bildirmek için callback.
  ///
  /// Throws [SerialPortException] hiçbir porta bağlanılamazsa.
  Future<void> connectToPort(String portName, {Function(String message)? onStatusChanged});

  /// Porta komut gönderir ve cevap bekler.
  ///
  /// Aynı anda sadece bir komut işlenir (mutex).
  /// Cevap [timeout] süresi içinde gelmezse `null` döner.
  ///
  /// [command]: Gönderilecek komut stringi
  /// [timeout]: Maksimum bekleme süresi (varsayılan: 500ms)
  ///
  /// Throws [SerialPortException] bağlantı yoksa veya yazma başarısızsa.
  Future<String?> sendAndReceive(String command, {Duration? timeout});

  /// Bağlantıyı kapatır ve tüm kaynakları serbest bırakır.
  Future<void> disconnect();
}
