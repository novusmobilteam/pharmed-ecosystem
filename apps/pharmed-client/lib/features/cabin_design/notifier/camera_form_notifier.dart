// [SWREQ-CAM-056] [IEC 62304 §5.5]
// Kabin dizayn ekranındaki kamera formu: tanım, kabin ataması, deneme
// çekimi, kaydet/sil. Bir form açılışı = bir notifier (panel State'i sahiplenir).
// Sınıf: Class B

import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../core/hardware/camera/camera_config.dart';
import '../../../../core/hardware/camera/camera_tester.dart';
import '../../../../core/mixins/api_request_mixin.dart';

enum CameraStream {
  main(101),
  sub(102);

  const CameraStream(this.channel);
  final int channel;

  static CameraStream fromChannel(int channel) => channel == 102 ? sub : main;
}

class CameraFormNotifier extends ChangeNotifier with ApiRequestMixin {
  CameraFormNotifier({
    required ICameraDeviceRepository devices,
    required ICameraSecretStore secrets,
    required CameraTester tester,
    required List<CameraDevice> otherCameras,
    CameraDevice? existing,
    int? initialCabinId,
    CameraDeviceValidator validator = const CameraDeviceValidator(),
  }) : _devices = devices,
       _secrets = secrets,
       _tester = tester,
       _otherCameras = otherCameras,
       _validator = validator,
       _existing = existing,
       _id = existing?.id ?? _newId(),
       _name = existing?.name ?? '',
       _host = existing?.host ?? '',
       _port = existing?.rtspPort ?? 554,
       _stream = CameraStream.fromChannel(existing?.channel ?? 101),
       _username = existing?.username ?? '',
       _cabinIds =
           existing?.cabinIds.toSet() ??
           {
             if (initialCabinId != null && !otherCameras.any((c) => c.cabinIds.contains(initialCabinId)))
               initialCabinId,
           },
       _enabled = existing?.enabled ?? true;

  static const _unit = 'SW-UNIT-CAM';
  static const _swreq = 'SWREQ-CAM-056';

  static const testOp = OperationKey.custom('camera-form-test');
  static const snapshotOp = OperationKey.custom('camera-form-snapshot');
  static const saveOp = OperationKey.custom('camera-form-save');
  static const deleteOp = OperationKey.custom('camera-form-delete');

  static final _rng = Random.secure();
  static String _newId() {
    final time = DateTime.now().millisecondsSinceEpoch.toRadixString(36);
    final rand = List.generate(4, (_) => _rng.nextInt(36).toRadixString(36)).join();
    return 'cam$time$rand';
  }

  final ICameraDeviceRepository _devices;
  final ICameraSecretStore _secrets;
  final CameraTester _tester;
  final List<CameraDevice> _otherCameras;
  final CameraDeviceValidator _validator;
  final CameraDevice? _existing;
  final String _id;

  // ── Form alanları ─────────────────────────────────────────────────────────

  String _name;
  String _host;
  int _port;
  CameraStream _stream;
  String _username;

  /// Yeni girilen şifre. Düzenlemede boşsa kayıtlı şifre korunur.
  /// Ekranda hiçbir zaman kayıtlı şifre gösterilmez.
  String _password = '';
  Set<int> _cabinIds;
  bool _enabled;

  bool get isEditing => _existing != null;
  String get name => _name;
  String get host => _host;
  int get port => _port;
  CameraStream get stream => _stream;
  String get username => _username;
  bool get hasNewPassword => _password.isNotEmpty;
  Set<int> get cabinIds => _cabinIds;
  bool get enabled => _enabled;

  /// Başka bir kameraya atanmış kabin → o kamera (seçilemez).
  CameraDevice? ownerOfCabin(int cabinId) => _otherCameras.firstWhereOrNull((c) => c.cabinIds.contains(cabinId));

  // ── Test durumu ───────────────────────────────────────────────────────────

  CameraTestResult? _testResult;
  CameraTestResult? get testResult => _testResult;

  /// Testin yapıldığı bağlantı değerleri. Form değişirse test geçersizleşir.
  String? _testedFingerprint;

  String get _fingerprint => '${_host.trim()}|$_port|${_stream.channel}|${_username.trim()}|${_password.hashCode}';

  bool get isTestValid => _testResult != null && _testedFingerprint == _fingerprint;

  bool get isTesting => isLoading(testOp) || isLoading(snapshotOp);
  bool get isSaving => isLoading(saveOp);
  bool get isDeleting => isLoading(deleteOp);
  bool get isBusy => isTesting || isSaving || isDeleting;

  String? get testError => isFailed(testOp) ? message(testOp) : (isFailed(snapshotOp) ? message(snapshotOp) : null);
  String? get saveError => isFailed(saveOp) ? message(saveOp) : (isFailed(deleteOp) ? message(deleteOp) : null);

  /// Test için gereken alanlar dolu mu? (Düzenlemede şifre boş olabilir.)
  bool get canTest =>
      !isBusy && _host.trim().isNotEmpty && _username.trim().isNotEmpty && (isEditing || hasNewPassword);

  /// Kaydet ancak MEVCUT değerlerle başarılı test sonrası açılır.
  bool get canSave => !isBusy && isTestValid && _name.trim().isNotEmpty && _cabinIds.isNotEmpty;

  // ── Düzenleme ─────────────────────────────────────────────────────────────

  void setName(String? v) => _edit(() => _name = v ?? '');
  void setHost(String? v) => _edit(() => _host = (v ?? '').trim());
  void setPort(String? v) => _edit(() => _port = int.tryParse((v ?? '').trim()) ?? 0);
  void setStream(CameraStream v) => _edit(() => _stream = v);
  void setUsername(String? v) => _edit(() => _username = (v ?? '').trim());
  void setPassword(String? v) => _edit(() => _password = v ?? '');
  void setEnabled(bool v) => _edit(() => _enabled = v);

  void toggleCabin(int cabinId) {
    if (ownerOfCabin(cabinId) != null) return;
    _edit(() => _cabinIds = _cabinIds.contains(cabinId) ? ({..._cabinIds}..remove(cabinId)) : {..._cabinIds, cabinId});
  }

  void _edit(VoidCallback change) {
    if (isBusy) return;
    change();
    clearOperation(saveOp); // eski kayıt hatası artık geçerli değil
  }

  // ── Test ──────────────────────────────────────────────────────────────────

  /// Bağlantı + anlık görüntü + 3 sn deneme kaydı.
  Future<void> runTest() async {
    if (!canTest) return;
    final config = await _buildConfig(testOp);
    if (config == null) return;

    final fingerprint = _fingerprint;
    await execute(
      testOp,
      operation: () => _tester.test(config),
      onData: (result) {
        _testResult = result;
        _testedFingerprint = fingerprint;
      },
      onFailed: (e) {
        _testResult = null;
        _testedFingerprint = null;
        setFailed(testOp, message: _testFailureMessage(e));
      },
      swreq: _swreq,
    );
  }

  /// Test penceresindeki "Yenile" — kamerayı ayarlarken sadece görüntüyü tazeler.
  Future<void> refreshSnapshot() async {
    final previous = _testResult;
    if (previous == null || isBusy) return;
    final config = await _buildConfig(snapshotOp);
    if (config == null) return;

    await execute(
      snapshotOp,
      operation: () => _tester.takeSnapshot(config),
      onData: (shot) {
        final (bytes, connectTime) = shot;
        _testResult = CameraTestResult(
          snapshot: bytes,
          connectTime: connectTime,
          sampleDuration: previous.sampleDuration,
          sampleBytes: previous.sampleBytes,
          testedAt: DateTime.now(),
        );
      },
      onFailed: (e) => setFailed(snapshotOp, message: _testFailureMessage(e)),
      swreq: _swreq,
    );
  }

  /// Teknisyene ne yapması gerektiğini söyleyen mesaj (genel "kayıt yapılamadı" değil).
  String _testFailureMessage(AppException e) {
    final l10n = contextlessL10n();
    if (e is! CameraRecordingException) return e.userMessage;
    return switch (e.reason) {
      CameraRecordingFailureReason.authenticationFailed => l10n.cabinDesign_camera_testAuthFailedError,
      CameraRecordingFailureReason.startupTimeout => l10n.cabinDesign_camera_testTimeoutError,
      CameraRecordingFailureReason.ffmpegNotFound => l10n.cabinDesign_camera_testFfmpegMissingError,
      _ => l10n.cabinDesign_camera_testUnreachableError,
    };
  }

  /// Şifre: formda yeni girilen ya da (düzenlemede) güvenli depodaki.
  Future<CameraConfig?> _buildConfig(OperationKey key) async {
    var password = _password;
    if (password.isEmpty && isEditing) {
      password = (await _secrets.readPassword(_id)).when(ok: (p) => p ?? '', error: (_) => '');
    }
    if (password.isEmpty) {
      setFailed(key, message: contextlessL10n().cabinDesign_camera_passwordRequiredError);
      return null;
    }
    return CameraConfig.fromDevice(_buildDevice(), password);
  }

  CameraDevice _buildDevice() => CameraDevice(
    id: _id,
    name: _name.trim(),
    host: _host.trim(),
    username: _username.trim(),
    cabinIds: _cabinIds,
    rtspPort: _port,
    channel: _stream.channel,
    enabled: _enabled,
  );

  // ── Kaydet / Sil ──────────────────────────────────────────────────────────

  /// Sıra: doğrula → şifre → tanım. Şifre yazılıp tanım yazılamazsa kalan
  /// şifre zararsızdır (tanımsız kamera kayda katılmaz); tersi olursa
  /// tanımlı ama şifresiz kamera oluşurdu.
  Future<CameraDevice?> save() async {
    if (!canSave) return null;
    final device = _buildDevice();

    final validation = _validator.validate(device, others: _otherCameras);
    if (validation.isError) {
      setFailed(saveOp, message: _validationMessage(validation));
      return null;
    }

    CameraDevice? saved;
    await executeVoid(
      saveOp,
      operation: () async {
        if (hasNewPassword) {
          final pw = await _secrets.writePassword(_id, _password);
          if (pw.isError) return pw;
        }
        return _devices.save(device);
      },
      onSuccess: () {
        saved = device;
        _password = ''; // bellekte tutma; artık güvenli depoda
        _testedFingerprint = _fingerprint;
      },
      swreq: _swreq,
    );
    if (saved != null) {
      MedLogger.info(
        unit: _unit,
        swreq: _swreq,
        message: isEditing ? 'Kamera güncellendi' : 'Kamera tanımlandı',
        context: {'cameraId': device.id, 'name': device.name, 'cabinIds': device.cabinIds.toList()},
      );
    }
    return saved;
  }

  Future<bool> delete() async {
    if (!isEditing || isBusy) return false;
    var ok = false;
    await executeVoid(
      deleteOp,
      operation: () async {
        final r = await _devices.delete(_id);
        if (r.isError) return r;
        await _secrets.deletePassword(_id); // tanım gittiyse şifre sorunu kritik değil
        return const Result.ok(null);
      },
      onSuccess: () => ok = true,
      swreq: _swreq,
    );
    if (ok) {
      MedLogger.info(unit: _unit, swreq: _swreq, message: 'Kamera silindi', context: {'cameraId': _id});
    }
    return ok;
  }

  String _validationMessage(Result<void> r) {
    final e = r.when(ok: (_) => null, error: (e) => e);
    final l10n = contextlessL10n();
    if (e is! ValidationException) return e?.userMessage ?? l10n.cabinDesign_camera_saveFailedError;
    return switch (e.field) {
      'name' => l10n.cabinDesign_camera_nameRequiredError,
      'host' when e.value is CameraDevice => l10n.cabinDesign_camera_duplicateHostError(
        (e.value! as CameraDevice).name,
      ),
      'host' => l10n.cabinDesign_camera_invalidHostError,
      'rtspPort' => l10n.cabinDesign_camera_invalidPortError,
      'username' => l10n.cabinDesign_camera_usernameRequiredError,
      'cabinIds' when e.value is CameraDevice => l10n.cabinDesign_camera_cabinAlreadyAssignedError(
        (e.value! as CameraDevice).name,
      ),
      'cabinIds' => l10n.cabinDesign_camera_noCabinSelectedError,
      _ => e.userMessage,
    };
  }
}
