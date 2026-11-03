part of '../../fault_view.dart';

// [SWREQ-UI-CAB-006]
// Master kabin Çekmece Arıza ekranı — dolum/sayım ekranlarıyla aynı şema:
//   Sol  : kabin şeridi + görüntülenen kabinin iç yerleşimi (gözlerde atanmış
//          ilaç adları; arızalı/bakımdaki gözler renkli ve seçilebilir).
//   Sağ  : başlık + iki sütun —
//          • Arızalı / bakımdaki gözler (görüntülenen kabin) — dokununca seçer
//          • Seçili göz: konum, atanmış ilaç ve stok, arıza formu, geçmiş
// Mobil kabin (MobileFaultView) bu değişiklikten etkilenmez.
//
// Sınıf: Class B

class MasterFaultView extends ConsumerStatefulWidget {
  const MasterFaultView({super.key, required this.stationContext, this.menu});

  final StationCabinsContext stationContext;
  final MenuItem? menu;

  @override
  ConsumerState<MasterFaultView> createState() => _MasterFaultViewState();
}

class _MasterFaultViewState extends ConsumerState<MasterFaultView> {
  late final TextEditingController _descriptionController;

  /// Arıza kayıtları kabin bazlı — görüntülenen kabin burada tutulur.
  final StationCabinScope _scope = StationCabinScope();

  /// İstasyondaki tüm atamalar (gözlerdeki ilaç adları ve stok bilgisi için).
  List<MedicineAssignment> _assignments = const [];

  CabinVisualizerData? get _data => widget.stationContext.dataFor(_scope.viewedCabinId);

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
    _scope.attach(widget.stationContext);
    _initialize(_data);
    _loadAssignments();
  }

  @override
  void didUpdateWidget(MasterFaultView old) {
    super.didUpdateWidget(old);
    // Kayıt sonrası kabin görsel verisi yenilenince (refreshCabinVisualizer)
    // görüntülenen kabin korunarak yeniden yüklenir.
    final previous = old.stationContext.dataFor(_scope.viewedCabinId);
    _scope.attach(widget.stationContext);
    if (_data != previous) {
      _initialize(_data);
    }
  }

  Future<void> _loadAssignments() async {
    final result = await ref.read(getStationAssignmentsUseCaseProvider).call();
    if (!mounted) return;
    result.when(
      ok: (list) => setState(() => _assignments = _scope.stationAssignments(list)),
      error: (_) {}, // atama yoksa gözler "boş" görünür; arıza işlemi etkilenmez
    );
  }

  void _onCabinTap(int cabinId) {
    if (ref.read(masterFaultNotifierProvider) is MasterFaultSaving) return;
    if (!_scope.view(cabinId)) return;
    setState(() {});
    _initialize(_data);
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _initialize(CabinVisualizerData? data) {
    if (data == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(masterFaultNotifierProvider.notifier).init(data);
    });
  }

  // Göz değişiminde controller'ı state ile eşitle.
  void _syncDescriptionController(MasterFaultState state) {
    if (state is MasterFaultCellSelected) {
      final newText = state.description ?? '';
      if (_descriptionController.text != newText) {
        _descriptionController.text = newText;
        _descriptionController.selection = TextSelection.fromPosition(TextPosition(offset: newText.length));
      }
    } else if (_descriptionController.text.isNotEmpty) {
      _descriptionController.clear();
    }
  }

  /// Gözün bulunduğu çekmece.
  DrawerGroup? _groupOf(List<DrawerGroup> groups, int? unitId) =>
      groups.firstWhereOrNull((g) => g.units.any((u) => u.id == unitId));

  /// Göze atanmış ilaç (kübik/birim doz: cabinDrawerId; serum: raf).
  MedicineAssignment? _assignmentOf(int? unitId) {
    if (unitId == null) return null;
    return _assignments.firstWhereOrNull((a) => (a.cabinDrawerId ?? a.drawerUnit?.id) == unitId);
  }

  void _selectUnit(List<DrawerGroup> groups, DrawerUnit unit) {
    final group = _groupOf(groups, unit.id);
    if (group == null) return;
    ref.read(masterFaultNotifierProvider.notifier).selectUnit(group, unit);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(masterFaultNotifierProvider);
    final notifier = ref.read(masterFaultNotifierProvider.notifier);

    _syncDescriptionController(state);

    ref.listen(masterFaultNotifierProvider, (_, next) {
      if (next is MasterFaultError) {
        MessageUtils.showErrorSnackbar(context, next.message);
        notifier.dismissError();
      } else if (next is MasterFaultSuccess) {
        final msg = next.isNewRecord ? context.l10n.fault_recordCreatedSuccess : context.l10n.fault_recordClosedSuccess;
        MessageUtils.showSuccessSnackbar(context, msg);
        notifier.dismissSuccess();
      }
    });

    final isLoading = _data == null || state is MasterFaultUninitialized || state is MasterFaultLoading;
    final groups = state.groups;
    final selectedUnitId = state.selectedUnitId;
    final viewedAssignments = _scope.ofCabin(_assignments, _scope.viewedCabinId);

    return CabinOperationSelectionLayout(
      left: StationCabinSelectionPanel(
        cabins: _scope.cabins,
        viewedCabinId: _scope.viewedCabinId,
        onCabinTap: _onCabinTap,
        selectedCountByCabin: const {},
        interior: isLoading
            ? Container(
                decoration: MedDecoration.panelDecoration,
                child: _data == null
                    ? const EmptyStateWidget(variant: EmptyStateVariant.cabinData)
                    : const Center(child: MedLoadingIndicator()),
              )
            : CabinOverviewSelectionPanel(
                key: ValueKey(_scope.viewedCabinId),
                cabin: _scope.viewedCabin,
                groups: groups,
                assignments: viewedAssignments,
                selectedUnitIds: {?selectedUnitId},
                allowFaultyTap: true,
                onCellTap: (unit) => _selectUnit(groups, unit),
                onSerumTrayTap: (shelf, _) => _selectUnit(groups, shelf),
              ),
      ),
      right: CabinSelectionContentShell(
        menu: widget.menu,
        showSearch: false,
        searchQuery: '',
        onSearchQueryChanged: (_) {},
        isLoading: isLoading,
        content: isLoading
            ? null
            : Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: MedSpacing.xl,
                children: [
                  Expanded(
                    flex: 3,
                    child: _ActiveFaultList(
                      groups: groups,
                      faults: state.faults,
                      selectedUnitId: selectedUnitId,
                      assignmentOf: _assignmentOf,
                      onSelect: (unit) => _selectUnit(groups, unit),
                    ),
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(
                    flex: 2,
                    child: _SelectedCellPanel(
                      state: state,
                      assignment: _assignmentOf(selectedUnitId),
                      descriptionController: _descriptionController,
                      onStatusChanged: notifier.onStatusChanged,
                      onSubmit: () {
                        notifier.onDescriptionChanged(_descriptionController.text);
                        notifier.submit();
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Göz etiketi: "Çekmece adı · G-3". Numara, iç yerleşim panelindeki
/// numarayla aynı sırayı izler (kübikte görsel sıra, iade sütunu hariç).
String _cellLocationLabel(DrawerGroup group, DrawerUnit unit) {
  const columns = 4;
  var units = group.isKubik ? kubikUnitsInVisualOrder(group.units, columnCount: columns) : group.units;
  if (group.isKubik && group.isReturnDrawer) {
    units = [
      for (var i = 0; i < units.length; i++)
        if (i % columns != columns - 1) units[i],
    ];
  }
  final index = units.indexWhere((u) => u.id == unit.id);
  return index < 0 ? group.name : '${group.name} · G-${index + 1}';
}

String _formatDateTime(DateTime? date) {
  if (date == null) return '—';
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(date.day)}.${two(date.month)}.${date.year} ${two(date.hour)}:${two(date.minute)}';
}

// ── Sol sütun: aktif arızalar ──────────────────────────────────────────────

class _ActiveFaultList extends StatelessWidget {
  const _ActiveFaultList({
    required this.groups,
    required this.faults,
    required this.selectedUnitId,
    required this.assignmentOf,
    required this.onSelect,
  });

  final List<DrawerGroup> groups;
  final List<MasterFault> faults;
  final int? selectedUnitId;
  final MedicineAssignment? Function(int? unitId) assignmentOf;
  final ValueChanged<DrawerUnit> onSelect;

  @override
  Widget build(BuildContext context) {
    // Açık kayıtlar (endDate yok), kabin görselindeki gözlerle eşleşenler.
    final entries = <({DrawerGroup group, DrawerUnit unit, MasterFault fault})>[
      for (final f in faults)
        if (f.endDate == null)
          for (final g in groups)
            for (final u in g.units)
              if (u.id != null && u.id == f.slotId) (group: g, unit: u, fault: f),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: MedSpacing.md,
      children: [
        Row(
          children: [
            Expanded(
              child: MedLabel(text: context.l10n.fault_activeListTitle, variant: MedLabelVariant.monoDetail),
            ),
            MedChip(label: '${entries.length}', size: MedChipSize.sm, shape: MedChipShape.pill),
          ],
        ),
        Expanded(
          child: entries.isEmpty
              ? Center(
                  child: EmptyStateWidget(
                    size: EmptyStateSize.compact,
                    icon: PhosphorIcons.checkCircle(),
                    title: context.l10n.fault_activeListEmpty,
                  ),
                )
              : ListView.separated(
                  itemCount: entries.length,
                  separatorBuilder: (_, _) => const SizedBox(height: MedSpacing.sm),
                  itemBuilder: (context, i) {
                    final e = entries[i];
                    return _ActiveFaultTile(
                      location: _cellLocationLabel(e.group, e.unit),
                      fault: e.fault,
                      medicineName: assignmentOf(e.unit.id)?.medicine?.name,
                      isSelected: e.unit.id == selectedUnitId,
                      onTap: () => onSelect(e.unit),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _ActiveFaultTile extends StatelessWidget {
  const _ActiveFaultTile({
    required this.location,
    required this.fault,
    required this.medicineName,
    required this.isSelected,
    required this.onTap,
  });

  final String location;
  final MasterFault fault;
  final String? medicineName;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isMaintenance = fault.workingStatus == CabinWorkingStatus.maintenance;
    final accent = isMaintenance ? MedColors.amber : MedColors.red;
    final label = isMaintenance ? context.l10n.fault_historyStatusMaintenance : context.l10n.fault_historyStatusFault;

    return InkWell(
      onTap: onTap,
      borderRadius: MedRadius.mdAll,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? MedColors.blueLight : MedColors.surface,
          borderRadius: MedRadius.mdAll,
          border: Border.all(color: isSelected ? MedColors.blue : MedColors.border, width: isSelected ? 1.5 : 1),
        ),
        child: Row(
          spacing: 10,
          children: [
            MedStatusBar(color: accent, height: 52, width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(
                    location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: MedTextStyles.titleMd(color: MedColors.text),
                  ),
                  Text(
                    medicineName ?? context.l10n.drawerStatus_empty,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: MedTextStyles.bodyLg(
                      color: medicineName != null ? MedColors.text2 : MedColors.text4,
                      weight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    spacing: 4,
                    children: [
                      Icon(PhosphorIcons.clock(), size: 13, color: MedColors.text3),
                      Text(_formatDateTime(fault.startDate), style: MedTextStyles.monoSm(color: MedColors.text3)),
                    ],
                  ),
                ],
              ),
            ),
            MedChip(label: label, mono: false, style: isMaintenance ? MedChipStyle.warning : MedChipStyle.danger),
          ],
        ),
      ),
    );
  }
}

// ── Sağ sütun: seçili göz ──────────────────────────────────────────────────

class _SelectedCellPanel extends StatelessWidget {
  const _SelectedCellPanel({
    required this.state,
    required this.assignment,
    required this.descriptionController,
    required this.onStatusChanged,
    required this.onSubmit,
  });

  final MasterFaultState state;
  final MedicineAssignment? assignment;
  final TextEditingController descriptionController;
  final ValueChanged<int> onStatusChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final s = state;
    if (s is MasterFaultSaving) return const _SavingContent();
    if (s is! MasterFaultCellSelected) {
      return Center(
        child: EmptyStateWidget(
          size: EmptyStateSize.compact,
          variant: EmptyStateVariant.noCellSelected,
          title: context.l10n.common_selectCellTitle,
          description: context.l10n.fault_selectCellPlaceholder,
        ),
      );
    }

    final status = s.selectedUnit.workingStatus;
    return ListView(
      children: [
        // Konum + durum
        Row(
          spacing: 10,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(color: MedColors.blueLight, borderRadius: MedRadius.mdAll),
              child: Icon(PhosphorIcons.squaresFour(), size: 18, color: MedColors.blue),
            ),
            Expanded(
              child: Text(
                _cellLocationLabel(s.selectedGroup, s.selectedUnit),
                style: MedTextStyles.titleMd(color: MedColors.text),
              ),
            ),
            MedChip(
              label: status.label,
              size: MedChipSize.sm,
              mono: false,
              style: switch (status) {
                CabinWorkingStatus.working => MedChipStyle.success,
                CabinWorkingStatus.faulty => MedChipStyle.danger,
                CabinWorkingStatus.maintenance => MedChipStyle.warning,
              },
            ),
          ],
        ),
        const SizedBox(height: MedSpacing.lg),
        _AssignedMedicineCard(assignment: assignment),
        const SizedBox(height: MedSpacing.lg),
        if (!s.isNewRecord) ...[_ActiveFaultBanner(fault: s.activeFault!), const SizedBox(height: 14)],
        if (s.isNewRecord) ...[
          _RecordTypeSelector(selectedStatus: s.selectedStatus, onChanged: onStatusChanged),
          const SizedBox(height: 14),
        ],
        _DescriptionField(controller: descriptionController),
        const SizedBox(height: 14),
        _RecordSubmitButton(
          isNewRecord: s.isNewRecord,
          status: s.selectedStatus,
          enabled: s.canSubmit,
          onTap: onSubmit,
        ),
        if (s.faultHistory.isNotEmpty) ...[const SizedBox(height: 18), _FaultHistory(history: s.faultHistory)],
      ],
    );
  }
}

class _AssignedMedicineCard extends StatelessWidget {
  const _AssignedMedicineCard({required this.assignment});

  final MedicineAssignment? assignment;

  @override
  Widget build(BuildContext context) {
    final a = assignment;
    final medicine = a?.medicine;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: MedColors.surface2,
        borderRadius: MedRadius.mdAll,
        border: Border.all(color: MedColors.border2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 6,
        children: [
          MedLabel(text: context.l10n.fault_assignedMedicineLabel, variant: MedLabelVariant.monoDetail),
          if (medicine == null)
            Text(context.l10n.fault_noAssignedMedicine, style: MedTextStyles.bodyMd(color: MedColors.text3))
          else ...[
            Row(
              spacing: 8,
              children: [
                Icon(PhosphorIcons.pill(), size: 18, color: MedColors.blue),
                Expanded(
                  child: Text(
                    medicine.name ?? '—',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: MedTextStyles.titleSm(color: MedColors.text),
                  ),
                ),
              ],
            ),
            if (medicine.barcode != null) Text(medicine.barcode!, style: MedTextStyles.monoSm(color: MedColors.text3)),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                MedChip(
                  label: '${context.l10n.cabinAssignmentList_stockColumn}: ${a!.stockRatioLabel}',
                  size: MedChipSize.sm,
                  mono: false,
                ),
                MedChip(
                  label: '${context.l10n.common_minLabel} ${a.minQuantity.formatFractional}',
                  size: MedChipSize.sm,
                  mono: false,
                ),
                MedChip(
                  label: '${context.l10n.common_criticalLabel} ${a.criticalQuantity.formatFractional}',
                  size: MedChipSize.sm,
                  mono: false,
                ),
                MedChip(
                  label: '${context.l10n.common_maxLabel} ${a.maxQuantity.formatFractional}',
                  size: MedChipSize.sm,
                  mono: false,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ── Kayıt tipi seçimi (Arıza / Bakım) ──────────────────────────────────────

/// İki seçenek kartı: ikon + başlık + seçim işareti. Seçili kart kendi
/// renginde (arıza kırmızı, bakım amber) vurgulanır.
class _RecordTypeSelector extends StatelessWidget {
  const _RecordTypeSelector({required this.selectedStatus, required this.onChanged});

  final CabinWorkingStatus selectedStatus;

  /// 0 → arıza, 1 → bakım (notifier.onStatusChanged ile aynı sözleşme).
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6,
      children: [
        MedLabel(text: context.l10n.fault_recordTypeLabel, variant: MedLabelVariant.monoDetail),
        Row(
          spacing: 10,
          children: [
            Expanded(
              child: _RecordTypeOption(
                icon: PhosphorIcons.warningOctagon(),
                label: context.l10n.fault_historyStatusFault,
                color: MedColors.red,
                background: MedColors.redLight,
                isSelected: selectedStatus == CabinWorkingStatus.faulty,
                onTap: () => onChanged(0),
              ),
            ),
            Expanded(
              child: _RecordTypeOption(
                icon: PhosphorIcons.wrench(),
                label: context.l10n.fault_historyStatusMaintenance,
                color: MedColors.amber,
                background: MedColors.amberLight,
                isSelected: selectedStatus == CabinWorkingStatus.maintenance,
                onTap: () => onChanged(1),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RecordTypeOption extends StatelessWidget {
  const _RecordTypeOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.background,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color background;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: MedRadius.mdAll,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? background : MedColors.surface,
          borderRadius: MedRadius.mdAll,
          border: Border.all(color: isSelected ? color : MedColors.border, width: isSelected ? 2 : 1.5),
        ),
        child: Row(
          spacing: 10,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: isSelected ? color : MedColors.surface3,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 18, color: isSelected ? Colors.white : MedColors.text3),
            ),
            Expanded(
              child: Text(
                label,
                style: MedTextStyles.titleMd(color: isSelected ? color : MedColors.text2),
              ),
            ),
            Icon(
              isSelected ? PhosphorIconsFill.checkCircle : PhosphorIcons.circle(),
              size: 20,
              color: isSelected ? color : MedColors.text4,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Kaydet butonu ──────────────────────────────────────────────────────────

/// Yeni kayıt: "Kayıt Oluştur" — arıza seçiliyken kırmızı, bakımda amber.
/// Açık kayıt: "Kaydı Sonlandır" — yeşil.
class _RecordSubmitButton extends StatelessWidget {
  const _RecordSubmitButton({
    required this.isNewRecord,
    required this.status,
    required this.enabled,
    required this.onTap,
  });

  final bool isNewRecord;
  final CabinWorkingStatus status;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color color;
    final IconData icon;
    final String label;
    if (!isNewRecord) {
      color = MedColors.green;
      icon = PhosphorIcons.checkCircle();
      label = context.l10n.fault_closeFaultButton;
    } else if (status == CabinWorkingStatus.maintenance) {
      color = MedColors.amber;
      icon = PhosphorIcons.wrench();
      label = context.l10n.fault_createRecordButton;
    } else {
      color = MedColors.red;
      icon = PhosphorIcons.warningOctagon();
      label = context.l10n.fault_createRecordButton;
    }

    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Material(
        color: color,
        borderRadius: MedRadius.mdAll,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: MedRadius.mdAll,
          child: SizedBox(
            height: 46,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 8,
              children: [
                Icon(icon, size: 18, color: Colors.white),
                Text(label, style: MedTextStyles.titleMd(color: Colors.white)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
