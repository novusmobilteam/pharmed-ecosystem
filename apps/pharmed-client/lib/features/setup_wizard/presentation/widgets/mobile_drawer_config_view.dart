part of '../view/step4_view.dart';

// [SWREQ-SETUP-UI-011] [IEC 62304 §5.5]
// Mobil kabin wizard adım 4 — çekmece yapılandırma + port keşfi arayüzü.
// Sınıf: Class B

class MobileDrawerConfigView extends ConsumerWidget {
  const MobileDrawerConfigView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(step4MobileNotifierProvider);
    final notifier = ref.read(step4MobileNotifierProvider.notifier);
    final layout = state.mobileLayout;
    final discoveryDone = state.portDiscoveryState == PortDiscoveryState.discovered;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Çekmece sayısı ──────────────────────────────────────
          SectionLabel(label: context.l10n.wizard_drawerCountLabel),
          const SizedBox(height: 10),
          Row(
            children: [
              MedCounter(
                value: layout.drawerCount,
                min: 1,
                max: 8,
                onDecrement: () => notifier.updateDrawerCount(layout.drawerCount - 1),
                onIncrement: () => notifier.updateDrawerCount(layout.drawerCount + 1),
              ),
              const SizedBox(width: 16),
              Text(
                '1–8 çekmece',
                style: TextStyle(fontFamily: MedFonts.sans, fontSize: 12, color: MedColors.text3),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Tüm çekmeceler aynı yapıda toggle ───────────────────
          _SameConfigToggle(
            value: layout.sameConfig,
            onChanged: (val) => notifier.toggleSameConfig(value: val),
          ),
          const SizedBox(height: 24),

          // ── Çekmece listesi ──────────────────────────────────────
          for (final drawer in layout.sameConfig ? layout.drawers.take(1).toList() : layout.drawers)
            _DrawerConfigCard(
              drawer: drawer,
              discoveryDone: discoveryDone,
              onConfigChanged: (rowColumns) => notifier.updateDrawerConfig(drawer.drawerIndex, rowColumns),
              onRemove: drawer.isActive ? null : () => notifier.removeInactiveDrawer(drawer.drawerIndex),
            ),

          const SizedBox(height: 8),

          // ── Port keşfi bölümü ─────────────────────────────────────
          _PortDiscoverySection(
            state: state.portDiscoveryState,
            layout: layout,
            error: state.portDiscoveryError,
            onDiscover: notifier.discoverPorts,
            onReset: notifier.resetPortDiscovery,
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Port keşfi bölümü
// ────────────────────────────────────────────────────────────────────────────

class _PortDiscoverySection extends StatelessWidget {
  const _PortDiscoverySection({
    required this.state,
    required this.layout,
    required this.onDiscover,
    required this.onReset,
    this.error,
  });

  final PortDiscoveryState state;
  final WizardMobileLayout layout;
  final String? error;
  final VoidCallback onDiscover;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(label: 'PORT KEŞFİ'),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: MedColors.surface,
            border: Border.all(color: _borderColor),
            borderRadius: MedRadius.mdAll,
            boxShadow: MedShadows.sm,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(color: _iconBgColor, borderRadius: MedRadius.smAll),
                      child: Icon(_icon, size: 18, color: _iconColor),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _title,
                            style: MedTextStyles.bodyMd(color: MedColors.text, weight: FontWeight.w600),
                          ),
                          const SizedBox(height: 3),
                          Text(_description, style: MedTextStyles.bodySm(color: MedColors.text3)),
                          if (error != null) ...[
                            const SizedBox(height: 6),
                            Text(error!, style: MedTextStyles.bodySm(color: MedColors.red)),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    _DiscoveryButton(state: state, onDiscover: onDiscover, onReset: onReset),
                  ],
                ),
              ),
              if (state == PortDiscoveryState.discovered || state == PortDiscoveryState.discovering) ...[
                Divider(height: 1, thickness: 1, color: MedColors.border2),
                _PortResultList(layout: layout, isDiscovering: state == PortDiscoveryState.discovering),
              ],
              if (state == PortDiscoveryState.discovered && !layout.allActive) ...[
                Divider(height: 1, thickness: 1, color: MedColors.border2),
                _InactiveDrawerWarning(inactiveCount: layout.inactiveDrawerCount),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Color get _borderColor => switch (state) {
    PortDiscoveryState.discovered => layout.allActive ? MedColors.green : MedColors.amber,
    PortDiscoveryState.error => MedColors.red,
    _ => MedColors.border,
  };

  Color get _iconBgColor => switch (state) {
    PortDiscoveryState.discovered => layout.allActive ? MedColors.greenLight : MedColors.amberLight,
    PortDiscoveryState.error => MedColors.redLight,
    PortDiscoveryState.discovering => MedColors.blueLight,
    _ => MedColors.surface3,
  };

  Color get _iconColor => switch (state) {
    PortDiscoveryState.discovered => layout.allActive ? MedColors.green : MedColors.amber,
    PortDiscoveryState.error => MedColors.red,
    PortDiscoveryState.discovering => MedColors.blue,
    _ => MedColors.text3,
  };

  IconData get _icon => switch (state) {
    PortDiscoveryState.discovered => layout.allActive ? Icons.check_circle_rounded : Icons.warning_rounded,
    PortDiscoveryState.error => Icons.error_rounded,
    PortDiscoveryState.discovering => Icons.radar_rounded,
    _ => Icons.usb_rounded,
  };

  String get _title => switch (state) {
    PortDiscoveryState.idle => 'Port Keşfi',
    PortDiscoveryState.discovering => 'Portlar Taranıyor...',
    PortDiscoveryState.discovered => layout.allActive ? 'Tüm Portlar Aktif' : 'Bazı Portlar Yanıt Vermedi',
    PortDiscoveryState.error => 'Keşif Başarısız',
  };

  String get _description => switch (state) {
    PortDiscoveryState.idle =>
      'Fiziksel çekmecelerin donanıma bağlı olup olmadığını doğrulamak '
          'için port keşfini başlatın. Keşif sırasında çekmeceler açılacaktır.',
    PortDiscoveryState.discovering => 'Çekmeceler tek tek taranıyor. Lütfen bekleyin...',
    PortDiscoveryState.discovered =>
      layout.allActive
          ? 'Tüm ${layout.drawerCount} çekmeceye ait port başarıyla tespit edildi.'
          : '${layout.drawerCount} çekmeceden ${layout.inactiveDrawerCount} tanesi '
                'yanıt vermedi. Pasif çekmeceleri silebilir veya uyarıyla kaydedebilirsiniz.',
    PortDiscoveryState.error => 'Port keşfi tamamlanamadı. Bağlantıları kontrol edip tekrar deneyin.',
  };
}

class _DiscoveryButton extends StatelessWidget {
  const _DiscoveryButton({required this.state, required this.onDiscover, required this.onReset});

  final PortDiscoveryState state;
  final VoidCallback onDiscover;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    if (state == PortDiscoveryState.discovering) {
      return const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2));
    }

    if (state == PortDiscoveryState.discovered || state == PortDiscoveryState.error) {
      return _ActionChip(icon: Icons.refresh_rounded, label: 'Yeniden Tara', onTap: onReset);
    }

    return _ActionChip(icon: Icons.radar_rounded, label: 'Portları Tara', onTap: onDiscover, primary: true);
  }
}

class _PortResultList extends StatelessWidget {
  const _PortResultList({required this.layout, required this.isDiscovering});

  final WizardMobileLayout layout;
  final bool isDiscovering;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: layout.drawers.map((d) {
          final isScanned = d.portNumber != null || !isDiscovering;
          return _PortChip(
            drawerIndex: d.drawerIndex,
            portNumber: d.portNumber,
            isActive: d.isActive,
            isScanning: isDiscovering && !isScanned,
          );
        }).toList(),
      ),
    );
  }
}

class _PortChip extends StatelessWidget {
  const _PortChip({
    required this.drawerIndex,
    required this.portNumber,
    required this.isActive,
    required this.isScanning,
  });

  final int drawerIndex;
  final int? portNumber;
  final bool isActive;
  final bool isScanning;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color border;
    final Color textColor;
    final IconData icon;

    if (isScanning) {
      bg = MedColors.surface2;
      border = MedColors.border;
      textColor = MedColors.text3;
      icon = Icons.hourglass_empty_rounded;
    } else if (isActive) {
      bg = MedColors.greenLight;
      border = MedColors.green.withValues(alpha: 0.4);
      textColor = MedColors.green;
      icon = Icons.check_circle_rounded;
    } else {
      bg = MedColors.redLight;
      border = MedColors.red.withValues(alpha: 0.4);
      textColor = MedColors.red;
      icon = Icons.cancel_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: MedRadius.smAll,
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 5),
          Text(
            isScanning
                ? 'Çekmece ${drawerIndex + 1}'
                : portNumber != null
                ? 'Çekmece ${drawerIndex + 1} → Port $portNumber'
                : 'Çekmece ${drawerIndex + 1} → Yanıt yok',
            style: MedTextStyles.monoXs(color: textColor),
          ),
        ],
      ),
    );
  }
}

class _InactiveDrawerWarning extends StatelessWidget {
  const _InactiveDrawerWarning({required this.inactiveCount});

  final int inactiveCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: MedColors.amberLight,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 16, color: MedColors.amber),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$inactiveCount çekmece pasif olarak işaretlenecek. '
              'Pasif çekmecelerde dolum, boşaltma veya atama yapılamaz. '
              'Çekmece listesinden "Sil" seçeneği ile kaldırabilirsiniz.',
              style: MedTextStyles.bodySm(color: MedColors.amber),
            ),
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
  const _DrawerConfigCard({
    required this.drawer,
    required this.discoveryDone,
    required this.onConfigChanged,
    this.onRemove,
  });

  final WizardDrawerConfig drawer;
  final bool discoveryDone;
  final ValueChanged<List<int>> onConfigChanged;
  final VoidCallback? onRemove;

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
    final isInactive = widget.discoveryDone && !drawer.isActive;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isInactive ? MedColors.redLight : MedColors.surface,
        border: Border.all(
          color: isInactive
              ? MedColors.red.withValues(alpha: 0.3)
              : _expanded
              ? MedColors.blue.withAlpha(50)
              : MedColors.border,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
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
                      color: isInactive
                          ? MedColors.red.withValues(alpha: 0.15)
                          : _expanded
                          ? MedColors.blue
                          : MedColors.surface2,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isInactive
                            ? MedColors.red.withValues(alpha: 0.4)
                            : _expanded
                            ? MedColors.blue
                            : MedColors.border,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${drawer.drawerIndex + 1}',
                      style: TextStyle(
                        fontFamily: MedFonts.mono,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isInactive
                            ? MedColors.red
                            : _expanded
                            ? Colors.white
                            : MedColors.text3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${drawer.drawerIndex + 1}. Çekmece',
                          style: TextStyle(
                            fontFamily: MedFonts.sans,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isInactive ? MedColors.red : MedColors.text,
                          ),
                        ),
                        if (drawer.portNumber != null)
                          Text(
                            'Port ${drawer.portNumber}',
                            style: MedTextStyles.monoXs(color: isInactive ? MedColors.red : MedColors.text3),
                          ),
                      ],
                    ),
                  ),
                  if (isInactive)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: MedColors.red.withValues(alpha: 0.1),
                        borderRadius: MedRadius.xlAll,
                        border: Border.all(color: MedColors.red.withValues(alpha: 0.3)),
                      ),
                      child: Text('Yanıt yok', style: MedTextStyles.monoXs(color: MedColors.red)),
                    )
                  else
                    Text(
                      summary,
                      style: TextStyle(fontFamily: MedFonts.mono, fontSize: 11, color: MedColors.text3),
                    ),
                  const SizedBox(width: 8),
                  if (widget.onRemove != null) ...[
                    GestureDetector(
                      onTap: widget.onRemove,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: MedColors.redLight,
                          borderRadius: MedRadius.smAll,
                          border: Border.all(color: MedColors.red.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.delete_outline_rounded, size: 13, color: MedColors.red),
                            const SizedBox(width: 4),
                            Text(
                              'Sil',
                              style: MedTextStyles.bodySm(color: MedColors.red, weight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Icon(
                    _expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                    size: 20,
                    color: MedColors.text3,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded && !isInactive) ...[
            const Divider(height: 1, thickness: 1, color: MedColors.border2),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                children: [
                  for (int i = 0; i < drawer.rowCount; i++)
                    _RowConfigItem(
                      rowIndex: i,
                      columns: drawer.rowColumns[i],
                      maxColumns: 8,
                      onChanged: (v) => _updateRow(i, v),
                    ),
                  const SizedBox(height: 8),
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
          MedCounter(
            value: columns,
            min: 1,
            max: maxColumns,
            onDecrement: () => onChanged(columns - 1),
            onIncrement: () => onChanged(columns + 1),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _RowBarPreview(columns: columns, maxColumns: maxColumns),
          ),
        ],
      ),
    );
  }
}

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

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.enabled = true,
    this.danger = false,
    this.primary = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool enabled;
  final bool danger;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final color = !enabled
        ? MedColors.text4
        : danger
        ? MedColors.red
        : primary
        ? Colors.white
        : MedColors.blue;
    final bgColor = !enabled
        ? MedColors.surface2
        : danger
        ? MedColors.red.withOpacity(0.06)
        : primary
        ? MedColors.blue
        : MedColors.blueLight;
    final borderColor = !enabled
        ? MedColors.border
        : danger
        ? MedColors.red.withOpacity(0.25)
        : primary
        ? MedColors.blue
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
