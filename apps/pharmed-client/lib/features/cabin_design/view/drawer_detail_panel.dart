part of 'cabin_design_dialog.dart';

class _DrawerDetailPanel extends StatelessWidget {
  const _DrawerDetailPanel({required this.group, required this.cabin, required this.notifier});

  final DrawerGroup group;
  final Cabin cabin;
  final CabinDesignNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final returnSlotId = notifier.effectiveReturnSlotId;

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
        if (group.isKubik && cabin.type == CabinType.master) ...[
          const SizedBox(height: MedSpacing.xl),
          _ReturnDrawerToggle(
            isOn: returnSlotId == group.slot.id,
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
                  returnSlotId != null
                      ? context.l10n.cabinDesign_returnDrawer_currentInfo(_addressOf(returnSlotId))
                      : context.l10n.cabinDesign_returnDrawer_noneInfo,
                  style: MedTextStyles.bodySm(color: MedColors.text4),
                ),
              ),
            ],
          ),
        ],
        if (CabinDesignNotifier.isSwappable(group)) ...[
          const SizedBox(height: MedSpacing.xl),
          _DrawerPositionSection(group: group, notifier: notifier),
        ],
      ],
    );
  }

  String _addressOf(int slotId) => notifier.groups.firstWhereOrNull((g) => g.slot.id == slotId)?.address ?? '—';
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

/// Seçili çekmecenin sırasını kabindeki başka bir birim doz / kübik
/// çekmeceyle takas etme. Hedef, kabin görselinden seçilir.
class _DrawerPositionSection extends StatelessWidget {
  const _DrawerPositionSection({required this.group, required this.notifier});

  final DrawerGroup group;
  final CabinDesignNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isSource = notifier.swapSourceSlotId == group.slot.id;
    final connectionPending = notifier.pending.hasConnectionChange || notifier.pending.hasDesignChange;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.cabinDesign_position_sectionTitle, style: MedTextStyles.titleSm(color: MedColors.text3)),
        const SizedBox(height: MedSpacing.sm),
        Text(l10n.cabinDesign_position_swapHint, style: MedTextStyles.bodySm(color: MedColors.text3)),
        const SizedBox(height: MedSpacing.lg),
        Row(
          children: [
            if (isSource)
              MedButton(
                label: l10n.common_cancelButton,
                variant: MedButtonVariant.secondary,
                onPressed: notifier.cancelSwap,
              )
            else
              MedButton(
                label: l10n.cabinDesign_position_swapButton,
                variant: MedButtonVariant.secondary,
                prefixIcon: Icon(PhosphorIcons.arrowsDownUp(), size: 16),
                onPressed: notifier.canSwap(group) && !notifier.isSwapMode ? notifier.startSwap : null,
              ),
            if (notifier.pending.hasOrderChange) ...[
              const SizedBox(width: MedSpacing.sm),
              MedButton(
                label: l10n.cabinDesign_position_resetButton,
                variant: MedButtonVariant.ghost,
                onPressed: notifier.isSaving ? null : notifier.resetSlotOrder,
              ),
            ],
          ],
        ),
        if (connectionPending) ...[
          const SizedBox(height: MedSpacing.sm),
          _PositionInfo(text: l10n.cabinDesign_position_connectionPendingInfo, color: MedColors.text4),
        ] else if (notifier.pending.hasOrderChange) ...[
          const SizedBox(height: MedSpacing.sm),
          _PositionInfo(text: l10n.cabinDesign_position_pendingInfo, color: MedColors.amber),
        ],
      ],
    );
  }
}

class _PositionInfo extends StatelessWidget {
  const _PositionInfo({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info_outline_rounded, size: 14, color: color),
        const SizedBox(width: 6),
        Expanded(child: Text(text, style: MedTextStyles.bodySm(color: color))),
      ],
    );
  }
}
