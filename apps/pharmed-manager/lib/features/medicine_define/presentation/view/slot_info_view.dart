part of 'patient_medicine_define_view.dart';

class SlotInfoView extends StatelessWidget {
  const SlotInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MedicineDefineNotifier>(
      builder: (context, notifier, _) {
        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: notifier.slots.length,
                itemBuilder: (context, index) {
                  final slot = notifier.slots.elementAt(index);

                  return SelectableListTile(
                    item: slot as Selectable,
                    onTap: (item) => notifier.selectSlot(slot),
                    isSelected: notifier.selectedSlot == slot,
                  );
                },
              ),
            ),
            if (notifier.selectedSlot != null)
              TextInputField(
                label: 'Göz No',
                onChanged: (value) => notifier.compartmentNo = int.tryParse(value ?? "0") ?? 0,
              ),
          ],
        );
      },
    );
  }
}
