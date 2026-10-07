// pharmed-client/lib/core/hardware/printer/printer_failure_extension.dart
//
// [SWREQ-PRN-003]
// PrinterFailureReason → kullanıcıya gösterilecek mesaj.
// Ayarlar ekranı ve otomatik fiş basan işlem ekranları aynı metni kullanır.
//
// Sınıf: Class B

import 'package:flutter/widgets.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

extension PrinterFailureReasonX on PrinterFailureReason {
  String message(BuildContext context) => _message(context.l10n);

  /// Notifier gibi BuildContext olmayan yerler için.
  String get contextlessMessage => _message(contextlessL10n());

  String _message(AppLocalizations l10n) => switch (this) {
    PrinterFailureReason.notConfigured => l10n.printer_error_notConfigured,
    PrinterFailureReason.connectionFailed => l10n.printer_error_connectionFailed,
    PrinterFailureReason.writeFailed => l10n.printer_error_writeFailed,
    PrinterFailureReason.timeout => l10n.printer_error_timeout,
    PrinterFailureReason.renderFailed => l10n.printer_error_renderFailed,
    PrinterFailureReason.invalidDocument => l10n.printer_error_invalidDocument,
    PrinterFailureReason.unexpected => l10n.printer_error_unexpected,
  };
}

/// Result hatasından nedeni çıkarır; yazıcı dışı bir hata ise unexpected.
PrinterFailureReason printerFailureReasonOf(AppException error) =>
    error is PrinterException ? error.reason : PrinterFailureReason.unexpected;
