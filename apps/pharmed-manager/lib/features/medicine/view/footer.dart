part of 'medicine_screen.dart';

class Footer extends StatelessWidget {
  const Footer(this.notifier, {super.key});

  final MedicineNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 10,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        MedButton(
          label: context.l10n.medicine_defineMedicalConsumableButton,
          size: MedButtonSize.sm,
          onPressed: () async {
            final result = await showMedicalConsumableFormView(context);
            if (result) {
              notifier.fetch();
            }
          },
        ),
        MedButton(
          label: context.l10n.medicine_defineActiveIngredientButton,
          size: MedButtonSize.sm,
          onPressed: () => showActiveIngredientDialog(context),
        ),
        MedButton(
          label: context.l10n.medicine_defineDrugClassButton,
          size: MedButtonSize.sm,
          onPressed: () => showDrugClassDialog(context),
        ),
        MedButton(
          label: context.l10n.medicine_defineDrugTypeButton,
          size: MedButtonSize.sm,
          onPressed: () => showDrugTypeDialog(context),
        ),
        MedButton(
          label: context.l10n.medicine_createKitButton,
          size: MedButtonSize.sm,
          onPressed: () => showKitDialog(context),
        ),
        MedButton(
          label: context.l10n.medicine_defineMaterialTypeButton,
          size: MedButtonSize.sm,
          onPressed: () => showMaterialTypeDialog(context),
        ),
      ],
    );
  }
}
