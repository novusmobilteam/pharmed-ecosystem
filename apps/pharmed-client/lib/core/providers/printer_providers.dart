// pharmed-client/lib/core/providers/printer_providers.dart
//
// [SWREQ-PRN-060]
// Kiosk başına tek termal fiş yazıcısı → global (autoDispose olmayan) provider.
//
// Bağlantı ayarı (seri port / Windows kuyruğu, baud) AppSettingsCache'te kiosk
// bazında saklanır ve her yazdırma işinde yeniden okunur; ayar değişikliği için
// provider'ı yenilemek gerekmez.
//
// Geliştirmede:
//   --dart-define=PRINTER_MOCK=true   yazıcısız makinede fişleri PNG olarak kaydeder
// Mock flavor'da her zaman MockReceiptPrinter.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';

import 'package:pharmed_client/core/cache/app_settings_cache.dart';
import 'package:pharmed_client/core/flavor/app_flavor.dart';
import 'package:pharmed_client/core/hardware/printer/printer.dart';
import 'package:pharmed_client/features/auth/notifier/auth_notifier.dart';

final receiptPrinterProvider = Provider<IReceiptPrinter>((ref) {
  final printer = createReceiptPrinter(ref.read(appSettingsCacheProvider));
  ref.onDispose(printer.close);
  return printer;
});

IReceiptPrinter createReceiptPrinter(AppSettingsCache settings) {
  const forceMock = bool.fromEnvironment('PRINTER_MOCK');
  if (FlavorConfig.instance.isMock || forceMock) return MockReceiptPrinter();
  return EscPosReceiptPrinter(loadConfig: settings.getPrinterConfig);
}

/// [SWREQ-PRN-091] Alım / iade / fire / imha fişleri. İşlemi yapan kullanıcı
/// yazdırma anındaki oturumdan okunur.
final operationReceiptServiceProvider = Provider<OperationReceiptService>((ref) {
  return OperationReceiptService(
    printer: ref.read(receiptPrinterProvider),
    operatorName: () => ref.read(authNotifierProvider.notifier).currentUser?.fullName,
  );
});
