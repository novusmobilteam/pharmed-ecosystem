part of '../view/bed_assignment_panel.dart';

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.existingAssignment,
    required this.selectedBed,
    required this.onSave,
    required this.onDelete,
  });

  final BedAssignment? existingAssignment;
  final Bed? selectedBed;
  final VoidCallback onSave;
  final VoidCallback onDelete;

  bool get _isAssigned => existingAssignment != null;
  bool get _isChanged => _isAssigned && selectedBed != null && selectedBed!.id != existingAssignment!.bedId;
  bool get _canSave => !_isAssigned && selectedBed != null;

  @override
  Widget build(BuildContext context) {
    if (_isAssigned && !_isChanged) {
      return MedButton(
        label: context.l10n.assignment_removeAssignmentButton,
        onPressed: onDelete,
        variant: MedButtonVariant.danger,
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
          ),
          const SizedBox(height: 8),
          MedButton(
            label: context.l10n.assignment_removeAssignmentButton,
            variant: MedButtonVariant.danger,
            onPressed: onDelete,
          ),
        ],
      );
    }

    return MedButton(
      label: context.l10n.assignment_saveAssignmentButton,
      variant: MedButtonVariant.success,
      onPressed: _canSave ? onSave : null,
    );
  }
}
