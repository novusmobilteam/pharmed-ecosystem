part of 'dashboard_screen.dart';

enum UpcomingTreatmentUrgency { delayed, dueSoon, upcoming }

extension UpcomingTreatmentUrgencyX on UpcomingTreatment {
  /// firstTreatmentTime null ise ya da 60dk'dan sonraysa panelde hiç
  /// gösterilmez → null döner.
  UpcomingTreatmentUrgency? get urgency {
    final time = firstTreatmentTime;
    if (time == null) return null;

    if (isDelayed) return UpcomingTreatmentUrgency.delayed;

    final minutesUntil = time.difference(DateTime.now()).inMinutes;
    if (minutesUntil <= 20) return UpcomingTreatmentUrgency.dueSoon;
    if (minutesUntil <= 60) return UpcomingTreatmentUrgency.upcoming;
    return null;
  }
}

class UpcomingTreatmentGroups {
  const UpcomingTreatmentGroups({required this.delayed, required this.dueSoon, required this.upcoming});

  final List<UpcomingTreatment> delayed;
  final List<UpcomingTreatment> dueSoon;
  final List<UpcomingTreatment> upcoming;

  bool get isEmpty => delayed.isEmpty && dueSoon.isEmpty && upcoming.isEmpty;

  factory UpcomingTreatmentGroups.from(List<UpcomingTreatment>? items) {
    final delayed = <UpcomingTreatment>[];
    final dueSoon = <UpcomingTreatment>[];
    final upcoming = <UpcomingTreatment>[];

    if (items == null) {
      return const UpcomingTreatmentGroups(delayed: [], dueSoon: [], upcoming: []);
    }

    for (final item in items) {
      switch (item.urgency) {
        case UpcomingTreatmentUrgency.delayed:
          delayed.add(item);
        case UpcomingTreatmentUrgency.dueSoon:
          dueSoon.add(item);
        case UpcomingTreatmentUrgency.upcoming:
          upcoming.add(item);
        case null:
          break; // 60dk sonrası — bu panelin kapsamı dışında
      }
    }

    int byTime(UpcomingTreatment a, UpcomingTreatment b) =>
        (a.firstTreatmentTime ?? DateTime.now()).compareTo(b.firstTreatmentTime ?? DateTime.now());

    return UpcomingTreatmentGroups(
      delayed: delayed..sort(byTime),
      dueSoon: dueSoon..sort(byTime),
      upcoming: upcoming..sort(byTime),
    );
  }
}

class UpcomingTreatmentPanel extends StatelessWidget {
  const UpcomingTreatmentPanel({super.key, required this.section});

  final DashboardSection<List<UpcomingTreatment>?> section;

  @override
  Widget build(BuildContext context) {
    final groups = UpcomingTreatmentGroups.from(section.data);
    final visibleItems = [...groups.delayed, ...groups.dueSoon, ...groups.upcoming];
    final patientCount = visibleItems.length;
    final total = visibleItems.fold<int>(0, (sum, item) => sum + (item.treatmentCount ?? 0));

    return Container(
      decoration: BoxDecoration(
        borderRadius: MedRadius.lgAll,
        color: MedColors.surface,
        boxShadow: MedShadows.md,
        border: Border.all(color: MedColors.border),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: MedSpacing.insetXl.left * 1.5, vertical: MedSpacing.insetXl.top),
            decoration: BoxDecoration(
              color: MedColors.surface2,
              borderRadius: BorderRadius.only(topLeft: MedRadius.lg, topRight: MedRadius.lg),
            ),
            child: Row(
              children: [
                Column(
                  spacing: 12.0,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      spacing: 12.0,
                      children: [
                        Text(context.l10n.dashboard_upcomingTreatmentsPanelTitle, style: MedTextStyles.titleSm()),
                        if (section.savedAt != null)
                          Text(
                            '(${context.l10n.staleBanner_lastUpdatedLabel(section.savedAt?.formattedTime ?? '')})',
                            style: MedTextStyles.monoSm(),
                          ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${patientCount.toString()} ${context.l10n.drugActivity_column_patient}',
                          style: MedTextStyles.titleLg(),
                        ),
                        Text(' / ${context.l10n.rxGroup_itemCountBadge(total)}', style: MedTextStyles.monoMd()),
                      ],
                    ),
                  ],
                ),
                Spacer(),
                Row(
                  spacing: 10.0,
                  children: [
                    if (groups.delayed.isNotEmpty)
                      _UrgencyStatCard(
                        count: groups.delayed.length,
                        label: context.l10n.dashboard_upcomingTreatmentsDelayedTitle.toUpperCase(),
                        color: MedColors.red,
                        background: MedColors.redLight,
                        blinking: true,
                      ),
                    if (groups.dueSoon.isNotEmpty)
                      _UrgencyStatCard(
                        count: groups.dueSoon.length,
                        label: context.l10n.dashboard_upcomingTreatmentsDueSoonTitle.toUpperCase(),
                        color: MedColors.amber,
                        background: MedColors.amberLight,
                        blinking: true,
                      ),
                    if (groups.upcoming.isNotEmpty)
                      _UrgencyStatCard(
                        count: groups.upcoming.length,
                        label: context.l10n.dashboard_upcomingTreatmentsUpcomingTitle.toUpperCase(),
                        color: MedColors.text,
                        background: MedColors.surface3,
                      ),
                  ],
                ),
              ],
            ),
          ),

          if (groups.isEmpty)
            Center(child: const EmptyStateWidget(variant: EmptyStateVariant.noData))
          else
            Expanded(
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(
                  horizontal: MedSpacing.insetXl.left * 1.5,
                  vertical: MedSpacing.insetXl.top * 2,
                ),
                children: [
                  if (groups.delayed.isNotEmpty)
                    _UrgencySection(
                      title: context.l10n.dashboard_upcomingTreatmentsDelayedTitle,
                      color: MedColors.red,
                      background: MedColors.redLight,
                      items: groups.delayed,
                    ),
                  if (groups.dueSoon.isNotEmpty)
                    _UrgencySection(
                      title: context.l10n.dashboard_upcomingTreatmentsDueSoonTitle,
                      color: MedColors.amber,
                      background: MedColors.amberLight,
                      items: groups.dueSoon,
                    ),
                  if (groups.upcoming.isNotEmpty)
                    _UrgencySection(
                      title: context.l10n.dashboard_upcomingTreatmentsUpcomingTitle,
                      color: MedColors.text3,
                      background: MedColors.surface2,
                      items: groups.upcoming,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _UrgencySection extends StatelessWidget {
  const _UrgencySection({required this.title, required this.color, required this.items, required this.background});

  final String title;
  final Color color;
  final Color background;
  final List<UpcomingTreatment> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 6.0,
              children: [
                Container(
                  width: 8,
                  height: 30,
                  decoration: BoxDecoration(color: color, borderRadius: MedRadius.smAll),
                ),
                Text(title, style: MedTextStyles.titleMd(color: color)),
                Expanded(child: Container(height: 1, color: MedColors.border)),
                SizedBox(width: 8.0),
                Text('${items.length} ${context.l10n.drugActivity_column_patient}', style: MedTextStyles.monoMd()),
              ],
            ),
          ),
          ...items.map((item) => _TreatmentPatientTile(item: item, color: color, background: background)),
        ],
      ),
    );
  }
}

class _TreatmentPatientTile extends StatefulWidget {
  const _TreatmentPatientTile({required this.item, required this.color, required this.background});

  final UpcomingTreatment item;
  final Color color;
  final Color background;

  @override
  State<_TreatmentPatientTile> createState() => _TreatmentPatientTileState();
}

class _TreatmentPatientTileState extends State<_TreatmentPatientTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final color = widget.color;
    final treatments = item.details ?? [];
    final hasTreatments = treatments.isNotEmpty;
    final desc = '${item.serviceName} / ${item.roomName} - ${item.bedName}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: MedRadius.lgAll,
        color: MedColors.surface,
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Column(
        children: [
          Container(
            padding: MedSpacing.insetXl * 1.5,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: MedRadius.lg,
                topRight: MedRadius.lg,
                bottomLeft: !_expanded ? MedRadius.lg : Radius.zero,
                bottomRight: !_expanded ? MedRadius.lg : Radius.zero,
              ),
              color: widget.background,
            ),

            child: Row(
              spacing: 12.0,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(item.firstTreatmentTime.formattedTime.toString(), style: MedTextStyles.titleLg(color: color)),
                    Text(_relativeTimeLabel(context, item), style: MedTextStyles.bodyMd(color: color)),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: MedSpacing.md),
                  height: 34,
                  width: 1,
                  color: color.withAlpha(120),
                ),
                Column(
                  spacing: 4.0,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.patientFullName ?? '', style: MedTextStyles.titleMd()),
                    Text(desc, style: MedTextStyles.monoMd(color: MedColors.text3)),
                  ],
                ),
                const Spacer(),

                MedChip(
                  label: context.l10n.rxGroup_itemCountBadge(treatments.length),
                  shape: MedChipShape.pill,
                  background: MedColors.surface,
                  foreground: color,
                  border: color,
                ),
                if (hasTreatments)
                  IconButton(
                    onPressed: () => setState(() => _expanded = !_expanded),
                    icon: Icon(_expanded ? PhosphorIcons.caretUp() : PhosphorIcons.caretDown(), color: color),
                  ),
              ],
            ),
          ),
          if (hasTreatments)
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 200),
              sizeCurve: Curves.easeInOut,
              crossFadeState: _expanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
              firstChild: Padding(
                padding: EdgeInsets.symmetric(horizontal: MedSpacing.insetXl.left * 1.5, vertical: 8.0),
                child: Column(
                  children: List.generate(treatments.length, (index) {
                    final treatment = treatments.elementAt(index);
                    final dose =
                        '${treatment.dosePiece.formatFractional} ${treatment.medicine?.operationUnitLocalized(context)}';
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Row(
                        children: [
                          SizedBox(width: 70, child: Text(treatment.time.formattedTime, style: MedTextStyles.monoMd())),
                          Expanded(
                            child: Text(
                              treatment.materialName ?? '-',
                              style: MedTextStyles.bodyLg().copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                          Text(dose, style: MedTextStyles.bodyMd().copyWith(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    );
                  }),
                ),
              ),
              secondChild: const SizedBox(width: double.infinity),
            ),
        ],
      ),
    );
  }

  String _relativeTimeLabel(BuildContext context, UpcomingTreatment item) {
    if (item.isDelayed) return item.delayTime.delayLabel(context);
    final minutesUntil = -item.delayTime; // delayTime negatif → kalan süre pozitif
    return context.l10n.dashboard_upcomingTreatmentsDueInMinutesLabel(minutesUntil);
  }
}

class _UrgencyStatCard extends StatelessWidget {
  const _UrgencyStatCard({
    required this.count,
    required this.label,
    required this.color,
    required this.background,
    this.blinking = false,
  });

  final int count;
  final String label;
  final Color color;
  final Color background;
  final bool blinking;

  @override
  Widget build(BuildContext context) {
    return _BlinkingWrapper(
      enabled: blinking && count > 0,
      child: Container(
        width: 150,
        constraints: const BoxConstraints(minWidth: 104),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(color: background, borderRadius: MedRadius.mdAll),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 2.0,
          children: [
            Text(
              count.toString(),
              style: MedTextStyles.titleLg(color: color).copyWith(fontWeight: FontWeight.w800, fontSize: 26),
            ),
            Text(
              label,
              style: MedTextStyles.monoSm(color: color).copyWith(letterSpacing: 0.4),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _BlinkingWrapper extends StatefulWidget {
  const _BlinkingWrapper({required this.enabled, required this.child});

  final bool enabled;
  final Widget child;

  @override
  State<_BlinkingWrapper> createState() => _BlinkingWrapperState();
}

class _BlinkingWrapperState extends State<_BlinkingWrapper> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  @override
  void didUpdateWidget(covariant _BlinkingWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled == oldWidget.enabled) return;

    if (widget.enabled) {
      _controller.repeat(reverse: true);
    } else {
      _controller
        ..stop()
        ..value = 0.0;
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.enabled) _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;
    return FadeTransition(
      opacity: Tween<double>(
        begin: 1.0,
        end: 0.35,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
      child: widget.child,
    );
  }
}
