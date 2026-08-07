part of 'cabin_design_dialog.dart';

class _SerumManualLayoutPanel extends StatefulWidget {
  const _SerumManualLayoutPanel({required this.group});
  final DrawerGroup group;

  @override
  State<_SerumManualLayoutPanel> createState() => _SerumManualLayoutPanelState();
}

class _SerumManualLayoutPanelState extends State<_SerumManualLayoutPanel> {
  List<_SerumDrawerConfig> _drawers = List.generate(5, (i) => _SerumDrawerConfig(index: i));

  int get _drawerCount => _drawers.length;

  void _setDrawerCount(int count) {
    if (count < 1) return;
    setState(() {
      if (count > _drawers.length) {
        _drawers = [..._drawers, for (int i = _drawers.length; i < count; i++) _SerumDrawerConfig(index: i)];
      } else {
        _drawers = _drawers.sublist(0, count);
      }
    });
  }

  void _updateDrawer(int index, _SerumDrawerConfig updated) => setState(() => _drawers[index] = updated);

  void _applyToAll(_SerumDrawerConfig source) {
    setState(() {
      _drawers = [for (final d in _drawers) d.copyWith(sideBySide: source.sideBySide, frontToBack: source.frontToBack)];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(context.l10n.cabinDesign_serum_sectionTitle, style: MedTextStyles.titleSm(color: MedColors.text3)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: MedColors.surface3, borderRadius: MedRadius.smAll),
              child: Text(
                context.l10n.cabinDesign_serum_manualBadge,
                style: TextStyle(fontFamily: MedFonts.mono, fontSize: 9, color: MedColors.text3, letterSpacing: 0.5),
              ),
            ),
          ],
        ),
        const SizedBox(height: MedSpacing.md),
        Container(
          padding: MedSpacing.insetMd,
          decoration: BoxDecoration(
            color: MedColors.blueLight,
            border: Border.all(color: MedColors.border2),
            borderRadius: MedRadius.mdAll,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, size: 16, color: MedColors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.l10n.cabinDesign_serum_infoBanner,
                  style: MedTextStyles.bodySm(color: MedColors.text2),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: MedSpacing.xl2),
        Text(context.l10n.cabinDesign_serum_drawerCountLabel, style: MedTextStyles.bodyMd(color: MedColors.text)),
        const SizedBox(height: MedSpacing.sm),
        MedCounter(
          value: _drawerCount,
          min: 1,
          max: 8,
          onDecrement: () => _setDrawerCount(_drawerCount - 1),
          onIncrement: () => _setDrawerCount(_drawerCount + 1),
        ),
        const SizedBox(height: MedSpacing.xl2),
        for (final drawer in _drawers)
          ExpandableIndexedConfigCard(
            index: drawer.index,
            title: context.l10n.cabinDesign_serum_drawerCardTitle(drawer.index + 1),
            summary: context.l10n.cabinDesign_serum_drawerCardSummary(
              drawer.sideBySide,
              drawer.frontToBack,
              drawer.total,
            ),
            initiallyExpanded: drawer.index == 0,
            body: _SerumDrawerBody(
              drawer: drawer,
              onChanged: (updated) => _updateDrawer(drawer.index, updated),
              onApplyToAll: () => _applyToAll(drawer),
            ),
          ),
        if (_drawers.length > 1) ...[
          const SizedBox(height: MedSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, size: 14, color: MedColors.amber),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  context.l10n.cabinDesign_serum_incompleteWarning(
                    context.l10n.cabinDesign_serum_drawerCardTitle(_drawers.length),
                  ),
                  style: MedTextStyles.bodySm(color: MedColors.text3),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _SerumDrawerConfig {
  const _SerumDrawerConfig({required this.index, this.sideBySide = 3, this.frontToBack = 2});
  final int index;
  final int sideBySide;
  final int frontToBack;
  int get total => sideBySide * frontToBack;

  _SerumDrawerConfig copyWith({int? sideBySide, int? frontToBack}) => _SerumDrawerConfig(
    index: index,
    sideBySide: sideBySide ?? this.sideBySide,
    frontToBack: frontToBack ?? this.frontToBack,
  );
}

class _SerumDrawerBody extends StatelessWidget {
  const _SerumDrawerBody({required this.drawer, required this.onChanged, required this.onApplyToAll});

  final _SerumDrawerConfig drawer;
  final ValueChanged<_SerumDrawerConfig> onChanged;
  final VoidCallback onApplyToAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              context.l10n.cabinDesign_serum_equipmentLayoutTitle,
              style: MedTextStyles.titleSm(color: MedColors.text3),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: MedColors.surface3, borderRadius: MedRadius.smAll),
              child: Text(
                context.l10n.cabinDesign_serum_drawerBadge(drawer.index + 1),
                style: TextStyle(fontFamily: MedFonts.mono, fontSize: 10, color: MedColors.text3),
              ),
            ),
          ],
        ),
        const SizedBox(height: MedSpacing.lg),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.cabinDesign_serum_sideBySideLabel,
                    style: MedTextStyles.bodySm(color: MedColors.text3),
                  ),
                  const SizedBox(height: 6),
                  MedCounter(
                    value: drawer.sideBySide,
                    min: 1,
                    max: 8,
                    onDecrement: () => onChanged(drawer.copyWith(sideBySide: drawer.sideBySide - 1)),
                    onIncrement: () => onChanged(drawer.copyWith(sideBySide: drawer.sideBySide + 1)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: MedSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.cabinDesign_serum_frontToBackLabel,
                    style: MedTextStyles.bodySm(color: MedColors.text3),
                  ),
                  const SizedBox(height: 6),
                  MedCounter(
                    value: drawer.frontToBack,
                    min: 1,
                    max: 8,
                    onDecrement: () => onChanged(drawer.copyWith(frontToBack: drawer.frontToBack - 1)),
                    onIncrement: () => onChanged(drawer.copyWith(frontToBack: drawer.frontToBack + 1)),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: MedSpacing.xl),
        Container(
          padding: MedSpacing.insetMd,
          decoration: BoxDecoration(
            color: MedColors.surface2,
            border: Border.all(color: MedColors.border2),
            borderRadius: MedRadius.mdAll,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    context.l10n.cabinDesign_serum_topViewLabel,
                    style: TextStyle(
                      fontFamily: MedFonts.mono,
                      fontSize: 10,
                      color: MedColors.text4,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    context.l10n.cabinDesign_serum_totalEquipmentLabel(
                      drawer.sideBySide,
                      drawer.frontToBack,
                      drawer.total,
                    ),
                    style: TextStyle(fontFamily: MedFonts.mono, fontSize: 10, color: MedColors.text4),
                  ),
                ],
              ),
              const SizedBox(height: MedSpacing.sm),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: drawer.sideBySide,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                  mainAxisExtent: 56,
                ),
                itemCount: drawer.total,
                itemBuilder: (_, __) => Container(
                  decoration: BoxDecoration(
                    color: MedColors.blueLight,
                    border: Border.all(color: MedColors.border2),
                    borderRadius: MedRadius.smAll,
                  ),
                  alignment: Alignment.center,
                  child: Icon(Icons.medication_liquid_outlined, size: 18, color: MedColors.blue),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(context.l10n.cabinDesign_serum_frontLabel, style: MedTextStyles.bodySm(color: MedColors.text4)),
                  Text(context.l10n.cabinDesign_serum_backLabel, style: MedTextStyles.bodySm(color: MedColors.text4)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: MedSpacing.lg),
        _ActionChip(
          icon: Icons.grid_view_rounded,
          label: context.l10n.cabinDesign_serum_applyToAllButton,
          onTap: onApplyToAll,
        ),
      ],
    );
  }
}

// mobil wizard'daki _ActionChip'in birebir kopyası — private olduğu için
// paylaşılamadı, ileride pharmed_ui'ye taşınabilir.
class _ActionChip extends StatelessWidget {
  const _ActionChip({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: MedColors.blueLight,
          border: Border.all(color: MedColors.blue.withAlpha(77)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: MedColors.blue),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontFamily: MedFonts.sans,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: MedColors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
