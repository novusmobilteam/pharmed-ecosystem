// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:pharmed_core/pharmed_core.dart';

import 'package:pharmed_client/core/providers/camera_providers.dart' show recordingStagingFolder;
import 'package:pharmed_client/core/recording/storage/operation_recording_json_mapper.dart';

/// Lokal kayıt arşivinin dosya düzeni. [SWREQ-CAM-020]
///
/// ```
/// recordings/
/// ├── .staging/                                ← kayıt sürerken (yarım dosyalar BURADA)
/// │   ├── <opId>.start.json                    ← write-ahead manifest
/// │   └── <opId>--<cameraId>_<ms>.mp4          ← kamera başına ffmpeg çıktısı
/// ├── refill/                                  ← işlem tipi
/// │   └── 2026-10-01/                          ← lokal tarih
/// │       ├── 20261001-173550_refill_c79-80_u42_<opId>.json           ← sidecar
/// │       ├── 20261001-173550_refill_c79-80_u42_<opId>.<cameraId>.mp4  ← kamera 1
/// │       └── 20261001-173550_refill_c79-80_u42_<opId>.<cameraId>.mp4  ← kamera 2
/// └── ...
/// ```
///
/// - Arşive yalnızca TAMAMLANMIŞ dosyalar girer (staging → atomik taşıma).
/// - Sidecar operasyonu ve tüm videolarını tanımlar; Hive indeksi kaybolsa
///   bile arşiv dosyalardan yeniden kurulabilir.
/// - Dosya adı Explorer'da filtrelenebilir (`_refill_`, `_c79`, `_u42_`,
///   `20261001-17`, kamera id'si). KVKK: adda kullanıcının adı değil kimliği var.
class RecordingStorage {
  RecordingStorage({required String rootPath, OperationRecordingJsonMapper? mapper})
    : root = Directory(rootPath),
      _mapper = mapper ?? const OperationRecordingJsonMapper();

  final Directory root;
  final OperationRecordingJsonMapper _mapper;

  static const _stagingName = recordingStagingFolder;
  static const _manifestSuffix = '.start.json';
  static const _sessionSeparator = '--';
  static const _encoder = JsonEncoder.withIndent('  ');

  Directory get stagingDir => Directory(p.join(root.path, _stagingName));

  // ── Adlandırma ────────────────────────────────────────────────────────────

  String baseName(OperationRecording r) {
    final t = r.startedAt.toLocal();
    final stamp = '${t.year}${_2(t.month)}${_2(t.day)}-${_2(t.hour)}${_2(t.minute)}${_2(t.second)}';
    final cabins = (r.cabinIds.toList()..sort()).join('-');
    return '${stamp}_${r.type.name}_c${cabins.isEmpty ? '0' : cabins}_u${r.userId ?? 0}_${_safe(r.operationId)}';
  }

  Directory archiveDir(OperationRecording r) {
    final t = r.startedAt.toLocal();
    return Directory(p.join(root.path, r.type.name, '${t.year}-${_2(t.month)}-${_2(t.day)}'));
  }

  /// Sidecar adının sonundaki operationId (dosyayı açmadan eşleştirme için).
  static String operationIdFromSidecarName(String fileName) {
    final parts = p.basenameWithoutExtension(fileName).split('_');
    return parts.length >= 5 ? parts.sublist(4).join('_') : parts.last;
  }

  // ── Staging ───────────────────────────────────────────────────────────────

  File manifestFile(String operationId) => File(p.join(stagingDir.path, '${_safe(operationId)}$_manifestSuffix'));

  Future<void> writeManifest(OperationRecordingStart start) async {
    await stagingDir.create(recursive: true);
    await _writeAtomic(manifestFile(start.operationId), _encoder.convert(_mapper.startToJson(start)));
  }

  Future<List<OperationRecordingStart>> readManifests() async {
    if (!await stagingDir.exists()) return const [];
    final result = <OperationRecordingStart>[];
    await for (final e in stagingDir.list(followLinks: false)) {
      if (e is! File || !e.path.endsWith(_manifestSuffix)) continue;
      try {
        result.add(_mapper.startFromJson(jsonDecode(await e.readAsString()) as Map<String, Object?>));
      } catch (_) {
        /* bozuk manifest — atomik yazımda olmamalı; yok sayılır */
      }
    }
    return result;
  }

  /// Staging'de bu operasyona ait videolar: cameraId → dosya.
  Future<Map<String, File>> findStagingVideos(String operationId) async {
    final result = <String, File>{};
    if (!await stagingDir.exists()) return result;
    final prefix = '${_safe(operationId)}$_sessionSeparator';
    await for (final e in stagingDir.list(followLinks: false)) {
      final name = p.basename(e.path);
      if (e is! File || !name.startsWith(prefix) || !name.endsWith('.mp4')) continue;
      final cameraId = name.substring(prefix.length).split('_').first;
      result[cameraId] = e;
    }
    return result;
  }

  Future<void> deleteManifest(String operationId) => _deleteIfExists(manifestFile(operationId));

  // ── Arşivleme ─────────────────────────────────────────────────────────────

  /// Videoları staging'den arşive taşır, sidecar'ı yazar, manifest'i siler.
  /// Sıra bilinçli: önce videolar, sonra sidecar. Sidecar varsa videolar da
  /// yerindedir. [SWREQ-CAM-022]
  Future<ArchivedRecording> archive(OperationRecording recording) async {
    final dir = archiveDir(recording);
    await dir.create(recursive: true);
    final base = baseName(recording);

    final tracks = <CameraTrack>[];
    for (final t in recording.tracks) {
      final video = t.video;
      if (video == null) {
        tracks.add(t);
        continue;
      }
      final target = File(p.join(dir.path, '$base.${_safe(t.cameraId)}.mp4'));
      await _move(File(video.path), target);
      tracks.add(t.withVideo(video.copyWith(path: target.path)));
    }
    final archived = recording.withTracks(tracks);

    final sidecar = File(p.join(dir.path, '$base.json'));
    await _writeAtomic(sidecar, _encoder.convert(_mapper.toJson(archived)));
    await deleteManifest(recording.operationId);

    return ArchivedRecording(recording: archived, sidecarPath: sidecar.path);
  }

  Future<OperationRecording> readSidecar(String sidecarPath) async {
    final json = jsonDecode(await File(sidecarPath).readAsString()) as Map<String, Object?>;
    return _mapper.fromJson(json, sidecarDir: p.dirname(sidecarPath), exists: (path) => File(path).existsSync());
  }

  /// Arşivdeki tüm sidecar'ları akış olarak verir (listeyi belleğe almaz).
  Stream<File> sidecars() async* {
    if (!await root.exists()) return;
    await for (final typeDir in root.list(followLinks: false)) {
      if (typeDir is! Directory || p.basename(typeDir.path) == _stagingName) continue;
      await for (final dayDir in typeDir.list(followLinks: false)) {
        if (dayDir is! Directory) continue;
        await for (final f in dayDir.list(followLinks: false)) {
          if (f is File && f.path.endsWith('.json')) yield f;
        }
      }
    }
  }

  // ── Silme ─────────────────────────────────────────────────────────────────

  Future<void> deleteVideos(Iterable<String> videoPaths) async {
    for (final path in videoPaths) {
      await _deleteIfExists(File(path));
    }
  }

  Future<void> deleteRecording({required Iterable<String> videoPaths, required String sidecarPath}) async {
    await deleteVideos(videoPaths);
    await _deleteIfExists(File(sidecarPath));
  }

  /// Boşalan gün klasörlerini temizler.
  Future<void> pruneEmptyDirs() async {
    if (!await root.exists()) return;
    await for (final typeDir in root.list(followLinks: false)) {
      if (typeDir is! Directory || p.basename(typeDir.path) == _stagingName) continue;
      await for (final dayDir in typeDir.list(followLinks: false)) {
        if (dayDir is Directory && await dayDir.list().isEmpty) await dayDir.delete();
      }
    }
  }

  // ── Yardımcılar ───────────────────────────────────────────────────────────

  /// Aynı volume'da rename atomiktir. Farklı volume'a düşerse kopyala + sil.
  static Future<void> _move(File source, File target) async {
    try {
      await source.rename(target.path);
    } on FileSystemException {
      await source.copy(target.path);
      await source.delete();
    }
  }

  /// Geçici dosyaya yazıp rename: okuyan taraf hiçbir zaman yarım JSON görmez.
  static Future<void> _writeAtomic(File target, String content) async {
    final tmp = File('${target.path}.tmp');
    await tmp.writeAsString(content, flush: true);
    if (await target.exists()) await target.delete(); // Windows rename üzerine yazmaz
    await tmp.rename(target.path);
  }

  static Future<void> _deleteIfExists(File f) async {
    if (await f.exists()) await f.delete();
  }

  static String _2(int v) => v.toString().padLeft(2, '0');

  /// Dosya adında güvenli: harf, rakam, tire. ('_' ayraç, '.' uzantı ayracı.)
  static String _safe(String v) => v.replaceAll(RegExp(r'[^A-Za-z0-9-]'), '-');
}

class ArchivedRecording {
  const ArchivedRecording({required this.recording, required this.sidecarPath});
  final OperationRecording recording;
  final String sidecarPath;
}
