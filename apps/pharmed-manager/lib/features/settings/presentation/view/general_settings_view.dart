part of 'settings_view.dart';

class GeneralSettingsView extends StatelessWidget {
  const GeneralSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final options = List.generate(12, (index) => (index + 1) * 5);
    final settings = context.watch<SettingsNotifier>();

    return Column(
      spacing: 10,
      children: [
        DropdownInputField(
          options: options,
          onChanged: (_) {},
          labelBuilder: (option) => option?.toString(),
          label: 'Program Otomatik Beklemeye Geçme Süresi (saniye)',
        ),
        TextInputField(
          label: 'Miad Uyarı',
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (_) {},
        ),
        CustomCheckboxTile(
          label: 'HBYS Stok Kontrol',
          value: true,
          onTap: () {},
        ),
        CustomCheckboxTile(
          label: 'Kabinlerde sadece parmak okuyucu çalışsın.',
          value: false,
          onTap: () {},
        ),
        CustomCheckboxTile(
          label: 'Süre dışındaki orderlar alınabilir.',
          value: true,
          onTap: () {},
        ),
        CustomCheckboxTile(
          label: 'İlaç dolum esnasında birim doz çekmecelerde her bölme için ayrı miad tarihi girilebilsin.',
          value: settings.isPerCellMiadEnabled, // 2 ise checked
          onTap: () => settings.togglePerCellMiad(),
        ),
      ],
    );
  }
}
