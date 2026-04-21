part of 'step4_drawer_config.dart';

// lib/features/setup_wizard/presentation/widgets/mobile_config_view.dart
//
// [SWREQ-SETUP-UI-011] [IEC 62304 §5.5]
// Mobil kabin wizard adım 4 — çekmece yapılandırma arayüzü.
// Her çekmece için satır listesi; her satırın sütun sayısı bağımsız ayarlanır.
// Sınıf: Class B

class MobileConfigView extends StatelessWidget {
  const MobileConfigView({
    super.key,
    required this.layout,
    required this.onDrawerCountChanged,
    required this.onDrawerConfigChanged,
    required this.onSameConfigToggled,
  });

  final WizardMobileLayout layout;
  final ValueChanged<int> onDrawerCountChanged;
  final ValueChanged<bool> onSameConfigToggled;
  final void Function(int drawerIndex, List<int> rowColumns) onDrawerConfigChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Çekmece sayısı ──
          SectionLabel(label: context.l10n.wizard_drawerCountLabel),
          const SizedBox(height: 10),
          Row(
            children: [
              MedCounter(
                value: layout.drawerCount,
                min: 1,
                max: 8,
                onDecrement: () => onDrawerCountChanged(layout.drawerCount - 1),
                onIncrement: () => onDrawerCountChanged(layout.drawerCount + 1),
              ),
              const SizedBox(width: 16),
              Text(
                '1–8 çekmece',
                style: TextStyle(fontFamily: MedFonts.sans, fontSize: 12, color: MedColors.text3),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Tüm çekmeceler aynı yapıda toggle ──
          _SameConfigToggle(value: layout.sameConfig, onChanged: onSameConfigToggled),
          const SizedBox(height: 24),

          // ── Çekmece listesi ──
          for (final drawer in layout.sameConfig ? layout.drawers.take(1).toList() : layout.drawers)
            _DrawerConfigCard(
              drawer: drawer,
              onConfigChanged: (rowColumns) => onDrawerConfigChanged(drawer.drawerIndex, rowColumns),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Toggle
// ─────────────────────────────────────────────

class _SameConfigToggle extends StatelessWidget {
  const _SameConfigToggle({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: value ? MedColors.blueLight : MedColors.surface2,
          border: Border.all(color: value ? MedColors.blue.withOpacity(0.4) : MedColors.border),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 24,
              decoration: BoxDecoration(
                color: value ? MedColors.blue : MedColors.border,
                borderRadius: BorderRadius.circular(12),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 18,
                  height: 18,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tüm çekmeceler aynı yapıda',
                    style: TextStyle(
                      fontFamily: MedFonts.sans,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: MedColors.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value
                        ? 'Tüm çekmeceler aynı satır/sütun konfigürasyonunu kullanır'
                        : 'Kapalıysa her çekmece için satır/sütun ayrı seçilebilir',
                    style: TextStyle(fontFamily: MedFonts.sans, fontSize: 11, color: MedColors.text3),
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

// ─────────────────────────────────────────────
// Çekmece kartı
// ─────────────────────────────────────────────

class _DrawerConfigCard extends StatefulWidget {
  const _DrawerConfigCard({required this.drawer, required this.onConfigChanged});

  final WizardDrawerConfig drawer;
  final ValueChanged<List<int>> onConfigChanged;

  @override
  State<_DrawerConfigCard> createState() => _DrawerConfigCardState();
}

class _DrawerConfigCardState extends State<_DrawerConfigCard> {
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _expanded = widget.drawer.drawerIndex == 0;
  }

  void _updateRow(int rowIndex, int columns) {
    final updated = widget.drawer.withRowColumns(rowIndex, columns);
    widget.onConfigChanged(updated.rowColumns);
  }

  void _addRow() {
    final updated = widget.drawer.withRowAdded();
    widget.onConfigChanged(updated.rowColumns);
  }

  void _removeLastRow() {
    if (widget.drawer.rowCount <= 1) return;
    final updated = widget.drawer.withRowRemoved(widget.drawer.rowCount - 1);
    widget.onConfigChanged(updated.rowColumns);
  }

  @override
  Widget build(BuildContext context) {
    final drawer = widget.drawer;
    final summary = '${drawer.rowCount} satır · ${drawer.totalCells} hücre';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: MedColors.surface,
        border: Border.all(color: _expanded ? MedColors.blue.withAlpha(50) : MedColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          // ── Başlık satırı ──
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: _expanded ? MedColors.blue : MedColors.surface2,
                      shape: BoxShape.circle,
                      border: Border.all(color: _expanded ? MedColors.blue : MedColors.border),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${drawer.drawerIndex + 1}',
                      style: TextStyle(
                        fontFamily: MedFonts.mono,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _expanded ? Colors.white : MedColors.text3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${drawer.drawerIndex + 1}. Çekmece',
                    style: TextStyle(
                      fontFamily: MedFonts.sans,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: MedColors.text,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    summary,
                    style: TextStyle(fontFamily: MedFonts.mono, fontSize: 11, color: MedColors.text3),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                    size: 20,
                    color: MedColors.text3,
                  ),
                ],
              ),
            ),
          ),

          // ── Detay alanı ──
          if (_expanded) ...[
            const Divider(height: 1, thickness: 1, color: MedColors.border2),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                children: [
                  // Satır listesi
                  for (int i = 0; i < drawer.rowCount; i++)
                    _RowConfigItem(
                      rowIndex: i,
                      columns: drawer.rowColumns[i],
                      maxColumns: 8,
                      onChanged: (v) => _updateRow(i, v),
                    ),

                  const SizedBox(height: 8),

                  // Alt butonlar: Satır ekle / Son satırı sil
                  Row(
                    children: [
                      _ActionChip(
                        icon: Icons.add_rounded,
                        label: context.l10n.wizard_addRowButton,
                        enabled: drawer.rowCount < 8,
                        onTap: _addRow,
                      ),
                      const SizedBox(width: 8),
                      _ActionChip(
                        icon: Icons.remove_rounded,
                        label: context.l10n.wizard_removeLastRowButton,
                        enabled: drawer.rowCount > 1,
                        danger: true,
                        onTap: _removeLastRow,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Tek satır yapılandırma satırı
// ─────────────────────────────────────────────

class _RowConfigItem extends StatelessWidget {
  const _RowConfigItem({
    required this.rowIndex,
    required this.columns,
    required this.maxColumns,
    required this.onChanged,
  });

  final int rowIndex;
  final int columns;
  final int maxColumns;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          // Satır numarası etiketi
          SizedBox(
            width: 56,
            child: Text(
              'SATIR ${rowIndex + 1}',
              style: TextStyle(
                fontFamily: MedFonts.mono,
                fontSize: 9,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.6,
                color: MedColors.text3,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Counter
          MedCounter(
            value: columns,
            min: 1,
            max: maxColumns,
            onDecrement: () => onChanged(columns - 1),
            onIncrement: () => onChanged(columns + 1),
          ),
          const SizedBox(width: 12),

          // Hücre bar önizleme
          Expanded(
            child: _RowBarPreview(columns: columns, maxColumns: maxColumns),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Satır bar önizleme
// ─────────────────────────────────────────────

class _RowBarPreview extends StatelessWidget {
  const _RowBarPreview({required this.columns, required this.maxColumns});

  final int columns;
  final int maxColumns;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      child: Row(
        children: List.generate(maxColumns, (i) {
          final active = i < columns;
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              decoration: BoxDecoration(
                color: active ? MedColors.blue.withOpacity(0.2) : MedColors.surface2,
                border: Border.all(color: active ? MedColors.blue.withOpacity(0.4) : MedColors.border2),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Aksiyon chip (Satır ekle / sil)
// ─────────────────────────────────────────────

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.enabled = true,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool enabled;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = !enabled
        ? MedColors.text4
        : danger
        ? MedColors.red
        : MedColors.blue;
    final bgColor = !enabled
        ? MedColors.surface2
        : danger
        ? MedColors.red.withOpacity(0.06)
        : MedColors.blueLight;
    final borderColor = !enabled
        ? MedColors.border
        : danger
        ? MedColors.red.withOpacity(0.25)
        : MedColors.blue.withOpacity(0.3);

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(fontFamily: MedFonts.sans, fontSize: 12, fontWeight: FontWeight.w500, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
