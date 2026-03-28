import 'package:flutter/material.dart';
import '../atoms/atoms.dart';
import '../molecules/molecules.dart';

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
          // ── Header ─────────────────────────────────────
          _TreatmentHeader(pendingCount: _pendingCount, isStale: widget.isStale),

          // ── Toolbar: arama + filtre + yeni ata ─────────
          _TreatmentToolbar(
            activeFilter: _activeFilter,
            onFilterChanged: (f) => setState(() => _activeFilter = f),
            onSearch: widget.onSearch,
            // [HAZ-009] onNewAssign doğrudan tetiklenmez,
            // çağıran taraf dialog göstermeli
            onNewAssign: widget.onNewAssign,
          ),

          // ── Zaman çizelgesi ────────────────────────────
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

// ── Header ────────────────────────────────────────────────────────

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
          StatusDot(color: MedColors.blue),
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

// ── Toolbar ───────────────────────────────────────────────────────

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
          // Arama kutusu
          Expanded(child: _SearchBox(onChanged: onSearch)),
          const SizedBox(width: 7),

          // Filtre chip'leri
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

          // Yeni Ata butonu
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
