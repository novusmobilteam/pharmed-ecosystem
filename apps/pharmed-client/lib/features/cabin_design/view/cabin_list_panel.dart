part of 'cabin_design_dialog.dart';

/// Sol panel: istasyonun kabinleri ve kameraları.
class _StationSidebar extends StatelessWidget {
  const _StationSidebar({required this.notifier});

  final CabinDesignNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final selection = notifier.selection;
    final selectedCabinId = selection is SelectedCabin ? selection.cabinId : null;
    final selectedCameraId = selection is CameraSelection ? selection.cameraId : null;
    final cabins = notifier.stationCabins;
    final cameras = notifier.cameras;
    final horizontal = MedSpacing.insetXl.left * 1.5;

    return Container(
      color: MedColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: MedSpacing.lg),
              children: [
                _SectionHeader(
                  title: context.l10n.cabinDesign_cabinList_sectionTitle,
                  badge: context.l10n.cabinDesign_cabinList_countBadge(cabins.length),
                ),
                for (final cabin in cabins) ...[
                  _CabinListItem(
                    cabin: cabin,
                    isSelected: cabin.id != null && cabin.id == selectedCabinId,
                    onTap: cabin.id != null ? () => notifier.selectCabin(cabin.id!) : null,
                  ),
                  const SizedBox(height: MedSpacing.xs),
                ],
                const SizedBox(height: MedSpacing.xl),
                _SectionHeader(title: context.l10n.cabinDesign_cameraList_sectionTitle, badge: '${cameras.length}'),
                if (cameras.isEmpty)
                  Text(
                    context.l10n.cabinDesign_cameraList_emptyHint,
                    style: MedTextStyles.bodySm(color: MedColors.text4),
                  )
                else
                  for (final camera in cameras) ...[
                    _CameraListItem(
                      camera: camera,
                      isSelected: camera.id == selectedCameraId,
                      onTap: () => notifier.selectCamera(camera.id),
                    ),
                    const SizedBox(height: MedSpacing.xs),
                  ],
              ],
            ),
          ),
          Padding(
            padding: MedSpacing.insetXl * 1.5,
            child: Column(
              spacing: MedSpacing.sm,
              children: [
                MedButton(
                  fullWidth: true,
                  label: context.l10n.cabinDesign_cabinList_addCabinButton,
                  prefixIcon: Icon(PhosphorIcons.plus()),
                  onPressed: notifier.startAddCabin,
                  variant: MedButtonVariant.secondary,
                ),
                MedButton(
                  fullWidth: true,
                  label: context.l10n.cabinDesign_cameraList_addCameraButton,
                  prefixIcon: Icon(PhosphorIcons.videoCamera()),
                  onPressed: () => notifier.startAddCamera(),
                  variant: MedButtonVariant.secondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.badge});

  final String title;
  final String badge;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: MedSpacing.md),
      child: Row(
        children: [
          Text(title, style: MedTextStyles.titleSm(color: MedColors.text3)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: MedColors.surface3, borderRadius: MedRadius.smAll),
            child: Text(badge, style: MedTextStyles.monoSm()),
          ),
        ],
      ),
    );
  }
}

class _CabinListItem extends StatelessWidget {
  const _CabinListItem({required this.cabin, required this.isSelected, required this.onTap});

  final Cabin cabin;
  final bool isSelected;
  final VoidCallback? onTap;

  bool get _isPassive => cabin.status == Status.passive;

  @override
  Widget build(BuildContext context) {
    return _SidebarTile(
      isSelected: isSelected,
      onTap: onTap,
      leading: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          // TODO: canlı bağlantı durumu henüz bağlanmadı — şimdilik pasif/aktif.
          color: _isPassive ? MedColors.text4 : MedColors.green,
        ),
      ),
      title: cabin.name ?? '—',
      subtitle: cabin.type?.label,
      badge: _isPassive ? context.l10n.cabinDesign_cabinList_passiveBadge : null,
    );
  }
}

class _CameraListItem extends StatelessWidget {
  const _CameraListItem({required this.camera, required this.isSelected, required this.onTap});

  final CameraDevice camera;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _SidebarTile(
      isSelected: isSelected,
      onTap: onTap,
      leading: Icon(PhosphorIcons.videoCamera(), size: 16, color: camera.enabled ? MedColors.blue : MedColors.text4),
      title: camera.name,
      subtitle: '${camera.host} · ${context.l10n.cabinDesign_cameraList_cabinCount(camera.cabinIds.length)}',
      badge: camera.enabled ? null : context.l10n.cabinDesign_cameraList_disabledBadge,
    );
  }
}

class _SidebarTile extends StatelessWidget {
  const _SidebarTile({
    required this.isSelected,
    required this.onTap,
    required this.leading,
    required this.title,
    this.subtitle,
    this.badge,
  });

  final bool isSelected;
  final VoidCallback? onTap;
  final Widget leading;
  final String title;
  final String? subtitle;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: MedSpacing.insetXl,
        decoration: BoxDecoration(
          color: isSelected ? MedColors.blueLight : MedColors.surface,
          border: Border.all(color: isSelected ? MedColors.blue : MedColors.border2),
          borderRadius: MedRadius.mdAll,
        ),
        child: Row(
          spacing: 12.0,
          children: [
            leading,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: MedTextStyles.bodyLg(color: MedColors.text).copyWith(fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: MedSpacing.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: MedColors.text4, borderRadius: MedRadius.smAll),
                          child: Text(
                            badge!.toUpperCase(),
                            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: MedTextStyles.bodyMd(color: MedColors.text3),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
