part of 'step4_drawer_config.dart';

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
  final void Function(int drawerIndex, {int? rows, int? columns}) onDrawerConfigChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Çekmece sayısı ──
          SectionLabel(label: 'Çekmece Sayısı'),
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
          // sameConfig açıksa sadece ilk çekmece gösterilir
          for (final drawer in layout.sameConfig ? layout.drawers.take(1).toList() : layout.drawers)
            _DrawerConfigCard(
              drawer: drawer,
              onRowsChanged: (v) => onDrawerConfigChanged(drawer.drawerIndex, rows: v),
              onColumnsChanged: (v) => onDrawerConfigChanged(drawer.drawerIndex, columns: v),
            ),
        ],
      ),
    );
  }
}

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
            // Toggle track
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

class _DrawerConfigCard extends StatefulWidget {
  const _DrawerConfigCard({required this.drawer, required this.onRowsChanged, required this.onColumnsChanged});

  final WizardDrawerConfig drawer;
  final ValueChanged<int> onRowsChanged;
  final ValueChanged<int> onColumnsChanged;

  @override
  State<_DrawerConfigCard> createState() => _DrawerConfigCardState();
}

class _DrawerConfigCardState extends State<_DrawerConfigCard> {
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    // İlk çekmece varsayılan açık
    _expanded = widget.drawer.drawerIndex == 0;
  }

  @override
  Widget build(BuildContext context) {
    final drawer = widget.drawer;
    final summary = '${drawer.rows} satır × ${drawer.columns} sütun';

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
          if (_expanded)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Satır sayısı
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SATIR SAYISI',
                          style: TextStyle(
                            fontFamily: MedFonts.mono,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                            color: MedColors.text3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        MedCounter(
                          value: drawer.rows,
                          min: 1,
                          max: 8,
                          onDecrement: () => widget.onRowsChanged(drawer.rows - 1),
                          onIncrement: () => widget.onRowsChanged(drawer.rows + 1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Sütun sayısı
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SÜTUN SAYISI',
                          style: TextStyle(
                            fontFamily: MedFonts.mono,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                            color: MedColors.text3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        MedCounter(
                          value: drawer.columns,
                          min: 1,
                          max: 8,
                          onDecrement: () => widget.onColumnsChanged(drawer.columns - 1),
                          onIncrement: () => widget.onColumnsChanged(drawer.columns + 1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Mini önizleme
                  Column(
                    children: [
                      const SizedBox(height: 17),
                      _DrawerMiniPreview(rows: drawer.rows, columns: drawer.columns),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Çekmece grid önizlemesi
class _DrawerMiniPreview extends StatelessWidget {
  const _DrawerMiniPreview({required this.rows, required this.columns});
  final int rows;
  final int columns;

  @override
  Widget build(BuildContext context) {
    // Max 6x6 göster, daha fazlası küçük nokta olarak temsil edilir

    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: MedColors.surface,
        border: Border.all(color: MedColors.border2),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(6),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisSpacing: 2,
          crossAxisSpacing: 2,
        ),
        itemCount: rows * columns,
        itemBuilder: (_, _) => Container(
          decoration: BoxDecoration(
            color: MedColors.surface2,
            borderRadius: BorderRadius.circular(2),
            border: Border.all(color: MedColors.border2),
          ),
        ),
      ),
    );
  }
}
