// pharmed_core/lib/src/services/printer/printer_config.dart
//
// [SWREQ-PRN-004]
// Kiosk bazında saklanan termal yazıcı bağlantı ayarı.
//
// Sınıf: Class B

enum PrinterConnectionType {
  /// Seri port (USB-TTL dönüştürücü) — sahadaki hedef bağlantı.
  serial,

  /// Windows yazıcı kuyruğuna RAW gönderim (USB yazıcı sınıfı, geliştirme/test).
  windowsSpooler,
}

final class PrinterConfig {
  const PrinterConfig({required this.connectionType, required this.target, this.baudRate = defaultBaudRate});

  /// EM5820 fabrika ayarı. Yazıcı üretici aracıyla 115200'e alınırsa ayar
  /// ekranından değiştirilir (uzun listelerde ~12 kat hızlı gönderim).
  static const defaultBaudRate = 9600;

  final PrinterConnectionType connectionType;

  /// Seri bağlantıda port adı (örn. "COM5"), kuyrukta Windows yazıcı adı (örn. "POS-58").
  final String target;

  /// Yalnızca seri bağlantıda kullanılır.
  final int baudRate;

  bool get isValid => target.trim().isNotEmpty && baudRate > 0;

  PrinterConfig copyWith({PrinterConnectionType? connectionType, String? target, int? baudRate}) {
    return PrinterConfig(
      connectionType: connectionType ?? this.connectionType,
      target: target ?? this.target,
      baudRate: baudRate ?? this.baudRate,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is PrinterConfig &&
      other.connectionType == connectionType &&
      other.target == target &&
      other.baudRate == baudRate;

  @override
  int get hashCode => Object.hash(connectionType, target, baudRate);

  @override
  String toString() => 'PrinterConfig(${connectionType.name}, $target, $baudRate)';
}
