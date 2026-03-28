part of 'settings_view.dart';

class PrescriptionSettingsView extends StatelessWidget {
  const PrescriptionSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final options = List.generate(12, (index) => (index + 1) * 5);

    return Column(
      spacing: 10,
      children: [
        DropdownInputField(
          options: options,
          onChanged: (_) {},
          labelBuilder: (option) => option?.toString(),
          label: 'Reçete Erişilebilirlik Süresi (dakika)',
        ),
        Row(
          spacing: 10,
          children: [
            Icon(PhosphorIcons.info()),
            Expanded(
              child: Text(
                'Reçetelerin ürün alım saatlerinden ne kadar önce ve sonra erişilebilir olacağını belirtir.',
                textAlign: TextAlign.left,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
