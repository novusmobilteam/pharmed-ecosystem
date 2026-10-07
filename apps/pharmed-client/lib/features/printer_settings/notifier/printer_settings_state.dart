// pharmed-client/lib/features/printer_settings/notifier/printer_settings_state.dart
//
// [SWREQ-PRN-050]
// Ayarlar › Yazıcı bölümünün durumu. Form (bağlantı türü / hedef / baud),
// kayıtlı ayar ile karşılaştırılarak "kaydedilmemiş değişiklik" tespit edilir.
//
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

enum PrinterSettingsFeedbackKind { saved, removed, testSucceeded, testFailed }

class PrinterSettingsFeedback {
  const PrinterSettingsFeedback(this.kind, {this.failure});

  final PrinterSettingsFeedbackKind kind;

  /// Yalnızca [PrinterSettingsFeedbackKind.testFailed] için.
  final PrinterFailureReason? failure;

  bool get isError => kind == PrinterSettingsFeedbackKind.testFailed;
}

class PrinterSettingsState {
  const PrinterSettingsState({
    this.isLoading = true,
    this.saved,
    this.connectionType = PrinterConnectionType.serial,
    this.target,
    this.baudRate = PrinterConfig.defaultBaudRate,
    this.serialPorts = const [],
    this.windowsPrinters = const [],
    this.isSaving = false,
    this.isPrinting = false,
    this.feedback,
  });

  /// Seri bağlantıda seçilebilen hızlar.
  static const baudRates = [9600, 19200, 38400, 57600, 115200];

  final bool isLoading;

  /// Cache'te kayıtlı ayar; null → kioskta yazıcı tanımlı değil.
  final PrinterConfig? saved;

  // ── Form ────────────────────────────────────────────────────
  final PrinterConnectionType connectionType;
  final String? target;
  final int baudRate;

  // ── Seçenekler ──────────────────────────────────────────────
  final List<String> serialPorts;
  final List<String> windowsPrinters;

  final bool isSaving;
  final bool isPrinting;
  final PrinterSettingsFeedback? feedback;

  List<String> get targets => switch (connectionType) {
    PrinterConnectionType.serial => serialPorts,
    PrinterConnectionType.windowsSpooler => windowsPrinters,
  };

  /// Formdaki ayar; hedef seçilmediyse null.
  PrinterConfig? get draft {
    final t = target;
    if (t == null || t.trim().isEmpty) return null;
    return PrinterConfig(connectionType: connectionType, target: t, baudRate: baudRate);
  }

  bool get isDirty => draft != null && draft != saved;
  bool get isBusy => isLoading || isSaving || isPrinting;

  PrinterSettingsState copyWith({
    bool? isLoading,
    PrinterConfig? saved,
    bool clearSaved = false,
    PrinterConnectionType? connectionType,
    String? target,
    bool clearTarget = false,
    int? baudRate,
    List<String>? serialPorts,
    List<String>? windowsPrinters,
    bool? isSaving,
    bool? isPrinting,
    PrinterSettingsFeedback? feedback,
    bool clearFeedback = false,
  }) {
    return PrinterSettingsState(
      isLoading: isLoading ?? this.isLoading,
      saved: clearSaved ? null : (saved ?? this.saved),
      connectionType: connectionType ?? this.connectionType,
      target: clearTarget ? null : (target ?? this.target),
      baudRate: baudRate ?? this.baudRate,
      serialPorts: serialPorts ?? this.serialPorts,
      windowsPrinters: windowsPrinters ?? this.windowsPrinters,
      isSaving: isSaving ?? this.isSaving,
      isPrinting: isPrinting ?? this.isPrinting,
      feedback: clearFeedback ? null : (feedback ?? this.feedback),
    );
  }
}
