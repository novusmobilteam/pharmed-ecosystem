part of '../../fault_view.dart';

/// Kabin seçim adımı yok: üstteki kabin şeridinden görüntülenen kabin
/// değiştirilir, alttaki çekmece/göz/arıza panelleri o kabine göre yüklenir.
class MasterFaultView extends ConsumerStatefulWidget {
  const MasterFaultView({super.key, required this.stationContext});

  final StationCabinsContext stationContext;

  @override
  ConsumerState<MasterFaultView> createState() => _MasterFaultViewState();
}

class _MasterFaultViewState extends ConsumerState<MasterFaultView> {
  late final TextEditingController _descriptionController;

  /// Arıza kayıtları kabin bazlı — görüntülenen kabin burada tutulur.
  final StationCabinScope _scope = StationCabinScope();

  CabinVisualizerData? get _data => widget.stationContext.dataFor(_scope.viewedCabinId);

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
    _scope.attach(widget.stationContext);
    _initialize(_data);
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

  // Göz değişiminde controller temizle
  void _syncDescriptionController(MasterFaultState state) {
    if (state is MasterFaultCellSelected) {
      final newText = state.description ?? '';
      if (_descriptionController.text != newText) {
        _descriptionController.text = newText;
        // İmleci sona taşı
        _descriptionController.selection = TextSelection.fromPosition(TextPosition(offset: newText.length));
      }
    } else {
      if (_descriptionController.text.isNotEmpty) {
        _descriptionController.clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(masterFaultNotifierProvider);
    final notifier = ref.read(masterFaultNotifierProvider.notifier);

    // Controller'ı state ile senkronize et
    _syncDescriptionController(state);

    // Hata dinle
    ref.listen(masterFaultNotifierProvider, (_, next) {
      if (next is MasterFaultError) {
        MessageUtils.showErrorSnackbar(context, next.message);
        notifier.dismissError();
      } else if (next is MasterFaultSuccess) {
        final msg = next.isNewRecord
            ? context.l10n.fault_recordCreatedSuccess
            : context.l10n.fault_recordClosedSuccess;
        MessageUtils.showSuccessSnackbar(context, msg);
        notifier.dismissSuccess();
      }
    });

    final strip = StationCabinStrip(cabins: _scope.cabins, viewedCabinId: _scope.viewedCabinId, onCabinTap: _onCabinTap);

    Widget withStrip(Widget body) => Column(
      spacing: MedSpacing.lg,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        strip,
        Expanded(child: body),
      ],
    );

    if (_data == null || state is MasterFaultUninitialized) {
      return withStrip(const EmptyStateWidget(variant: EmptyStateVariant.cabinData));
    }

    if (state is MasterFaultLoading) {
      return withStrip(const Center(child: CircularProgressIndicator(strokeWidth: 2)));
    }

    final groups = state.groups;
    final selectedSlotId = state.selectedSlotId;
    final selectedGroup = state.selectedGroup;
    final selectedUnitId = state.selectedUnitId;
    final faults = state.faults;

    return withStrip(CabinOperationScaffold(
      leftPanel: MasterCabinOverviewPanel(
        groups: groups,
        selectedSlotId: selectedSlotId,
        mode: CabinOperationMode.fault,
        onDrawerTap: notifier.onDrawerTap,
      ),
      centerPanel: MasterCabinDrawerPanel(
        mode: CabinOperationMode.fault,
        group: selectedGroup,
        faults: faults,
        stocks: const [],
        assignments: const [],
        selectedUnitId: selectedUnitId,
        selectedStepNo: null,
        onCellTap: notifier.onCellTap,
      ),
      rightPanel: OperationPanelBase(
        mode: CabinOperationMode.fault,
        child: FaultPanel(
          isSaving: state is MasterFaultSaving,
          panelState: state is MasterFaultCellSelected ? state : null,
          descriptionController: _descriptionController,
          onStatusChanged: notifier.onStatusChanged,
          onSubmit: () {
            notifier.onDescriptionChanged(_descriptionController.text);
            notifier.submit();
          },
        ),
      ),
    ));
  }
}
