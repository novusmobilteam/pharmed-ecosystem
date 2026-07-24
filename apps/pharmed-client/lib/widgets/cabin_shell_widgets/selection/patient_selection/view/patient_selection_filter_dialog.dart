part of 'patient_selection_guide.dart';

class PatientSelectionFilterDialog extends StatefulWidget {
  const PatientSelectionFilterDialog({super.key, required this.fields});

  final List<FilterField> fields;

  @override
  State<PatientSelectionFilterDialog> createState() => PatientSelectionFilterDialogState();
}

class PatientSelectionFilterDialogState extends State<PatientSelectionFilterDialog> {
  late final Map<String, dynamic> _values = {for (final f in widget.fields) f.key: f.initialValue};

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        width: 420,
        constraints: const BoxConstraints(maxHeight: 640),
        // padding: MedSpacing.insetXl,
        decoration: const BoxDecoration(color: Colors.white, borderRadius: MedRadius.xl2All, boxShadow: MedShadows.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsetsGeometry.symmetric(
                horizontal: MedSpacing.insetXl.left,
                vertical: MedSpacing.insetXl.top,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Filtreler', style: MedTextStyles.titleMd()),
                  Align(alignment: Alignment.topRight, child: CloseButton()),
                ],
              ),
            ),
            Divider(height: 1),
            const SizedBox(height: MedSpacing.md),
            Flexible(
              child: SingleChildScrollView(
                padding: MedSpacing.insetXl,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final field in widget.fields) ...[
                      if (field.label != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: MedSpacing.sm),
                          child: Text(
                            field.label!,
                            style: MedTextStyles.bodyMd().copyWith(color: MedColors.text3, fontWeight: FontWeight.w600),
                          ),
                        ),
                      field.buildInput(context, _values[field.key], (v) => setState(() => _values[field.key] = v)),
                      const SizedBox(height: MedSpacing.lg),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: MedSpacing.xl),
            Padding(
              padding: EdgeInsetsGeometry.only(
                left: MedSpacing.insetXl.left,
                right: MedSpacing.insetXl.left,
                bottom: MedSpacing.insetXl.bottom,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(context.l10n.common_cancelButton),
                    ),
                  ),
                  const SizedBox(width: MedSpacing.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(_values),
                      child: Text(context.l10n.common_saveButton),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
