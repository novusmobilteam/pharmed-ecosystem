part of 'cabin_design_dialog.dart';

/// Deneme çekimi penceresi: bağlantı + anlık görüntü + kısa kayıt.
/// Test CameraFormNotifier'da yürür; bu pencere yalnızca onun görünümüdür
/// (pencere kapatılsa da sonuç formda kalır).
class _CameraTestDialog extends StatelessWidget {
  const _CameraTestDialog({required this.form});

  final CameraFormNotifier form;

  static Future<void> show(BuildContext context, CameraFormNotifier form) => showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _CameraTestDialog(form: form),
  );

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: MedRadius.lgAll),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: ListenableBuilder(
          listenable: form,
          builder: (context, _) {
            final result = form.testResult;
            final error = form.testError;
            final testing = form.isLoading(CameraFormNotifier.testOp);
            final refreshing = form.isLoading(CameraFormNotifier.snapshotOp);

            return Padding(
              padding: MedSpacing.insetXl * 1.5,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: MedSpacing.lg,
                children: [
                  Text(context.l10n.cabinDesign_camera_testDialogTitle, style: MedTextStyles.titleMd()),

                  // ── Görüntü alanı ─────────────────────────────────
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Container(
                      decoration: BoxDecoration(
                        color: MedColors.surface3,
                        border: Border.all(color: MedColors.border2),
                        borderRadius: MedRadius.mdAll,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: switch ((testing, result, error)) {
                        (true, _, _) => Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: MedSpacing.md,
                          children: [
                            const MedLoadingIndicator(),
                            Text(
                              context.l10n.cabinDesign_camera_testInProgress,
                              style: MedTextStyles.bodySm(color: MedColors.text3),
                            ),
                          ],
                        ),
                        (false, final r?, _) => Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.memory(r.snapshot, fit: BoxFit.contain, gaplessPlayback: true),
                            if (refreshing)
                              const ColoredBox(
                                color: Color(0x55FFFFFF),
                                child: Center(child: MedLoadingIndicator()),
                              ),
                          ],
                        ),
                        (false, null, final e?) => Padding(
                          padding: MedSpacing.insetXl,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: MedSpacing.sm,
                            children: [
                              Icon(Icons.videocam_off_outlined, size: 32, color: MedColors.red),
                              Text(
                                e,
                                textAlign: TextAlign.center,
                                style: MedTextStyles.bodyMd(color: MedColors.text2),
                              ),
                            ],
                          ),
                        ),
                        _ => const SizedBox.shrink(),
                      },
                    ),
                  ),

                  // ── Ölçümler ──────────────────────────────────────
                  if (result != null && !testing)
                    Row(
                      spacing: MedSpacing.sm,
                      children: [
                        Expanded(
                          child: _InfoField(
                            label: context.l10n.cabinDesign_camera_testConnectLabel,
                            value: '${result.connectTime.inMilliseconds} ms',
                          ),
                        ),
                        Expanded(
                          child: _InfoField(
                            label: context.l10n.cabinDesign_camera_testBitrateLabel,
                            value: '${result.bitrateKbps.round()} kbps',
                          ),
                        ),
                        Expanded(
                          child: _InfoField(
                            label: context.l10n.cabinDesign_camera_testStorageLabel,
                            value: context.l10n.cabinDesign_camera_testStorageValue(
                              result.mbPerMinute.toStringAsFixed(1),
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (result != null && error != null && !testing)
                    Text(error, style: MedTextStyles.bodySm(color: MedColors.red)),

                  // ── Butonlar ──────────────────────────────────────
                  Row(
                    children: [
                      if (result != null && !testing)
                        MedButton(
                          label: context.l10n.cabinDesign_camera_testRefreshButton,
                          prefixIcon: Icon(PhosphorIcons.arrowsClockwise()),
                          variant: MedButtonVariant.secondary,
                          isLoading: refreshing,
                          onPressed: refreshing ? null : form.refreshSnapshot,
                        ),
                      if (result == null && error != null && !testing)
                        MedButton(
                          label: context.l10n.cabinDesign_camera_testRetryButton,
                          prefixIcon: Icon(PhosphorIcons.arrowsClockwise()),
                          variant: MedButtonVariant.secondary,
                          onPressed: form.canTest ? form.runTest : null,
                        ),
                      const Spacer(),
                      MedButton(
                        label: context.l10n.common_closeButton,
                        onPressed: form.isTesting ? null : () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
