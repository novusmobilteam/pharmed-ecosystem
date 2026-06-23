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
      final range = context.read<PrescriptionNotifier>().dateRange;
      print('Date Range: $range');
      if (hosp != null) {
        context.read<PrescriptionDetailNotifier>().load(hosp, range: range);
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
      disableScroll: true,
      subtitle: 'Reçete Geçmişi',
      onClose: listNotifier.closePanel,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          spacing: 12.0,
          children: [
            Row(
              spacing: 12.0,
              children: [
                Expanded(
                  child: MedDateInputField(
                    key: ValueKey(detailNotifier.startDate),
                    label: 'Başlangıç Tarihi',
                    initialValue: detailNotifier.startDate,
                    onDateSelected: detailNotifier.selectStartDate,
                  ),
                ),
                Expanded(
                  child: MedDateInputField(
                    key: ValueKey(detailNotifier.endDate),
                    label: 'Bitiş Tarihi',
                    initialValue: detailNotifier.endDate,
                    onDateSelected: detailNotifier.selectEndDate,
                  ),
                ),
              ],
            ),
            MedDropdownInputField(
              key: ValueKey(detailNotifier.type),
              initialValue: detailNotifier.type,
              options: [null, ...PrescriptionMovementType.values],
              onChanged: (v) {
                debugPrint('dropdown changed: $v');
                detailNotifier.selectPrescriptionType(v);
              },
              labelBuilder: (type) => type?.label ?? 'Tümü',
              label: 'Durum',
            ),
            _buildContent(context, detailNotifier, listNotifier),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, PrescriptionDetailNotifier notifier, PrescriptionNotifier listNotifier) {
    if (notifier.isLoading(notifier.fetchOp) && notifier.groupedPrescriptions.isEmpty) {
      return const Center(
        child: Padding(padding: EdgeInsets.all(40), child: MedLoadingIndicator()),
      );
    }

    if (notifier.groupedPrescriptions.isEmpty) {
      return EmptyStateWidget(variant: EmptyStateVariant.noResults);
    }

    final grouped = notifier.groupedPrescriptions;
    final prescriptionIds = grouped.keys.toList();
    final currentUser = context.watch<AuthNotifier>().currentUser;
    final permissions = PrescriptionActionPermissions.fromRole(currentUser?.roleType);

    return Expanded(
      child: ListView.separated(
        itemCount: grouped.length,
        shrinkWrap: false,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final prescriptionId = prescriptionIds[index];
          final items = grouped[prescriptionId] ?? [];

          return RxGroupCard(
            prescriptionId: prescriptionId,
            items: items,
            permissions: permissions,
            canOverrideRfidLock: currentUser?.roleType?.canOverrideRfidLock ?? false,
            onRfidTap: (item) async {
              await notifier.assignRfidTag(
                item,
                onFailed: (message) => MessageUtils.showErrorSnackbar(context, message),
              );
            },
            onRfidDelete: (item) async {
              await notifier.deleteRfidTag(item);
            },
            onApprove: (items) async {
              await notifier.checkAndApprove(
                prescriptionId,
                items,
                onCheckWarning: (message, onContinue) {
                  MessageUtils.showConfirmDialog(
                    context: context,
                    action: ConfirmAction.custom,
                    customTitle: 'Kontrol Uyarısı',
                    customMessage: message,
                    confirmButtonText: 'Devam Et',
                    cancelButtonText: 'Vazgeç',
                    iconData: PhosphorIcons.warning(PhosphorIconsStyle.fill),
                    color: MedColors.amber,
                    onConfirm: onContinue,
                  );
                },
                onSuccess: (message) {
                  MessageUtils.showSuccessSnackbar(context, message);
                },
                onFailed: (message) {
                  MessageUtils.showErrorSnackbar(context, message);
                },
              );
            },
            onCancel: (items) async {
              await _submit(context, prescriptionId, notifier, items, PrescriptionActionType.cancel);
            },
            onReject: (items) async {
              await _submit(context, prescriptionId, notifier, items, PrescriptionActionType.reject);
            },
          );
        },
      ),
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
