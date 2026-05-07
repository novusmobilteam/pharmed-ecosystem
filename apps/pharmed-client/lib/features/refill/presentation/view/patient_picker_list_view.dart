part of 'mobile_refill_panel.dart';

class _PatientPickerListView extends StatefulWidget {
  const _PatientPickerListView({required this.assignments, required this.onSelected});

  final List<BedAssignment> assignments;
  final ValueChanged<BedAssignment> onSelected;

  @override
  State<_PatientPickerListView> createState() => _PatientPickerListViewState();
}

class _PatientPickerListViewState extends State<_PatientPickerListView> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Filtre: hasta adı + oda + yatak + servis (case-insensitive contains).
  List<BedAssignment> get _filtered {
    if (_query.trim().isEmpty) return widget.assignments;
    final q = _query.trim().toLowerCase();

    return widget.assignments.where((a) {
      final patient = a.hospitalization?.patient;
      final room = a.bed?.room;
      final serviceName = a.hospitalization?.physicalService?.name;

      final haystack = [
        patient?.fullName,
        patient?.name,
        patient?.surname,
        room?.name,
        a.bed?.name,
        serviceName,
      ].whereType<String>().join(' ').toLowerCase();

      return haystack.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.assignments.isEmpty) {
      return const EmptyStateWidget(variant: EmptyStateVariant.noPatient);
    }

    final filtered = _filtered;

    return Column(
      children: [
        _buildSearchField(),
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Aramayla eşleşen hasta bulunamadı.',
                      style: MedTextStyles.bodyMd(color: MedColors.text3),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) =>
                      _PatientPickerItem(assignment: filtered[i], onTap: () => widget.onSelected(filtered[i])),
                ),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return MedTextField(
      controller: _searchController,
      hint: 'Hasta, oda, yatak veya servis ara...',
      prefixIcon: Icon(PhosphorIcons.magnifyingGlass()),
      onChanged: (v) => setState(() => _query = v),
    );
  }
}

class _PatientPickerItem extends StatelessWidget {
  const _PatientPickerItem({required this.assignment, required this.onTap});

  final BedAssignment assignment;
  final VoidCallback onTap;

  String get _name {
    final p = assignment.hospitalization?.patient;
    if (p == null) return 'Bilinmeyen Hasta';
    final full = p.fullName.trim();
    return full.isNotEmpty ? full : '—';
  }

  String? get _location {
    final room = assignment.bed?.room?.name;
    final bed = assignment.bed?.name;
    if (room != null && bed != null) return '$room · $bed';
    return room ?? bed;
  }

  String get _initials {
    final parts = _name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(color: MedColors.blueLight, shape: BoxShape.circle),
              child: Center(
                child: Text(
                  _initials,
                  style: MedTextStyles.bodySm(color: MedColors.blue, weight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _name,
                    style: MedTextStyles.bodyMd(color: MedColors.text, weight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (_location != null) Text(_location!, style: MedTextStyles.monoXs(color: MedColors.text3)),
                ],
              ),
            ),
            Icon(PhosphorIcons.caretRight(), size: 14, color: MedColors.text4),
          ],
        ),
      ),
    );
  }
}
