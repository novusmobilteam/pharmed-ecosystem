// [SWREQ-NET-007] Gönderilmeyi bekleyen loglar için diskte kalıcı kuyruk.
//
// Biçim: NDJSON (satır başına bir kayıt).
//   current.ndjson        — yeni kayıtların eklendiği dosya
//   batch-<zaman>.ndjson  — gönderime ayrılmış dosyalar, en eski önce
// Gönderim zamanı gelince current dosyası atomik olarak batch-* adına
// taşınır; gönderici batch dosyalarını sırayla işler, başarıyla gidenleri
// dosyadan çıkarır. Uygulama çökse ya da ağ günlerce olmasa da kayıt
// kaybolmaz; yalnızca [maxBytes] aşılırsa en eski dosyalar düşürülür.
//
// Tek isolate'ta, senkron dosya işlemleriyle çalışır: ekleme ile taşıma
// arasında yarış olmaz.
//
// Sınıf: Class B

import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

class LogOutbox {
  LogOutbox({required this.directory, required this.maxBytes});

  final Directory directory;
  final int maxBytes;

  static const _currentName = 'current.ndjson';
  static final _batchPattern = RegExp(r'^batch-(\d+)\.ndjson$');

  File get _current => File(p.join(directory.path, _currentName));

  int _pendingInCurrent = 0;

  /// current dosyasına eklenmiş, henüz gönderime ayrılmamış kayıt sayısı
  /// (bu açılışta eklenenler).
  int get pendingInCurrent => _pendingInCurrent;

  void ensureCreated() {
    try {
      directory.createSync(recursive: true);
    } catch (_) {}
  }

  /// Bir kaydı ekler. JSON'a çevrilemeyen değerler metin olarak yazılır.
  void append(Map<String, dynamic> entry) {
    try {
      _current.writeAsStringSync(
        '${jsonEncode(entry, toEncodable: (o) => o.toString())}\n',
        mode: FileMode.append,
        flush: true,
      );
      _pendingInCurrent++;
    } catch (_) {
      // Kuyruğa yazılamaması uygulamayı durdurmamalı; kayıt yerel log
      // dosyasında yine de var.
    }
  }

  /// current dosyasını gönderime ayırır (boşsa bir şey yapmaz) ve boyut
  /// sınırını uygular. Düşürülen kayıt sayısını döner.
  int seal() {
    try {
      final cur = _current;
      if (cur.existsSync() && cur.lengthSync() > 0) {
        cur.renameSync(p.join(directory.path, 'batch-${DateTime.now().microsecondsSinceEpoch}.ndjson'));
      }
      _pendingInCurrent = 0;
    } catch (_) {}
    return _enforceLimit();
  }

  /// Gönderime ayrılmış dosyalar, en eskiden yeniye.
  List<File> batches() {
    try {
      final files = directory
          .listSync()
          .whereType<File>()
          .where((f) => _batchPattern.hasMatch(p.basename(f.path)))
          .toList();
      files.sort((a, b) => _stamp(a).compareTo(_stamp(b)));
      return files;
    } catch (_) {
      return const [];
    }
  }

  /// Bir batch dosyasındaki kayıtlar. Bozuk satırlar atlanır.
  List<Map<String, dynamic>> read(File batch) {
    try {
      return batch
          .readAsLinesSync()
          .where((l) => l.trim().isNotEmpty)
          .map((l) {
            try {
              final v = jsonDecode(l);
              return v is Map<String, dynamic> ? v : null;
            } catch (_) {
              return null;
            }
          })
          .whereType<Map<String, dynamic>>()
          .toList();
    } catch (_) {
      return const [];
    }
  }

  /// Dosyada yalnızca [remaining] kalsın; boşsa dosya silinir.
  void rewrite(File batch, List<Map<String, dynamic>> remaining) {
    try {
      if (remaining.isEmpty) {
        batch.deleteSync();
        return;
      }
      final tmp = File('${batch.path}.tmp');
      tmp.writeAsStringSync(
        '${remaining.map((e) => jsonEncode(e, toEncodable: (o) => o.toString())).join('\n')}\n',
        flush: true,
      );
      tmp.renameSync(batch.path);
    } catch (_) {}
  }

  int get totalBytes {
    var total = 0;
    try {
      for (final f in directory.listSync().whereType<File>()) {
        total += f.lengthSync();
      }
    } catch (_) {}
    return total;
  }

  int _enforceLimit() {
    var dropped = 0;
    var total = totalBytes;
    if (total <= maxBytes) return 0;
    for (final f in batches()) {
      if (total <= maxBytes) break;
      try {
        final size = f.lengthSync();
        dropped += read(f).length;
        f.deleteSync();
        total -= size;
      } catch (_) {}
    }
    return dropped;
  }

  static int _stamp(File f) => int.tryParse(_batchPattern.firstMatch(p.basename(f.path))?.group(1) ?? '') ?? 0;
}
