// [SWREQ-CORE-LOG-002] [SWREQ-CAM-023]
// Uygulamanın cihazda kalıcı veri yazdığı klasörler (loglar, kamera kayıtları).
//
//   Windows : %LOCALAPPDATA%\PharMed\…           (kiosk — değişmedi)
//   macOS   : ~/Library/Application Support/PharMed/…, loglar ~/Library/Logs/PharMed
//             (sandbox'ta HOME uygulama container'ını gösterir)
//   Linux   : $XDG_DATA_HOME/PharMed ya da ~/.local/share/PharMed
// Hiçbiri çözülemezse geçici klasöre düşülür (kalıcı değildir).
//
// Sınıf: Class B

import 'dart:io';

import 'package:path/path.dart' as p;

String? _env(String key) {
  final v = Platform.environment[key];
  return v == null || v.isEmpty ? null : v;
}

/// Kalıcı uygulama verisinin kökü.
String pharmedDataRoot() {
  if (Platform.isWindows) {
    final base = _env('LOCALAPPDATA');
    if (base != null) return p.join(base, 'PharMed');
  } else if (Platform.isMacOS) {
    final home = _env('HOME');
    if (home != null) return p.join(home, 'Library', 'Application Support', 'PharMed');
  } else if (Platform.isLinux) {
    final xdg = _env('XDG_DATA_HOME');
    if (xdg != null) return p.join(xdg, 'PharMed');
    final home = _env('HOME');
    if (home != null) return p.join(home, '.local', 'share', 'PharMed');
  }
  return p.join(Directory.systemTemp.path, 'PharMed');
}

/// Log dosyalarının klasörü. macOS'ta Console.app'in de gösterdiği standart
/// `~/Library/Logs` altı; diğerlerinde veri kökünün `logs` alt klasörü.
String appLogDirectoryPath() {
  if (Platform.isMacOS) {
    final home = _env('HOME');
    if (home != null) return p.join(home, 'Library', 'Logs', 'PharMed');
  }
  return p.join(pharmedDataRoot(), 'logs');
}

/// Klasörü işletim sisteminin dosya yöneticisinde açar (yoksa oluşturur).
/// Hata fırlatmaz; açılamazsa false döner.
Future<bool> revealInFileManager(String path) async {
  try {
    await Directory(path).create(recursive: true);
    final command = Platform.isWindows ? 'explorer' : (Platform.isMacOS ? 'open' : 'xdg-open');
    await Process.run(command, [path]);
    return true;
  } catch (_) {
    return false;
  }
}
