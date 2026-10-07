// pharmed-client/lib/features/printer_settings/notifier/printer_settings_notifier.dart
//
// [SWREQ-PRN-050] [SWREQ-PRN-080]
// Ayarlar › Yazıcı: kiosk yazıcı bağlantısının seçilmesi, kaydedilmesi ve
// test fişi basılması.
//
// Test fişi formdaki (henüz kaydedilmemiş olabilir) ayarla basılır; böylece
// kurulumda doğru port bulunmadan ayar kaydedilmek zorunda kalınmaz.
// Mock yazıcı etkinse test fişi de mock'a gider (PNG önizleme).
//
// Sınıf: Class B

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import 'package:pharmed_client/core/cache/app_settings_cache.dart';
import 'package:pharmed_client/core/hardware/printer/printer.dart';
import 'package:pharmed_client/core/providers/printer_providers.dart';

import '../receipts/printer_test_receipt.dart';
import 'printer_settings_state.dart';

final printerSettingsNotifierProvider =
    NotifierProvider.autoDispose<PrinterSettingsNotifier, PrinterSettingsState>(PrinterSettingsNotifier.new);

class PrinterSettingsNotifier extends AutoDisposeNotifier<PrinterSettingsState> {
  static const _unit = 'SW-UNIT-PRN';

  bool _disposed = false;

  AppSettingsCache get _settings => ref.read(appSettingsCacheProvider);
  IReceiptPrinter get _printer => ref.read(receiptPrinterProvider);

  /// Mock yazıcı etkinse PNG'lerin kaydedildiği klasör; gerçek yazıcıda null.
  String? get mockOutputDirectory => switch (_printer) {
    final MockReceiptPrinter m => m.outputDirectory,
    _ => null,
  };

  @override
  PrinterSettingsState build() {
    _disposed = false;
    ref.onDispose(() => _disposed = true);
    Future.microtask(_load);
    return const PrinterSettingsState();
  }

  void _emit(PrinterSettingsState next) {
    if (!_disposed) state = next;
  }

  /// Kabinin RS485 hattının portu — yazıcı listesinde gösterilmez; yanlışlıkla
  /// seçilirse ESC/POS baytları kabin kartlarına gider.
  String? _cabinPort;

  List<String> _printerPorts() {
    final cabin = _cabinPort?.trim().toUpperCase();
    return [
      for (final p in SerialPrinterTransport.availablePorts())
        if (p.trim().toUpperCase() != cabin) p,
    ];
  }

  Future<void> _load() async {
    final saved = await _settings.getPrinterConfig();
    _cabinPort = await _settings.getComPort();
    final ports = _printerPorts();
    final printers = WindowsSpoolerPrinterTransport.installedPrinters();
    _emit(
      PrinterSettingsState(
        isLoading: false,
        saved: saved,
        connectionType: saved?.connectionType ?? PrinterConnectionType.serial,
        target: saved?.target,
        baudRate: saved?.baudRate ?? PrinterConfig.defaultBaudRate,
        serialPorts: _withSelected(ports, saved?.connectionType == PrinterConnectionType.serial ? saved?.target : null),
        windowsPrinters: _withSelected(
          printers,
          saved?.connectionType == PrinterConnectionType.windowsSpooler ? saved?.target : null,
        ),
      ),
    );
  }

  /// Kayıtlı hedef şu an listede yoksa (cihaz çıkarılmış) yine de seçili görünsün.
  static List<String> _withSelected(List<String> options, String? selected) {
    if (selected == null || options.contains(selected)) return options;
    return [selected, ...options];
  }

  // ── Form ────────────────────────────────────────────────────

  void setConnectionType(PrinterConnectionType type) {
    if (type == state.connectionType) return;
    final saved = state.saved;
    _emit(
      state.copyWith(
        connectionType: type,
        // Kayıtlı türe geri dönülürse kayıtlı hedef geri gelir.
        target: saved?.connectionType == type ? saved!.target : null,
        clearTarget: saved?.connectionType != type,
        clearFeedback: true,
      ),
    );
  }

  void setTarget(String? target) => _emit(state.copyWith(target: target, clearTarget: target == null, clearFeedback: true));

  void setBaudRate(int baudRate) => _emit(state.copyWith(baudRate: baudRate, clearFeedback: true));

  void refreshTargets() {
    _emit(
      state.copyWith(
        serialPorts: _withSelected(
          _printerPorts(),
          state.connectionType == PrinterConnectionType.serial ? state.target : null,
        ),
        windowsPrinters: _withSelected(
          WindowsSpoolerPrinterTransport.installedPrinters(),
          state.connectionType == PrinterConnectionType.windowsSpooler ? state.target : null,
        ),
      ),
    );
  }

  // ── Kaydet / kaldır ─────────────────────────────────────────

  Future<void> save() async {
    final draft = state.draft;
    if (draft == null || state.isBusy) return;
    _emit(state.copyWith(isSaving: true, clearFeedback: true));
    await _settings.savePrinterConfig(draft);
    MedLogger.info(
      unit: _unit,
      swreq: 'SWREQ-PRN-050',
      message: 'Yazıcı ayarı kaydedildi',
      context: {'previous': state.saved?.toString(), 'current': draft.toString()},
    );
    _emit(
      state.copyWith(
        isSaving: false,
        saved: draft,
        feedback: const PrinterSettingsFeedback(PrinterSettingsFeedbackKind.saved),
      ),
    );
  }

  Future<void> remove() async {
    if (state.saved == null || state.isBusy) return;
    _emit(state.copyWith(isSaving: true, clearFeedback: true));
    await _settings.clearPrinterConfig();
    MedLogger.info(
      unit: _unit,
      swreq: 'SWREQ-PRN-050',
      message: 'Yazıcı ayarı kaldırıldı',
      context: {'previous': state.saved?.toString()},
    );
    _emit(
      state.copyWith(
        isSaving: false,
        clearSaved: true,
        clearTarget: true,
        feedback: const PrinterSettingsFeedback(PrinterSettingsFeedbackKind.removed),
      ),
    );
  }

  // ── Test fişi ───────────────────────────────────────────────

  Future<void> printTest() async {
    final draft = state.draft;
    if (draft == null || state.isBusy) return;
    _emit(state.copyWith(isPrinting: true, clearFeedback: true));

    final printer = _printer is MockReceiptPrinter
        ? _printer
        : EscPosReceiptPrinter(loadConfig: () async => draft);
    final result = await printer.printReceipt(buildPrinterTestReceipt(draft));

    _emit(
      state.copyWith(
        isPrinting: false,
        feedback: result.when(
          ok: (_) => const PrinterSettingsFeedback(PrinterSettingsFeedbackKind.testSucceeded),
          error: (e) => PrinterSettingsFeedback(
            PrinterSettingsFeedbackKind.testFailed,
            failure: printerFailureReasonOf(e),
          ),
        ),
      ),
    );
  }
}
