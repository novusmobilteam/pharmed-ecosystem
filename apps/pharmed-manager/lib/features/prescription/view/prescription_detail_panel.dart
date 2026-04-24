part of 'prescription_screen.dart';

// [SWREQ-MGR-RX-004] [IEC 62304 §5.5]
// Hastaya ait reçete geçmişini SidePanel içinde listeler.
// Eski PrescriptionListView + CustomDialog yerine geçer.
// Sınıf: Class B

class PrescriptionDetailPanel extends StatefulWidget {
  const PrescriptionDetailPanel({super.key});

  @override
  State<PrescriptionDetailPanel> createState() => _PrescriptionDetailPanelState();
}

class _PrescriptionDetailPanelState extends State<PrescriptionDetailPanel> {
  @override
  void initState() {
    super.initState();
    // Panel açılınca seçili hospitalization'ı detay notifier'a yükle.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final hosp = context.read<PrescriptionNotifier>().selectedHospitalization;
      if (hosp != null) {
        context.read<PrescriptionDetailNotifier>().load(hosp);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final listNotifier = context.watch<PrescriptionNotifier>();
    final detailNotifier = context.watch<PrescriptionDetailNotifier>();

    final hosp = listNotifier.selectedHospitalization;
    final patientName = hosp?.patient?.fullName ?? 'Hasta';

    return SidePanel(
      title: patientName,
      subtitle: 'Reçete Geçmişi',
      onClose: listNotifier.closePanel,
      // Arama SidePanel header'ına entegre
      //headerExtra: SidePanelSearchBar(onChanged: detailNotifier.search),
      child: _buildContent(context, detailNotifier),
    );
  }

  Widget _buildContent(BuildContext context, PrescriptionDetailNotifier notifier) {
    if (notifier.isLoading(notifier.fetchOp) && notifier.groupedPrescriptions.isEmpty) {
      return const Center(
        child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator.adaptive()),
      );
    }

    if (notifier.groupedPrescriptions.isEmpty) {
      return CommonEmptyStates.generic(
        icon: PhosphorIcons.receipt(),
        message: 'Reçete bulunamadı',
        subMessage: 'Hastaya ait reçete kaydı yok.',
      );
    }

    final grouped = notifier.groupedPrescriptions;
    final prescriptionIds = grouped.keys.toList();

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: grouped.length,
      shrinkWrap: true,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final prescriptionId = prescriptionIds[index];
        final items = grouped[prescriptionId] ?? [];

        return RxGroupCard(
          prescriptionId: prescriptionId,
          items: items,
          interactive: true,
          // onRfidTap: (item) async {
          //   await _submit(context, prescriptionId, notifier, items, PrescriptionActionType.approve);
          // },
          onApprove: (items) async {
            await _submit(context, prescriptionId, notifier, items, PrescriptionActionType.approve);
          },
          onCancel: (items) async {
            await _submit(context, prescriptionId, notifier, items, PrescriptionActionType.cancel);
          },
          onReject: (items) async {
            await _submit(context, prescriptionId, notifier, items, PrescriptionActionType.reject);
          },
        );
      },
    );
  }

  Future<void> _submit(
    BuildContext context,
    int prescriptionId,
    PrescriptionDetailNotifier notifier,
    List<PrescriptionItem> items,
    PrescriptionActionType type,
  ) async {
    await notifier.submit(
      type,
      prescriptionId,
      items,
      onLoading: () => showLoading(context),
      onFailed: (message) {
        hideLoading(context);
        MessageUtils.showErrorSnackbar(context, message);
      },
      onSuccess: (message) {
        hideLoading(context);
        MessageUtils.showSuccessSnackbar(context, message);
      },
    );
  }
}
