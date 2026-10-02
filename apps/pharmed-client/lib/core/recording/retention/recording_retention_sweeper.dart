import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:pharmed_ui/pharmed_ui.dart'; // MedLogger
import 'package:win32/win32.dart';

import 'package:pharmed_client/core/recording/outbox/hive_recording_outbox.dart';
import 'package:pharmed_client/core/recording/recording_config.dart';
import 'package:pharmed_client/core/recording/storage/recording_storage.dart';

/// Boş disk alanı sorgusu. Platform desteklemiyorsa null döner ve sadece
/// kota kuralı uygulanır.
abstract interface class IDiskSpaceProbe {
  Future<int?> freeBytes(String path);
}

class WindowsDiskSpaceProbe implements IDiskSpaceProbe {
  const WindowsDiskSpaceProbe();

  @override
  Future<int?> freeBytes(String path) async {
    if (!Platform.isWindows) return null;
    final dir = path.toNativeUtf16(allocator: calloc);
    final free = calloc<Uint64>();
    try {
      // NOT: win32 paket sürümüne göre dönüş tipi değişebilir (int / Win32Result).
      final ok = GetDiskFreeSpaceEx(dir, free, nullptr, nullptr);
      return ok != 0 ? free.value : null;
    } finally {
      calloc.free(dir);
      calloc.free(free);
    }
  }
}

/// Lokal arşivin saklama politikası. [SWREQ-CAM-040]
///
/// Sıra (her sweep'te):
///  1. YAŞ: sunucuda (gerçekten) doğrulanmış ve [maxAge]'den eski kayıtlar
///     silinir. API yokken sahte yanıtla doğrulananlar (verifiedByStub) bu
///     kurala girmez.
///  2. KORUMA: yüklenmemiş kayıtlar yaşları ne olursa olsun SİLİNMEZ
///     (denetim kanıtı) — ama süreyi aşanlar için uyarı loglanır.
///  3. KOTA / BOŞ ALAN: toplam boyut [maxTotalBytes]'ı aşıyorsa veya disk
///     boş alanı [minFreeDiskBytes]'ın altındaysa en eskiden başlayarak:
///       a) önce doğrulanmış kayıtlar (süreleri dolmamış olsa bile) silinir,
///       b) yetmezse, son çare olarak yüklenmemiş kayıtların VİDEOSU silinir
///          (tahliye); metadata korunur ve sunucuya "video yok" diye gider.
///          Bu durum ERROR seviyesinde loglanır.
///
/// Bellek: dosya sistemi taranmaz; boyutlar outbox indeksinden okunur
/// (günde binlerce kayıtta da sabit maliyet).
class RecordingRetentionSweeper {
  RecordingRetentionSweeper({
    required HiveRecordingOutbox outbox,
    required RecordingStorage storage,
    required RecordingStorageConfig config,
    IDiskSpaceProbe diskProbe = const WindowsDiskSpaceProbe(),
    DateTime Function() clock = DateTime.now,
  }) : _outbox = outbox,
       _storage = storage,
       _config = config,
       _disk = diskProbe,
       _clock = clock;

  static const _unit = 'SW-UNIT-CAM';

  final HiveRecordingOutbox _outbox;
  final RecordingStorage _storage;
  final RecordingStorageConfig _config;
  final IDiskSpaceProbe _disk;
  final DateTime Function() _clock;

  Timer? _timer;
  bool _running = false;

  void start() {
    _timer = Timer.periodic(_config.sweepInterval, (_) => unawaited(sweep()));
    unawaited(sweep());
  }

  Future<void> sweep() async {
    if (_running) return;
    _running = true;
    try {
      await _outbox.exclusive(_sweep);
    } catch (e, st) {
      MedLogger.error(
        unit: _unit,
        swreq: 'SWREQ-CAM-040',
        message: 'Saklama temizliği hata verdi',
        error: e,
        stackTrace: st,
      );
    } finally {
      _running = false;
    }
  }

  Future<void> _sweep() async {
    final now = _clock();
    final cutoff = now.subtract(_config.maxAge);
    final entries = (await _outbox.entries())..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    // 1) Yaş kuralı — yalnızca doğrulanmışlar
    var deletedByAge = 0;
    final remaining = <RecordingOutboxEntry>[];
    for (final e in entries) {
      if (e.isServerVerified && e.createdAt.isBefore(cutoff)) {
        await _deleteAll(e);
        deletedByAge++;
      } else {
        remaining.add(e);
      }
    }

    // 2) Süreyi aşmış ama yüklenmemiş kayıtlar — korunur, uyarılır
    final overdue = remaining.where((e) => !e.isServerVerified && e.createdAt.isBefore(cutoff)).length;
    if (overdue > 0) {
      MedLogger.warn(
        unit: _unit,
        swreq: 'SWREQ-CAM-040',
        message: 'Saklama süresini aşmış, henüz yüklenmemiş kayıtlar var (silinmedi)',
        context: {'count': overdue, 'maxAgeDays': _config.maxAge.inDays},
      );
    }

    // 3) Kota / boş alan
    var total = remaining.fold<int>(0, (s, e) => s + e.videoBytes);
    var free = await _disk.freeBytes(_storage.root.path);
    bool pressure() => total > _config.maxTotalBytes || (free != null && free < _config.minFreeDiskBytes);

    var deletedByQuota = 0;
    var evicted = 0;
    if (pressure()) {
      // a) doğrulanmışlar, en eski önce
      for (final e in remaining.where((e) => e.isServerVerified).toList()) {
        if (!pressure()) break;
        final freed = e.videoBytes;
        await _deleteAll(e);
        remaining.remove(e);
        total -= freed;
        if (free != null) free = free + freed;
        deletedByQuota++;
      }
      // b) son çare: yüklenmemişlerin videosu
      for (final e in remaining.where((e) => e.hasVideoOnDisk).toList()) {
        if (!pressure()) break;
        final freed = e.videoBytes;
        await _storage.deleteVideos(e.videos.map((v) => v.path));
        // Metadata yüklenmemiş videoları "bekleniyor" diye gönderildiyse,
        // güncel liste ile yeniden gönderilsin diye pending'e döner
        // (sunucu çağrısı idempotent; yüklenmiş videolar korunur).
        await _outbox.update(
          e.copyWith(
            videoEvicted: true,
            state: e.state == RecordingUploadState.metadataSent ? RecordingUploadState.pending : null,
          ),
        );
        total -= freed;
        if (free != null) free = free + freed;
        evicted++;
        MedLogger.error(
          unit: _unit,
          swreq: 'SWREQ-CAM-041',
          message: 'Disk baskısı: yüklenmemiş kaydın videosu silindi (${e.operationId}); metadata korunuyor',
          error: 'videoEvicted',
        );
      }
    }

    if (deletedByAge + deletedByQuota + evicted > 0) {
      await _storage.pruneEmptyDirs();
      MedLogger.info(
        unit: _unit,
        swreq: 'SWREQ-CAM-040',
        message: 'Saklama temizliği tamamlandı',
        context: {
          'deletedByAge': deletedByAge,
          'deletedByQuota': deletedByQuota,
          'evicted': evicted,
          'archiveBytes': total,
          'freeDiskBytes': free,
        },
      );
    }
  }

  Future<void> _deleteAll(RecordingOutboxEntry e) async {
    await _storage.deleteRecording(
      videoPaths: e.hasVideoOnDisk ? e.videos.map((v) => v.path) : const [],
      sidecarPath: e.sidecarPath,
    );
    await _outbox.remove(e.operationId);
  }

  void dispose() => _timer?.cancel();
}
