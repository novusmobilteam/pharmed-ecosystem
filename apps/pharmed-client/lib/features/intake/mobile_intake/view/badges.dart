part of 'mobile_intake_dialog.dart';

/// Status badge — state + drawerStage kombinasyonunu kullanıcıya tek bir
/// "şu an ne oluyor" etiketi olarak gösterir. Tüm pattern match buraya
/// gömülüdür; başka widget'a yansımaz.
class _StatusBadge extends ConsumerWidget {
  const _StatusBadge();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mobileIntakeNotifierProvider);
    final drawerStage = ref.watch(mobileDrawerSessionProvider).stage;
    final ready = state.readyContext;
    if (ready == null) return const SizedBox.shrink();

    final info = _resolve(state, drawerStage, ready);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: info.bg, borderRadius: MedRadius.mdAll),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(info.icon, size: 14, color: info.fg),
          const SizedBox(width: 6),
          Text(
            info.label,
            style: MedTextStyles.bodySm(color: info.fg, weight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  /// State + drawerStage → badge görseli.
  ///
  /// Sıra önemli: özel state'ler (Saving / Error / Rollback / FatalError)
  /// önce yakalanır; sonra Ready ailesi için drawerStage bazlı dallanma yapılır.
  _BadgeInfo _resolve(MobileIntakeState state, MobileDrawerStage stage, MobileIntakeReady ready) {
    // ── Özel state'ler ────────────────────────────────────────────────
    if (state is MobileIntakeFatalError) {
      return _BadgeInfo(
        'Kritik Hata',
        PhosphorIcons.warningOctagon(PhosphorIconsStyle.bold),
        MedColors.redLight,
        MedColors.red,
      );
    }

    if (state is MobileIntakeSaving) {
      return _BadgeInfo(
        'Kaydediliyor',
        PhosphorIcons.circleNotch(PhosphorIconsStyle.bold),
        MedColors.blueLight,
        MedColors.blue,
      );
    }

    if (state is MobileIntakeError) {
      return _BadgeInfo(
        'Hata',
        PhosphorIcons.warningCircle(PhosphorIconsStyle.bold),
        MedColors.redLight,
        MedColors.red,
      );
    }

    if (state is MobileIntakeRollbackInProgress) {
      // Rollback drawer aşamasına göre kullanıcıya farklı sinyal verir.
      if (stage is MobileDrawerOpening) {
        return _BadgeInfo(
          'Çekmece açılıyor',
          PhosphorIcons.circleNotch(PhosphorIconsStyle.bold),
          MedColors.amberLight,
          MedColors.amber,
        );
      }
      if (stage is MobileDrawerOpened) {
        return _BadgeInfo(
          'İlaçları çıkartın',
          PhosphorIcons.handPalm(PhosphorIconsStyle.bold),
          MedColors.amberLight,
          MedColors.amber,
        );
      }
      if (stage is MobileDrawerClosed && ready.rfidReadEpcs.isEmpty) {
        // Sonlanma anı — RollbackCompleted'e geçişten hemen önceki frame
        return _BadgeInfo(
          'İşlem sonlandırılıyor',
          PhosphorIcons.clock(PhosphorIconsStyle.bold),
          MedColors.amberLight,
          MedColors.amber,
        );
      }
      return _BadgeInfo(
        'İlaçlar hâlâ kabinde',
        PhosphorIcons.warning(PhosphorIconsStyle.bold),
        MedColors.amberLight,
        MedColors.amber,
      );
    }

    // ── Ready ailesi — drawerStage'e göre ─────────────────────────────
    if (stage is MobileDrawerOpening) {
      return _BadgeInfo(
        'Çekmece açılıyor',
        PhosphorIcons.circleNotch(PhosphorIconsStyle.bold),
        MedColors.blueLight,
        MedColors.blue,
      );
    }

    if (stage is MobileDrawerClosed) {
      if (ready.canComplete) {
        return _BadgeInfo(
          'Çekmece kapatıldı',
          PhosphorIcons.checkCircle(PhosphorIconsStyle.bold),
          MedColors.greenLight,
          MedColors.green,
        );
      }
      return _BadgeInfo(
        'Eksik / Tutarsız',
        PhosphorIcons.warning(PhosphorIconsStyle.bold),
        MedColors.amberLight,
        MedColors.amber,
      );
    }

    // Drawer Opened
    if (!ready.baselineCompleted) {
      return _BadgeInfo(
        'Tarama yapılıyor',
        PhosphorIcons.tag(PhosphorIconsStyle.bold),
        MedColors.blueLight,
        MedColors.blue,
      );
    }
    return _BadgeInfo(
      'Çekmece açık',
      PhosphorIcons.lockOpen(PhosphorIconsStyle.bold),
      MedColors.greenLight,
      MedColors.green,
    );
  }
}

/// Status badge görseli — pattern match dönüş tipi.
class _BadgeInfo {
  const _BadgeInfo(this.label, this.icon, this.bg, this.fg);
  final String label;
  final IconData icon;
  final Color bg;
  final Color fg;
}

// ─────────────────────────────────────────────────────────────────────────────
// Stats — 3 kolon (Seçili / Yerleştirilen / Plan Dışı)
// ─────────────────────────────────────────────────────────────────────────────

class _StatsRow extends ConsumerWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mobileIntakeNotifierProvider);
    final ready = state.readyContext;
    if (ready == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      color: MedColors.bg,
      child: Row(
        children: [
          Expanded(
            child: _StatCell(label: 'Seçili', value: '${ready.selectedItemIds.length} ilaç'),
          ),
          Expanded(
            child: _StatCell(label: 'Kabinde Okunan', value: '${ready.totalReadCount} etiket'),
          ),
          Expanded(
            child: _StatCell(
              label: 'Plan Dışı',
              value: '${ready.unplannedCount}',
              valueColor: ready.unplannedCount > 0 ? MedColors.red : null,
              icon: ready.unplannedCount > 0 ? PhosphorIcons.warning(PhosphorIconsStyle.bold) : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.label, required this.value, this.valueColor, this.icon});

  final String label;
  final String value;
  final Color? valueColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: MedTextStyles.monoXs(color: MedColors.text3)),
        const SizedBox(height: 4),
        Row(
          children: [
            if (icon != null) ...[Icon(icon, size: 18, color: valueColor ?? MedColors.text), const SizedBox(width: 6)],
            Text(value, style: MedTextStyles.titleSm(color: valueColor ?? MedColors.text)),
          ],
        ),
      ],
    );
  }
}
