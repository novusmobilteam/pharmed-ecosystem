part of 'dashboard_screen.dart';

class UpcomingTreatmentsView extends StatelessWidget {
  const UpcomingTreatmentsView({super.key, required this.treatments, required this.isStale, required this.notifier});

  final DashboardNotifier notifier;
  final List<PrescriptionItem> treatments;
  final bool isStale;

  @override
  Widget build(BuildContext context) {
    final items = treatments.map((t) {
      final palette = AvatarPalette.values[(t.id ?? 0) % AvatarPalette.values.length];
      final initials = (t.patientName ?? 'Bilinmeyen Hasta')
          .split(' ')
          .where((w) => w.isNotEmpty)
          .take(2)
          .map((w) => w[0].toUpperCase())
          .join();

      return TreatmentItem(
        time: t.time?.formattedTime.toString() ?? '',
        patientName: t.patientName ?? 'Bilinmeyen Hasta',
        patientId: '',
        //patientId: t.patientIdLabel,
        avatar: MedAvatar(initials: initials, palette: palette),
        medicineName: t.medicine?.name ?? 'Bilinmeyen İlaç',
        dose: '',
        drawerCode: '',
        priority: TreatmentPriority.normal,
        status: TreatmentStatus.pending,
        //dose: t.medicine?,
        //drawerCode: t.drawerCode,
        //priority: _mapPriority(t.priority),
        //status: _mapStatus(t.status),
        onDetail: () {},
      );
    }).toList();

    return TreatmentList(items: items, isStale: isStale, onNewAssign: () {});
  }
}

// ─────────────────────────────────────────────────────────────────
// TreatmentList
// [SWREQ-UI-006] [HAZ-003] [HAZ-009]
// Yaklaşan tedaviler zaman çizelgesi.
// Acil satırlar kırmızı arka plan ile ayrıştırılır.
// "Yeni Ata" butonu MedConfirmationDialog geçirmek zorundadır.
// Sınıf: Class B
// ─────────────────────────────────────────────────────────────────

class TreatmentItem {
  const TreatmentItem({
    required this.time,
    required this.patientName,
    required this.patientId,
    required this.avatar,
    required this.medicineName,
    required this.dose,
    required this.drawerCode,
    required this.priority,
    required this.status,
    this.onDetail,
  });

  final String time;
  final String patientName;

  /// Format: "#P-0033 · Oda 301"
  final String patientId;

  /// MedAvatar atom — initials + palette dışarıda oluşturulur
  final MedAvatar avatar;
  final String medicineName;
  final String dose;
  final String drawerCode;
  final TreatmentPriority priority;
  final TreatmentStatus status;
  final VoidCallback? onDetail;
}

enum TreatmentFilter { all, pending, urgent }

class TreatmentList extends StatefulWidget {
  const TreatmentList({super.key, required this.items, this.isStale = false, this.onSearch, this.onNewAssign});

  final List<TreatmentItem> items;

  /// [HAZ-007] true → header badge soluklaşır
  final bool isStale;

  final ValueChanged<String>? onSearch;

  /// [HAZ-009] Çağıran taraf MedConfirmationDialog göstermekle yükümlü
  final VoidCallback? onNewAssign;

  @override
  State<TreatmentList> createState() => _TreatmentListState();
}

class _TreatmentListState extends State<TreatmentList> {
  TreatmentFilter _activeFilter = TreatmentFilter.all;

  List<TreatmentItem> get _filteredItems {
    return switch (_activeFilter) {
      TreatmentFilter.all => widget.items,
      TreatmentFilter.pending => widget.items.where((i) => i.status == TreatmentStatus.pending).toList(),
      TreatmentFilter.urgent => widget.items.where((i) => i.priority == TreatmentPriority.urgent).toList(),
    };
  }

  int get _pendingCount => widget.items.where((i) => i.status == TreatmentStatus.pending).length;

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredItems;

    return Container(
      decoration: BoxDecoration(
        color: MedColors.surface,
        border: Border.all(color: MedColors.border),
        borderRadius: MedRadius.lgAll,
        boxShadow: MedShadows.md,
      ),
      child: Column(
        children: [
          _TreatmentHeader(pendingCount: _pendingCount, isStale: widget.isStale),
          _TreatmentToolbar(
            activeFilter: _activeFilter,
            onFilterChanged: (f) => setState(() => _activeFilter = f),
            onSearch: widget.onSearch,
            onNewAssign: widget.onNewAssign,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: filtered.isEmpty
                ? _EmptyState(filter: _activeFilter)
                : Column(
                    children: [
                      for (int i = 0; i < filtered.length; i++)
                        TreatmentRow(
                          time: filtered[i].time,
                          patientName: filtered[i].patientName,
                          patientId: filtered[i].patientId,
                          avatar: filtered[i].avatar,
                          medicineName: filtered[i].medicineName,
                          dose: filtered[i].dose,
                          drawerCode: filtered[i].drawerCode,
                          priority: filtered[i].priority,
                          status: filtered[i].status,
                          isLast: i == filtered.length - 1,
                          onDetail: filtered[i].onDetail,
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _TreatmentHeader extends StatelessWidget {
  const _TreatmentHeader({required this.pendingCount, required this.isStale});

  final int pendingCount;
  final bool isStale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: MedColors.border2)),
      ),
      child: Row(
        children: [
          MedStatusDot(color: MedColors.blue),
          const SizedBox(width: 8),
          Text('YAKLAŞAN TEDAVİLER', style: MedTextStyles.titleSm()),
          const Spacer(),
          AnimatedOpacity(
            opacity: isStale ? 0.45 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: MedBadge(label: '$pendingCount Bekliyor', variant: MedBadgeVariant.amber),
          ),
        ],
      ),
    );
  }
}

class _TreatmentToolbar extends StatelessWidget {
  const _TreatmentToolbar({required this.activeFilter, required this.onFilterChanged, this.onSearch, this.onNewAssign});

  final TreatmentFilter activeFilter;
  final ValueChanged<TreatmentFilter> onFilterChanged;
  final ValueChanged<String>? onSearch;
  final VoidCallback? onNewAssign;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: MedColors.border2)),
      ),
      child: Row(
        children: [
          Expanded(child: _SearchBox(onChanged: onSearch)),
          const SizedBox(width: 7),
          _FilterChip(
            label: 'Tümü',
            isActive: activeFilter == TreatmentFilter.all,
            onTap: () => onFilterChanged(TreatmentFilter.all),
          ),
          const SizedBox(width: 5),
          _FilterChip(
            label: 'Bekleyen',
            isActive: activeFilter == TreatmentFilter.pending,
            onTap: () => onFilterChanged(TreatmentFilter.pending),
          ),
          const SizedBox(width: 5),
          _FilterChip(
            label: 'Acil',
            isActive: activeFilter == TreatmentFilter.urgent,
            onTap: () => onFilterChanged(TreatmentFilter.urgent),
          ),
          const SizedBox(width: 7),
          _NewAssignButton(onTap: onNewAssign),
        ],
      ),
    );
  }
}

class _SearchBox extends StatelessWidget {
  const _SearchBox({this.onChanged});

  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: MedColors.surface2,
        border: Border.all(color: MedColors.border),
        borderRadius: MedRadius.mdAll,
      ),
      child: Row(
        children: [
          Icon(Icons.search, size: 12, color: MedColors.text4),
          const SizedBox(width: 6),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              style: MedTextStyles.bodyMd(color: MedColors.text),
              decoration: InputDecoration(
                hintText: 'Hasta veya ilaç ara...',
                hintStyle: MedTextStyles.bodyMd(color: MedColors.text4),
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.isActive, required this.onTap});

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? MedColors.blueLight : MedColors.surface2,
          border: Border.all(color: isActive ? MedColors.blue : MedColors.border),
          borderRadius: MedRadius.xlAll,
        ),
        child: Text(
          label,
          style: MedTextStyles.bodySm(color: isActive ? MedColors.blue : MedColors.text3, weight: FontWeight.w500),
        ),
      ),
    );
  }
}

class _NewAssignButton extends StatelessWidget {
  const _NewAssignButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: MedColors.blue,
          borderRadius: MedRadius.mdAll,
          boxShadow: const [BoxShadow(color: Color(0x4D1A6FD8), blurRadius: 6, offset: Offset(0, 2))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add, size: 11, color: Colors.white),
            const SizedBox(width: 5),
            Text(
              'Yeni Ata',
              style: MedTextStyles.bodySm(color: Colors.white, weight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.filter});

  final TreatmentFilter filter;

  @override
  Widget build(BuildContext context) {
    final message = switch (filter) {
      TreatmentFilter.all => 'Tedavi kaydı bulunamadı',
      TreatmentFilter.pending => 'Bekleyen tedavi yok',
      TreatmentFilter.urgent => 'Acil tedavi yok',
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: MedLabel(text: message, variant: MedLabelVariant.cardLabel),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// TreatmentRow
// [SWREQ-UI-MOL-004] [HAZ-003]
// Yaklaşan tedaviler listesindeki tek zaman çizelgesi satırı.
// Sınıf: Class B — ilaç adı, doz, öncelik yanlış gösterilirse
//         yanlış tedavi uygulanabilir
// ─────────────────────────────────────────────────────────────────

enum TreatmentPriority { urgent, normal, routine }

enum TreatmentStatus { pending, done, returned }

class TreatmentRow extends StatelessWidget {
  const TreatmentRow({
    super.key,
    required this.time,
    required this.patientName,
    required this.patientId,
    required this.avatar,
    required this.medicineName,
    required this.dose,
    required this.drawerCode,
    required this.priority,
    required this.status,
    this.isLast = false,
    this.onDetail,
  });

  final String time;
  final String patientName;

  /// Örn: "#P-0033 · Oda 301"
  final String patientId;

  final MedAvatar avatar;
  final String medicineName;

  /// Örn: "1×1 — PO (AC)"
  final String dose;

  /// Örn: "A-09", "B-11"
  final String drawerCode;

  final TreatmentPriority priority;
  final TreatmentStatus status;

  /// Son satırda timeline dikey çizgisi gizlenir
  final bool isLast;

  final VoidCallback? onDetail;

  // [HAZ-003] Acil + bekleyen kombinasyonu → kırmızı arka plan
  bool get _isUrgent => priority == TreatmentPriority.urgent && status == TreatmentStatus.pending;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: _isUrgent ? 6 : 0, vertical: 9),
      decoration: _isUrgent ? BoxDecoration(color: const Color(0xFFFFF8F8), borderRadius: MedRadius.mdAll) : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 44,
            child: Text(
              time,
              style: MedTextStyles.monoMd(
                color: _isUrgent ? MedColors.red : MedColors.text2,
                weight: _isUrgent ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          _TimelineLine(priority: priority, status: status, isLast: isLast),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    avatar,
                    const SizedBox(width: 7),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MedLabel(
                            text: patientName,
                            variant: MedLabelVariant.monoValue,
                            overflow: TextOverflow.ellipsis,
                          ),
                          MedLabel(text: patientId, variant: MedLabelVariant.monoDetail),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Flexible(
                      child: MedLabel(
                        text: medicineName,
                        variant: MedLabelVariant.monoValue,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    MedLabel(text: dose, variant: MedLabelVariant.monoDetail),
                    const SizedBox(width: 6),
                    _DrawerTag(code: drawerCode, isWarning: _isUrgent),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Row(
            children: [
              _PriorityBadge(priority: priority),
              const SizedBox(width: 4),
              _StatusBadge(status: status),
              const SizedBox(width: 4),
              _DetailButton(onTap: onDetail),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimelineLine extends StatelessWidget {
  const _TimelineLine({required this.priority, required this.status, required this.isLast});

  final TreatmentPriority priority;
  final TreatmentStatus status;
  final bool isLast;

  Color get _circleColor {
    if (status == TreatmentStatus.done) return MedColors.green;
    return switch (priority) {
      TreatmentPriority.urgent => MedColors.red,
      TreatmentPriority.normal => MedColors.blue,
      TreatmentPriority.routine => MedColors.text3,
    };
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 10,
      height: 48,
      child: Column(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _circleColor, width: 2),
              color: status == TreatmentStatus.done ? _circleColor.withAlpha(38) : MedColors.surface,
            ),
          ),
          if (!isLast)
            Expanded(
              child: Center(child: Container(width: 1.5, color: MedColors.border2)),
            ),
        ],
      ),
    );
  }
}

class _DrawerTag extends StatelessWidget {
  const _DrawerTag({required this.code, this.isWarning = false});

  final String code;
  final bool isWarning;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: isWarning ? MedColors.redLight : MedColors.blueLight,
        borderRadius: const BorderRadius.all(Radius.circular(4)),
      ),
      child: Text(code, style: MedTextStyles.monoXs(color: isWarning ? MedColors.red : MedColors.blue)),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge({required this.priority});

  final TreatmentPriority priority;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label) = switch (priority) {
      TreatmentPriority.urgent => (MedColors.redLight, MedColors.red, 'Acil'),
      TreatmentPriority.normal => (MedColors.blueLight, MedColors.blue, 'Normal'),
      TreatmentPriority.routine => (MedColors.greenLight, MedColors.green, 'Rutin'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: MedRadius.xlAll),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: MedFonts.mono,
          fontSize: 9,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
          color: fg,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final TreatmentStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label, border) = switch (status) {
      TreatmentStatus.pending => (MedColors.amberLight, MedColors.amber, 'Bekliyor', null),
      TreatmentStatus.done => (MedColors.greenLight, MedColors.green, 'Dağıtıldı', null),
      TreatmentStatus.returned => (MedColors.surface3, MedColors.text3, 'İade', MedColors.border2),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: MedRadius.xlAll,
        border: border != null ? Border.all(color: border) : null,
      ),
      child: Text(label, style: MedTextStyles.monoXs(color: fg)),
    );
  }
}

class _DetailButton extends StatelessWidget {
  const _DetailButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: MedColors.surface,
          border: Border.all(color: MedColors.border2),
          borderRadius: const BorderRadius.all(Radius.circular(6)),
        ),
        alignment: Alignment.center,
        child: Icon(Icons.visibility_outlined, size: 11, color: MedColors.text3),
      ),
    );
  }
}
