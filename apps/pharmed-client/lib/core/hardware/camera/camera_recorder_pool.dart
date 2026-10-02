import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart'; // MedLogger

import 'package:pharmed_client/core/hardware/camera/camera_config.dart';

typedef RecorderFactory = IOperationRecorder Function(CameraConfig config);

/// Bir operasyona katılacak kamera: kaydedicisi ya da neden katılamadığı.
class ResolvedCamera {
  const ResolvedCamera({required this.device, this.recorder, this.failure});
  final CameraDevice device;
  final IOperationRecorder? recorder;
  final CameraRecordingFailureReason? failure;
}

/// Kamera başına bir kaydedici tutar. Tanım veya şifre değiştiyse eski
/// kaydediciyi bırakıp yenisini kurar. [SWREQ-CAM-053]
///
/// Not: Koordinatör begin/end'i sıraya dizdiği için çözümleme anında hiçbir
/// kaydedici kayıtta değildir; eski kaydediciyi dispose etmek güvenlidir.
class CameraRecorderPool {
  CameraRecorderPool({
    required ICameraDeviceRepository devices,
    required ICameraSecretStore secrets,
    required RecorderFactory create,
  }) : _devices = devices,
       _secrets = secrets,
       _create = create;

  static const _unit = 'SW-UNIT-CAM';

  final ICameraDeviceRepository _devices;
  final ICameraSecretStore _secrets;
  final RecorderFactory _create;

  final _entries = <String, ({CameraDevice device, String password, IOperationRecorder recorder})>{};

  /// [cabinIds]'e hizmet veren, etkin kameraları çözer. Kabinlere kamera
  /// atanmamışsa boş liste döner (hata değil).
  Future<List<ResolvedCamera>> resolveFor(Set<int> cabinIds) async {
    final all = (await _devices.getAll()).when(
      ok: (list) => list,
      error: (e) {
        MedLogger.error(unit: _unit, swreq: 'SWREQ-CAM-053', message: 'Kamera tanımları okunamadı', error: e);
        return const <CameraDevice>[];
      },
    );

    // Silinmiş kameraların kaydedicilerini bırak.
    final liveIds = all.map((d) => d.id).toSet();
    for (final id in _entries.keys.where((id) => !liveIds.contains(id)).toList()) {
      await _entries.remove(id)!.recorder.dispose();
    }

    final result = <ResolvedCamera>[];
    for (final device in all.where((d) => d.servesAny(cabinIds))) {
      final password = (await _secrets.readPassword(device.id)).when(ok: (p) => p, error: (_) => null);
      if (password == null || password.isEmpty) {
        MedLogger.warn(
          unit: _unit,
          swreq: 'SWREQ-CAM-053',
          message: 'Kamera için şifre tanımlı değil, kayda katılamıyor',
          context: {'cameraId': device.id, 'cameraName': device.name},
        );
        result.add(ResolvedCamera(device: device, failure: CameraRecordingFailureReason.invalidInput));
        continue;
      }
      result.add(ResolvedCamera(device: device, recorder: await _recorderFor(device, password)));
    }
    return result;
  }

  Future<IOperationRecorder> _recorderFor(CameraDevice device, String password) async {
    final existing = _entries[device.id];
    if (existing != null && existing.device == device && existing.password == password) {
      return existing.recorder;
    }
    if (existing != null) await existing.recorder.dispose();
    final recorder = _create(CameraConfig.fromDevice(device, password));
    _entries[device.id] = (device: device, password: password, recorder: recorder);
    return recorder;
  }

  Future<void> dispose() async {
    for (final e in _entries.values) {
      await e.recorder.dispose();
    }
    _entries.clear();
  }
}
