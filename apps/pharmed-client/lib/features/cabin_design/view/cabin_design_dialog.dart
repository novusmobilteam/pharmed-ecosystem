// [SWREQ-UI-CABIN-DESIGN-001] [IEC 62304 §5.5]
// Kabin dizaynı ekranı — dialog olarak açılır. Bu turun kapsamı:
//   - Sol: CabinDesignVisual (çekmece seçimi)
//   - Sağ üst: Temel Ayarlar (SALT-OKUNUR — UpdateCabinUseCase henüz
//     bağlanmadı, bkz. dizayn notu)
//   - Sağ alt: seçili çekmeceye göre ÇekmeceDetayı+İadeToggle YA DA
//     serum ise manuel iç dizayn paneli (görsel-only, henüz kaydedilmiyor)
//   - Alt bar: "Cihazı Tara" GÖRÜNÜR ama PASİF (kapsam dışı)
//
// Sınıf: Class B

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../widgets/widgets.dart';
import '../notifier/cabin_design_notifier.dart';

part 'basic_settings_panel.dart';
part 'drawer_detail_panel.dart';
part 'serum_layout_panel.dart';
part 'cabin_design_visual.dart';

class CabinDesignDialog extends StatelessWidget {
  const CabinDesignDialog({super.key, required this.cabinId});

  final int cabinId;

  static Future<void> show(BuildContext context, {required int cabinId}) {
    return showDialog<void>(
      context: context,
      builder: (_) => CabinDesignDialog(cabinId: cabinId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CabinDesignNotifier>(
      create: (ctx) => CabinDesignNotifier(getVisualizerData: ctx.read(), setReturnDrawer: ctx.read())..init(cabinId),
      child: const _CabinDesignDialogContent(),
    );
  }
}

class _CabinDesignDialogContent extends StatefulWidget {
  const _CabinDesignDialogContent();

  @override
  State<_CabinDesignDialogContent> createState() => _CabinDesignDialogContentState();
}

class _CabinDesignDialogContentState extends State<_CabinDesignDialogContent> {
  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<CabinDesignNotifier>();

    // ref.listen'ın eşdeğeri: hata mesajı doluysa post-frame'de göster,
    // sonra temizle. build sırasında showSnackbar çağırmamak için.
    if (notifier.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        MessageUtils.showErrorSnackbar(context, notifier.errorMessage!);
        notifier.dismissError();
      });
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: MedRadius.lgAll),
      insetPadding: MedSpacing.insetXl * 2,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200, maxHeight: 950),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Header(cabin: notifier.cabin),
            const Divider(height: 1, color: MedColors.border2),
            Expanded(
              child: !notifier.isReady ? const Center(child: MedLoadingIndicator()) : _Body(notifier: notifier),
            ),
            const Divider(height: 1, color: MedColors.border2),
            Padding(
              padding: MedSpacing.insetXl,
              child: _BottomBar(notifier: notifier),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.cabin});

  final Cabin? cabin;

  @override
  Widget build(BuildContext context) {
    final subtitleParts = <String>[
      if (cabin?.name != null) cabin!.name!,
      if (cabin?.station?.title != null) cabin!.station!.title,
      if (cabin?.type != null) cabin!.type!.label,
    ];

    return Padding(
      padding: MedSpacing.insetXl,
      child: Row(
        children: [
          MedRectangleIconButton(
            iconData: PhosphorIcons.gridFour(),
            color: MedColors.blue,
            dimWhenDisabled: false,
            iconColor: Colors.white,
          ),
          const SizedBox(width: MedSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.l10n.cabinDesign_dialogTitle, style: MedTextStyles.titleLg()),
                if (subtitleParts.isNotEmpty)
                  Text(subtitleParts.join(' · '), style: MedTextStyles.bodySm(color: MedColors.text3)),
              ],
            ),
          ),
          CloseButton(),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.notifier});

  final CabinDesignNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: MedColors.surface2,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Center(
              child: SingleChildScrollView(
                padding: MedSpacing.insetXl * 2,
                child: CabinDesignVisual(
                  groups: notifier.groups,
                  selectedSlotId: notifier.selectedSlotId,
                  onSlotTap: (g) {
                    final id = g.slot.id;
                    if (id != null) notifier.selectSlot(id);
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 24),
          Container(width: 1, color: MedColors.border2),
          Expanded(
            flex: 5,
            child: Container(
              padding: MedSpacing.insetXl * 2,
              alignment: Alignment.topCenter,
              color: MedColors.surface,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (notifier.selectedGroup?.isSerum != true) ...[
                      _BasicSettingsPanel(cabin: notifier.cabin!),
                      const SizedBox(height: MedSpacing.xl2),
                      const Divider(color: MedColors.border2, height: 1),
                      const SizedBox(height: MedSpacing.xl2),
                    ],
                    switch (notifier.selectedGroup) {
                      null => Text(
                        context.l10n.cabinDesign_noSelectionHint,
                        style: MedTextStyles.bodySm(color: MedColors.text4),
                      ),
                      final g when g.isSerum => _SerumManualLayoutPanel(group: g),
                      final g => _DrawerDetailPanel(group: g, notifier: notifier),
                    },
                    const SizedBox(height: MedSpacing.xl),
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

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.notifier});

  final CabinDesignNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MedButton(
          label: context.l10n.cabinDesign_scanButton,
          prefixIcon: Icon(PhosphorIcons.arrowsClockwise()),
          onPressed: null, // kapsam dışı — bağlı değil
        ),
        const Spacer(),
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(context.l10n.common_cancelButton)),
        const SizedBox(width: MedSpacing.sm),
        MedButton(
          label: context.l10n.cabinDesign_saveButton,
          isLoading: notifier.isSaving,
          onPressed: notifier.canSave
              ? () async {
                  final ok = await notifier.save();
                  if (ok && context.mounted) {
                    MessageUtils.showSuccessSnackbar(context, context.l10n.common_operationSuccessMessage);
                    Navigator.of(context).pop();
                  }
                }
              : null,
        ),
      ],
    );
  }
}
