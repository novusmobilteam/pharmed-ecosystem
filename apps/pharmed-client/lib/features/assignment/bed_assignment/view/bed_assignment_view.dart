// [SWREQ-UI-CAB-006]
// Hasta bazlı atama ekranı — sadece mobil kabin.
//
// Sol panel:  MobileCabinOverviewPanel  — slot listesi
// Orta panel: MobileCabinDetailPanel   — seçili slot grid'i
// Sağ panel:  OperationPanelBase
//               └── PatientAssignmentPanel
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:pharmed_client/features/assignment/bed_assignment/view/bed_assignment_panel.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:provider/provider.dart';

import '../notifier/bed_assignment_notifier.dart';

class BedAssignmentView extends StatelessWidget {
  const BedAssignmentView({super.key, this.data});

  final CabinVisualizerData? data;

  @override
  Widget build(BuildContext context) {
    final data = this.data;
    if (data == null) {
      return const EmptyStateWidget(variant: EmptyStateVariant.cabinData);
    }

    return ChangeNotifierProvider<BedAssignmentNotifier>(
      create: (ctx) => BedAssignmentNotifier(
        getAssignments: ctx.read(),
        createAssignment: ctx.read(),
        deleteAssignment: ctx.read(),
        updateAssignment: ctx.read(),
        getCabin: ctx.read(),
        getStation: ctx.read(),
        getService: ctx.read(),
      )..init(data),
      child: const _BedAssignmentContent(),
    );
  }
}

class _BedAssignmentContent extends StatefulWidget {
  const _BedAssignmentContent();

  @override
  State<_BedAssignmentContent> createState() => _BedAssignmentContentState();
}

class _BedAssignmentContentState extends State<_BedAssignmentContent> {
  bool _wasSaving = false;

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<BedAssignmentNotifier>();

    // Hata/başarı bildirimleri — snackbar tetiklemek için isLoading geçişini
    // izliyoruz (saveOp: true → false geçişinde sonucu kontrol ediyoruz).
    WidgetsBinding.instance.addPostFrameCallback((_) => _handleSaveResult(notifier));

    if (notifier.isLoading(notifier.initOp) && notifier.mobileSlots.isEmpty) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    return CabinOperationScaffold(
      leftPanel: MobileCabinOverviewPanel(
        slots: notifier.slots,
        selectedSlotId: notifier.selectedSlotId,
        mode: CabinOperationMode.assign,
        onSlotTap: notifier.onSlotTap,
      ),
      centerPanel: MobileCabinDrawerPanel(
        mode: CabinOperationMode.assign,
        slot: notifier.selectedSlot,
        selectedCell: notifier.selectedCell,
        onCellTap: notifier.selectedSlot?.workingStatus == null ? notifier.onCellTap : null,
        assignmentByCoord: notifier.assignmentByCoord,
      ),
      rightPanel: OperationPanelBase(
        mode: CabinOperationMode.assign,
        child: BedAssignmentPanel(notifier: notifier),
      ),
    );
  }

  void _handleSaveResult(BedAssignmentNotifier notifier) {
    if (!mounted) return;

    final isSaving = notifier.isLoading(notifier.saveOp);
    if (_wasSaving && !isSaving) {
      // saveOp az önce bitti — sonucu kontrol et.
      if (notifier.isFailed(notifier.saveOp)) {
        MessageUtils.showErrorSnackbar(context, notifier.errorMessage ?? '');
        notifier.dismissError();
      } else if (notifier.showSuccess) {
        final msg = notifier.isCreated
            ? context.l10n.assignment_success_created
            : context.l10n.assignment_success_deleted;
        MessageUtils.showSuccessSnackbar(context, msg);
        notifier.dismissSuccess();
      }
    }
    _wasSaving = isSaving;
  }
}
