// pharmed-client/lib/features/fingerprint_enrollment/view/fingerprint_enrollment_screen.dart
//
// [SWREQ-FP-100] [SWREQ-FP-101] [SWREQ-FP-102]
// Parmak izi tanıtma dialogu — Ayarlar › Parmak İzi › "Parmak izlerini yönet".
// Tüm akış (şifre, onay, okuma, kaydetme, silme) bu dialogda tamamlanır.
//
// Adımlar: şifre doğrulama → KVKK onayı → parmaklar.
// Parmaklar düzeni:
//   [Sol: iki el, parmak durumları]  [Sağ: seçili parmağın okuma paneli]
//   [Alt: gönderilmeyi bekleyenler + Kaydet ve Gönder]
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:pharmed_client/features/auth/auth.dart';
import 'package:pharmed_client/features/fingerprint_test/view/fingerprint_image_view.dart';

import '../notifier/fingerprint_enrollment_notifier.dart';
import 'fingerprint_labels.dart';

class FingerprintEnrollmentDialog extends ConsumerWidget {
  const FingerprintEnrollmentDialog({super.key});

  /// Dışarı dokunarak kapanmaz: kaydedilmemiş okumalar varsa çıkış onayı istenir.
  static Future<void> show(BuildContext context) => showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const FingerprintEnrollmentDialog(),
  );

  /// Adıma göre dialog boyutu; ekrandan taşmaz.
  static Size _sizeFor(EnrollmentStep step, Size screen) {
    final (w, h) = switch (step) {
      EnrollmentStep.password => (520.0, 500.0),
      EnrollmentStep.consent => (720.0, 660.0),
      EnrollmentStep.fingers => (1120.0, 780.0),
    };
    final maxW = screen.width - 48, maxH = screen.height - 48;
    return Size(w < maxW ? w : maxW, h < maxH ? h : maxH);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final n = ref.watch(fingerprintEnrollmentNotifierProvider);
    final size = _sizeFor(n.step, MediaQuery.sizeOf(context));
    final fingersStep = n.step == EnrollmentStep.fingers;

    return PopScope(
      canPop: !n.hasUnsavedWork && !n.isCapturing && !n.isSaving,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (n.isCapturing || n.isSaving) return;
        MessageUtils.showConfirmExitDialog(
          context: context,
          onConfirm: () {
            n.discardAllForExit();
            Navigator.of(context).pop();
          },
        );
      },
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => ref.read(authNotifierProvider.notifier).onUserActivity(),
        child: Dialog(
          insetPadding: const EdgeInsets.all(24),
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(borderRadius: MedRadius.lgAll),
          backgroundColor: fingersStep ? MedColors.bg : MedColors.surface,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            width: size.width,
            height: size.height,
            // Snackbar'lar dialogun içinde görünsün (arkadaki ekranın altında kalmasın).
            child: ScaffoldMessenger(
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: Column(
                  children: [
                    _Header(n: n),
                    Expanded(
                      child: switch (n.step) {
                        EnrollmentStep.password => _PasswordStep(n: n),
                        EnrollmentStep.consent => _ConsentStep(n: n),
                        EnrollmentStep.fingers => _FingersStep(n: n),
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Üst bar
// ─────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.n});

  final FingerprintEnrollmentNotifier n;

  @override
  Widget build(BuildContext context) {
    final info = n.scannerInfo;
    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(horizontal: 22.0),
      decoration: const BoxDecoration(
        color: MedColors.surface,
        border: Border(bottom: BorderSide(color: MedColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              context.l10n.fingerprint_enroll_screenTitle,
              overflow: TextOverflow.ellipsis,
              style: MedTextStyles.titleMd(color: MedColors.text),
            ),
          ),
          const Spacer(),
          if (n.step == EnrollmentStep.fingers) ...[
            if (n.isOpeningScanner)
              const SizedBox(width: 18, height: 18, child: MedLoadingIndicator())
            else if (info != null)
              MedChip(label: info.model, style: MedChipStyle.success, icon: Icons.usb_rounded)
            else ...[
              MedChip(
                label: (n.scannerFailure ?? FingerprintFailureReason.notOpen).label(context),
                style: MedChipStyle.danger,
                mono: false,
              ),
              const SizedBox(width: MedSpacing.md),
              MedButton(
                label: context.l10n.fingerprint_enroll_scannerRetryButton,
                size: MedButtonSize.sm,
                variant: MedButtonVariant.secondary,
                onPressed: n.openScanner,
              ),
            ],
          ],
          IconButton(
            padding: EdgeInsets.zero,
            tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
            // PopScope kaydedilmemiş okuma varsa onay ister.
            onPressed: n.isCapturing || n.isSaving ? null : () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.close_rounded, color: MedColors.text2),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// 1. Şifre
// ─────────────────────────────────────────────────────────────────

class _PasswordStep extends StatefulWidget {
  const _PasswordStep({required this.n});

  final FingerprintEnrollmentNotifier n;

  @override
  State<_PasswordStep> createState() => _PasswordStepState();
}

class _PasswordStepState extends State<_PasswordStep> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await widget.n.verifyPassword(_password.text);
    if (mounted && widget.n.step != EnrollmentStep.password) _password.clear();
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.n;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: SizedBox(
          width: 420,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(PhosphorIcons.lockKey(), size: 40, color: MedColors.blue),
                const SizedBox(height: MedSpacing.lg),
                Text(
                  context.l10n.fingerprint_enroll_passwordTitle,
                  textAlign: TextAlign.center,
                  style: MedTextStyles.titleMd(color: MedColors.text),
                ),
                const SizedBox(height: MedSpacing.sm),
                Text(
                  context.l10n.fingerprint_enroll_passwordDescription(n.user?.fullName ?? ''),
                  textAlign: TextAlign.center,
                  style: MedTextStyles.bodyMd(color: MedColors.text3),
                ),
                const SizedBox(height: MedSpacing.xl2),
                MedTextInputField(
                  controller: _password,
                  label: context.l10n.fingerprint_enroll_passwordLabel,
                  obscureText: true,
                  autoFocus: true,
                  prefixIcon: Icon(PhosphorIcons.lock(), color: MedColors.text3),
                  validator: (v) => (v == null || v.isEmpty) ? context.l10n.fingerprint_enroll_passwordRequired : null,
                  onChanged: (_) {},
                  onFieldSubmitted: (_) => _submit(),
                ),
                if (n.passwordError != null) ...[
                  const SizedBox(height: MedSpacing.md),
                  _Banner.error(n.passwordError!),
                ],
                const SizedBox(height: MedSpacing.xl),
                MedButton(
                  label: context.l10n.fingerprint_enroll_verifyButton,
                  size: MedButtonSize.lg,
                  fullWidth: true,
                  isLoading: n.isVerifying,
                  onPressed: n.isVerifying ? null : _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// 2. KVKK
// ─────────────────────────────────────────────────────────────────

class _ConsentStep extends StatelessWidget {
  const _ConsentStep({required this.n});
  final FingerprintEnrollmentNotifier n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: SizedBox(
          width: 640,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(PhosphorIcons.shieldCheck(), size: 28, color: MedColors.blue),
                  const SizedBox(width: MedSpacing.lg),
                  Expanded(
                    child: Text(
                      context.l10n.fingerprint_enroll_consentTitle,
                      style: MedTextStyles.titleMd(color: MedColors.text),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: MedSpacing.xl),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 320),
                child: Container(
                  padding: MedSpacing.insetXl,
                  decoration: BoxDecoration(
                    color: MedColors.surface2,
                    border: Border.all(color: MedColors.border),
                    borderRadius: MedRadius.mdAll,
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      context.l10n.fingerprint_enroll_consentBody,
                      style: MedTextStyles.bodyMd(color: MedColors.text2).copyWith(height: 1.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: MedSpacing.xl),
              MedCheckboxField(
                value: n.consentAccepted,
                onChanged: n.setConsent,
                label: context.l10n.fingerprint_enroll_consentCheckbox,
              ),
              const SizedBox(height: MedSpacing.xl),
              MedButton(
                label: context.l10n.fingerprint_enroll_continueButton,
                size: MedButtonSize.lg,
                fullWidth: true,
                onPressed: n.consentAccepted ? n.continueAfterConsent : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// 3. Parmaklar
// ─────────────────────────────────────────────────────────────────

class _FingersStep extends StatelessWidget {
  const _FingersStep({required this.n});

  final FingerprintEnrollmentNotifier n;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!FingerprintApi.isAvailable)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: _Banner.info(context.l10n.fingerprint_settings_simulatedNotice),
          ),
        if (n.loadError != null)
          Padding(padding: const EdgeInsets.fromLTRB(24, 16, 24, 0), child: _Banner.error(n.loadError!)),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 5,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Kullanıcının karşısından bakış: sol el solda.
                      Expanded(
                        child: _HandCard(n: n, hand: FingerHand.left),
                      ),
                      const SizedBox(width: MedSpacing.xl),
                      Expanded(
                        child: _HandCard(n: n, hand: FingerHand.right),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: MedSpacing.xl),
                Expanded(flex: 3, child: _CapturePanel(n: n)),
              ],
            ),
          ),
        ),
        _SaveBar(n: n),
      ],
    );
  }
}

class _HandCard extends StatelessWidget {
  const _HandCard({required this.n, required this.hand});

  final FingerprintEnrollmentNotifier n;
  final FingerHand hand;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(PhosphorIcons.hand(), size: 20, color: MedColors.text2),
              const SizedBox(width: MedSpacing.md),
              Text(
                (hand == FingerHand.left
                        ? context.l10n.fingerprint_enroll_leftHand
                        : context.l10n.fingerprint_enroll_rightHand)
                    .toUpperCase(),
                style: MedTextStyles.titleSm(color: MedColors.text2).copyWith(letterSpacing: 0.8),
              ),
            ],
          ),
          const SizedBox(height: MedSpacing.lg),
          for (final p in fingersOf(hand)) ...[_FingerTile(n: n, position: p), const SizedBox(height: MedSpacing.md)],
          if (n.isLoadingEnrolled) const LinearProgressIndicator(minHeight: 2),
        ],
      ),
    );
  }
}

enum _TileState { notEnrolled, enrolled, ready, capturing }

class _FingerTile extends StatelessWidget {
  const _FingerTile({required this.n, required this.position});
  final FingerprintEnrollmentNotifier n;
  final FingerPosition position;

  _TileState get _state {
    if (n.isCapturing && n.selected == position) return _TileState.capturing;
    if (n.isDraftComplete(position)) return _TileState.ready;
    if (n.isEnrolled(position)) return _TileState.enrolled;
    return _TileState.notEnrolled;
  }

  @override
  Widget build(BuildContext context) {
    final state = _state;
    final selected = n.selected == position;

    final (statusLabel, statusStyle, icon, iconColor) = switch (state) {
      _TileState.ready => (
        context.l10n.fingerprint_enroll_statusReady,
        MedChipStyle.info,
        Icons.fingerprint,
        MedColors.blue,
      ),
      _TileState.enrolled => (
        context.l10n.fingerprint_enroll_statusEnrolled,
        MedChipStyle.success,
        Icons.check_circle_rounded,
        MedColors.green,
      ),
      _TileState.capturing => (
        context.l10n.fingerprint_enroll_sampleProgress(
          n.samplesOf(position).length + 1,
          FingerprintEnrollmentRules.samplesPerFinger,
        ),
        MedChipStyle.info,
        Icons.fingerprint,
        MedColors.blue,
      ),
      _TileState.notEnrolled => (
        context.l10n.fingerprint_enroll_statusNotEnrolled,
        MedChipStyle.neutral,
        Icons.fingerprint,
        MedColors.text4,
      ),
    };

    return GestureDetector(
      onTap: () => n.select(position),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        constraints: const BoxConstraints(minHeight: 56),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? MedColors.blueLight : MedColors.surface,
          border: Border.all(color: selected ? MedColors.blue : MedColors.border, width: selected ? 2 : 1),
          borderRadius: MedRadius.mdAll,
        ),
        child: Row(
          children: [
            Icon(icon, size: 24, color: iconColor),
            const SizedBox(width: MedSpacing.lg),
            Expanded(
              child: Text(
                position.shortLabel(context),
                style: MedTextStyles.bodyMd(color: MedColors.text, weight: FontWeight.w600),
              ),
            ),
            MedChip(label: statusLabel, style: statusStyle, size: MedChipSize.sm, mono: false),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Okuma paneli
// ─────────────────────────────────────────────────────────────────

class _CapturePanel extends StatelessWidget {
  const _CapturePanel({required this.n});
  final FingerprintEnrollmentNotifier n;

  @override
  Widget build(BuildContext context) {
    final position = n.selected;
    if (position == null) {
      return _Panel(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.touch_app_outlined, size: 56, color: MedColors.text4),
              const SizedBox(height: MedSpacing.lg),
              Text(
                context.l10n.fingerprint_enroll_selectFingerHint,
                textAlign: TextAlign.center,
                style: MedTextStyles.bodyMd(color: MedColors.text3),
              ),
            ],
          ),
        ),
      );
    }

    final samples = n.samplesOf(position);
    final total = FingerprintEnrollmentRules.samplesPerFinger;
    final enrolledInfo = n.enrolled[position];

    final promptText = switch (n.prompt) {
      EnrollmentPrompt.placeFinger => context.l10n.fingerprint_enroll_placeFinger,
      EnrollmentPrompt.liftFinger => context.l10n.fingerprint_enroll_liftFinger,
      EnrollmentPrompt.none when n.isDraftComplete(position) => context.l10n.fingerprint_enroll_fingerReady,
      EnrollmentPrompt.none => null,
    };

    return _Panel(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(position.label(context), style: MedTextStyles.titleMd(color: MedColors.text)),
          if (enrolledInfo?.enrolledAt != null) ...[
            const SizedBox(height: 2),
            Text(
              context.l10n.fingerprint_enroll_enrolledAt(
                DateFormat('dd.MM.yyyy HH:mm').format(enrolledInfo!.enrolledAt!),
              ),
              style: MedTextStyles.bodySm(color: MedColors.text3),
            ),
          ],
          const SizedBox(height: MedSpacing.lg),

          // Okuma noktaları
          Row(
            children: [
              for (var i = 0; i < total; i++) ...[
                Expanded(
                  child: _SampleDot(
                    index: i,
                    sample: i < samples.length ? samples[i] : null,
                    active: n.isCapturing && i == samples.length,
                  ),
                ),
                if (i < total - 1) const SizedBox(width: MedSpacing.md),
              ],
            ],
          ),
          const SizedBox(height: MedSpacing.lg),

          Expanded(
            child: FingerprintImageView(
              image: n.lastImage,
              placeholder: promptText ?? context.l10n.fingerprint_enroll_startButton,
            ),
          ),
          const SizedBox(height: MedSpacing.lg),

          if (promptText != null)
            Text(
              promptText,
              textAlign: TextAlign.center,
              style: MedTextStyles.titleMd(color: n.isCapturing ? MedColors.blue : MedColors.green),
            ),
          if (n.lastFailure != null) ...[
            const SizedBox(height: MedSpacing.md),
            _Banner.error(
              n.lastFailure == FingerprintFailureReason.lowQuality && n.lastQuality != null
                  ? '${n.lastFailure!.label(context)} · ${context.l10n.fingerprint_enroll_qualityLabel(n.lastQuality!)}'
                  : n.lastFailure!.label(context),
            ),
          ],
          const SizedBox(height: MedSpacing.lg),
          _CaptureActions(n: n, position: position),
        ],
      ),
    );
  }
}

class _SampleDot extends StatelessWidget {
  const _SampleDot({required this.index, required this.sample, required this.active});
  final int index;
  final FingerprintSample? sample;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final done = sample != null;
    return Container(
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: done ? MedColors.greenLight : (active ? MedColors.blueLight : MedColors.surface2),
        border: Border.all(color: done ? MedColors.green : (active ? MedColors.blue : MedColors.border)),
        borderRadius: MedRadius.mdAll,
      ),
      child: done
          ? Text(
              context.l10n.fingerprint_enroll_qualityLabel(sample!.quality),
              style: MedTextStyles.monoSm(color: MedColors.green, weight: FontWeight.w600),
            )
          : Text('${index + 1}', style: MedTextStyles.titleSm(color: active ? MedColors.blue : MedColors.text4)),
    );
  }
}

class _CaptureActions extends StatelessWidget {
  const _CaptureActions({required this.n, required this.position});
  final FingerprintEnrollmentNotifier n;
  final FingerPosition position;

  Future<void> _delete(BuildContext context) async {
    MessageUtils.showConfirmDeleteDialog(
      context: context,
      itemName: position.label(context),
      onConfirm: () async {
        final error = await n.deleteEnrolled(position);
        if (!context.mounted) return;
        if (error != null) MessageUtils.showErrorSnackbar(context, error);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scannerReady = n.scannerInfo != null;

    if (n.isCapturing) {
      return MedButton(
        label: context.l10n.fingerprint_enroll_cancelButton,
        size: MedButtonSize.lg,
        variant: MedButtonVariant.ghost,
        fullWidth: true,
        onPressed: n.cancelCapture,
      );
    }

    final hasDraft = n.isDraftComplete(position);
    final enrolled = n.isEnrolled(position);
    final busy = n.isSaving || n.isDeleting;

    return Row(
      children: [
        Expanded(
          child: MedButton(
            label: hasDraft || enrolled
                ? context.l10n.fingerprint_enroll_retakeButton
                : context.l10n.fingerprint_enroll_startButton,
            size: MedButtonSize.lg,
            fullWidth: true,
            prefixIcon: const Icon(Icons.fingerprint),
            onPressed: scannerReady && !busy ? n.startCapture : null,
          ),
        ),
        if (hasDraft) ...[
          const SizedBox(width: MedSpacing.md),
          MedButton(
            label: context.l10n.fingerprint_enroll_discardDraftButton,
            size: MedButtonSize.lg,
            variant: MedButtonVariant.ghost,
            onPressed: busy ? null : () => n.discardDraft(position),
          ),
        ] else if (enrolled) ...[
          const SizedBox(width: MedSpacing.md),
          MedButton(
            label: context.l10n.fingerprint_enroll_deleteButton,
            size: MedButtonSize.lg,
            variant: MedButtonVariant.error,
            isLoading: n.isDeleting,
            onPressed: busy ? null : () => _delete(context),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Alt çubuk
// ─────────────────────────────────────────────────────────────────

class _SaveBar extends StatelessWidget {
  const _SaveBar({required this.n});
  final FingerprintEnrollmentNotifier n;

  Future<void> _save(BuildContext context) async {
    final error = await n.save();
    if (!context.mounted) return;
    if (error == null) {
      MessageUtils.showSuccessSnackbar(context, context.l10n.fingerprint_enroll_saveSuccess);
    } else {
      MessageUtils.showErrorSnackbar(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pending = n.pendingFingers;
    final text = pending.isEmpty
        ? context.l10n.fingerprint_enroll_selectFingerHint
        : context.l10n.fingerprint_enroll_pendingCount(pending.length);
    const color = MedColors.text2;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: const BoxDecoration(
        color: MedColors.surface,
        border: Border(top: BorderSide(color: MedColors.border)),
      ),
      child: Row(
        children: [
          Icon(PhosphorIcons.info(), color: color, size: 20),
          const SizedBox(width: MedSpacing.md),
          Expanded(
            child: Text(
              text,
              style: MedTextStyles.bodyMd(color: color, weight: FontWeight.w600),
            ),
          ),
          if (pending.isNotEmpty) ...[
            Wrap(
              spacing: MedSpacing.sm,
              children: [
                for (final p in pending) MedChip(label: p.label(context), style: MedChipStyle.info, mono: false),
              ],
            ),
            const SizedBox(width: MedSpacing.lg),
          ],
          MedButton(
            label: context.l10n.fingerprint_enroll_saveButton,
            size: MedButtonSize.lg,
            variant: MedButtonVariant.success,
            prefixIcon: const Icon(Icons.cloud_upload_outlined),
            isLoading: n.isSaving,
            onPressed: n.canSave ? () => _save(context) : null,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Yardımcılar
// ─────────────────────────────────────────────────────────────────

class _Panel extends StatelessWidget {
  const _Panel({required this.child, this.padding = const EdgeInsets.all(24)});
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: MedColors.surface,
        border: Border.all(color: MedColors.border),
        borderRadius: MedRadius.lgAll,
        boxShadow: MedShadows.sm,
      ),
      child: child,
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner._(this.text, this.color, this.background, this.icon);

  factory _Banner.error(String text) => _Banner._(text, MedColors.red, MedColors.redLight, Icons.error_outline);
  factory _Banner.info(String text) => _Banner._(text, MedColors.blue, MedColors.blueLight, Icons.info_outline);

  final String text;
  final Color color;
  final Color background;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: MedSpacing.insetLg,
      decoration: BoxDecoration(
        color: background,
        border: Border.all(color: color.withAlpha(60)),
        borderRadius: MedRadius.mdAll,
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: MedSpacing.md),
          Expanded(
            child: Text(
              text,
              style: MedTextStyles.bodySm(color: color, weight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
