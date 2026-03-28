part of 'settings_view.dart';

class CabinSettingsView extends StatelessWidget {
  const CabinSettingsView({super.key});

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
          label: 'Çekmece Açık Bekleme Süresi (saniye)',
        ),
        Row(
          spacing: 10,
          children: [
            Icon(PhosphorIcons.info()),
            Expanded(
              child: Text(
                'Açık olan çekmece kapatılmadığı zaman sistemin çekmeceye ne zaman kapatma komutu göndereceğini belirtir.',
                textAlign: TextAlign.left,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
