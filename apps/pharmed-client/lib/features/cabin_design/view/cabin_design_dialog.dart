// [SWREQ-UI-CABIN-DESIGN-001] [IEC 62304 §5.5]
// Kabin dizaynı ekranı — dialog olarak açılır.
//   - Sol: istasyon kabin listesi (+ ileride kameralar)
//   - Sağ: seçime göre kabin görseli + ayarlar YA DA yeni kabin formu
//   - Alt bar: Kaydet (seçili kabinin bekleyen değişiklikleri)
//
// Sınıf: Class B

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/features/auth/notifier/auth_notifier.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/enums/tray_size.dart';
import '../../../core/providers/operation_recording_providers.dart';
import '../../../widgets/widgets.dart';
import '../notifier/cabin_design_models.dart';
import '../notifier/cabin_design_notifier.dart';
import '../notifier/camera_form_notifier.dart';

part 'basic_settings_panel.dart';
part 'drawer_detail_panel.dart';
part 'serum_layout_panel.dart';
part 'cabin_list_panel.dart';
part 'new_cabin_panel.dart';
part 'cabin_settings_view.dart';
part 'camera_form_panel.dart';
part 'camera_test_dialog.dart';

class CabinDesignDialog extends ConsumerStatefulWidget {
  const CabinDesignDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(context: context, builder: (_) => const CabinDesignDialog());
  }

  @override
  ConsumerState<CabinDesignDialog> createState() => _CabinDesignDialogState();
}

class _CabinDesignDialogState extends ConsumerState<CabinDesignDialog> {
  @override
  void initState() {
    super.initState();
    final notifier = ref.read(cabinDesignNotifierProvider);

    // Yükleme / kabin değiştirme hataları snackbar ile; kaydet/tara/durum
    // hataları panelde satır içi gösterilir (notifier.inlineError).
    void showError(String? message) {
      if (mounted && message != null) MessageUtils.showErrorSnackbar(context, message);
    }

    notifier.setCallbacks(key: CabinDesignNotifier.loadOp, onError: showError);
    notifier.setCallbacks(key: CabinDesignNotifier.switchCabinOp, onError: showError);

    WidgetsBinding.instance.addPostFrameCallback((_) => notifier.init());
  }

  @override
  Widget build(BuildContext context) {
    final authNotif = ref.read(authNotifierProvider.notifier);
    final notifier = ref.watch(cabinDesignNotifierProvider);

    final selection = notifier.selection;

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
              _Header(cabin: notifier.selectedCabin),
              const Divider(height: 1, color: MedColors.border2),
              Expanded(
                child: switch ((notifier.hasStation, notifier.isLoading(CabinDesignNotifier.loadOp))) {
                  (_, true) => const Center(child: MedLoadingIndicator()),
                  (false, false) => _LoadFailedView(message: notifier.message(CabinDesignNotifier.loadOp)),
                  (true, false) => Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(flex: 2, child: _StationSidebar(notifier: notifier)),
                      const VerticalDivider(width: 1),
                      Expanded(
                        flex: 6,
                        child: switch (selection) {
                          NewCabinDraft draft => _NewCabinPanel(draft: draft, notifier: notifier),
                          // Key: başka kameraya/yeni kameraya geçişte form sıfırdan kurulsun.
                          CameraSelection camera => _CameraFormPanel(
                            key: ValueKey('camera-${camera.cameraId ?? 'new'}'),
                            selection: camera,
                            design: notifier,
                          ),
                          SelectedCabin() when notifier.isSwitchingCabin || notifier.cabin == null => const Center(
                            child: MedLoadingIndicator(),
                          ),
                          SelectedCabin() => _Body(notifier: notifier),
                          null => const Center(child: MedLoadingIndicator()),
                        },
                      ),
                    ],
                  ),
                },
              ),
              const Divider(height: 1, color: MedColors.border2),
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
          const CloseButton(),
        ],
      ),
    );
  }
}

/// İstasyon/kabin hiç yüklenemediyse — eskiden sonsuz spinner'da kalıyordu.
class _LoadFailedView extends StatelessWidget {
  const _LoadFailedView({required this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline_rounded, size: 18, color: MedColors.red),
          const SizedBox(width: MedSpacing.sm),
          Text(message ?? '—', style: MedTextStyles.bodyMd(color: MedColors.text2)),
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
            flex: 7,
            child: Center(
              child: SingleChildScrollView(
                padding: MedSpacing.insetXl * 3,
                child: MasterCabinDeviceVisual(
                  groups: notifier.displayedGroups,
                  selectedSlotId: notifier.selectedSlotId,
                  isMaster: notifier.isMaster,
                  onSlotTap: (g) {
                    final id = g.slot.id;
                    if (id != null) notifier.selectSlot(id);
                  },
                ),
              ),
            ),
          ),
          const VerticalDivider(width: 1),
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
          onPressed: notifier.canSave ? notifier.save : null,
        ),
      ],
    );
  }
}
