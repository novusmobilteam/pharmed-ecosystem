import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../core/core.dart';
import '../../settings/presentation/notifier/settings_notifier.dart';

class PlatformSelectionScreen extends StatelessWidget {
  const PlatformSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Uygulama Modunu Seçiniz',
              style: context.textTheme.titleLarge,
            ),
            Text('Seçiminize göre kurulum işlemleri bir sonraki aşamada başlayacaktır.'),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _SelectionCard(
                  title: 'Manager (Yönetici)',
                  icon: PhosphorIcons.desktop(),
                  onTap: () => _handleSelection(context, AppMode.manager),
                ),
                const SizedBox(width: 20),
                _SelectionCard(
                  title: 'Client (İstemci)',
                  icon: PhosphorIcons.computerTower(),
                  onTap: () => _handleSelection(context, AppMode.client),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSelection(BuildContext context, AppMode mode) async {
    final settings = context.read<SettingsNotifier>();

    // 1. Modu kaydet
    await settings.setCurrentMode(mode);

    // 2. İlk çalışmayı tamamla
    await settings.setFirstRunDone();
  }
}

class _SelectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _SelectionCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      hoverColor: context.colorScheme.primary.withAlpha(AlphaValues.veryLight),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 250,
        height: 300,
        decoration: BoxDecoration(
          border: Border.all(color: context.colorScheme.primary.withAlpha(AlphaValues.dark)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: context.colorScheme.primary),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
