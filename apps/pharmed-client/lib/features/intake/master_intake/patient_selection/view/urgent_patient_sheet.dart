part of 'patient_selection_panel.dart';

class UrgentPatientSheet extends StatelessWidget {
  const UrgentPatientSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class _UrgentPatientCreateSheetContent extends ConsumerStatefulWidget {
  const _UrgentPatientCreateSheetContent({required this.services, required this.onCancel, required this.onCreated});

  final List<HospitalService> services;
  final VoidCallback onCancel;
  final ValueChanged<Hospitalization> onCreated;

  @override
  ConsumerState<_UrgentPatientCreateSheetContent> createState() => _UrgentPatientCreateSheetContentState();
}

class _UrgentPatientCreateSheetContentState extends ConsumerState<_UrgentPatientCreateSheetContent> {
  static const int _collapsedCount = 6;
  HospitalService? _selected;
  bool _showAll = false;

  @override
  void initState() {
    super.initState();
    if (widget.services.length == 1) _selected = widget.services.first;
  }

  List<HospitalService> get _visibleServices =>
      _showAll ? widget.services : widget.services.take(_collapsedCount).toList();
  int get _hiddenCount => widget.services.length - _collapsedCount;

  Future<void> _submit() async {
    final selected = _selected;
    if (selected?.id == null) return;
    final notifier = ref.read(intakePatientSelectionNotifierProvider.notifier);
    await notifier.createUrgentPatient(
      serviceId: selected!.id!,
      onCreated: widget.onCreated,
      onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCreating = ref.watch(
      intakePatientSelectionNotifierProvider.select(
        (s) => s is IntakePatientSelectionReady ? s.isCreatingUrgent : false,
      ),
    );

    return Material(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: MedRadius.xl2),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(MedSpacing.xl2, MedSpacing.lg, MedSpacing.xl2, MedSpacing.xl2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 12.0),
            Text(
              context.l10n.patientPicker_createUrgentPatientButton,
              style: MedTextStyles.titleMd(color: MedColors.red),
            ),
            const SizedBox(height: 2),
            Text(context.l10n.assignment_serviceSelectorHint, style: MedTextStyles.bodySm(color: MedColors.text3)),
            const SizedBox(height: MedSpacing.lg),
            Wrap(
              spacing: MedSpacing.sm,
              runSpacing: MedSpacing.sm,
              children: [
                for (final s in _visibleServices)
                  _ServiceChip(
                    label: s.name ?? '—',
                    isSelected: _selected?.id == s.id,
                    onTap: () => setState(() => _selected = s),
                  ),
                if (!_showAll && _hiddenCount > 0)
                  _ServiceChip(
                    label: '+$_hiddenCount daha',
                    isSelected: false,
                    onTap: () => setState(() => _showAll = true),
                  ),
              ],
            ),
            const SizedBox(height: MedSpacing.xl),
            Row(
              spacing: 6.0,
              children: [
                Expanded(
                  child: MedButton(
                    label: context.l10n.common_dismissButton,
                    variant: MedButtonVariant.secondary,
                    onPressed: widget.onCancel,
                  ),
                ),

                Expanded(
                  flex: 3,
                  child: MedButton(
                    label: context.l10n.patientPicker_createUrgentPatientButton,
                    variant: MedButtonVariant.danger,
                    isLoading: isCreating,
                    onPressed: _selected == null ? null : _submit,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceChip extends StatelessWidget {
  const _ServiceChip({required this.label, required this.isSelected, required this.onTap});

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MedChip(
      size: MedChipSize.lg,
      label: label,
      onTap: onTap,
      style: isSelected ? MedChipStyle.danger : MedChipStyle.neutral,
      showBorder: false,
      mono: false,
    );
  }
}
