// [SWREQ-UI-NAV-KABIN-001]
// "Kabin Yönetimi" menü öğesine tıklandığında açılan mega menü paneli.
// Sol sidebar → kategori seçimi  |  Sağ → 2×2 kart grid + hızlı butonlar.
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart' hide MaterialType;
import 'package:pharmed_ui/pharmed_ui.dart';

import 'package:provider/provider.dart';

import '../../../../features/settings/notifier/settings_notifier.dart';

class DashboardNavbarMenu extends StatelessWidget {
  const DashboardNavbarMenu({
    super.key,
    this.onCardTap,
    this.onQuickTap,
    required this.parentId,
    required this.flattenedMenus,
  });

  final int parentId;
  final List<MenuItem> flattenedMenus;
  final void Function(int id)? onCardTap;
  final void Function(String id)? onQuickTap;

  @override
  Widget build(BuildContext context) {
    final children = flattenedMenus.where((m) => m.parentId == parentId).toList();
    if (children.isEmpty) return const SizedBox.shrink();

    final settings = context.watch<SettingsNotifier>();

    return Material(
      type: MaterialType.transparency,
      child: Container(
        width: 750,
        decoration: BoxDecoration(
          color: MedColors.surface,
          border: Border.all(color: MedColors.border),
          borderRadius: const BorderRadius.only(
            topRight: MedRadius.lg,
            bottomLeft: MedRadius.lg,
            bottomRight: MedRadius.lg,
          ),
          boxShadow: MedShadows.md,
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 16),
              // cabinType tüm kartlar için TEK bir FutureBuilder'da çözülür
              // — her _SubCard kendi başına getDeviceMode() çağırmaz.
              FutureBuilder<CabinType?>(
                key: ValueKey(settings.debugCabin?.id),
                future: settings.getDeviceMode(),
                builder: (context, snapshot) {
                  final cabinType = snapshot.data;
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: children.map((item) {
                      return SizedBox(
                        width: 350,
                        child: _SubCard(item: item, cabinType: cabinType, onTap: (id) => onCardTap?.call(id)),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final parent = flattenedMenus.firstWhere((m) => m.id == parentId);
    final locale = Localizations.localeOf(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(parent.localizedName(locale), style: MedTextStyles.titleMd()),
        Text(parent.localizedDescription(locale), style: MedTextStyles.bodyMd()),
      ],
    );
  }
}

class _SubCard extends StatelessWidget {
  const _SubCard({required this.item, required this.cabinType, required this.onTap});

  final MenuItem item;
  final CabinType? cabinType;
  final void Function(int id) onTap;

  @override
  Widget build(BuildContext context) {
    final iconData = item.unicode?.toIcon;
    final locale = Localizations.localeOf(context);
    final isMobileItem = item.isMobile ?? false;
    final isActive = cabinType != CabinType.mobile || isMobileItem;

    return GestureDetector(
      onTap: () => isActive ? onTap(item.id ?? 0) : null,
      child: Opacity(
        opacity: isActive ? 1 : 0.5,
        child: Container(
          height: 85,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: MedColors.surface2,
            border: Border.all(color: MedColors.border2),
            borderRadius: MedRadius.mdAll,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 6.0,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(color: MedColors.surface3, borderRadius: MedRadius.mdAll),
                child: Icon(iconData, size: 16, color: MedColors.text2),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(item.localizedName(locale), style: MedTextStyles.titleSm()),
                    const SizedBox(height: 2),
                    Text(
                      item.localizedDescription(locale),
                      style: MedTextStyles.bodySm(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
