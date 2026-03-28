part of 'patient_medicine_define_view.dart';

class TimesRow extends StatelessWidget {
  const TimesRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: AppDimensions.registrationDialogSpacing / 3,
      children: List.generate(
        5,
        (index) {
          return Expanded(
            child: TimeBox(index: index),
          );
        },
      ),
    );
  }
}

class TimeBox extends StatelessWidget {
  const TimeBox({required this.index, super.key});
  final int index;

  @override
  Widget build(BuildContext context) {
    return Consumer<MedicineDefineNotifier>(
      builder: (context, vm, _) {
        final time = vm.selectedTimes.elementAtOrNull(index);
        final text =
            time != null ? '${time.hour.toString().padLeft(2, '0')}.${time.minute.toString().padLeft(2, '0')}' : '';
        final controller = TextEditingController(text: text);

        return GestureDetector(
          onTap: () async {
            final TimeOfDay? selectedTime = await showTimePicker(
              context: context,
              initialTime:
                  time != null ? TimeOfDay(hour: time.hour, minute: time.minute) : const TimeOfDay(hour: 12, minute: 0),
            );
            if (selectedTime != null) {
              vm.updateSelectedTime(index, selectedTime);
            }
          },
          child: TextInputField(
            controller: controller,
            readOnly: true,
            label: 'Saat',
            onChanged: (_) {},
          ),
        );
      },
    );
  }
}
