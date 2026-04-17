part of 'fault_view.dart';

class MobileFaultView extends ConsumerStatefulWidget {
  const MobileFaultView({super.key, this.data});

  final CabinVisualizerData? data;

  @override
  ConsumerState<MobileFaultView> createState() => _MobileFaultViewState();
}

class _MobileFaultViewState extends ConsumerState<MobileFaultView> {
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
    _initialize(widget.data);
  }

  @override
  void didUpdateWidget(MobileFaultView old) {
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
      ref.read(mobileFaultNotifierProvider.notifier).init(data);
    });
  }

  void _syncDescriptionController(MobileFaultState state) {
    final newText = state is MobileFaultSlotSelected ? (state.description ?? '') : '';
    if (_descriptionController.text != newText) {
      _descriptionController.text = newText;
      _descriptionController.selection = TextSelection.fromPosition(TextPosition(offset: newText.length));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mobileFaultNotifierProvider);
    final notifier = ref.read(mobileFaultNotifierProvider.notifier);

    _syncDescriptionController(state);

    ref.listen(mobileFaultNotifierProvider, (_, next) {
      if (next is MobileFaultError) {
        MessageUtils.showErrorSnackbar(context, next.message);
        notifier.dismissError();
      } else if (next is MobileFaultSuccess) {
        MessageUtils.showSuccessSnackbar(context, next.message);
        notifier.dismissSuccess();
      }
    });

    if (widget.data == null || state is MobileFaultUninitialized) {
      return const EmptyStateWidget(variant: EmptyStateVariant.cabinData);
    }

    if (state is MobileFaultLoading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    return CabinOperationScaffold(
      leftPanel: MobileCabinOverviewPanel(
        slots: state.slots,
        mode: CabinOperationMode.fault,
        selectedSlotId: state.selectedSlotId,
        onSlotTap: notifier.onSlotTap,
      ),
      centerPanel: MobileCabinDrawerPanel(mode: CabinOperationMode.fault, slot: state.selectedSlot),
      rightPanel: OperationPanelBase(
        mode: CabinOperationMode.fault,
        child: FaultPanel(
          descriptionController: _descriptionController,
          isSaving: state is MobileFaultSaving,
          panelState: state is MobileFaultSlotSelected ? state : null,
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
