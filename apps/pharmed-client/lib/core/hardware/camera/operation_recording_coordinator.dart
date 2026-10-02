import 'dart:async';
import 'dart:math';

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import 'package:pharmed_client/core/hardware/cabin/master_drawer/master_drawer_stage.dart';
import 'package:pharmed_client/core/hardware/camera/camera_recorder_pool.dart';

/// İşlemi yapan kullanıcı (auth state'ten çözülür).
typedef RecordingUser = ({int? id, String? fullName});

/// Kabin operasyonları ile kamera kaydedicileri arasındaki köprü.
///
/// - GLOBAL'dir: tüm feature'lar aynı koordinatörü kullanır; begin/end tek
///   sıraya dizilir, bir operasyonun kaydı kapanmadan diğeri başlamaz. [SWREQ-CAM-013]
/// - Operasyonun kabinlerine hizmet veren TÜM kameralar birlikte kayda girer;
///   her kamera kendi dosyasını üretir. [SWREQ-CAM-054]
/// - Politika BEST-EFFORT: kamera başlatılamazsa operasyon devam eder,
///   neden ilgili CameraTrack'e yazılır.
class OperationRecordingCoordinator {
  OperationRecordingCoordinator({
    required CameraRecorderPool pool,
    required IOperationRecordingOutbox outbox,
    required RecordingUser Function() currentUser,
    DateTime Function() clock = DateTime.now,
    String Function()? idGenerator,
  }) : _pool = pool,
       _outbox = outbox,
       _currentUser = currentUser,
       _clock = clock,
       _idGenerator = idGenerator ?? _defaultId;

  static const _unit = 'SW-UNIT-CAM';
  static final _rng = Random.secure();

  /// Zamana göre sıralanabilir + rastgele ek: istasyonlar arası çakışmaz.
  static String _defaultId() {
    final time = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    final rand = List.generate(4, (_) => _rng.nextInt(36).toRadixString(36)).join();
    return '$time-$rand';
  }

  /// Kaydedici oturum kimliği: staging dosya adından operasyon ve kamera
  /// geri çözülebilsin diye (`<opId>--<cameraId>_<ms>.mp4`).
  static String sessionIdFor(String operationId, String cameraId) => '$operationId--$cameraId';

  final CameraRecorderPool _pool;
  final IOperationRecordingOutbox _outbox;
  final RecordingUser Function() _currentUser;
  final DateTime Function() _clock;
  final String Function() _idGenerator;

  OperationRecordingHandle? _active;
  Future<void> _tail = Future<void>.value();

  /// Bir operasyon sürüyor mu? Upload worker bu sırada duraklar.
  bool get hasActiveOperation => _active != null;

  /// Operasyon başında çağrılır. Kamera olmasa/başlamasa bile HER ZAMAN bir
  /// handle döner; operasyonun tüm çıkış noktalarında `handle.end()` çağrılmalı.
  /// İlk çekmece açılmadan ÖNCE await edilmeli (~1,4 sn). [SWREQ-CAM-010]
  Future<OperationRecordingHandle> begin({required RecordedOperationType type, required Set<int> cabinIds}) =>
      _serialize(() => _doBegin(type: type, cabinIds: cabinIds));

  Future<void> dispose() => _pool.dispose();

  // ---------------------------------------------------------------------------

  Future<OperationRecordingHandle> _doBegin({required RecordedOperationType type, required Set<int> cabinIds}) async {
    final previous = _active;
    if (previous != null) {
      MedLogger.warn(
        unit: _unit,
        swreq: 'SWREQ-CAM-013',
        message: 'Önceki operasyon kaydı kapatılmadan yeni operasyon başladı',
        context: {'previousOperationId': previous.operationId},
      );
      previous._ended = true;
      await _doEnd(previous, OperationEndReason.superseded, _clock());
    }

    final operationId = _idGenerator();
    final startedAt = _clock();
    final user = _currentUser();
    final cameras = await _pool.resolveFor(cabinIds);

    // [SWREQ-CAM-021] Write-ahead: kayıt başlamadan operasyon bilgisi diske.
    await _outbox.stage(
      OperationRecordingStart(
        operationId: operationId,
        type: type,
        cabinIds: cabinIds,
        startedAt: startedAt,
        cameras: {for (final c in cameras) c.device.id: c.device.name},
        userId: user.id,
        userFullName: user.fullName,
      ),
    );

    // Kameralar paralel başlar — toplam bekleme en yavaş kamera kadar.
    final tracks = await Future.wait(cameras.map((c) => _startTrack(operationId, c)));

    final handle = OperationRecordingHandle._(
      this,
      operationId: operationId,
      type: type,
      cabinIds: cabinIds,
      startedAt: startedAt,
      userId: user.id,
      userFullName: user.fullName,
      tracks: tracks,
    );
    for (final t in tracks) {
      final recorder = t.recorder;
      if (recorder == null) continue;
      t.subscription = recorder.statusStream.listen((s) => _onTrackStatus(handle, t, s));
    }
    _active = handle;

    MedLogger.info(
      unit: _unit,
      swreq: 'SWREQ-CAM-010',
      message: cameras.isEmpty ? 'Operasyon başladı (kabinlere atanmış kamera yok)' : 'Operasyon kaydı başladı',
      context: {
        'operationId': operationId,
        'type': type.name,
        'cabinIds': cabinIds.toList(),
        'cameras': {for (final t in tracks) t.device.name: t.failure?.name ?? 'recording'},
      },
    );
    return handle;
  }

  Future<_TrackState> _startTrack(String operationId, ResolvedCamera camera) async {
    final recorder = camera.recorder;
    if (recorder == null) return _TrackState(camera.device, null, camera.failure);

    final result = await recorder.start(sessionId: sessionIdFor(operationId, camera.device.id));
    final failure = result.when<CameraRecordingFailureReason?>(
      ok: (_) => null,
      error: (e) => e is CameraRecordingException ? e.reason : CameraRecordingFailureReason.unexpected,
    );
    if (failure != null) {
      MedLogger.warn(
        unit: _unit,
        swreq: 'SWREQ-CAM-010',
        message: 'Kamera kayda başlayamadı, operasyon bu kamera olmadan devam ediyor',
        context: {'operationId': operationId, 'camera': camera.device.name, 'reason': failure.name},
      );
    }
    return _TrackState(camera.device, failure == null ? recorder : null, failure);
  }

  void _onTrackStatus(OperationRecordingHandle handle, _TrackState track, CameraRecorderStatus status) {
    if (status is! RecorderInterrupted || handle._ended) return;
    handle._addMarker(RecordingMarkerType.recordingInterrupted, cameraId: track.device.id);
    MedLogger.warn(
      unit: _unit,
      swreq: 'SWREQ-CAM-011',
      message: 'Operasyon bitmeden kamera kaydı kesildi',
      context: {'operationId': handle.operationId, 'camera': track.device.name, 'reason': status.reason.name},
    );
  }

  Future<void> _scheduleEnd(OperationRecordingHandle handle, OperationEndReason reason) {
    final endedAt = _clock(); // operasyonun bittiği an, sıra beklemesinden bağımsız
    return _serialize(() => _doEnd(handle, reason, endedAt));
  }

  Future<void> _doEnd(OperationRecordingHandle handle, OperationEndReason reason, DateTime endedAt) async {
    // Handle hem "superseded" ile hem de sırada bekleyen kendi end()'i ile
    // kapatılmaya çalışılabilir; ikincisi YENİ operasyonun kaydını durdurmamalı.
    if (handle._finalized) return;
    handle._finalized = true;
    if (identical(_active, handle)) _active = null;

    for (final t in handle._tracks) {
      await t.subscription?.cancel();
    }

    // Kameralar paralel durur.
    final tracks = await Future.wait(
      handle._tracks.map((t) async {
        RecordingFile? video;
        final recorder = t.recorder;
        if (recorder != null) {
          // Hata durumu kaydedici tarafından zaten loglanıyor.
          video = (await recorder.stop()).when(ok: (f) => f, error: (_) => null);
        }
        return CameraTrack(cameraId: t.device.id, cameraName: t.device.name, video: video, failure: t.failure);
      }),
    );

    final recording = OperationRecording(
      operationId: handle.operationId,
      type: handle.type,
      cabinIds: handle.cabinIds,
      startedAt: handle.startedAt,
      endedAt: endedAt,
      endReason: reason,
      markers: List.unmodifiable(handle._markers),
      tracks: tracks,
      userId: handle.userId,
      userFullName: handle.userFullName,
    );

    final committed = await _outbox.commit(recording);
    committed.when(
      ok: (_) => MedLogger.info(
        unit: _unit,
        swreq: 'SWREQ-CAM-012',
        message: 'Operasyon kaydı kapatıldı',
        context: {
          'operationId': recording.operationId,
          'endReason': reason.name,
          'videos': tracks.where((t) => t.hasVideo).length,
          'markers': recording.markers.length,
        },
      ),
      error: (e) => MedLogger.error(
        unit: _unit,
        swreq: 'SWREQ-CAM-012',
        message: 'Operasyon kaydı arşivlenemedi (${recording.operationId}); açılışta kurtarılacak',
        error: e,
      ),
    );
  }

  /// Görevleri sırayla çalıştırır; bir görevin hatası sırayı kırmaz.
  Future<T> _serialize<T>(Future<T> Function() task) {
    final completer = Completer<T>();
    _tail = _tail.then((_) async {
      try {
        completer.complete(await task());
      } catch (e, st) {
        MedLogger.error(
          unit: _unit,
          swreq: 'SWREQ-CAM-013',
          message: 'Operasyon kaydı işleminde beklenmeyen hata',
          error: e,
          stackTrace: st,
        );
        completer.completeError(e, st);
      }
    });
    return completer.future;
  }
}

class _TrackState {
  _TrackState(this.device, this.recorder, this.failure);
  final CameraDevice device;

  /// Kayda başladıysa kaydedici; başlamadıysa null.
  final IOperationRecorder? recorder;
  final CameraRecordingFailureReason? failure;
  StreamSubscription<CameraRecorderStatus>? subscription;
}

/// Tek bir operasyonun kaydı. Feature (mixin) bunu tutar.
final class OperationRecordingHandle {
  OperationRecordingHandle._(
    this._coordinator, {
    required this.operationId,
    required this.type,
    required this.cabinIds,
    required this.startedAt,
    required List<_TrackState> tracks,
    this.userId,
    this.userFullName,
  }) : _tracks = tracks;

  final OperationRecordingCoordinator _coordinator;
  final String operationId;
  final RecordedOperationType type;
  final Set<int> cabinIds;
  final DateTime startedAt;
  final int? userId;
  final String? userFullName;
  final List<_TrackState> _tracks;

  final _markers = <RecordingMarker>[];

  /// end() çağrıldı (yeni işaret kabul edilmez).
  bool _ended = false;

  /// Koordinatör kaydı durdurup outbox'a verdi.
  bool _finalized = false;

  /// Operasyonun kabinlerine atanmış kamera var mı?
  bool get hasCameras => _tracks.isNotEmpty;

  /// En az bir kamera kayıtta mı? (Zorunlu kayıt politikası buna bakacak.)
  bool get cameraStarted => _tracks.any((t) => t.recorder != null);

  bool get isEnded => _ended;

  /// Çekmece/kapak stage geçişini işaret olarak düşer. [SWREQ-CAM-011]
  void markDrawerStage(MasterDrawerStage? previous, MasterDrawerStage current, {int? cabinDrawerId}) {
    final type = switch (current) {
      // MasterDrawerExecutionMixin ile aynı ayrım: ana çekmecenin ilk açılışı
      // WaitingForPull'dan, kapak açılışı OpeningLid/LidFailed'dan gelir.
      MasterDrawerOpened() when previous is MasterDrawerWaitingForPull => RecordingMarkerType.drawerOpened,
      MasterDrawerOpened() when previous is MasterDrawerOpeningLid || previous is MasterDrawerLidFailed =>
        RecordingMarkerType.lidOpened,
      MasterDrawerLidClosed() => RecordingMarkerType.lidClosed,
      MasterDrawerLidFailed() => RecordingMarkerType.lidFailed,
      MasterDrawerClosed() => RecordingMarkerType.drawerClosed,
      MasterDrawerFailed() => RecordingMarkerType.drawerFailed,
      _ => null,
    };
    if (type != null) _addMarker(type, cabinDrawerId: cabinDrawerId);
  }

  /// Operasyonu kapatır: kayıtları durdurur ve outbox'a verir. İdempotent —
  /// ikinci çağrı yok sayılır, ilk verilen [reason] geçerlidir. [SWREQ-CAM-012]
  Future<void> end(OperationEndReason reason) {
    if (_ended) return Future<void>.value();
    _ended = true;
    return _coordinator._scheduleEnd(this, reason);
  }

  void _addMarker(RecordingMarkerType type, {int? cabinDrawerId, String? cameraId}) {
    if (_ended) return;
    _markers.add(
      RecordingMarker(type: type, at: _coordinator._clock(), cabinDrawerId: cabinDrawerId, cameraId: cameraId),
    );
  }
}
