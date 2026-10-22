// [SWREQ-MGR-CAM-001] [IEC 62304 §5.5]
// Bir kabin operasyonunun kamera kaydını izleme: kaydı sunucudan okur,
// seçili kameranın videosunu oynatır, olaylara (işaretlere) atlar.
// Sınıf: Class B

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import 'package:pharmed_manager/core/core.dart';

class OperationRecordingNotifier extends ChangeNotifier with ApiRequestMixin {
  OperationRecordingNotifier({
    required this.operationId,
    required GetOperationRecordingUseCase getRecording,
    required GetRecordingVideoSourceUseCase getVideoSource,
  }) : _getRecording = getRecording,
       _getVideoSource = getVideoSource {
    _errorSub = _player.stream.error.listen(_onPlaybackError);
  }

  /// Satırın sunucu operationId'si. Kayda bağlı id'lerden herhangi biri hem
  /// kaydı hem videoları açar.
  final int operationId;
  final GetOperationRecordingUseCase _getRecording;
  final GetRecordingVideoSourceUseCase _getVideoSource;

  /// Olaya atlarken öncesinden gösterilen süre — olayın hemen öncesi de görünsün.
  static const _seekPreRoll = Duration(seconds: 1);

  final OperationKey _fetchOp = OperationKey.custom('fetch-operation-recording');

  final Player _player = Player();
  late final VideoController videoController = VideoController(_player);
  StreamSubscription<String>? _errorSub;

  OperationRecordingDetail? _detail;
  OperationRecordingDetail? get detail => _detail;

  bool _loaded = false;

  String? _selectedCameraId;
  String? get selectedCameraId => _selectedCameraId;

  bool _playbackFailed = false;
  bool get playbackFailed => _playbackFailed;

  bool get isFetching => isLoading(_fetchOp);
  bool get hasLoadError => isFailed(_fetchOp);

  /// İstek başarılı ama bu işlem için kayıt yok.
  bool get notFound => _loaded && _detail == null;

  Stream<Duration> get positionStream => _player.stream.position;
  Stream<Duration> get durationStream => _player.stream.duration;
  Stream<bool> get playingStream => _player.stream.playing;

  Duration get position => _player.state.position;
  Duration get duration => _player.state.duration;
  bool get isPlaying => _player.state.playing;

  /// Oynatma hızları — düğme sırayla dolaşır.
  static const playbackRates = [1.0, 1.5, 2.0, 0.5];
  double _rate = 1.0;
  double get rate => _rate;

  RecordedCamera? get selectedCamera => _detail?.cameras.firstWhereOrNull((c) => c.cameraId == _selectedCameraId);

  Future<void> load() async {
    await execute<OperationRecordingDetail?>(
      _fetchOp,
      operation: () => _getRecording(operationId),
      onData: (detail) {
        _detail = detail;
        _loaded = true;
        notifyListeners();
        final cameras = detail?.cameras ?? const <RecordedCamera>[];
        final initial = cameras.firstWhereOrNull((c) => c.isPlayable) ?? cameras.firstOrNull;
        if (initial != null) unawaited(selectCamera(initial.cameraId));
      },
    );
  }

  Future<void> selectCamera(String cameraId) async {
    final camera = _detail?.cameras.firstWhereOrNull((c) => c.cameraId == cameraId);
    if (camera == null) return;
    _selectedCameraId = cameraId;
    _playbackFailed = false;
    notifyListeners();

    if (!camera.isPlayable) {
      await _player.stop();
      return;
    }
    final source = _getVideoSource(operationId: operationId, cameraId: cameraId);
    MedLogger.info(
      unit: 'SW-UNIT-CAM',
      swreq: 'SWREQ-MGR-CAM-001',
      message: 'Operasyon kaydı videosu açılıyor',
      context: {'operationId': operationId, 'cameraId': cameraId},
    );
    await _player.open(Media(source.uri.toString(), httpHeaders: source.headers));
  }

  /// Seçili kamerada olayın anına (biraz öncesine) atlar ve oynatır.
  Future<void> seekTo(RecordedMarker marker) async {
    final cameraId = _selectedCameraId;
    final offset = cameraId == null ? null : marker.offsetFor(cameraId);
    if (offset == null || !(selectedCamera?.isPlayable ?? false)) return;
    final target = offset - _seekPreRoll;
    await _player.seek(target.isNegative ? Duration.zero : target);
    await _player.play();
  }

  Future<void> togglePlay() => _player.playOrPause();

  Future<void> seek(Duration position) => _player.seek(position);

  Future<void> cycleRate() async {
    final i = playbackRates.indexOf(_rate);
    _rate = playbackRates[(i + 1) % playbackRates.length];
    await _player.setRate(_rate);
    notifyListeners();
  }

  void _onPlaybackError(String error) {
    MedLogger.warn(
      unit: 'SW-UNIT-CAM',
      swreq: 'SWREQ-MGR-CAM-001',
      message: 'Operasyon kaydı videosu oynatılamadı',
      context: {'operationId': operationId, 'cameraId': _selectedCameraId, 'error': error},
    );
    _playbackFailed = true;
    notifyListeners();
  }

  @override
  void dispose() {
    unawaited(_errorSub?.cancel());
    unawaited(_player.dispose());
    super.dispose();
  }
}
