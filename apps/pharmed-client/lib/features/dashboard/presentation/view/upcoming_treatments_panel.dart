part of 'dashboard_screen.dart';

/// Yaklaşan tedaviler — ekranın baskın paneli.
///
/// İlk sıradaki tedavi accent şeritle vurgulanır; saat ve kalan süre
/// monospace ile sabit genişlikte hizalanır.
class UpcomingTreatmentsPanel extends StatelessWidget {
  const UpcomingTreatmentsPanel({super.key, required this.treatments, required this.isLoggedIn, this.onTap});

  final List<PrescriptionItem> treatments;
  final bool isLoggedIn;
  final void Function(PrescriptionItem item)? onTap;

  @override
  Widget build(BuildContext context) {
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
            icon: PhosphorIcons.calendarDots(),
            title: context.l10n.dashboard_upcomingTreatmentsPanelTitle,
            trailing: treatments.isEmpty
                ? null
                : _CountBadge(
                    label: context.l10n.dashboard_upcomingTreatmentsCountBadge(treatments.length),
                    color: MedColors.blue,
                    background: MedColors.blueLight,
                  ),
          ),

          if (treatments.isEmpty)
            _PanelEmpty(icon: PhosphorIcons.checkCircle(), label: context.l10n.dashboard_upcomingTreatmentsEmptyTitle)
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: treatments.length,
              separatorBuilder: (_, __) => const Divider(height: 1, thickness: 1, color: MedColors.border),
              itemBuilder: (context, index) => _TreatmentRow(
                item: treatments[index],
                isNext: index == 0,
                enabled: isLoggedIn,
                onTap: onTap == null ? null : () => onTap!(treatments[index]),
              ),
            ),
        ],
      ),
    );
  }
}

class _TreatmentRow extends StatelessWidget {
  const _TreatmentRow({required this.item, required this.isNext, required this.enabled, this.onTap});

  final PrescriptionItem item;
  final bool isNext;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final time = item.time;
    final isOverdue = time != null && time.isBefore(DateTime.now());

    final accent = isOverdue
        ? MedColors.red
        : isNext
        ? MedColors.blue
        : MedColors.border2;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: Container(
          constraints: const BoxConstraints(minHeight: MedSpacing.touchTarget),
          padding: const EdgeInsets.symmetric(horizontal: MedSpacing.xl, vertical: MedSpacing.lg),
          child: Row(
            children: [
              // Saat + kalan süre — sabit genişlik, hizalama bozulmasın
              SizedBox(
                width: 60,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatTime(time),
                      style: MedTextStyles.monoMd(
                        color: isOverdue ? MedColors.red : MedColors.text,
                        weight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatRemaining(context, time),
                      style: MedTextStyles.monoXs(color: isOverdue ? MedColors.red : MedColors.text4),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: MedSpacing.lg),

              // Accent şerit — sıradaki tedaviyi işaretler
              Container(
                width: 3,
                height: 36,
                decoration: BoxDecoration(color: accent, borderRadius: MedRadius.smAll),
              ),

              const SizedBox(width: MedSpacing.lg),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.medicine?.name ?? context.l10n.common_unknownFallback,
                      style: MedTextStyles.bodyMd(weight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _subtitle(context),
                      style: MedTextStyles.bodySm(color: MedColors.text3),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              if (enabled && onTap != null) ...[
                const SizedBox(width: MedSpacing.md),
                Icon(PhosphorIcons.caretRight(), size: 16, color: MedColors.text4),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _subtitle(BuildContext context) {
    final name = item.patientName ?? context.l10n.common_unknownFallback;
    final protocol = item.protocolNo;
    return protocol == null ? name : '$name · $protocol';
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '--:--';
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// Kalan süre — gecikmişse negatif göstermek yerine "gecikti" der.
  String _formatRemaining(BuildContext context, DateTime? time) {
    if (time == null) return '—';

    final diff = time.difference(DateTime.now());
    if (diff.isNegative) return context.l10n.dashboard_upcomingTreatmentsOverdueStatus;

    final minutes = diff.inMinutes;
    if (minutes < 60) return context.l10n.common_minutesRemainingStatus(minutes);

    final hours = diff.inHours;
    if (hours < 24) return context.l10n.common_hoursRemainingStatus(hours);

    return context.l10n.common_daysRemainingStatus(diff.inDays);
  }
}
