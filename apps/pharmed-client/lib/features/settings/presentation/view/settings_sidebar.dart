// lib/features/settings/presentation/widgets/settings_sidebar.dart

part of 'settings_modal.dart';

class _SettingsSidebar extends StatelessWidget {
  const _SettingsSidebar({required this.activeSection, required this.onSectionTap});

  final SettingsSection activeSection;
  final ValueChanged<SettingsSection> onSectionTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SidebarItem(
              icon: Icons.home_outlined,
              label: context.l10n.settings_generalLabel,
              isActive: activeSection == SettingsSection.general,
              onTap: () => onSectionTap(SettingsSection.general),
            ),
            _SidebarItem(
              icon: Icons.monitor_outlined,
              label: context.l10n.settings_appearanceLabel,
              isActive: activeSection == SettingsSection.appearance,
              onTap: () => onSectionTap(SettingsSection.appearance),
            ),

            // Debug — sadece kDebugMode'da
            if (kDebugMode) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                child: Divider(height: 1, color: MedColors.border2),
              ),
              _SidebarItem(
                icon: Icons.security_outlined,
                label: 'Debug',
                isActive: activeSection == SettingsSection.debug,
                onTap: () => onSectionTap(SettingsSection.debug),
                badge: 'DEV',
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        margin: const EdgeInsets.only(bottom: 2),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: isActive ? MedColors.blueLight : Colors.transparent,
          borderRadius: MedRadius.smAll,
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: isActive ? MedColors.blue : MedColors.text3),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontFamily: MedFonts.sans,
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
                color: isActive ? MedColors.blue : MedColors.text2,
              ),
            ),
            if (badge != null) ...[
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(color: MedColors.amberLight, borderRadius: BorderRadius.circular(4)),
                child: Text(
                  badge!,
                  style: TextStyle(fontFamily: MedFonts.mono, fontSize: 9, color: MedColors.amber, letterSpacing: 0.3),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
