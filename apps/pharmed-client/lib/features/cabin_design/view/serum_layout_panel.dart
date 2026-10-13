part of 'cabin_design_dialog.dart';

/// Serum kabininin 3 rafının yapılandırma paneli.
///
/// Durum notifier'dadır ([CabinDesignNotifier.serumShelvesFor]); değişiklikler
/// bekleyen değişiklik olarak tutulur ve alt bardaki "Kaydet" ile gönderilir.
class _SerumManualLayoutPanel extends StatelessWidget {
  const _SerumManualLayoutPanel({required this.group, required this.notifier});

  final DrawerGroup group;
  final CabinDesignNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final slotId = group.slot.id;
    if (slotId == null) return const SizedBox.shrink();

    final shelves = notifier.serumShelvesFor(slotId);
    final errorText = notifier.inlineError;
    final loadError = notifier.serumLoadError;
    final isLoading = notifier.isLoadingSerumLayout;
    final enabled = notifier.canEditSerumLayout(slotId);

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
            if (errorText != null) ...[
              const SizedBox(height: MedSpacing.md),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.error_outline_rounded, size: 14, color: MedColors.red),
                  const SizedBox(width: 6),
                  Expanded(child: Text(errorText, style: MedTextStyles.bodySm(color: MedColors.red))),
                ],
              ),
            ],
            const SizedBox(height: MedSpacing.xl2),
            if (isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: MedSpacing.xl3),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (loadError != null)
              _SerumLoadErrorBox(message: loadError, onRetry: () => notifier.loadSerumLayout(slotId))
            else
              for (final shelf in shelves)
                ExpandableIndexedConfigCard(
                  index: shelf.orderNo - 1,
                  title: context.l10n.cabinDesign_serum_shelfCardTitle(shelf.orderNo),
                  summary: context.l10n.cabinDesign_serum_shelfCardSummary(
                    shelf.usedArea,
                    SerumShelfLayout.totalArea,
                    shelf.trays.length,
                  ),
                  initiallyExpanded: shelf.orderNo == 1,
                  body: _SerumShelfBody(
                    shelf: shelf,
                    enabled: enabled,
                    onChanged: (updated) => notifier.updateSerumShelf(slotId, updated),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _SerumShelfBody extends StatelessWidget {
  const _SerumShelfBody({required this.shelf, required this.enabled, required this.onChanged});

  final SerumShelfLayout shelf;
  final bool enabled;
  final ValueChanged<SerumShelfLayout> onChanged;

  void _addTray(SerumTraySize size) {
    if (!enabled || !shelf.canAdd(size)) return;
    onChanged(shelf.copyWith(trays: [...shelf.trays, SerumTray(size: size)]));
  }

  void _removeTrayAt(int index) {
    if (!enabled) return;
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
              onChanged: enabled
                  ? (v) => onChanged(
                      shelf.copyWith(lockType: v ? SerumShelfLockType.locked : SerumShelfLockType.unlocked),
                    )
                  : null,
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
              onTap: enabled && shelf.canAdd(SerumTraySize.small) ? () => _addTray(SerumTraySize.small) : null,
            ),
            _ActionChip(
              icon: Icons.add_rounded,
              label: context.l10n.cabinDesign_serum_addMediumButton,
              onTap: enabled && shelf.canAdd(SerumTraySize.medium) ? () => _addTray(SerumTraySize.medium) : null,
            ),
            _ActionChip(
              icon: Icons.add_rounded,
              label: context.l10n.cabinDesign_serum_addLargeButton,
              onTap: enabled && shelf.canAdd(SerumTraySize.large) ? () => _addTray(SerumTraySize.large) : null,
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
                    context.l10n.cabinDesign_serum_areaUsedLabel(shelf.usedArea, SerumShelfLayout.totalArea),
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
                        flex: tray.size.areaSize,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 3),
                          child: _TrayBlock(size: tray.size),
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
                        context.l10n.cabinDesign_serum_trayListItemLabel(i + 1, shelf.trays[i].size.label(context)),
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

/// Kayıtlı yerleşim okunamadı — düzenleme kapalı, tekrar denenebilir.
class _SerumLoadErrorBox extends StatelessWidget {
  const _SerumLoadErrorBox({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: MedSpacing.insetMd,
      decoration: BoxDecoration(
        color: MedColors.redLight,
        border: Border.all(color: MedColors.border2),
        borderRadius: MedRadius.mdAll,
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, size: 16, color: MedColors.red),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: MedTextStyles.bodySm(color: MedColors.text2))),
          const SizedBox(width: 8),
          _ActionChip(icon: Icons.refresh_rounded, label: context.l10n.common_retryButton, onTap: onRetry),
        ],
      ),
    );
  }
}

class _TrayBlock extends StatelessWidget {
  const _TrayBlock({required this.size});
  final SerumTraySize size;

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
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final onChanged = this.onChanged;
    return GestureDetector(
      onTap: onChanged == null ? null : () => onChanged(!value),
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
