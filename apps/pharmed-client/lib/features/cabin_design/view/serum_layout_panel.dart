part of 'cabin_design_dialog.dart';

/// Tek bir rafın (DrawerSlot karşılığı) tasarım anındaki taslak durumu.
/// [trays] eklenme sırasıyla tutulur — SAĞDAN SOLA yerleşim mantığına göre
/// ilk eklenen avadanlık en sağdaki alanı kaplar (port ataması bu sıraya
/// göre backend tarafında otomatik yapılır, burada port bilgisi tutulmaz).
class _SerumShelfConfig {
  const _SerumShelfConfig({required this.index, this.isLocked = false, this.trays = const []});

  final int index; // 0..2 → Raf 1..3
  final bool isLocked;
  final List<TraySize> trays;

  static const int totalArea = 8;

  int get usedArea => trays.fold(0, (sum, t) => sum + t.areaSize);
  int get remainingArea => totalArea - usedArea;

  bool canAdd(TraySize size) => remainingArea >= size.areaSize;

  _SerumShelfConfig copyWith({bool? isLocked, List<TraySize>? trays}) =>
      _SerumShelfConfig(index: index, isLocked: isLocked ?? this.isLocked, trays: trays ?? this.trays);
}

class _SerumManualLayoutPanel extends StatefulWidget {
  const _SerumManualLayoutPanel({required this.group});
  final DrawerGroup group;

  @override
  State<_SerumManualLayoutPanel> createState() => _SerumManualLayoutPanelState();
}

class _SerumManualLayoutPanelState extends State<_SerumManualLayoutPanel> {
  static const int _shelfCount = 3;

  late List<_SerumShelfConfig> _shelves = List.generate(_shelfCount, (i) => _SerumShelfConfig(index: i));

  void _updateShelf(int index, _SerumShelfConfig updated) => setState(() => _shelves[index] = updated);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
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
                    style: TextStyle(
                      fontFamily: MedFonts.mono,
                      fontSize: 9,
                      color: MedColors.text3,
                      letterSpacing: 0.5,
                    ),
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
            for (final shelf in _shelves)
              ExpandableIndexedConfigCard(
                index: shelf.index,
                title: context.l10n.cabinDesign_serum_shelfCardTitle(shelf.index + 1),
                summary: context.l10n.cabinDesign_serum_shelfCardSummary(
                  shelf.usedArea,
                  _SerumShelfConfig.totalArea,
                  shelf.trays.length,
                ),
                initiallyExpanded: shelf.index == 0,
                body: _SerumShelfBody(shelf: shelf, onChanged: (updated) => _updateShelf(shelf.index, updated)),
              ),
          ],
        ),
      ),
    );
  }
}

class _SerumShelfBody extends StatelessWidget {
  const _SerumShelfBody({required this.shelf, required this.onChanged});

  final _SerumShelfConfig shelf;
  final ValueChanged<_SerumShelfConfig> onChanged;

  void _addTray(TraySize size) {
    if (!shelf.canAdd(size)) return;
    onChanged(shelf.copyWith(trays: [...shelf.trays, size]));
  }

  void _removeTrayAt(int index) {
    final updated = [...shelf.trays]..removeAt(index);
    onChanged(shelf.copyWith(trays: updated));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Elektromanyetik kilit toggle'ı ──────────────────────────
        Row(
          children: [
            Expanded(
              child: Text(
                context.l10n.cabinDesign_serum_lockToggleLabel,
                style: MedTextStyles.bodyMd(color: MedColors.text),
              ),
            ),
            _MedToggleSwitch(
              value: shelf.isLocked,
              onChanged: (v) => onChanged(shelf.copyWith(isLocked: v)),
            ),
          ],
        ),
        const SizedBox(height: MedSpacing.lg),

        // ── Avadanlık ekleme butonları ───────────────────────────────
        Text(context.l10n.cabinDesign_serum_equipmentLayoutTitle, style: MedTextStyles.titleSm(color: MedColors.text3)),
        const SizedBox(height: MedSpacing.sm),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _ActionChip(
              icon: Icons.add_rounded,
              label: context.l10n.cabinDesign_serum_addSmallButton,
              onTap: shelf.canAdd(TraySize.small) ? () => _addTray(TraySize.small) : null,
            ),
            _ActionChip(
              icon: Icons.add_rounded,
              label: context.l10n.cabinDesign_serum_addMediumButton,
              onTap: shelf.canAdd(TraySize.medium) ? () => _addTray(TraySize.medium) : null,
            ),
            _ActionChip(
              icon: Icons.add_rounded,
              label: context.l10n.cabinDesign_serum_addLargeButton,
              onTap: shelf.canAdd(TraySize.large) ? () => _addTray(TraySize.large) : null,
            ),
          ],
        ),
        if (shelf.remainingArea == 0) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 13, color: MedColors.amber),
              const SizedBox(width: 5),
              Text(
                context.l10n.cabinDesign_serum_capacityFullWarning,
                style: MedTextStyles.bodySm(color: MedColors.text3),
              ),
            ],
          ),
        ],
        const SizedBox(height: MedSpacing.xl),

        // ── Üstten görünüm (sağdan sola dolum) ───────────────────────
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
                    context.l10n.cabinDesign_serum_areaUsedLabel(shelf.usedArea, _SerumShelfConfig.totalArea),
                    style: TextStyle(fontFamily: MedFonts.mono, fontSize: 10, color: MedColors.text4),
                  ),
                ],
              ),
              const SizedBox(height: MedSpacing.sm),
              SizedBox(
                height: 56,
                child: Row(
                  children: [
                    if (shelf.remainingArea > 0)
                      Expanded(
                        flex: shelf.remainingArea,
                        child: Padding(padding: const EdgeInsets.only(right: 3), child: _EmptyAreaBlock()),
                      ),
                    // sağdan sola: ilk eklenen en sağda → reversed render
                    for (final tray in shelf.trays.reversed)
                      Expanded(
                        flex: tray.areaSize,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 3),
                          child: _TrayBlock(size: tray),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(context.l10n.cabinDesign_serum_leftLabel, style: MedTextStyles.bodySm(color: MedColors.text4)),
                  Text(context.l10n.cabinDesign_serum_rightLabel, style: MedTextStyles.bodySm(color: MedColors.text4)),
                ],
              ),
            ],
          ),
        ),

        // ── Eklenen avadanlıklar listesi (kaldırma) ──────────────────
        if (shelf.trays.isNotEmpty) ...[
          const SizedBox(height: MedSpacing.lg),
          for (var i = 0; i < shelf.trays.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: MedColors.surface,
                  border: Border.all(color: MedColors.border2),
                  borderRadius: MedRadius.smAll,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.l10n.cabinDesign_serum_trayListItemLabel(i + 1, shelf.trays[i].label(context)),
                        style: MedTextStyles.bodySm(color: MedColors.text2),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _removeTrayAt(i),
                      child: Icon(Icons.close_rounded, size: 16, color: MedColors.text4),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ],
    );
  }
}

class _TrayBlock extends StatelessWidget {
  const _TrayBlock({required this.size});
  final TraySize size;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MedColors.blueLight,
        border: Border.all(color: MedColors.border2),
        borderRadius: MedRadius.smAll,
      ),
      alignment: Alignment.center,
      child: Icon(Icons.medication_liquid_outlined, size: 18, color: MedColors.blue),
    );
  }
}

class _EmptyAreaBlock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MedColors.surface3,
        border: Border.all(color: MedColors.border2, style: BorderStyle.solid),
        borderRadius: MedRadius.smAll,
      ),
    );
  }
}

/// Basit toggle switch — mock'taki 48x26px / --blue spesifikasyonuna göre.
/// Projede hazır bir MedSwitch varsa onunla değiştirilmeli.
class _MedToggleSwitch extends StatelessWidget {
  const _MedToggleSwitch({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: 48,
        height: 26,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: value ? MedColors.blue : MedColors.border,
          borderRadius: BorderRadius.circular(13),
        ),
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        ),
      ),
    );
  }
}

// mobil wizard'daki _ActionChip'in birebir kopyası — private olduğu için
// paylaşılamadı, ileride pharmed_ui'ye taşınabilir.
// (Bu widget zaten dosyada tanımlıydı — onTap artık nullable, disabled
// durumda soluk render ediliyor.)
class _ActionChip extends StatelessWidget {
  const _ActionChip({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  bool get _enabled => onTap != null;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _enabled ? MedColors.blueLight : MedColors.surface3,
          border: Border.all(color: _enabled ? MedColors.blue.withAlpha(77) : MedColors.border2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: _enabled ? MedColors.blue : MedColors.text4),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontFamily: MedFonts.sans,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _enabled ? MedColors.blue : MedColors.text4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
