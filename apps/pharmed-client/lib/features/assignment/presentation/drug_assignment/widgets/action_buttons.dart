part of '../view/drug_assignment_panel.dart';

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.canSave, required this.isAssigned, required this.onSave, required this.onDelete});

  final bool canSave;
  final bool isAssigned;
  final VoidCallback onSave;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Kaydet
        MedButton(
          label: context.l10n.assignment_saveAssignmentButton,
          variant: MedButtonVariant.primary,
          onPressed: canSave ? onSave : null,
        ),

        // Sil — sadece atanmış göz için
        if (isAssigned) ...[
          const SizedBox(height: 8),
          MedButton(
            label: context.l10n.assignment_removeAssignmentButton,
            variant: MedButtonVariant.danger,
            onPressed: onDelete,
          ),
        ],
      ],
    );
  }
}
