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
        MedCheckbox(label: 'HBYS Stok Kontrol', value: true, onChanged: (_) {}),
        MedCheckbox(label: 'Kabinlerde sadece parmak okuyucu çalışsın.', value: false, onChanged: (_) {}),
        MedCheckbox(label: 'Süre dışındaki orderlar alınabilir.', value: true, onChanged: (_) {}),
        MedCheckbox(
          label: 'İlaç dolum esnasında birim doz çekmecelerde her bölme için ayrı miad tarihi girilebilsin.',
          value: settings.isPerCellMiadEnabled, // 2 ise checked
          onChanged: (_) => settings.togglePerCellMiad(),
        ),
      ],
    );
  }
}
