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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../widgets/widgets.dart';
import '../notifier/cabin_design_notifier.dart';
import '../notifier/cabin_design_state.dart';

part 'basic_settings_panel.dart';
part 'drawer_detail_panel.dart';
part 'serum_layout_panel.dart';
part 'cabin_design_visual.dart';

class CabinDesignDialog extends ConsumerStatefulWidget {
  const CabinDesignDialog({super.key, required this.cabinId});

  final int cabinId;

  static Future<void> show(BuildContext context, {required int cabinId}) {
    return showDialog<void>(
      context: context,
      builder: (_) => CabinDesignDialog(cabinId: cabinId),
    );
  }

  @override
  ConsumerState<CabinDesignDialog> createState() => _CabinDesignDialogState();
}

class _CabinDesignDialogState extends ConsumerState<CabinDesignDialog> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cabinDesignNotifierProvider.notifier).init(widget.cabinId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cabinDesignNotifierProvider);
    final notifier = ref.read(cabinDesignNotifierProvider.notifier);

    ref.listen(cabinDesignNotifierProvider, (_, next) {
      if (next is CabinDesignError) {
        MessageUtils.showErrorSnackbar(context, next.message);
        notifier.dismissError();
      }
    });

    final ready = switch (state) {
      CabinDesignReady s => s,
      CabinDesignError(previousState: CabinDesignReady s) => s,
      _ => null,
    };

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: MedRadius.lgAll),
      insetPadding: MedSpacing.insetXl * 2,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200, maxHeight: 950),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Header(cabin: ready?.cabin),
            const Divider(height: 1, color: MedColors.border2),
            Expanded(
              child: ready == null
                  ? const Center(child: MedLoadingIndicator())
                  : _Body(ready: ready, notifier: notifier),
            ),
            const Divider(height: 1, color: MedColors.border2),
            Padding(
              padding: MedSpacing.insetXl,
              child: _BottomBar(ready: ready, notifier: notifier),
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
  const _Body({required this.ready, required this.notifier});

  final CabinDesignReady ready;
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
                  groups: ready.groups,
                  selectedSlotId: ready.selectedSlotId,
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
                    if (ready.selectedGroup?.isSerum != true) ...[
                      _BasicSettingsPanel(cabin: ready.cabin),
                      const SizedBox(height: MedSpacing.xl2),
                      const Divider(color: MedColors.border2, height: 1),
                      const SizedBox(height: MedSpacing.xl2),
                    ],
                    switch (ready.selectedGroup) {
                      null => Text(
                        context.l10n.cabinDesign_noSelectionHint,
                        style: MedTextStyles.bodySm(color: MedColors.text4),
                      ),
                      final g when g.isSerum => _SerumManualLayoutPanel(group: g),
                      final g => _DrawerDetailPanel(group: g, ready: ready, notifier: notifier),
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
  const _BottomBar({required this.ready, required this.notifier});

  final CabinDesignReady? ready;
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
          isLoading: ready?.isSaving ?? false,
          onPressed: (ready?.canSave ?? false)
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
