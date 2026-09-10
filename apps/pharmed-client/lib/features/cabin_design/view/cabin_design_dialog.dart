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
import 'package:pharmed_client/features/auth/notifier/auth_notifier.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/enums/tray_size.dart';
import '../../../core/mixins/api_request_mixin.dart';
import '../../../widgets/widgets.dart';
import '../../dashboard/dashboard.dart';
import '../notifier/cabin_design_notifier.dart';

part 'basic_settings_view.dart';
part 'drawer_detail_view.dart';
part 'serum_layout_view.dart';
part 'cabin_list_view.dart';
part 'new_cabin_view.dart';
part 'cabin_settings_view.dart';

class CabinDesignDialog extends ConsumerStatefulWidget {
  const CabinDesignDialog({super.key, required this.stationCabinsContext});

  final StationCabinsContext stationCabinsContext;

  static Future<void> show(BuildContext context, StationCabinsContext stationCabinsContext) {
    return showDialog<void>(
      context: context,
      builder: (_) => CabinDesignDialog(stationCabinsContext: stationCabinsContext),
    );
  }

  @override
  ConsumerState<CabinDesignDialog> createState() => _CabinDesignDialogState();
}

class _CabinDesignDialogState extends ConsumerState<CabinDesignDialog> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();

    final notifier = ref.read(cabinDesignNotifierProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifier.init(widget.stationCabinsContext);
    });

    notifier.setCallbacks(
      key: notifier.saveChangesOp,
      onError: (message) {
        MessageUtils.showErrorSnackbar(context, message ?? context.l10n.emptyState_serverErrorDescription);
      },
    );
    notifier.setCallbacks(
      key: notifier.scanOp,
      onError: (message) {
        MessageUtils.showErrorSnackbar(context, message ?? context.l10n.emptyState_serverErrorDescription);
      },
    );
    notifier.setCallbacks(
      key: notifier.createCabinOp,
      onError: (message) {
        MessageUtils.showErrorSnackbar(context, message ?? context.l10n.emptyState_serverErrorDescription);
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifier.init(widget.stationCabinsContext);
      setState(() => _initialized = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authNotif = ref.read(authNotifierProvider.notifier);
    final notifier = ref.watch(cabinDesignNotifierProvider);

    final isCreating = notifier.mode == CabinDesignMode.create;
    final sidebarCabins = notifier.cabins;
    final selectedCabinId = isCreating || !_initialized ? null : notifier.selectedCabin.id;

    return GestureDetector(
      onTap: authNotif.onUserActivity,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: MedRadius.lgAll),
        insetPadding: MedSpacing.insetXl * 2,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1600, maxHeight: 950),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Header(cabin: !_initialized || isCreating ? null : notifier.selectedCabin),
              const Divider(height: 1, color: MedColors.border2),
              Expanded(
                child: !_initialized
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
                              onAddCabinTap: notifier.toggleDesignMode,
                            ),
                          ),
                          VerticalDivider(width: 1),
                          Expanded(
                            flex: 6,
                            child: isCreating ? _NewCabinPanel(notifier: notifier) : _Body(notifier: notifier),
                          ),
                        ],
                      ),
              ),
              const Divider(height: 1, color: MedColors.border2),
              if (_initialized)
                Padding(
                  padding: MedSpacing.insetXl,
                  child: _BottomBar(notifier: notifier),
                ),
            ],
          ),
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
    final isMaster = notifier.selectedCabin.type == CabinType.master;
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
                  groups: notifier.groups,
                  selectedSlotId: notifier.selectedSlotId,
                  isMaster: isMaster,
                  onSlotTap: (g) {
                    final id = g.slot.id;
                    if (id != null) notifier.selectCabinSlot(id);
                  },
                ),
              ),
            ),
          ),
          VerticalDivider(width: 1),
          Expanded(flex: 5, child: CabinSettingsView(notifier: notifier)),
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
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(context.l10n.common_cancelButton)),
        const SizedBox(width: MedSpacing.sm),
        MedButton(
          label: context.l10n.common_saveButton,
          isLoading: notifier.isSaving,
          onPressed: notifier.canSave ? () => notifier.save() : null,
        ),
      ],
    );
  }
}
