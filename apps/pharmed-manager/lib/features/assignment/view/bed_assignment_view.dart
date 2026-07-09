part of 'assignment_screen.dart';

class BedAssignmentView extends StatelessWidget {
  const BedAssignmentView({super.key, required this.cabin, required this.data, required this.station});

  final Cabin cabin;
  final Station station;
  final CabinVisualizerData data;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => BedAssignmentNotifier(
        getBedAssignmentsUseCase: context.read(),
        createBedAssignmentUseCase: context.read(),
        updateBedAssignmentUseCase: context.read(),
        deleteBedAssignmentUseCase: context.read(),
        getServiceUseCase: context.read(),
      )..init(visualizer: data, cabin: cabin, station: station),
      child: Consumer<BedAssignmentNotifier>(
        builder: (context, notifier, _) {
          return CabinOperationScaffold(
            padding: EdgeInsets.zero,
            leftPanel: MobileCabinOverviewPanel(
              slots: notifier.slots,
              selectedSlotId: notifier.selectedSlot?.slotId,
              mode: CabinOperationMode.assign,
              onSlotTap: notifier.selectSlot,
            ),
            centerPanel: MobileCabinDrawerPanel(
              mode: CabinOperationMode.assign,
              slot: notifier.selectedSlot,
              selectedCell: notifier.selectedCell,
              onCellTap: notifier.selectCell,
              assignmentByCoord: notifier.assignmentByCoord,
            ),
            rightPanel: OperationPanelBase(
              mode: CabinOperationMode.assign,
              child: BedAssignmentPanel(
                onServiceSelected: notifier.selectService,
                onRoomSelected: notifier.selectRoom,
                onBedSelected: notifier.selectBed,
                onSave: () => notifier.saveAssignment(
                  onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
                  onSuccess: (msg) =>
                      MessageUtils.showSuccessSnackbar(context, msg ?? context.l10n.common_operationSuccessMessage),
                ),
                onDelete: () => notifier.deleteAssignment(
                  onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
                  onSuccess: (msg) =>
                      MessageUtils.showSuccessSnackbar(context, msg ?? context.l10n.common_operationSuccessMessage),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class BedAssignmentPanel extends StatelessWidget {
  const BedAssignmentPanel({
    super.key,

    required this.onServiceSelected,
    required this.onRoomSelected,
    required this.onBedSelected,
    required this.onSave,
    required this.onDelete,
  });

  final ValueChanged<HospitalService?> onServiceSelected;
  final ValueChanged<Room?> onRoomSelected;
  final ValueChanged<Bed?> onBedSelected;
  final VoidCallback onSave;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Consumer<BedAssignmentNotifier>(
      builder: (context, notifier, _) {
        if (notifier.selectedCell != null) {
          return _CellSelectedContent(
            onServiceSelected: onServiceSelected,
            onRoomSelected: onRoomSelected,
            onBedSelected: onBedSelected,
            onSave: onSave,
            onDelete: onDelete,
          );
        } else {
          return _PlaceholderContent();
        }
      },
    );
  }
}

class _PlaceholderContent extends StatelessWidget {
  const _PlaceholderContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: MedColors.surface3,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: MedColors.border, width: 1.5),
          ),
          child: Icon(PhosphorIcons.user(), size: 22, color: MedColors.text4),
        ),
        const SizedBox(height: 12),
        Text(
          context.l10n.common_selectCellTitle,
          style: TextStyle(
            fontFamily: MedFonts.sans,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: MedColors.text3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          context.l10n.assignment_assignBedPlaceholder,
          style: MedTextStyles.bodySm(color: MedColors.text4),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _CellSelectedContent extends StatelessWidget {
  const _CellSelectedContent({
    required this.onServiceSelected,
    required this.onRoomSelected,
    required this.onBedSelected,
    required this.onSave,
    required this.onDelete,
  });

  final ValueChanged<HospitalService?> onServiceSelected;
  final ValueChanged<Room?> onRoomSelected;
  final ValueChanged<Bed?> onBedSelected;
  final VoidCallback onSave;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Consumer<BedAssignmentNotifier>(
      builder: (context, notifier, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (notifier.currentAssignment == null)
              _BedSelector(
                onServiceSelected: onServiceSelected,
                onRoomSelected: onRoomSelected,
                onBedSelected: onBedSelected,
              ),
            if (notifier.bed != null) _BedCard(),
            const SizedBox(height: 20),
            _ActionButtons(
              currentAssignment: notifier.currentAssignment,
              selectedBed: notifier.bed,
              onSave: onSave,
              onDelete: onDelete,
            ),
          ],
        );
      },
    );
  }
}

class _BedSelector extends StatelessWidget {
  const _BedSelector({required this.onServiceSelected, required this.onRoomSelected, required this.onBedSelected});

  final ValueChanged<HospitalService?> onServiceSelected;
  final ValueChanged<Room?> onRoomSelected;
  final ValueChanged<Bed?> onBedSelected;

  @override
  Widget build(BuildContext context) {
    return Consumer<BedAssignmentNotifier>(
      builder: (context, notifier, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Servis dropdown
            MedDropdownInputField<HospitalService>(
              label: context.l10n.assignment_serviceSelectorHint,
              initialValue: notifier.service,
              options: notifier.services,
              labelBuilder: (s) => s?.name ?? '—',
              onChanged: (service) => onServiceSelected(service),
            ),
            const SizedBox(height: 6),

            // Oda dropdown — servis seçilince aktif
            MedDropdownInputField<Room>(
              label: context.l10n.assignment_roomSelectorHint,
              initialValue: notifier.room,
              options: notifier.rooms,
              labelBuilder: (r) => r?.name ?? '—',
              enabled: notifier.service != null && notifier.rooms.isNotEmpty,
              onChanged: (room) => onRoomSelected(room),
            ),
            const SizedBox(height: 6),

            // Yatak dropdown — oda seçilince aktif
            MedDropdownInputField<Bed>(
              label: context.l10n.assignment_bedSelectorHint,
              initialValue: notifier.bed,
              options: notifier.beds,
              labelBuilder: (b) => b?.name ?? '—',
              enabled: notifier.room != null && notifier.beds.isNotEmpty,
              onChanged: (bed) => onBedSelected(bed),
            ),

            const SizedBox(height: 12),
          ],
        );
      },
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.currentAssignment,
    required this.selectedBed,
    required this.onSave,
    required this.onDelete,
  });

  final BedAssignment? currentAssignment;
  final Bed? selectedBed;
  final VoidCallback onSave;
  final VoidCallback onDelete;

  bool get _isAssigned => currentAssignment != null;
  bool get _isChanged => _isAssigned && selectedBed != null && selectedBed!.id != currentAssignment!.bedId;
  bool get _canSave => !_isAssigned && selectedBed != null;

  @override
  Widget build(BuildContext context) {
    return Consumer<BedAssignmentNotifier>(
      builder: (context, notifier, _) {
        if (_isAssigned && !_isChanged) {
          return MedButton(
            label: context.l10n.assignment_removeAssignmentButton,
            onPressed: onDelete,
            variant: MedButtonVariant.danger,
            isLoading: notifier.isLoading(notifier.deleteOp),
          );
        }

        if (_isChanged) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MedButton(
                label: context.l10n.assignment_changeAssignmentButton,
                variant: MedButtonVariant.primary,
                onPressed: onSave,
                isLoading: notifier.isLoading(notifier.submitOp),
              ),
              const SizedBox(height: 8),
              MedButton(
                label: context.l10n.assignment_removeAssignmentButton,
                variant: MedButtonVariant.danger,
                onPressed: onDelete,
                isLoading: notifier.isLoading(notifier.deleteOp),
              ),
            ],
          );
        }

        return MedButton(
          label: context.l10n.assignment_saveAssignmentButton,
          variant: MedButtonVariant.success,
          onPressed: _canSave ? onSave : null,
          isLoading: notifier.isLoading(notifier.submitOp),
        );
      },
    );
  }
}

class _BedCard extends StatelessWidget {
  const _BedCard();

  @override
  Widget build(BuildContext context) {
    return Consumer<BedAssignmentNotifier>(
      builder: (context, notifier, _) {
        final bed = notifier.bed!;
        final room = notifier.room;
        final service = notifier.service;

        // Mevcut atamada yatış bilgisi varsa göster
        final hospitalization = notifier.currentAssignment?.hospitalization;
        final patientName = hospitalization?.patient?.fullName;

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: MedColors.blueLight,
            border: Border.all(color: MedColors.blue.withAlpha(50), width: 1.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(color: MedColors.blue, borderRadius: BorderRadius.circular(8)),
                    alignment: Alignment.center,
                    child: const Icon(Icons.bed_rounded, size: 18, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bed.name ?? '—',
                          style: TextStyle(
                            fontFamily: MedFonts.sans,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: MedColors.text,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (room != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            room.name ?? '—',
                            style: TextStyle(
                              fontFamily: MedFonts.mono,
                              fontSize: 10,
                              color: MedColors.text3,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              if (service != null || patientName != null) ...[
                const SizedBox(height: 10),
                const Divider(height: 1, color: Color(0x1A1A6FD8)),
                const SizedBox(height: 10),
                if (service != null) _InfoRow(label: context.l10n.assignment_serviceLabel, value: service.name ?? '—'),
                if (patientName != null) ...[
                  const SizedBox(height: 4),
                  _InfoRow(label: context.l10n.assignment_patientLabel, value: patientName),
                ],
              ],
            ],
          ),
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: TextStyle(fontFamily: MedFonts.mono, fontSize: 9, color: MedColors.text3, letterSpacing: 0.4),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontFamily: MedFonts.sans,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: MedColors.text,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
