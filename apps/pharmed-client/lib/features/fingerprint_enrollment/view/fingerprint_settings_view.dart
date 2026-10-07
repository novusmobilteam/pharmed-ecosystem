// pharmed-client/lib/features/fingerprint_enrollment/view/fingerprint_settings_view.dart
//
// [SWREQ-FP-100]
// Ayarlar › Parmak İzi bölümü: kayıtlı parmakların özeti + tanıtma ekranına geçiş.
// Tanıtma işlemi alan gerektirdiği için tam ekran ayrı bir sayfada yapılır.
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:pharmed_client/core/providers/fingerprint_providers.dart';
import 'package:pharmed_client/features/auth/auth.dart';

import 'fingerprint_enrollment_screen.dart';
import 'fingerprint_labels.dart';

class FingerprintSettingsView extends ConsumerStatefulWidget {
  const FingerprintSettingsView({super.key});

  @override
  ConsumerState<FingerprintSettingsView> createState() => _FingerprintSettingsViewState();
}

class _FingerprintSettingsViewState extends ConsumerState<FingerprintSettingsView> {
  bool _loading = false;
  String? _error;
  List<EnrolledFinger> _enrolled = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    if (ref.read(authNotifierProvider) is! AuthLoggedIn) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await ref.read(getEnrolledFingersUseCaseProvider).call();
    if (!mounted) return;
    setState(() {
      _loading = false;
      result.when(
        ok: (list) {
          _enrolled = list;
        },
        error: (e) {
          _error = e.userMessage;
        },
      );
    });
  }

  Future<void> _openEnrollment() async {
    await FingerprintEnrollmentDialog.show(context);
    if (mounted) await _load();
  }

  @override
  Widget build(BuildContext context) {
    // Pencere açıkken giriş/çıkış yapılırsa liste güncellensin.
    ref.listen(authNotifierProvider, (prev, next) {
      final prevId = prev is AuthLoggedIn ? prev.user.id : null;
      final nextId = next is AuthLoggedIn ? next.user.id : null;
      if (prevId == nextId) return;
      if (nextId != null) {
        _load();
      } else {
        setState(() => _enrolled = const []);
      }
    });
    final loggedIn = ref.watch(authNotifierProvider) is AuthLoggedIn;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: MedColors.blueLight, borderRadius: MedRadius.mdAll),
                child: const Icon(Icons.fingerprint, color: MedColors.blue, size: 26),
              ),
              const SizedBox(width: MedSpacing.lg),
              Expanded(
                child: Text(
                  context.l10n.fingerprint_settings_title,
                  style: MedTextStyles.titleMd(color: MedColors.text),
                ),
              ),
            ],
          ),
          const SizedBox(height: MedSpacing.lg),
          Text(
            context.l10n.fingerprint_settings_description,
            style: MedTextStyles.bodyMd(color: MedColors.text2).copyWith(height: 1.5),
          ),
          const SizedBox(height: MedSpacing.xl),

          if (!loggedIn)
            _Notice(icon: PhosphorIcons.lock(), text: context.l10n.fingerprint_settings_loginRequired)
          else ...[
            if (!FingerprintApi.isAvailable) ...[
              _Notice(icon: PhosphorIcons.info(), text: context.l10n.fingerprint_settings_simulatedNotice),
              const SizedBox(height: MedSpacing.lg),
            ],
            Container(
              width: double.infinity,
              padding: MedSpacing.insetXl,
              decoration: BoxDecoration(
                color: MedColors.surface2,
                border: Border.all(color: MedColors.border),
                borderRadius: MedRadius.mdAll,
              ),
              child: _loading
                  ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                  : _error != null
                  ? Row(
                      children: [
                        Expanded(
                          child: Text(_error!, style: MedTextStyles.bodySm(color: MedColors.red)),
                        ),
                        MedButton(
                          label: context.l10n.common_retryButton,
                          size: MedButtonSize.sm,
                          variant: MedButtonVariant.ghost,
                          onPressed: _load,
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _enrolled.isEmpty
                              ? context.l10n.fingerprint_settings_noneEnrolled
                              : context.l10n.fingerprint_settings_enrolledCount(_enrolled.length),
                          style: MedTextStyles.bodyMd(color: MedColors.text, weight: FontWeight.w600),
                        ),
                        if (_enrolled.isNotEmpty) ...[
                          const SizedBox(height: MedSpacing.md),
                          Wrap(
                            spacing: MedSpacing.sm,
                            runSpacing: MedSpacing.sm,
                            children: [
                              for (final f in _enrolled)
                                MedChip(
                                  label: f.position.label(context),
                                  icon: Icons.check_rounded,
                                  style: MedChipStyle.success,
                                  mono: false,
                                ),
                            ],
                          ),
                        ],
                      ],
                    ),
            ),
            const SizedBox(height: MedSpacing.xl),
            MedButton(
              label: _enrolled.isEmpty
                  ? context.l10n.fingerprint_settings_enrollButton
                  : context.l10n.fingerprint_settings_manageButton,
              prefixIcon: const Icon(Icons.fingerprint),
              onPressed: _loading ? null : _openEnrollment,
            ),
          ],
        ],
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: MedSpacing.insetLg,
      decoration: BoxDecoration(
        color: MedColors.blueLight,
        border: Border.all(color: MedColors.blueMid),
        borderRadius: MedRadius.mdAll,
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: MedColors.blue),
          const SizedBox(width: MedSpacing.md),
          Expanded(
            child: Text(
              text,
              style: MedTextStyles.bodySm(color: MedColors.blue, weight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
