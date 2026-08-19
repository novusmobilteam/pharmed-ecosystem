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
part 'cabin_list_panel.dart';
part 'new_cabin_panel.dart';
part 'cabin_settings_view.dart';

class CabinDesignDialog extends ConsumerStatefulWidget {
  const CabinDesignDialog({super.key});

  static Future<void> show(BuildContext context, {required int cabinId}) {
    return showDialog<void>(context: context, builder: (_) => CabinDesignDialog());
  }

  @override
  ConsumerState<CabinDesignDialog> createState() => _CabinDesignDialogState();
}

class _CabinDesignDialogState extends ConsumerState<CabinDesignDialog> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cabinDesignNotifierProvider.notifier).init();
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

    final creating = switch (state) {
      CabinDesignCreating s => s,
      CabinDesignError(previousState: CabinDesignCreating s) => s,
      _ => null,
    };

    final sidebarCabins = ready?.stationCabins ?? creating?.stationCabins ?? const <Cabin>[];
    final selectedCabinId = creating != null ? null : ready?.cabin.id;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: MedRadius.lgAll),
      insetPadding: MedSpacing.insetXl * 2,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1600, maxHeight: 950),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Header(cabin: ready?.cabin),
            const Divider(height: 1, color: MedColors.border2),
            Expanded(
              child: ready == null && creating == null
                  ? const Center(child: MedLoadingIndicator())
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 2,
                          child: _CabinListPanel(
                            cabins: sidebarCabins,
                            selectedCabinId: selectedCabinId,
                            onCabinTap: notifier.selectCabin,
                            onAddCabinTap: notifier.startAddCabin,
                          ),
                        ),
                        VerticalDivider(width: 1),
                        Expanded(
                          flex: 6,
                          child: creating != null
                              ? _NewCabinPanel(creating: creating, notifier: notifier)
                              : ready!.isSwitchingCabin
                              ? Center(child: MedLoadingIndicator())
                              : _Body(ready: ready, notifier: notifier),
                        ),
                      ],
                    ),
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
    final isMaster = ready.cabin.type == CabinType.master;
    return Container(
      color: MedColors.surface2,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 7,
            child: Center(
              child: SingleChildScrollView(
                padding: MedSpacing.insetXl * 3,
                child: MasterCabinDeviceVisual(
                  groups: ready.pendingScanGroups ?? ready.groups,
                  selectedSlotId: ready.selectedSlotId,
                  isMaster: isMaster,
                  onSlotTap: (g) {
                    final id = g.slot.id;
                    if (id != null) notifier.selectSlot(id);
                  },
                ),
              ),
            ),
          ),
          VerticalDivider(width: 1),
          Expanded(
            flex: 5,
            child: CabinSettingsView(notifier: notifier, ready: ready),
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({this.ready, required this.notifier});

  final CabinDesignReady? ready;
  final CabinDesignNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(context.l10n.common_cancelButton)),
        const SizedBox(width: MedSpacing.sm),
        MedButton(
          label: context.l10n.common_saveButton,
          isLoading: ready?.isSaving ?? false,
          onPressed: (ready?.canSave ?? false) ? () => notifier.save() : null,
        ),
      ],
    );
  }
}
