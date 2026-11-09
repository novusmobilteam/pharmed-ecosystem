// [SWREQ-NET-007] Log gönderiminin uygulama içindeki tek giriş noktası.
//
// Açılışta (initAppLogging) kurulur ki ilk satırlar da kuyruğa girsin; ağ
// gerektiren gönderici (LogUploadWorker) Riverpod hazır olunca bağlanır.
//
// Sınıf: Class B

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:pharmed_ui/pharmed_ui.dart';

import 'device_identity.dart';
import 'device_log_mapper.dart';
import 'log_outbox.dart';
import 'log_shipping_config.dart';

class LogShipping {
  LogShipping._({required this.config, required this.device, required this.appRunId, required this.outbox});

  /// Gönderim kapalıysa null.
  static LogShipping? instance;

  final LogShippingConfig config;
  final DeviceIdentity device;
  final String appRunId;
  final LogOutbox outbox;

  /// Kuyruk [LogShippingConfig.batchSize]'a ulaşınca çağrılır — gönderici
  /// zamanlayıcıyı beklemeden gönderir.
  void Function()? onBatchReady;

  /// Gönderim kapalıysa hiçbir şey yapmaz (kuyruğa da yazmaz).
  static LogShipping? init({required LogShippingConfig config, required String dataRoot, required String flavor}) {
    if (!config.enabled) return null;
    final outbox = LogOutbox(directory: Directory(p.join(dataRoot, 'log-outbox')), maxBytes: config.maxOutboxBytes)
      ..ensureCreated();
    final shipping = LogShipping._(
      config: config,
      device: DeviceIdentity.load(dataRoot: dataRoot, appVersion: config.appVersion, flavor: flavor),
      appRunId: uuidV4(),
      outbox: outbox,
    );
    MedLogger.addSink(_ShippingSink(shipping));
    return instance = shipping;
  }
}

/// INFO+ kayıtları sözleşme gövdesine çevirip kuyruğa yazar. DEBUG kayıtları
/// MedLogger zaten sink'lere iletmez; mapper da ayrıca eler.
class _ShippingSink implements LogSink {
  _ShippingSink(this._shipping);

  final LogShipping _shipping;

  @override
  void write(LogEntry entry) {
    final json = DeviceLogMapper.toJson(entry, appRunId: _shipping.appRunId);
    if (json == null) return;
    final outbox = _shipping.outbox;
    outbox.append(json);
    if (outbox.pendingInCurrent >= _shipping.config.batchSize) _shipping.onBatchReady?.call();
  }
}
