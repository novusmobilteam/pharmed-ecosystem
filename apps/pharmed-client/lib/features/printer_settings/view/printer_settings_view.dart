// pharmed-client/lib/features/printer_settings/view/printer_settings_view.dart
//
// [SWREQ-PRN-050] [SWREQ-PRN-080]
// Ayarlar › Yazıcı bölümü: bağlantı türü, port / Windows yazıcısı, baud,
// kaydet, kaldır ve test fişi.
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:pharmed_client/core/hardware/printer/printer.dart';

import '../notifier/printer_settings_notifier.dart';
import '../notifier/printer_settings_state.dart';

class PrinterSettingsView extends ConsumerWidget {
  const PrinterSettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(printerSettingsNotifierProvider);
    final notifier = ref.read(printerSettingsNotifierProvider.notifier);
    final mockDirectory = notifier.mockOutputDirectory;
    final l10n = context.l10n;

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
                child: Icon(PhosphorIcons.printer(), color: MedColors.blue, size: 26),
              ),
              const SizedBox(width: MedSpacing.lg),
              Expanded(child: Text(l10n.printer_settings_title, style: MedTextStyles.titleMd(color: MedColors.text))),
            ],
          ),
          const SizedBox(height: MedSpacing.lg),
          Text(
            l10n.printer_settings_description,
            style: MedTextStyles.bodyMd(color: MedColors.text2).copyWith(height: 1.5),
          ),
          const SizedBox(height: MedSpacing.xl),

          if (mockDirectory != null) ...[
            _Notice(
              icon: PhosphorIcons.info(),
              text: l10n.printer_settings_mockNotice(mockDirectory),
              tone: _NoticeTone.info,
            ),
            const SizedBox(height: MedSpacing.lg),
          ],

          if (state.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else ...[
            if (state.saved == null) ...[
              _Notice(
                icon: PhosphorIcons.warningCircle(),
                text: l10n.printer_settings_notConfiguredNotice,
                tone: _NoticeTone.warning,
              ),
              const SizedBox(height: MedSpacing.lg),
            ],
            _ConnectionForm(state: state, notifier: notifier),
            const SizedBox(height: MedSpacing.xl),
            _Actions(state: state, notifier: notifier),
            if (state.isDirty && state.saved != null) ...[
              const SizedBox(height: MedSpacing.lg),
              Text(l10n.printer_settings_unsavedNotice, style: MedTextStyles.bodySm(color: MedColors.amber)),
            ],
            if (state.feedback != null) ...[
              const SizedBox(height: MedSpacing.lg),
              _FeedbackLine(feedback: state.feedback!),
            ],
          ],
        ],
      ),
    );
  }
}

class _ConnectionForm extends StatelessWidget {
  const _ConnectionForm({required this.state, required this.notifier});

  final PrinterSettingsState state;
  final PrinterSettingsNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isSerial = state.connectionType == PrinterConnectionType.serial;
    final targets = state.targets;

    return Container(
      width: double.infinity,
      padding: MedSpacing.insetXl,
      decoration: BoxDecoration(
        color: MedColors.surface2,
        border: Border.all(color: MedColors.border),
        borderRadius: MedRadius.mdAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.printer_settings_connectionLabel, style: MedTextStyles.bodySm(color: MedColors.text2)),
          const SizedBox(height: MedSpacing.sm),
          MedSegmentedButton(
            selectedIndex: PrinterConnectionType.values.indexOf(state.connectionType),
            labels: [l10n.printer_settings_connectionSerial, l10n.printer_settings_connectionSpooler],
            onChanged: state.isBusy ? (_) {} : (i) => notifier.setConnectionType(PrinterConnectionType.values[i]),
          ),
          const SizedBox(height: MedSpacing.xl),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                // Dropdown seçili değeri yalnızca ilk build'de okur; seçenek ya da
                // seçim dışarıdan değişince yeniden kurulması için anahtar.
                child: MedDropdownInputField<String>(
                  key: ValueKey('${state.connectionType.name}|${targets.join(',')}|${state.target}'),
                  label: isSerial ? l10n.printer_settings_portLabel : l10n.printer_settings_printerLabel,
                  placeholder: l10n.printer_settings_selectPlaceholder,
                  options: targets,
                  initialValue: state.target,
                  enabled: !state.isBusy && targets.isNotEmpty,
                  labelBuilder: (v) => v,
                  onChanged: notifier.setTarget,
                ),
              ),
              const SizedBox(width: MedSpacing.md),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: IconButton(
                  tooltip: l10n.printer_settings_refreshTooltip,
                  onPressed: state.isBusy ? null : notifier.refreshTargets,
                  icon: Icon(PhosphorIcons.arrowClockwise(), color: MedColors.blue),
                ),
              ),
            ],
          ),
          if (targets.isEmpty) ...[
            const SizedBox(height: MedSpacing.sm),
            Text(
              isSerial ? l10n.printer_settings_noPortsWarning : l10n.printer_settings_noPrintersWarning,
              style: MedTextStyles.bodySm(color: MedColors.amber),
            ),
          ],
          if (isSerial) ...[
            const SizedBox(height: MedSpacing.xl),
            MedDropdownInputField<int>(
              key: ValueKey('baud|${state.baudRate}'),
              label: l10n.printer_settings_baudLabel,
              options: PrinterSettingsState.baudRates,
              initialValue: state.baudRate,
              enabled: !state.isBusy,
              labelBuilder: (v) => v?.toString(),
              onChanged: (v) {
                if (v != null) notifier.setBaudRate(v);
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({required this.state, required this.notifier});

  final PrinterSettingsState state;
  final PrinterSettingsNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hasDraft = state.draft != null;

    return Wrap(
      spacing: MedSpacing.md,
      runSpacing: MedSpacing.md,
      children: [
        MedButton(
          label: l10n.printer_settings_saveButton,
          isLoading: state.isSaving,
          onPressed: state.isDirty && !state.isBusy ? notifier.save : null,
        ),
        MedButton(
          label: l10n.printer_settings_testButton,
          variant: MedButtonVariant.secondary,
          prefixIcon: Icon(PhosphorIcons.printer()),
          isLoading: state.isPrinting,
          onPressed: hasDraft && !state.isBusy ? notifier.printTest : null,
        ),
        if (state.saved != null)
          MedButton(
            label: l10n.printer_settings_removeButton,
            variant: MedButtonVariant.ghost,
            prefixIcon: Icon(PhosphorIcons.trash()),
            onPressed: state.isBusy ? null : notifier.remove,
          ),
      ],
    );
  }
}

class _FeedbackLine extends StatelessWidget {
  const _FeedbackLine({required this.feedback});

  final PrinterSettingsFeedback feedback;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = switch (feedback.kind) {
      PrinterSettingsFeedbackKind.saved => l10n.printer_settings_savedMessage,
      PrinterSettingsFeedbackKind.removed => l10n.printer_settings_removedMessage,
      PrinterSettingsFeedbackKind.testSucceeded => l10n.printer_settings_testSuccessMessage,
      PrinterSettingsFeedbackKind.testFailed => (feedback.failure ?? PrinterFailureReason.unexpected).message(context),
    };
    return _Notice(
      icon: feedback.isError ? PhosphorIcons.warningCircle() : PhosphorIcons.checkCircle(),
      text: text,
      tone: feedback.isError ? _NoticeTone.error : _NoticeTone.success,
    );
  }
}

enum _NoticeTone { info, success, warning, error }

class _Notice extends StatelessWidget {
  const _Notice({required this.icon, required this.text, required this.tone});

  final IconData icon;
  final String text;
  final _NoticeTone tone;

  @override
  Widget build(BuildContext context) {
    final (fg, bg, border) = switch (tone) {
      _NoticeTone.info => (MedColors.blue, MedColors.blueLight, MedColors.blueMid),
      _NoticeTone.success => (MedColors.green, MedColors.greenLight, MedColors.green.withAlpha(60)),
      _NoticeTone.warning => (MedColors.amber, MedColors.amberLight, MedColors.amberBorder),
      _NoticeTone.error => (MedColors.red, MedColors.redLight, MedColors.red.withAlpha(60)),
    };
    return Container(
      width: double.infinity,
      padding: MedSpacing.insetLg,
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border),
        borderRadius: MedRadius.mdAll,
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: fg),
          const SizedBox(width: MedSpacing.md),
          Expanded(
            child: Text(text, style: MedTextStyles.bodySm(color: fg, weight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
