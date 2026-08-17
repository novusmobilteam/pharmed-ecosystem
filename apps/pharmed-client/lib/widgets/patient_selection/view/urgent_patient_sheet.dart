part of 'patient_selection_panel.dart';

class UrgentPatientSheet extends StatefulWidget {
  const UrgentPatientSheet({super.key});

  @override
  State<UrgentPatientSheet> createState() => _UrgentPatientSheetState();
}

class _UrgentPatientSheetState extends State<UrgentPatientSheet> {
  static const int _collapsedCount = 6;
  HospitalService? _selected;
  bool _showAll = false;

  List<HospitalService> get _services => context.read<PatientSelectionNotifier>().services;

  @override
  void initState() {
    super.initState();
    if (_services.length == 1) _selected = _services.first;
  }

  List<HospitalService> get _visibleServices => _showAll ? _services : _services.take(_collapsedCount).toList();
  int get _hiddenCount => _services.length - _collapsedCount;

  Future<void> _submit() async {
    final selected = _selected;
    if (selected?.id == null) return;
    final notifier = context.read<PatientSelectionNotifier>();
    await notifier.createUrgentPatient(
      serviceId: selected!.id!,
      onCreated: (_) => notifier.closeCreateSheet(),
      onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoadingServices = context.select<PatientSelectionNotifier, bool>((n) => n.isLoading(n.fetchServicesOp));
    final isCreating = context.select<PatientSelectionNotifier, bool>((n) => n.isCreatingUrgent);

    if (isLoadingServices) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: MedLoadingIndicator()),
      );
    }

    return Material(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(MedSpacing.xl2, MedSpacing.lg, MedSpacing.xl2, MedSpacing.xl2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12.0),
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
                  child: MedRectangleButton(
                    label: context.l10n.common_dismissButton,
                    backgroundColor: Colors.transparent,
                    showBorder: true,
                    height: 40,
                    foregroundColor: Colors.black,
                    onTap: () => context.read<PatientSelectionNotifier>().closeCreateSheet(),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: MedRectangleButton(
                    label: context.l10n.patientPicker_createUrgentPatientButton,
                    height: 40,
                    isLoading: isCreating,
                    backgroundColor: MedColors.red,
                    suffixIcon: PhosphorIcons.plus(),
                    foregroundColor: Colors.white,
                    onTap: _selected == null ? null : _submit,
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
