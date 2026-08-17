part of 'cabin_design_dialog.dart';

class _DrawerDetailPanel extends StatelessWidget {
  const _DrawerDetailPanel({required this.group, required this.notifier});

  final DrawerGroup group;
  final CabinDesignNotifier notifier;

  bool get _isReturnDrawer => notifier.effectiveReturnSlotId == group.slot.id;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.cabinDesign_detail_sectionTitle, style: MedTextStyles.titleSm(color: MedColors.text3)),
        const SizedBox(height: MedSpacing.lg),
        Row(
          children: [
            Expanded(
              child: _InfoField(
                label: context.l10n.cabinDesign_detail_typeLabel,
                value: group.isKubik
                    ? context.l10n.cabinDesign_detail_typeKubik(4, (group.compartmentCount / 4).ceil())
                    : context.l10n.cabin_unitDoseTypeLabel,
              ),
            ),
            const SizedBox(width: MedSpacing.sm),
            Expanded(
              child: _InfoField(
                label: context.l10n.cabinDesign_detail_cellCountLabel,
                value: '${group.compartmentCount}',
              ),
            ),
          ],
        ),
        const SizedBox(height: MedSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _InfoField(label: context.l10n.cabinDesign_detail_addressLabel, value: group.address),
            ),
            const SizedBox(width: MedSpacing.sm),
            Expanded(
              child: _InfoField(
                label: context.l10n.cabinDesign_detail_configLabel,
                value: group.slot.drawerConfig?.drawerType?.name ?? '—',
              ),
            ),
          ],
        ),
        if (group.isKubik) ...[
          const SizedBox(height: MedSpacing.xl),
          _ReturnDrawerToggle(
            isOn: _isReturnDrawer,
            disabled: notifier.isSaving,
            onChanged: notifier.toggleReturnDrawer,
          ),
          const SizedBox(height: MedSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, size: 14, color: MedColors.text4),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  notifier.effectiveReturnSlotId != null
                      ? context.l10n.cabinDesign_returnDrawer_currentInfo(
                          _addressOf(notifier, notifier.effectiveReturnSlotId!),
                        )
                      : context.l10n.cabinDesign_returnDrawer_noneInfo,
                  style: MedTextStyles.bodySm(color: MedColors.text4),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  String _addressOf(CabinDesignNotifier notifier, int slotId) =>
      notifier.groups.firstWhereOrNull((g) => g.slot.id == slotId)?.address ?? '—';
}

class _InfoField extends StatelessWidget {
  const _InfoField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: MedSpacing.insetMd,
      decoration: BoxDecoration(
        color: MedColors.surface2,
        border: Border.all(color: MedColors.border2),
        borderRadius: MedRadius.smAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontFamily: MedFonts.mono, fontSize: 10, color: MedColors.text4, letterSpacing: 0.5),
          ),
          const SizedBox(height: 4),
          Text(value, style: MedTextStyles.monoMd(color: MedColors.text)),
        ],
      ),
    );
  }
}

class _ReturnDrawerToggle extends StatelessWidget {
  const _ReturnDrawerToggle({required this.isOn, required this.disabled, required this.onChanged});

  final bool isOn;
  final bool disabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: MedSpacing.insetLg,
      decoration: BoxDecoration(
        color: isOn ? MedColors.blueLight : MedColors.surface2,
        border: Border.all(color: isOn ? MedColors.blue : MedColors.border2),
        borderRadius: MedRadius.mdAll,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.cabinDesign_returnDrawer_toggleLabel,
                  style: MedTextStyles.bodyMd(color: MedColors.text).copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  context.l10n.cabinDesign_returnDrawer_toggleHint,
                  style: MedTextStyles.bodySm(color: MedColors.text3),
                ),
              ],
            ),
          ),
          MedToggle(value: isOn, onChanged: disabled ? null : onChanged),
        ],
      ),
    );
  }
}
