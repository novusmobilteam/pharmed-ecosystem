import 'dart:convert';
import 'dart:io';

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../mapper/fingerprint_mapper.dart';

/// [SWREQ-DATA-FP-003] Servis hazır olana kadar parmak izi kayıt servisini taklit eder
/// (kamera kaydındaki MockRecordingUploadRepository ile aynı yaklaşım).
///
/// * Gönderilen gövde gerçek servisteki gibi DTO'ya çevrilir (mapper doğrulanmış olur),
///   ama hiçbir yere gönderilmez; yalnızca özeti loglanır.
/// * Kayıtlı parmakların yalnızca POZİSYONLARI ve tarihleri [storeFilePath] JSON
///   dosyasında kullanıcı bazında tutulur — ekran yeniden açıldığında "kayıtlı" görünsün diye.
///   ŞABLON SAKLANMAZ (KVKK).
/// * Gerçek servisin davranışı taklit edilir: aynı pozisyon tekrar gelirse değiştirilir.
class FakeFingerprintRepository implements IFingerprintRepository {
  FakeFingerprintRepository({
    required String storeFilePath,
    required int? Function() currentUserId,
    this.latency = const Duration(milliseconds: 600),
    FingerprintMapper mapper = const FingerprintMapper(),
  }) : _file = File(storeFilePath),
       _currentUserId = currentUserId,
       _mapper = mapper;

  static const _unit = 'SW-UNIT-FP';
  static const _swreq = 'SWREQ-DATA-FP-003';

  final File _file;
  final int? Function() _currentUserId;
  final Duration latency;
  final FingerprintMapper _mapper;

  @override
  Future<Result<void>> enroll(FingerprintEnrollmentRequest request) async {
    final userId = _currentUserId();
    if (userId == null) return _unauthorized();
    await Future<void>.delayed(latency);

    // Gerçek istekteki gövde — boyut özetini loglamak için (şablonun kendisi loglanmaz).
    final body = jsonEncode(_mapper.toEnrollDto(request).toJson());

    final store = await _read();
    final fingers = {
      for (final f in store[userId.toString()] ?? const <EnrolledFingerDTO>[])
        if (f.fingerPosition != null) f.fingerPosition!: f,
    };
    final now = DateTime.now().toUtc().toIso8601String();
    for (final f in request.fingers) {
      fingers[f.position.isoCode] = EnrolledFingerDTO(
        fingerPosition: f.position.isoCode,
        enrolledAt: now,
        scannerVendor: request.source.scannerVendor,
      );
    }
    store[userId.toString()] = fingers.values.toList();
    await _write(store);

    MedLogger.info(
      unit: _unit,
      swreq: _swreq,
      message: 'Parmak izi kaydı simüle edildi (servis yok)',
      context: {
        'userId': userId,
        'fingers': request.fingers.map((f) => f.position.isoCode).toList(),
        'samples': request.fingers.fold<int>(0, (n, f) => n + f.samples.length),
        'source': '${request.source.scannerVendor}/${request.source.format.wireName}',
        'bodyBytes': body.length,
      },
    );
    return const Result.ok(null);
  }

  @override
  Future<Result<List<EnrolledFinger>>> getEnrolledFingers() async {
    final userId = _currentUserId();
    if (userId == null) return _unauthorized();
    await Future<void>.delayed(latency ~/ 2);
    final store = await _read();
    final dtos = store[userId.toString()] ?? const <EnrolledFingerDTO>[];
    final list = _mapper.toEnrolledFingerList(dtos)..sort((a, b) => a.position.isoCode.compareTo(b.position.isoCode));
    return Result.ok(list);
  }

  @override
  Future<Result<void>> deleteFinger(FingerPosition position) async {
    final userId = _currentUserId();
    if (userId == null) return _unauthorized();
    await Future<void>.delayed(latency ~/ 2);
    final store = await _read();
    final list = store[userId.toString()] ?? const <EnrolledFingerDTO>[];
    final next = list.where((f) => f.fingerPosition != position.isoCode).toList();
    if (next.length == list.length) {
      return Result.error(NotFoundException(message: 'Parmak kayıtlı değil', id: position.isoCode));
    }
    store[userId.toString()] = next;
    await _write(store);
    MedLogger.info(
      unit: _unit,
      swreq: _swreq,
      message: 'Parmak izi silme simüle edildi (servis yok)',
      context: {'userId': userId, 'finger': position.isoCode},
    );
    return const Result.ok(null);
  }

  // ── Dosya ────────────────────────────────────────────────────────────────

  Future<Map<String, List<EnrolledFingerDTO>>> _read() async {
    try {
      if (!await _file.exists()) return {};
      final json = jsonDecode(await _file.readAsString());
      if (json is! Map) return {};
      return {
        for (final e in json.entries)
          e.key.toString(): [
            for (final item in (e.value as List? ?? const []))
              if (item is Map) EnrolledFingerDTO.fromJson(item.cast<String, dynamic>()),
          ],
      };
    } catch (e) {
      MedLogger.warn(unit: _unit, swreq: _swreq, message: 'Sahte parmak izi deposu okunamadı', context: {'error': '$e'});
      return {};
    }
  }

  Future<void> _write(Map<String, List<EnrolledFingerDTO>> store) async {
    await _file.parent.create(recursive: true);
    await _file.writeAsString(
      jsonEncode({for (final e in store.entries) e.key: e.value.map((f) => f.toJson()).toList()}),
      flush: true,
    );
  }

  // Tip parametresi const ifadede kullanılamaz; yalnızca exception const.
  static Result<T> _unauthorized<T>() =>
      Result.error(const ServiceException(message: 'Oturum yok', statusCode: 401));
}
