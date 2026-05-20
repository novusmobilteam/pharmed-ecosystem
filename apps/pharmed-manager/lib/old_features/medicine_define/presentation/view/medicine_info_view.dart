part of 'patient_medicine_define_view.dart';

class MedicineInfoView extends StatelessWidget {
  const MedicineInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MedicineDefineNotifier>(
      builder: (context, vm, _) {
        return Column(
          spacing: AppDimensions.registrationDialogSpacing,
          children: [
            MedTextInputField(label: 'İlaç Adı', onChanged: (value) => vm.medicineName = value),
            MedTextInputField(label: 'Barkod', onChanged: (value) => vm.barcode = value),
            MedTextInputField(
              label: 'Doz',
              onChanged: (value) => vm.dosePiece = int.tryParse(value ?? "0"),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            TimesRow(),
          ],
        );
      },
    );
  }
}
