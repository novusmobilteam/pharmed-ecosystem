// [SWREQ-NET-007] Kuyruktaki logları arka planda backend'e gönderir.
//
// - Tek seferde tek gönderim (single-flight); kabin işlemleriyle yarışmaz,
//   hiçbir ekranı beklemez.
// - [LogShippingConfig.flushInterval]'da bir ya da kuyruk dolunca gönderir.
// - Hata olursa kayıtlar kuyrukta kalır; üstel bekleme + jitter ile tekrar
//   dener. Backend kayıt id'si ile çiftleri ayıkladığı için tekrar gönderim
//   güvenlidir.
// - Uzun süre hiçbir şey gönderilmediyse boş gönderim yapar (canlılık).
// - Backend'in reddettiği kayıtlar tekrar gönderilmez.
//
// Sınıf: Class B

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import 'log_shipping.dart';

typedef PostLogBatch = Future<Result<DeviceLogBatchResult>> Function(Map<String, dynamic> body, {String? deviceKey});

class LogUploadWorker {
  LogUploadWorker({
    required LogShipping shipping,
    required PostLogBatch post,
    DateTime Function() clock = DateTime.now,
    Random? random,
  }) : _shipping = shipping,
       _post = post,
       _clock = clock,
       _random = random ?? Random();

  static const _unit = 'SW-UNIT-LOG';
  static const _swreq = 'SWREQ-NET-007';

  final LogShipping _shipping;
  final PostLogBatch _post;
  final DateTime Function() _clock;
  final Random _random;

  Timer? _timer;
  bool _running = false;
  bool _disposed = false;
  int _failures = 0;
  DateTime? _nextAttemptAt;
  DateTime? _lastSentAt;

  void start() {
    final cfg = _shipping.config;
    _shipping.onBatchReady = kick;
    _timer = Timer.periodic(cfg.flushInterval, (_) => kick());
    MedLogger.info(
      unit: _unit,
      swreq: _swreq,
      message: 'Log gönderimi başladı',
      context: {'deviceId': _shipping.device.deviceId, 'appRunId': _shipping.appRunId},
    );
    kick();
  }

  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _shipping.onBatchReady = null;
  }

  /// Bir gönderim turu başlatır; biri sürüyorsa ya da bekleme süresi
  /// dolmadıysa bir şey yapmaz.
  void kick() {
    if (_disposed || _running) return;
    final wait = _nextAttemptAt;
    if (wait != null && _clock().isBefore(wait)) return;
    _running = true;
    _run().whenComplete(() => _running = false);
  }

  Future<void> _run() async {
    final outbox = _shipping.outbox;
    // Önceki batch'ler gönderilmeden yenisi ayrılmaz: ağ yokken her turda
    // yeni küçük dosya birikmesin. current büyüdüyse yine ayrılır.
    final dropped = outbox.batches().isEmpty || outbox.pendingInCurrent >= _shipping.config.batchSize
        ? outbox.seal()
        : 0;
    if (dropped > 0) {
      MedLogger.warn(
        unit: _unit,
        swreq: _swreq,
        message: 'Log kuyruğu boyut sınırını aştı, en eski kayıtlar düşürüldü',
        context: {'dropped': dropped, 'maxBytes': _shipping.config.maxOutboxBytes},
        dedupeKey: 'log-outbox-dropped',
      );
    }

    var sentAny = false;
    for (final batch in outbox.batches()) {
      if (_disposed) return;
      var remaining = outbox.read(batch);
      while (remaining.isNotEmpty) {
        final chunk = _takeChunk(remaining);
        final ok = await _send(chunk);
        if (!ok) {
          outbox.rewrite(batch, remaining);
          return; // bekleme süresi _send içinde ayarlandı
        }
        sentAny = true;
        remaining = remaining.sublist(chunk.length);
      }
      outbox.rewrite(batch, const []);
    }

    // Canlılık sinyali: uzun süredir hiçbir şey gitmediyse boş gönderim.
    final last = _lastSentAt;
    if (!sentAny && (last == null || _clock().difference(last) >= _shipping.config.heartbeatInterval)) {
      await _send(const []);
    }
  }

  /// Sayı ve boyut sınırına sığan ilk kayıtlar (en az bir kayıt).
  List<Map<String, dynamic>> _takeChunk(List<Map<String, dynamic>> entries) {
    final cfg = _shipping.config;
    var bytes = 0;
    var n = 0;
    for (final e in entries) {
      if (n >= cfg.batchSize) break;
      final size = utf8.encode(jsonEncode(e, toEncodable: (o) => o.toString())).length;
      if (n > 0 && bytes + size > cfg.maxBatchBytes) break;
      bytes += size;
      n++;
    }
    return entries.sublist(0, n);
  }

  Future<bool> _send(List<Map<String, dynamic>> entries) async {
    final stationId = MedLogger.session['stationId'];
    final body = {
      'device': _shipping.device.toJson(stationId: stationId is int ? stationId : null),
      'entries': entries,
    };
    final result = await _post(body, deviceKey: _shipping.config.deviceKey);
    return result.when(
      ok: (r) {
        _failures = 0;
        _nextAttemptAt = null;
        _lastSentAt = _clock();
        if (r.rejected.isNotEmpty) {
          // Reddedilen kayıtlar tekrar gönderilmez; sebebi yerel logda kalsın.
          MedLogger.warn(
            unit: _unit,
            swreq: _swreq,
            message: 'Backend bazı log kayıtlarını reddetti',
            context: {'rejected': r.rejected.length, 'sample': r.rejected.entries.take(3).map((e) => '${e.key}: ${e.value}').toList()},
            dedupeKey: 'log-rejected',
          );
        }
        return true;
      },
      error: (e) {
        _failures++;
        final delay = _backoff(_failures, e);
        _nextAttemptAt = _clock().add(delay);
        MedLogger.warn(
          unit: _unit,
          swreq: _swreq,
          message: 'Log gönderilemedi, ${delay.inSeconds} sn sonra tekrar denenecek',
          context: {...e.logContext, 'failures': _failures, 'pending': entries.length},
          dedupeKey: 'log-upload-failed:${e.runtimeType}',
        );
        return false;
      },
    );
  }

  /// Üstel bekleme + %20 jitter. Endpoint yoksa (404) doğrudan en uzun süre.
  Duration _backoff(int failures, AppException e) {
    final cfg = _shipping.config;
    if (e is ServiceException && e.statusCode == 404) return cfg.maxBackoff;
    final base = cfg.baseBackoff.inMilliseconds * pow(2, min(failures - 1, 10));
    final capped = min(base.toDouble(), cfg.maxBackoff.inMilliseconds.toDouble());
    final jitter = capped * 0.2 * (_random.nextDouble() * 2 - 1);
    return Duration(milliseconds: (capped + jitter).round().clamp(1000, cfg.maxBackoff.inMilliseconds));
  }
}
