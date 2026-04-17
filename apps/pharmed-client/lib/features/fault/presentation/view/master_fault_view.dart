part of 'fault_view.dart';

class MasterFaultView extends ConsumerStatefulWidget {
  const MasterFaultView({super.key, this.data});

  final CabinVisualizerData? data;

  @override
  ConsumerState<MasterFaultView> createState() => _MasterFaultViewState();
}

class _MasterFaultViewState extends ConsumerState<MasterFaultView> {
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
    _initialize(widget.data);
  }

  @override
  void didUpdateWidget(MasterFaultView old) {
    super.didUpdateWidget(old);
    if (widget.data != old.data) {
      _initialize(widget.data);
    }
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
        MessageUtils.showSuccessSnackbar(context, next.message);
        notifier.dismissSuccess();
      }
    });

    if (widget.data == null || state is MasterFaultUninitialized) {
      return const EmptyStateWidget(variant: EmptyStateVariant.cabinData);
    }

    if (state is MasterFaultLoading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    final groups = state.groups;
    final selectedSlotId = state.selectedSlotId;
    final selectedGroup = state.selectedGroup;
    final selectedUnitId = state.selectedUnitId;
    final faults = state.faults;

    return CabinOperationScaffold(
      leftPanel: MasterCabinOverviewPanel(
        groups: groups,
        selectedSlotId: selectedSlotId,
        mode: CabinOperationMode.fault,
        onDrawerTap: notifier.onDrawerTap,
      ),
      centerPanel: DrawerDetailPanel(
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
    );
  }
}
