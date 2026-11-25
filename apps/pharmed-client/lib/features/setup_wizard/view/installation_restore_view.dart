// [SWREQ-SETUP-RESTORE-005] [IEC 62304 §5.5]
// Kurulum sihirbazından önce gösterilen ekranlar: kayıtlı kurulum aranıyor,
// bulundu (geri yükle / yeni kurulum), kontrol edilemedi.
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../notifier/setup_wizard_notifier.dart';

// MARK: Aranıyor
class InstallationCheckingView extends StatelessWidget {
  const InstallationCheckingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MedLoadingIndicator(),
          const SizedBox(height: MedSpacing.xl),
          Text(
            context.l10n.wizard_restore_checkingMessage,
            style: MedTextStyles.bodyMd(color: MedColors.text3).copyWith(fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// MARK: Bulundu
class InstallationFoundView extends ConsumerWidget {
  const InstallationFoundView({super.key, required this.installation, required this.isRestoring});

  final StationInstallation installation;
  final bool isRestoring;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(setupWizardNotifierProvider.notifier);
    final primary = installation.primaryCabin;
    final warnings = [
      if (primary != null && !primary.hasDesign) context.l10n.wizard_restore_noDesignWarning,
      if (primary?.cabin.status?.isActive == false) context.l10n.wizard_restore_passiveWarning,
    ];

    return _RestoreCard(
      maxWidth: 560,
      icon: Icons.inventory_2_rounded,
      iconColor: MedColors.blue,
      iconBackground: MedColors.blueLight,
      title: context.l10n.wizard_restore_foundTitle,
      children: [
        Text(
          context.l10n.wizard_restore_foundDescription(installation.station?.name ?? '-', installation.cabins.length),
          style: MedTextStyles.bodyMd(color: MedColors.text3).copyWith(fontSize: 14),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: MedSpacing.xl2),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: MedColors.border),
            borderRadius: MedRadius.lgAll,
          ),
          child: Column(
            children: [
              for (final (index, item) in installation.cabins.indexed) ...[
                if (index > 0) const Divider(height: 1, color: MedColors.border2),
                _CabinRow(item: item),
              ],
            ],
          ),
        ),
        for (final warning in warnings) ...[
          const SizedBox(height: MedSpacing.lg),
          _WarningBanner(message: warning),
        ],
        const SizedBox(height: MedSpacing.xl3),
        MedButton(
          label: context.l10n.wizard_restore_continueButton,
          size: MedButtonSize.lg,
          fullWidth: true,
          isLoading: isRestoring,
          prefixIcon: const Icon(Icons.restore_rounded, size: 18),
          onPressed: isRestoring ? null : notifier.restoreInstallation,
        ),
        const SizedBox(height: MedSpacing.md),
        MedButton(
          label: context.l10n.wizard_restore_newSetupButton,
          variant: MedButtonVariant.ghost,
          fullWidth: true,
          onPressed: isRestoring ? null : notifier.startNewSetup,
        ),
        const SizedBox(height: MedSpacing.xs),
        Text(
          context.l10n.wizard_restore_newSetupHint,
          style: MedTextStyles.bodySm(color: MedColors.text4).copyWith(fontSize: 12),
          textAlign: TextAlign.center,
        ),
        if (notifier.macAddress != null) ...[
          const SizedBox(height: MedSpacing.lg),
          Text(notifier.macAddress!, style: MedTextStyles.monoSm(color: MedColors.text4)),
        ],
      ],
    );
  }
}

class _CabinRow extends StatelessWidget {
  const _CabinRow({required this.item});

  final InstalledCabin item;

  @override
  Widget build(BuildContext context) {
    final cabin = item.cabin;
    final isPassive = cabin.status?.isActive == false;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: MedSpacing.xl, vertical: MedSpacing.lg),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: MedColors.surface2, borderRadius: MedRadius.mdAll),
            child: Text(
              (cabin.no ?? '-').toUpperCase(),
              style: MedTextStyles.monoSm(color: MedColors.text2, weight: FontWeight.w700).copyWith(fontSize: 13),
            ),
          ),
          const SizedBox(width: MedSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cabin.name ?? '-', style: MedTextStyles.bodyMd(color: MedColors.text, weight: FontWeight.w600).copyWith(fontSize: 14)),
                if (cabin.type != null)
                  Text(cabin.type!.label, style: MedTextStyles.bodySm(color: MedColors.text3).copyWith(fontSize: 12)),
              ],
            ),
          ),
          if (item.isPrimary) _Badge(label: context.l10n.wizard_restore_primaryBadge, color: MedColors.blue, background: MedColors.blueLight),
          if (isPassive) ...[
            const SizedBox(width: MedSpacing.sm),
            _Badge(label: context.l10n.wizard_restore_passiveBadge, color: MedColors.text3, background: MedColors.surface3),
          ],
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color, required this.background});

  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: MedSpacing.md, vertical: MedSpacing.xs),
      decoration: BoxDecoration(color: background, borderRadius: MedRadius.smAll),
      child: Text(label, style: MedTextStyles.bodySm(color: color, weight: FontWeight.w600).copyWith(fontSize: 12)),
    );
  }
}

class _WarningBanner extends StatelessWidget {
  const _WarningBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: MedSpacing.insetMd,
      decoration: BoxDecoration(
        color: MedColors.amberLight,
        border: Border.all(color: MedColors.amberBorder),
        borderRadius: MedRadius.mdAll,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, size: 18, color: MedColors.amberStrong),
          const SizedBox(width: MedSpacing.md),
          Expanded(child: Text(message, style: MedTextStyles.bodySm(color: MedColors.text2).copyWith(fontSize: 12))),
        ],
      ),
    );
  }
}

// MARK: Kontrol edilemedi
class InstallationCheckErrorView extends ConsumerWidget {
  const InstallationCheckErrorView({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(setupWizardNotifierProvider.notifier);

    return _RestoreCard(
      maxWidth: 460,
      icon: Icons.cloud_off_rounded,
      iconColor: MedColors.red,
      iconBackground: MedColors.redLight,
      title: context.l10n.wizard_restore_checkErrorTitle,
      children: [
        Text(message, style: MedTextStyles.bodyMd(color: MedColors.text3).copyWith(fontSize: 14), textAlign: TextAlign.center),
        const SizedBox(height: MedSpacing.xl3),
        MedButton(
          label: context.l10n.common_retryButton,
          size: MedButtonSize.lg,
          fullWidth: true,
          prefixIcon: const Icon(Icons.refresh_rounded, size: 18),
          onPressed: notifier.checkInstallation,
        ),
        const SizedBox(height: MedSpacing.md),
        MedButton(
          label: context.l10n.wizard_restore_proceedToSetupButton,
          variant: MedButtonVariant.ghost,
          fullWidth: true,
          onPressed: notifier.startNewSetup,
        ),
        const SizedBox(height: MedSpacing.xs),
        Text(
          context.l10n.wizard_restore_newSetupHint,
          style: MedTextStyles.bodySm(color: MedColors.text4).copyWith(fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// MARK: Ortak kart
class _RestoreCard extends StatelessWidget {
  const _RestoreCard({
    required this.maxWidth,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.children,
  });

  final double maxWidth;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(MedSpacing.xl4),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Container(
            padding: const EdgeInsets.all(36),
            decoration: BoxDecoration(
              color: MedColors.surface,
              border: Border.all(color: MedColors.border),
              borderRadius: MedRadius.xlAll,
              boxShadow: MedShadows.md,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(color: iconBackground, borderRadius: BorderRadius.circular(18)),
                  child: Icon(icon, size: 32, color: iconColor),
                ),
                const SizedBox(height: MedSpacing.xl),
                Text(title, style: MedTextStyles.titleLg(color: MedColors.text).copyWith(fontSize: 20, fontWeight: FontWeight.w800), textAlign: TextAlign.center),
                const SizedBox(height: MedSpacing.md),
                ...children,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
