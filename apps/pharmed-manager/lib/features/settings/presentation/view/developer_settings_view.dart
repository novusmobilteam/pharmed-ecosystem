part of 'settings_view.dart';

class DeveloperSettingsView extends StatelessWidget {
  final SettingsNotifier settings;
  const DeveloperSettingsView({super.key, required this.settings});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Admin Dashboard Aktif',
              style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            value: settings.isAdminModeActive,
            onChanged: (val) {
              context.read<HomeNotifier>().fetchMenus();
              settings.setAdminMode(val);
              Navigator.of(context).pop();
            },
          ),
          const SizedBox(height: 10),
          Text('Uygulama Modu', style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(
            children: [
              _modeButton(context, 'Client Modu', AppMode.client),
              const SizedBox(width: 10),
              _modeButton(context, 'Manager Modu', AppMode.manager),
            ],
          ),
        ],
      ),
    );
  }

  Widget _modeButton(BuildContext context, String label, AppMode mode) {
    final isActive = settings.currentMode == mode;
    return PharmedButton(
      isActive: isActive,
      onPressed: () {
        settings.setCurrentMode(mode);
        context.read<HomeNotifier>().fetchMenus();
      },
      label: label,
    );
  }
}
