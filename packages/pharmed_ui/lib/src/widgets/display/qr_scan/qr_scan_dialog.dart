// [SWREQ-UI-QRSCAN-001] [IEC 62304 §5.5]
// Ortak karekod (İTS / GS1 DataMatrix) okutma dialog'u. Client ve manager'da
// karekod okutan TÜM ekranlar bunu kullanır:
//   - Alım (client)                     : karekodlu ilaç alındıktan sonra
//   - Okutulmayan Karekodlar (client)   : sonradan okutma
//   - Okutulmayan Karekodlar (manager)  : sonradan okutma
//   - İade (client)                     : iade ÖNCESİ okutma
//
// Dialog HİÇBİR ekranı / state yönetimini bilmez: içerik [QrScanRequest] ile
// gelir, gönderim [QrScanSubmit] callback'i ile yapılır. Sonuç
// [showQrScanDialog]'ın döndürdüğü [QrScanOutcome]'dur.
//
// GİRDİ:
//   Okuyucu klavye gibi davranır. Görünmez bir "okuyucu girişi" alanı odağı
//   tutar (ekran klavyesi AÇILMAZ — TextInputType.none); okuma Enter ile ya
//   da kısa bir sessizlikten sonra tamamlanır. "Elle Gir" görünür bir alan
//   açar.
//
// DURUMLAR (tasarım: Karekod_Okutma_Dialogu):
//   Tekli : bekleniyor → okutuldu (GS1 alanları) | hatalı karekod
//   Çoklu : sürüyor (n/m) → tamamlandı | aynı karekod tekrar
//   Gönderim hatası: banner + "Tekrar Gönder" — dialog açık kalır.
//
// Sınıf: Class B

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'qr_scan_controller.dart';

/// Ürün kartındaki bağlam çipi (konum, hasta, reçete...).
class QrScanChip {
  const QrScanChip(this.text, {this.accent = false});

  final String text;

  /// true → mavi (konum gibi birincil bağlam), false → nötr.
  final bool accent;
}

/// Dialog'un ekrana özgü içeriği.
class QrScanRequest {
  const QrScanRequest({
    required this.operationLabel,
    required this.medicineName,
    required this.requiredCount,
    this.expectedGtin,
    this.chips = const [],
    this.allowPartialSubmit = false,
    this.confirmLabel,
    this.cancelLabel,
  });

  /// Alt başlıktaki işlem adı: "İlaç Alım", "İlaç İade", "Okutulmayan Karekodlar".
  final String operationLabel;

  final String medicineName;

  /// Okutulması gereken kutu sayısı (≥ 1).
  final int requiredCount;

  /// İlacın barkodu / GTIN'i (13 veya 14 hane). null → eşleşme kontrolü yok.
  final String? expectedGtin;

  final List<QrScanChip> chips;

  /// true → en az bir kod okutulunca onaylanabilir (örn. okutulmayan
  /// karekodlar ekranında kutuların bir kısmını şimdi okutmak).
  /// false → tüm kutular okutulmadan onaylanamaz.
  final bool allowPartialSubmit;

  /// Birincil buton etiketi; varsayılan "Onayla" (iadede örn. "İadeye Geç").
  final String? confirmLabel;

  /// İkincil buton etiketi; varsayılan "İptal".
  final String? cancelLabel;
}

/// Okutulan kodları gönderir / işler. Hata dönerse mesajı dialog'da
/// gösterilir ve dialog açık kalır (kullanıcı tekrar gönderebilir ya da
/// iptal edebilir). Başarılıysa dialog [QrScanOutcome.submitted] ile kapanır.
///
/// Gönderimi başka bir işlemin parçası olan ekranlar (örn. iade) burada
/// yalnızca kodları saklayıp `Result.ok` dönebilir.
typedef QrScanSubmit = Future<Result<void>> Function(List<Gs1Code> codes);

enum QrScanOutcome {
  /// Kodlar [QrScanSubmit] ile başarıyla işlendi.
  submitted,

  /// Kullanıcı İptal / ✕ ile kapattı — hiçbir kod işlenmedi.
  cancelled,
}

Future<QrScanOutcome> showQrScanDialog(
  BuildContext context, {
  required QrScanRequest request,
  required QrScanSubmit onSubmit,
}) async {
  final outcome = await showMedDialog<QrScanOutcome>(
    context: context,
    barrierDismissible: false,
    builder: (_) => QrScanDialog(request: request, onSubmit: onSubmit),
  );
  return outcome ?? QrScanOutcome.cancelled;
}

class QrScanDialog extends StatefulWidget {
  const QrScanDialog({super.key, required this.request, required this.onSubmit});

  final QrScanRequest request;
  final QrScanSubmit onSubmit;

  @override
  State<QrScanDialog> createState() => _QrScanDialogState();
}

class _QrScanDialogState extends State<QrScanDialog> {
  /// Okuyucu Enter göndermezse, son karakterden bu kadar sonra okuma
  /// tamamlanmış sayılır.
  static const _scannerIdle = Duration(milliseconds: 250);

  /// Sessizlikle otomatik gönderim için asgari uzunluk — İTS karekodu en az
  /// GTIN (16) + seri no içerir; elle yarım yazılmış değer gönderilmesin.
  static const _minAutoSubmitLength = 20;

  late final QrScanController _scan;

  final _scannerController = TextEditingController();
  final _scannerFocus = FocusNode(debugLabel: 'qrScanner');
  Timer? _scannerIdleTimer;

  bool _manualEntry = false;
  final _manualController = TextEditingController();
  final _manualFocus = FocusNode(debugLabel: 'qrManual');

  bool _isSubmitting = false;
  String? _submitError;

  QrScanRequest get _request => widget.request;

  bool get _canConfirm => !_isSubmitting && (_request.allowPartialSubmit ? _scan.scannedCount > 0 : _scan.isComplete);

  @override
  void initState() {
    super.initState();
    _scan = QrScanController(requiredCount: _request.requiredCount, expectedGtin: _request.expectedGtin)
      ..addListener(_onScanChanged);
  }

  @override
  void dispose() {
    _scannerIdleTimer?.cancel();
    _scan
      ..removeListener(_onScanChanged)
      ..dispose();
    _scannerController.dispose();
    _scannerFocus.dispose();
    _manualController.dispose();
    _manualFocus.dispose();
    super.dispose();
  }

  void _onScanChanged() {
    if (!mounted) return;
    // Liste değiştiyse önceki gönderim hatası artık geçerli değil.
    setState(() => _submitError = null);
    _focusScanner();
  }

  // ── Okuyucu girişi ──────────────────────────────────────────────────

  void _onScannerChanged(String value) {
    _scannerIdleTimer?.cancel();
    if (value.trim().length < _minAutoSubmitLength) return;
    _scannerIdleTimer = Timer(_scannerIdle, _commitScanner);
  }

  void _commitScanner() {
    _scannerIdleTimer?.cancel();
    final text = _scannerController.text;
    _scannerController.clear();
    _scan.submit(text);
  }

  void _focusScanner() {
    if (!mounted || _manualEntry) return;
    if (!_scannerFocus.hasFocus) _scannerFocus.requestFocus();
  }

  // ── Elle giriş ──────────────────────────────────────────────────────

  void _toggleManualEntry() {
    setState(() => _manualEntry = !_manualEntry);
    if (_manualEntry) {
      _manualFocus.requestFocus();
    } else {
      _manualController.clear();
      _focusScanner();
    }
  }

  void _commitManual() {
    final text = _manualController.text;
    if (text.trim().isEmpty) return;
    _manualController.clear();
    _scan.submit(text);
    if (_scan.error == null) setState(() => _manualEntry = false);
    _focusScanner();
  }

  // ── Eylemler ────────────────────────────────────────────────────────

  Future<void> _confirm() async {
    if (!_canConfirm) return;
    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });

    final result = await widget.onSubmit(_scan.codes);
    if (!mounted) return;

    result.when(
      ok: (_) => Navigator.of(context).pop(QrScanOutcome.submitted),
      error: (e) {
        MedLogger.warn(
          unit: 'QrScan',
          swreq: 'SWREQ-UI-QRSCAN-001',
          message: 'Karekod gönderimi başarısız',
          context: {'operation': _request.operationLabel, 'count': _scan.scannedCount, 'error': e.message},
        );
        setState(() {
          _isSubmitting = false;
          _submitError = e.message;
        });
      },
    );
  }

  void _cancel() {
    if (_isSubmitting) return;
    Navigator.of(context).pop(QrScanOutcome.cancelled);
  }

  void _retryScan() {
    _scan.isMulti ? _scan.dismissError() : _scan.reset();
    _focusScanner();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Dialog(
      insetPadding: MedSpacing.insetXl,
      backgroundColor: MedColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: MedRadius.xl2All,
        side: const BorderSide(color: MedColors.border),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _QrDialogHeader(
              title: l10n.qrScan_dialogTitle,
              subtitle: _scan.isMulti
                  ? l10n.qrScan_subtitleMulti(_request.operationLabel)
                  : l10n.qrScan_subtitleSingle(_request.operationLabel),
              closeTooltip: l10n.qrScan_closeTooltip,
              onClose: _isSubmitting ? null : _cancel,
            ),
            Flexible(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _focusScanner,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 18,
                    children: [
                      _ScannerSink(
                        controller: _scannerController,
                        focusNode: _scannerFocus,
                        enabled: !_isSubmitting,
                        onChanged: _onScannerChanged,
                        onSubmitted: (_) => _commitScanner(),
                      ),
                      _MedicineCard(
                        name: _request.medicineName,
                        chips: [for (final c in _request.chips) (c.text, c.accent)],
                        scanned: _scan.scannedCount,
                        total: _request.requiredCount,
                        showSegments: _scan.isMulti,
                      ),
                      _buildStatus(context),
                      if (_scan.isMulti)
                        _CodeList(scan: _scan, onRemove: _isSubmitting ? null : _scan.removeAt)
                      else
                        ..._buildSingleCode(context),
                      if (_manualEntry)
                        _ManualEntryField(
                          controller: _manualController,
                          focusNode: _manualFocus,
                          onSubmit: _commitManual,
                        ),
                    ],
                  ),
                ),
              ),
            ),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  /// Ürün kartının altındaki durum alanı: gönderim hatası > okuma hatası >
  /// tamamlandı > okutma yönergesi.
  Widget _buildStatus(BuildContext context) {
    final l10n = context.l10n;

    if (_submitError case final message?) {
      return _StatusBanner.error(title: l10n.qrScan_submitErrorTitle, body: message);
    }

    if (_scan.error case final error?) {
      return switch (error.rejection) {
        QrScanRejection.unreadable => _StatusBanner.error(
          title: l10n.qrScan_unreadableTitle,
          body: l10n.qrScan_unreadableBody,
        ),
        QrScanRejection.gtinMismatch => _StatusBanner.error(
          title: l10n.qrScan_mismatchTitle,
          body: l10n.qrScan_mismatchBody,
        ),
        QrScanRejection.duplicate => _StatusBanner.error(
          title: l10n.qrScan_duplicateTitle,
          body: l10n.qrScan_duplicateBody(
            error.code.serial ?? error.code.raw,
            (error.duplicateOfIndex ?? 0) + 1,
            _scan.nextBoxNumber,
          ),
        ),
      };
    }

    if (_scan.isComplete) {
      return _scan.isMulti
          ? _StatusBanner.success(
              title: l10n.qrScan_allScannedTitle,
              body: l10n.qrScan_allScannedBody(_scan.scannedCount),
            )
          : _StatusBanner.success(title: l10n.qrScan_successTitle, body: l10n.qrScan_successBody);
    }

    return _scan.isMulti
        ? _ScanPrompt.compact(
            title: l10n.qrScan_multiPromptTitle(_scan.nextBoxNumber),
            body: l10n.qrScan_multiPromptBody,
            readyLabel: l10n.qrScan_readerReadyShort,
          )
        : _ScanPrompt.large(
            title: l10n.qrScan_scanPromptTitle,
            body: l10n.qrScan_scanPromptBody,
            readyLabel: l10n.qrScan_readerReady,
          );
  }

  List<Widget> _buildSingleCode(BuildContext context) {
    final l10n = context.l10n;
    final accepted = _scan.codes.firstOrNull;
    final error = _scan.error;

    return [
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          _FieldLabel(l10n.qrScan_scannedCodeLabel),
          if (accepted != null)
            _CodeBox.success(accepted.raw)
          else if (error != null)
            _CodeBox.error(error.code.raw)
          else
            _CodeBox.waiting(l10n.qrScan_waitingPlaceholder),
        ],
      ),
      if (accepted != null) _Gs1FieldGrid(code: accepted),
      if (error?.rejection == QrScanRejection.gtinMismatch && _scan.expectedGtin != null)
        _GtinCompare(
          expected: _scan.expectedGtin!,
          scanned: error!.code.gtin ?? error.code.rawGtin ?? error.code.raw,
          expectedName: _request.medicineName,
        ),
    ];
  }

  Widget _buildFooter(BuildContext context) {
    final l10n = context.l10n;
    final confirmBase = _request.confirmLabel ?? l10n.qrScan_confirmButton;
    final error = _scan.error;

    final Widget leading;
    if (_submitError == null && error != null) {
      leading = Expanded(
        child: Text(
          l10n.qrScan_errorCode(error.rejection.errorCode),
          style: MedTextStyles.monoXs().copyWith(color: MedColors.text3),
        ),
      );
    } else if (!_scan.isMulti && _scan.isComplete) {
      leading = _OutlinedAction(
        icon: PhosphorIcons.arrowCounterClockwise(),
        label: l10n.qrScan_rescanButton,
        onPressed: _isSubmitting ? null : _retryScan,
      );
    } else if (!_scan.isComplete) {
      leading = _TextAction(
        icon: PhosphorIcons.keyboard(),
        label: _manualEntry ? l10n.qrScan_scannerEntryButton : l10n.qrScan_manualEntryButton,
        onPressed: _isSubmitting ? null : _toggleManualEntry,
      );
    } else {
      leading = const SizedBox.shrink();
    }

    final Widget primary;
    if (_submitError != null) {
      // Gönderim reddedildi — aynı kodları tekrar gönder (liste değiştirilebilir).
      primary = MedButton(
        label: l10n.qrScan_resubmitButton,
        isLoading: _isSubmitting,
        onPressed: _canConfirm ? _confirm : null,
      );
    } else if (error != null && !_scan.isMulti) {
      // Tekli alımda okuma reddedildi — birincil eylem "Tekrar Okut".
      primary = MedButton(label: l10n.qrScan_retryScanButton, onPressed: _retryScan);
    } else {
      primary = MedButton(
        label: (_scan.isMulti && !_scan.isComplete)
            ? l10n.qrScan_confirmProgress(confirmBase, _scan.scannedCount, _scan.requiredCount)
            : confirmBase,
        isLoading: _isSubmitting,
        onPressed: _canConfirm ? _confirm : null,
      );
    }

    return _QrDialogFooter(
      children: [
        leading,
        if (leading is! Expanded) const Spacer(),
        _GhostAction(
          label: _request.cancelLabel ?? l10n.qrScan_cancelButton,
          onPressed: _isSubmitting ? null : _cancel,
        ),
        ConstrainedBox(constraints: const BoxConstraints(minWidth: 140), child: primary),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
// Parçalar
// ════════════════════════════════════════════════════════════════════════

/// Okuyucunun yazdığı görünmez alan. Ekran klavyesi açmaz; odak her
/// durum değişiminde buraya geri döner.
class _ScannerSink extends StatelessWidget {
  const _ScannerSink({
    required this.controller,
    required this.focusNode,
    required this.enabled,
    required this.onChanged,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool enabled;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox(
        height: 1,
        child: Opacity(
          opacity: 0,
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            autofocus: true,
            enabled: enabled,
            keyboardType: TextInputType.none,
            enableSuggestions: false,
            autocorrect: false,
            showCursor: false,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
          ),
        ),
      ),
    );
  }
}

class _QrDialogHeader extends StatelessWidget {
  const _QrDialogHeader({required this.title, required this.subtitle, required this.closeTooltip, this.onClose});

  final String title;
  final String subtitle;
  final String closeTooltip;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 18, 20, 18),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF4F7FF), Color(0xFFEEF2FB)],
        ),
        border: Border(bottom: BorderSide(color: MedColors.border2)),
      ),
      child: Row(
        spacing: 14,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: MedColors.blue, borderRadius: MedRadius.midAll),
            child: Icon(PhosphorIcons.qrCode(), color: Colors.white, size: 24),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(title, style: MedTextStyles.titleMd()),
                Text(subtitle, style: MedTextStyles.bodySm(color: MedColors.text2)),
              ],
            ),
          ),
          _SquareIconButton(icon: PhosphorIcons.x(), tooltip: closeTooltip, onPressed: onClose),
        ],
      ),
    );
  }
}

class _MedicineCard extends StatelessWidget {
  const _MedicineCard({
    required this.name,
    required this.chips,
    required this.scanned,
    required this.total,
    required this.showSegments,
  });

  final String name;

  /// (metin, vurgulu mu) — vurgulu çip mavi (konum), diğeri nötr (hasta).
  final List<(String, bool)> chips;
  final int scanned;
  final int total;
  final bool showSegments;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isComplete = scanned >= total;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: MedColors.surface2,
        border: Border.all(color: MedColors.border),
        borderRadius: MedRadius.midAll,
      ),
      child: Column(
        spacing: 12,
        children: [
          Row(
            spacing: 14,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 6,
                  children: [
                    Text(name, style: MedTextStyles.bodyMd().copyWith(fontSize: 15, fontWeight: FontWeight.w600)),
                    if (chips.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          for (final (text, accent) in chips)
                            _Chip(
                              text: text,
                              background: accent ? MedColors.blueLight : MedColors.surface3,
                              foreground: accent ? MedColors.blue : MedColors.text2,
                            ),
                        ],
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                spacing: 2,
                children: [
                  Text(
                    l10n.qrScan_scannedCounterLabel,
                    style: MedTextStyles.monoXs().copyWith(color: MedColors.text3, letterSpacing: 0.8),
                  ),
                  Text.rich(
                    TextSpan(
                      text: '$scanned',
                      style: MedTextStyles.titleLg().copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: isComplete ? MedColors.green : MedColors.text,
                      ),
                      children: [
                        TextSpan(
                          text: l10n.qrScan_boxCountSuffix(total),
                          style: MedTextStyles.titleSm().copyWith(fontSize: 15, color: MedColors.text3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (showSegments)
            Semantics(
              label: l10n.qrScan_progressSemantics(scanned, total),
              child: Row(
                spacing: 6,
                children: [
                  for (var i = 0; i < total; i++)
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 6,
                        decoration: BoxDecoration(
                          color: i < scanned ? MedColors.green : MedColors.border,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Okutma yönergesi — tekli alımda büyük, çoklu alımda sıradaki kutuya
/// odaklı kompakt görünüm.
class _ScanPrompt extends StatelessWidget {
  const _ScanPrompt.large({required this.title, required this.body, required this.readyLabel}) : _compact = false;

  const _ScanPrompt.compact({required this.title, required this.body, required this.readyLabel}) : _compact = true;

  final String title;
  final String body;
  final String readyLabel;
  final bool _compact;

  @override
  Widget build(BuildContext context) {
    final frame = _compact ? 60.0 : 104.0;

    return Container(
      padding: EdgeInsets.all(_compact ? 14 : 22),
      decoration: BoxDecoration(
        color: MedColors.blue.withValues(alpha: 0.04),
        // Tasarımda kesikli kenar — Flutter'da yerleşik yok; yumuşak düz kenar.
        border: Border.all(color: MedColors.blue.withValues(alpha: 0.45), width: 1.5),
        borderRadius: MedRadius.lgAll,
      ),
      child: Row(
        spacing: _compact ? 16 : 22,
        children: [
          _ScanFrame(size: frame),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: _compact ? 4 : 8,
              children: [
                Text(title, style: MedTextStyles.titleSm().copyWith(fontSize: _compact ? 15 : 16)),
                Text(body, style: MedTextStyles.bodySm(color: MedColors.text2).copyWith(height: 1.5)),
                if (!_compact) _ReaderReadyChip(label: readyLabel),
              ],
            ),
          ),
          if (_compact) _ReaderReadyChip(label: readyLabel),
        ],
      ),
    );
  }
}

/// Karekod silueti üzerinde gezinen tarama çizgisi.
class _ScanFrame extends StatefulWidget {
  const _ScanFrame({required this.size});

  final double size;

  @override
  State<_ScanFrame> createState() => _ScanFrameState();
}

class _ScanFrameState extends State<_ScanFrame> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final inset = size < 80 ? 5.0 : 6.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: MedColors.surface,
        border: Border.all(color: MedColors.border),
        borderRadius: size < 80 ? MedRadius.mdAll : MedRadius.midAll,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: 0.28,
            child: Icon(PhosphorIcons.qrCode(), size: size * 0.75, color: MedColors.text),
          ),
          AnimatedBuilder(
            animation: _controller,
            builder: (_, __) => Positioned(
              left: inset,
              right: inset,
              top: inset + Curves.easeInOut.transform(_controller.value) * (size - inset * 2 - 2),
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  color: MedColors.blue,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(color: MedColors.blue.withValues(alpha: 0.45), blurRadius: 10, spreadRadius: 2),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// "Okuyucu hazır" — nabız atan yeşil nokta.
class _ReaderReadyChip extends StatefulWidget {
  const _ReaderReadyChip({required this.label});

  final String label;

  @override
  State<_ReaderReadyChip> createState() => _ReaderReadyChipState();
}

class _ReaderReadyChipState extends State<_ReaderReadyChip> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 4, 10, 4),
      decoration: BoxDecoration(color: MedColors.greenLight, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          SizedBox(
            width: 8,
            height: 8,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedBuilder(
                  animation: _controller,
                  builder: (_, __) => Transform.scale(
                    scale: 0.8 + _controller.value * 1.2,
                    child: Opacity(
                      opacity: 0.5 * (1 - _controller.value),
                      child: const DecoratedBox(
                        decoration: BoxDecoration(color: MedColors.green, shape: BoxShape.circle),
                        child: SizedBox.expand(),
                      ),
                    ),
                  ),
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(color: MedColors.green, shape: BoxShape.circle),
                  child: SizedBox.expand(),
                ),
              ],
            ),
          ),
          Text(widget.label, style: MedTextStyles.monoXs().copyWith(color: MedColors.green)),
        ],
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner.success({required this.title, required this.body}) : _isError = false;

  const _StatusBanner.error({required this.title, required this.body}) : _isError = true;

  final String title;
  final String body;
  final bool _isError;

  @override
  Widget build(BuildContext context) {
    final accent = _isError ? MedColors.red : MedColors.green;
    final tint = _isError ? MedColors.redLight : MedColors.greenLight;

    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: tint,
          border: Border.all(color: accent.withValues(alpha: 0.35)),
          borderRadius: MedRadius.lgAll,
        ),
        child: Row(
          crossAxisAlignment: _isError ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          spacing: 14,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
              child: Icon(
                _isError
                    ? PhosphorIcons.warning(PhosphorIconsStyle.bold)
                    : PhosphorIcons.check(PhosphorIconsStyle.bold),
                color: Colors.white,
                size: 20,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  Text(title, style: MedTextStyles.titleSm().copyWith(fontSize: 16, color: accent)),
                  Text(body, style: MedTextStyles.bodySm(color: MedColors.text2).copyWith(height: 1.5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text, {this.trailing, this.trailingColor});

  final String text;
  final String? trailing;
  final Color? trailingColor;

  @override
  Widget build(BuildContext context) {
    final style = MedTextStyles.monoXs().copyWith(
      color: MedColors.text3,
      letterSpacing: 1,
      fontWeight: FontWeight.w500,
    );
    return Row(
      children: [
        Expanded(child: Text(text, style: style)),
        if (trailing != null) Text(trailing!, style: style.copyWith(color: trailingColor ?? MedColors.text3)),
      ],
    );
  }
}

/// Tekli alımda okutulan kodun gösterildiği kutu.
class _CodeBox extends StatelessWidget {
  const _CodeBox.waiting(String placeholder) : text = placeholder, _kind = 0;

  const _CodeBox.success(String code) : text = code, _kind = 1;

  const _CodeBox.error(String code) : text = code, _kind = 2;

  final String text;
  final int _kind;

  @override
  Widget build(BuildContext context) {
    final (Color border, Color background, List<BoxShadow> glow) = switch (_kind) {
      1 => (MedColors.green, MedColors.surface, const <BoxShadow>[]),
      2 => (
        MedColors.red,
        MedColors.redLight,
        [BoxShadow(color: MedColors.red.withValues(alpha: 0.10), spreadRadius: 3)],
      ),
      _ => (
        MedColors.blue,
        MedColors.surface,
        [BoxShadow(color: MedColors.blue.withValues(alpha: 0.12), spreadRadius: 3)],
      ),
    };
    final isWaiting = _kind == 0;

    return Container(
      constraints: const BoxConstraints(minHeight: 52),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: background,
        border: Border.all(color: border, width: 1.5),
        borderRadius: MedRadius.mdAll,
        boxShadow: glow,
      ),
      child: Row(
        spacing: 10,
        children: [
          Icon(PhosphorIcons.scan(), size: 20, color: isWaiting ? MedColors.text3 : border),
          if (isWaiting) const _BlinkingCaret(),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: MedTextStyles.monoSm().copyWith(color: isWaiting ? MedColors.text3 : MedColors.text),
            ),
          ),
        ],
      ),
    );
  }
}

class _BlinkingCaret extends StatefulWidget {
  const _BlinkingCaret();

  @override
  State<_BlinkingCaret> createState() => _BlinkingCaretState();
}

class _BlinkingCaretState extends State<_BlinkingCaret> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))
    ..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) => Opacity(
        opacity: _controller.value < 0.5 ? 1 : 0,
        child: Container(width: 2, height: 18, color: MedColors.blue),
      ),
    );
  }
}

/// Tekli alımda doğrulanan kodun GS1 alanları (2×2).
class _Gs1FieldGrid extends StatelessWidget {
  const _Gs1FieldGrid({required this.code});

  final Gs1Code code;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cells = [
      (l10n.qrScan_gtinLabel, code.gtin),
      (l10n.qrScan_serialLabel, code.serial),
      (l10n.qrScan_expiryLabel, _formatDate(code.expiry)),
      (l10n.qrScan_lotLabel, code.lot),
    ];

    Widget cell((String, String?) c) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      color: MedColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
        children: [
          Text(c.$1, style: MedTextStyles.monoXs().copyWith(color: MedColors.text3, letterSpacing: 1)),
          Text(c.$2 ?? '—', style: MedTextStyles.monoMd().copyWith(fontWeight: FontWeight.w500)),
        ],
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: MedColors.border2,
        border: Border.all(color: MedColors.border2),
        borderRadius: MedRadius.midAll,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        spacing: 1,
        children: [
          for (var row = 0; row < 2; row++)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 1,
                children: [
                  Expanded(child: cell(cells[row * 2])),
                  Expanded(child: cell(cells[row * 2 + 1])),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// GTIN uyuşmazlığında beklenen / okutulan karşılaştırması; farklı haneler
/// kırmızı ve altı çizili.
class _GtinCompare extends StatelessWidget {
  const _GtinCompare({required this.expected, required this.scanned, this.expectedName});

  final String expected;
  final String scanned;
  final String? expectedName;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final mono = MedTextStyles.monoMd().copyWith(fontWeight: FontWeight.w500);
    final diff = mono.copyWith(color: MedColors.red, decoration: TextDecoration.underline);

    Widget row({
      required String label,
      required InlineSpan value,
      required Color labelColor,
      String? note,
      Color? background,
    }) => Container(
      color: background ?? MedColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        spacing: 12,
        children: [
          SizedBox(
            width: 96,
            child: Text(label, style: MedTextStyles.monoXs().copyWith(color: labelColor, letterSpacing: 1)),
          ),
          Expanded(child: Text.rich(value)),
          if (note != null) Text(note, style: MedTextStyles.bodySm(color: MedColors.text2)),
        ],
      ),
    );

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: MedColors.border2),
        borderRadius: MedRadius.midAll,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          row(
            label: l10n.qrScan_expectedLabel,
            labelColor: MedColors.text3,
            value: TextSpan(text: expected, style: mono),
            note: expectedName,
          ),
          const Divider(height: 1, thickness: 1, color: MedColors.border2),
          row(
            label: l10n.qrScan_scannedCounterLabel,
            labelColor: MedColors.red,
            background: MedColors.redLight,
            value: TextSpan(
              children: [
                for (var i = 0; i < scanned.length; i++)
                  TextSpan(text: scanned[i], style: (i < expected.length && scanned[i] == expected[i]) ? mono : diff),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Çoklu alımda okutulan kodlar + sıradaki kutu satırı.
class _CodeList extends StatelessWidget {
  const _CodeList({required this.scan, this.onRemove});

  final QrScanController scan;

  /// null → satırlar kaldırılamaz (gönderim sürerken).
  final ValueChanged<int>? onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final error = scan.error;
    final duplicateIndex = error?.rejection == QrScanRejection.duplicate ? error!.duplicateOfIndex : null;

    final rows = <Widget>[
      for (final (i, code) in scan.codes.indexed)
        _CodeRow(
          boxNumber: i + 1,
          code: code,
          isDuplicate: i == duplicateIndex,
          onRemove: onRemove == null ? null : () => onRemove!(i),
        ),
      if (!scan.isComplete) _PendingRow(boxNumber: scan.nextBoxNumber),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        _FieldLabel(
          l10n.qrScan_scannedCodesLabel,
          trailing: '${scan.scannedCount} / ${scan.requiredCount}',
          trailingColor: scan.isComplete ? MedColors.green : null,
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: MedColors.border),
            borderRadius: MedRadius.midAll,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (final (i, row) in rows.indexed) ...[
                if (i > 0) const Divider(height: 1, thickness: 1, color: MedColors.border2),
                row,
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _CodeRow extends StatelessWidget {
  const _CodeRow({required this.boxNumber, required this.code, required this.isDuplicate, this.onRemove});

  final int boxNumber;
  final Gs1Code code;
  final bool isDuplicate;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final muted = isDuplicate ? MedColors.red : MedColors.text3;

    final details = [
      if (isDuplicate) l10n.qrScan_duplicateRowNote,
      if (code.expiry != null) l10n.qrScan_expiryShort(_formatDate(code.expiry)!),
      if (!isDuplicate && code.lot != null) l10n.qrScan_lotShort(code.lot!),
    ].join(' · ');

    return Container(
      constraints: const BoxConstraints(minHeight: 60),
      padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
      decoration: BoxDecoration(
        color: isDuplicate ? MedColors.redLight : MedColors.surface,
        border: isDuplicate ? Border.all(color: MedColors.red, width: 1.5) : null,
      ),
      child: Row(
        spacing: 12,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isDuplicate ? MedColors.red.withValues(alpha: 0.12) : MedColors.greenLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isDuplicate
                  ? PhosphorIcons.warning(PhosphorIconsStyle.bold)
                  : PhosphorIcons.check(PhosphorIconsStyle.bold),
              size: 14,
              color: isDuplicate ? MedColors.red : MedColors.green,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 3,
              children: [
                Text(
                  code.serial != null ? l10n.qrScan_serialValue(code.serial!) : code.raw,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: MedTextStyles.monoSm().copyWith(fontWeight: FontWeight.w500, color: MedColors.text),
                ),
                if (details.isNotEmpty) Text(details, style: MedTextStyles.monoXs().copyWith(color: muted)),
              ],
            ),
          ),
          Text(l10n.qrScan_boxLabel(boxNumber), style: MedTextStyles.monoXs().copyWith(color: muted)),
          _SquareIconButton(
            icon: PhosphorIcons.trash(),
            tooltip: l10n.qrScan_removeCodeTooltip(boxNumber),
            borderColor: isDuplicate ? MedColors.red.withValues(alpha: 0.4) : MedColors.border2,
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}

class _PendingRow extends StatelessWidget {
  const _PendingRow({required this.boxNumber});

  final int boxNumber;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      constraints: const BoxConstraints(minHeight: 60),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      color: MedColors.blue.withValues(alpha: 0.04),
      child: Row(
        spacing: 12,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: MedColors.blue.withValues(alpha: 0.45), width: 1.5),
            ),
            child: Text('$boxNumber', style: MedTextStyles.titleSm().copyWith(fontSize: 12, color: MedColors.blue)),
          ),
          const _BlinkingCaret(),
          Expanded(
            child: Text(l10n.qrScan_waitingPlaceholder, style: MedTextStyles.monoSm().copyWith(color: MedColors.text3)),
          ),
          Text(l10n.qrScan_boxLabel(boxNumber), style: MedTextStyles.monoXs().copyWith(color: MedColors.blue)),
        ],
      ),
    );
  }
}

/// "Elle Gir" ile açılan görünür giriş — ekran klavyesiyle.
class _ManualEntryField extends StatelessWidget {
  const _ManualEntryField({required this.controller, required this.focusNode, required this.onSubmit});

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Row(
      spacing: 10,
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            autocorrect: false,
            enableSuggestions: false,
            textInputAction: TextInputAction.done,
            style: MedTextStyles.monoSm(),
            decoration: InputDecoration(hintText: l10n.qrScan_manualEntryHint),
            onSubmitted: (_) => onSubmit(),
          ),
        ),
        MedButton(label: l10n.qrScan_manualEntryAddButton, onPressed: onSubmit),
      ],
    );
  }
}

// ── Footer ve düğmeler ────────────────────────────────────────────────

class _QrDialogFooter extends StatelessWidget {
  const _QrDialogFooter({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: MedColors.surface2,
        border: Border(top: BorderSide(color: MedColors.border2)),
      ),
      child: Row(spacing: 12, children: children),
    );
  }
}

class _GhostAction extends StatelessWidget {
  const _GhostAction({required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 22),
        backgroundColor: MedColors.surface,
        foregroundColor: MedColors.text2,
        side: const BorderSide(color: MedColors.border),
        shape: RoundedRectangleBorder(borderRadius: MedRadius.mdAll),
        textStyle: MedTextStyles.bodyMd().copyWith(fontWeight: FontWeight.w600),
      ),
      child: Text(label),
    );
  }
}

class _OutlinedAction extends StatelessWidget {
  const _OutlinedAction({required this.icon, required this.label, this.onPressed});

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        foregroundColor: MedColors.blue,
        side: const BorderSide(color: MedColors.blue, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: MedRadius.mdAll),
        textStyle: MedTextStyles.bodyMd().copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _TextAction extends StatelessWidget {
  const _TextAction({required this.icon, required this.label, this.onPressed});

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: TextButton.styleFrom(
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        foregroundColor: MedColors.blue,
        textStyle: MedTextStyles.bodyMd().copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _SquareIconButton extends StatelessWidget {
  const _SquareIconButton({required this.icon, required this.tooltip, this.onPressed, this.borderColor});

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: SizedBox(
        width: 44,
        height: 44,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.zero,
            backgroundColor: MedColors.surface,
            foregroundColor: MedColors.text2,
            side: BorderSide(color: borderColor ?? MedColors.border),
            shape: RoundedRectangleBorder(borderRadius: MedRadius.mdAll),
          ),
          child: Icon(icon, size: 18),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text, required this.background, required this.foreground});

  final String text;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: MedTextStyles.monoXs().copyWith(color: foreground)),
    );
  }
}

String? _formatDate(DateTime? d) {
  if (d == null) return null;
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(d.day)}.${two(d.month)}.${d.year}';
}
