part of 'dashboard_screen.dart';

/// Son ilaç hareketleri akışı.
///
/// Renk, ikon ve etiket [PrescriptionMovementType] extension'larından gelir —
/// panelde ayrı bir eşleme tutulmaz.
class DrugActivityPanel extends StatelessWidget {
  const DrugActivityPanel({super.key, required this.activities, this.maxItems = 5, this.onSeeAll});

  final List<PrescriptionItemMovement> activities;

  /// Panelde gösterilecek azami kayıt — fazlası 'drug-activity' rotasında.
  final int maxItems;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    final visible = activities.take(maxItems).toList();

    return Container(
      decoration: BoxDecoration(
        color: MedColors.surface,
        borderRadius: MedRadius.lgAll,
        border: Border.all(color: MedColors.border),
        boxShadow: MedShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PanelHeader(
            icon: PhosphorIcons.pulse(),
            title: context.l10n.dashboard_drugActivityPanelTitle,
            trailing: (onSeeAll != null && activities.length > maxItems) ? _SeeAllButton(onTap: onSeeAll!) : null,
          ),

          if (visible.isEmpty)
            _PanelEmpty(icon: PhosphorIcons.tray(), label: context.l10n.dashboard_drugActivityEmptyTitle)
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: visible.length,
              separatorBuilder: (_, __) => const Divider(height: 1, thickness: 1, color: MedColors.border),
              itemBuilder: (context, index) => _ActivityRow(movement: visible[index]),
            ),
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.movement});

  final PrescriptionItemMovement movement;

  @override
  Widget build(BuildContext context) {
    final type = movement.type;
    final item = movement.prescriptionItem;

    final medicineName = item?.medicine?.name ?? context.l10n.common_unknownFallback;
    final patientName = item?.prescription?.hospitalization?.patient?.fullName;

    return Container(
      constraints: const BoxConstraints(minHeight: MedSpacing.touchTarget),
      padding: const EdgeInsets.symmetric(horizontal: MedSpacing.xl, vertical: MedSpacing.lg),
      child: Row(
        children: [
          // Tip ikonu — renk enum'dan gelir
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: type.backgroundColor, borderRadius: MedRadius.mdAll),
            child: Icon(type.icon, size: 16, color: type.foregroundColor),
          ),

          const SizedBox(width: MedSpacing.lg),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        medicineName,
                        style: MedTextStyles.bodySm(color: MedColors.text, weight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (movement.quantity != null) ...[
                      const SizedBox(width: MedSpacing.sm),
                      Text(movement.quantity.formatFractional, style: MedTextStyles.monoSm(color: MedColors.text3)),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  _metaLine(context, patientName),
                  style: MedTextStyles.bodySm(color: MedColors.text4),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(width: MedSpacing.md),

          // Hareket etiketi + göreli zaman — sağa hizalı
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                type.actionLabel,
                style: MedTextStyles.bodySm(color: type.foregroundColor, weight: FontWeight.w500),
              ),
              const SizedBox(height: 2),
              Text(_relativeTime(context, movement.createdAt), style: MedTextStyles.monoXs(color: MedColors.text4)),
            ],
          ),
        ],
      ),
    );
  }

  /// Hasta · İşlemi yapan. Hasta yoksa (dolum/boşaltma) sadece kullanıcı.
  String _metaLine(BuildContext context, String? patientName) {
    final actor = movement.performedBy?.fullName;

    if (patientName != null && actor != null) return '$patientName · $actor';
    if (patientName != null) return patientName;
    if (actor != null) return '${movement.type.actorLabel}: $actor';
    return '—';
  }

  String _relativeTime(BuildContext context, DateTime? time) {
    if (time == null) return '—';

    final diff = DateTime.now().difference(time);

    // Saat farkı/senkron kayması → negatif; "az önce" olarak göster
    if (diff.isNegative || diff.inMinutes < 1) {
      return context.l10n.common_justNowStatus;
    }

    if (diff.inMinutes < 60) {
      return context.l10n.common_minutesAgoStatus(diff.inMinutes);
    }
    if (diff.inHours < 24) {
      return context.l10n.common_hoursAgoStatus(diff.inHours);
    }
    return context.l10n.common_daysAgoStatus(diff.inDays);
  }
}

class _SeeAllButton extends StatelessWidget {
  const _SeeAllButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: MedRadius.smAll,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: MedSpacing.md, vertical: MedSpacing.xs),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.l10n.common_seeAllButton,
                style: MedTextStyles.bodySm(color: MedColors.blue, weight: FontWeight.w500),
              ),
              const SizedBox(width: MedSpacing.xs),
              Icon(PhosphorIcons.caretRight(), size: 12, color: MedColors.blue),
            ],
          ),
        ),
      ),
    );
  }
}
