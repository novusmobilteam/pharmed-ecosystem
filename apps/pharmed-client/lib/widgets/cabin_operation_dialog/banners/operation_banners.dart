import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'banner_shell.dart';

/// Plan dışı çıkış — kırmızı tema, "warning" ikonu. Mesaj override edilebilir.
class UnplannedMovementBanner extends StatelessWidget {
  const UnplannedMovementBanner({super.key, required this.epcs, this.message, this.title});

  final Set<String> epcs;
  final String? message;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return OperationBanner(
      tone: BannerTone.error,
      icon: PhosphorIcons.warning(),
      title: title ?? context.l10n.operationBanner_unplannedMovementTitle,
      message: message ?? context.l10n.operationBanner_unplannedMovementMessage(epcs.length),
      epcs: epcs,
    );
  }
}

/// İşlem hatası — complete fail. Mesaj zorunlu (her zaman bağlama özel).
class OperationErrorBanner extends StatelessWidget {
  const OperationErrorBanner({super.key, required this.message, this.title});

  final String message;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return OperationBanner(
      tone: BannerTone.error,
      icon: PhosphorIcons.warningCircle(),
      title: title ?? context.l10n.refill_error_queueTitle,
      message: message,
    );
  }
}

/// Beklenmeyen ilaç (kabine ait olmayan tag okundu). Amber tema (uyarı) veya
/// kırmızı tema (dolum blokajı). Mesaj override edilebilir.
class UnexpectedTagBanner extends StatelessWidget {
  const UnexpectedTagBanner({super.key, required this.epcs, this.blocking = false, this.message, this.title});

  final Set<String> epcs;
  final bool blocking;
  final String? message;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return OperationBanner(
      tone: blocking ? BannerTone.error : BannerTone.warning,
      icon: blocking ? PhosphorIcons.prohibit() : PhosphorIcons.package(),
      title: title ??
          (blocking
              ? context.l10n.operationBanner_unexpectedTagBlockingTitle
              : context.l10n.operationBanner_unexpectedTagWarningTitle),
      message:
          message ??
          (blocking
              ? context.l10n.operationBanner_unexpectedTagBlockingMessage(epcs.length)
              : context.l10n.operationBanner_unexpectedTagWarningMessage(epcs.length)),
      epcs: epcs,
    );
  }
}

/// Eksik stok — beklenen ama okunmayan ilaçlar. Amber tema, başlıklı.
class MissingStockBanner extends StatelessWidget {
  const MissingStockBanner({super.key, this.epcs, required this.count, this.message, this.title});

  final Set<String>? epcs;
  final int count;
  final String? message;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return OperationBanner(
      tone: BannerTone.warning,
      icon: PhosphorIcons.minusCircle(),
      title: title ?? context.l10n.operationBanner_missingStockTitle,
      message: message ?? context.l10n.operationBanner_missingStockMessage(count),
      epcs: epcs,
    );
  }
}

/// Rollback — kullanıcı fiziksel bir eylemi geri almalı. Hata değil,
/// yönlendirme → info (mavi). Daha önce OperationErrorBanner (kırmızı)
/// ile karışıyordu, bilinçli olarak ayrıldı.
class RollbackBanner extends StatelessWidget {
  const RollbackBanner({super.key, required this.message, this.title});

  final String message;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return OperationBanner(
      tone: BannerTone.info,
      icon: PhosphorIcons.arrowCounterClockwise(),
      title: title ?? context.l10n.operationStatus_rollingBackLabel,
      message: message,
    );
  }
}
