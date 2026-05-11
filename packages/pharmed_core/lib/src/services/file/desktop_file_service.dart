import 'dart:io';

import 'package:file_picker/file_picker.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class DesktopFileService {
  /// Dosya kaydetme dialog'u açar (Generic)
  static Future<File?> saveFile({
    required List<int> bytes,
    required String fileName,
    required String extension, // Örn: 'pdf', 'xlsx' (noktasız)
    String? dialogTitle = 'Dosyayı Kaydet',
  }) async {
    try {
      // Uzantıdaki noktayı temizle (örn: .pdf -> pdf)
      final cleanExtension = extension.replaceAll('.', '');

      // Kaydetme dialog'unu aç
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: dialogTitle,
        fileName: '$fileName.$cleanExtension',
        type: FileType.custom,
        allowedExtensions: [cleanExtension], // Sadece ilgili uzantıya izin ver
      );

      if (outputFile != null) {
        // Kullanıcı dosya adını değiştirirken uzantıyı sildiyse biz ekleyelim
        if (!outputFile.toLowerCase().endsWith('.$cleanExtension')) {
          outputFile = '$outputFile.$cleanExtension';
        }

        final file = File(outputFile);
        await file.writeAsBytes(bytes);
        return file;
      }
      return null;
    } catch (e) {
      throw Exception('Dosya kaydetme hatası: $e');
    }
  }

  /// Masaüstüne direkt kaydet (Generic)
  static Future<File?> saveToDesktop({
    required List<int> bytes,
    required String fileName,
    required String extension,
  }) async {
    try {
      final cleanExtension = extension.replaceAll('.', '');
      final desktopPath = await _getDesktopPath();

      // Dosya yolunu oluştur
      final filePath = path.join(desktopPath, '$fileName.$cleanExtension');

      final file = File(filePath);
      await file.writeAsBytes(bytes);
      return file;
    } catch (e) {
      throw Exception('Masaüstüne kaydetme hatası: $e');
    }
  }

  static Future<String> _getDesktopPath() async {
    if (Platform.isWindows) {
      return path.join(Platform.environment['USERPROFILE']!, 'Desktop');
    } else if (Platform.isMacOS) {
      return path.join(Platform.environment['HOME']!, 'Desktop');
    } else if (Platform.isLinux) {
      return path.join(Platform.environment['HOME']!, 'Desktop');
    } else {
      final directory = await getTemporaryDirectory();
      return directory.path;
    }
  }
}
