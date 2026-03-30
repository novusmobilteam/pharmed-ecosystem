import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/core.dart';

import 'cabin_assignment_form_notifier.dart';

Future<bool> showCabinAssignmentFormView(BuildContext context, CabinAssignment? data) async {
  final bool? isSuccess = await showDialog<bool>(
    context: context,
    builder: (context) => ChangeNotifierProvider(
      create: (context) => CabinAssignmentFormNotifier(
        initial: data ?? CabinAssignment.empty(cabinId: 0, cabinDrawerId: data?.cabinDrawerId ?? 0),
        createAssignmentUseCase: context.read(),
        updateAssignmentUseCase: context.read(),
      ),
      child: const CabinAssignmentFormView(),
    ),
  );

  return isSuccess ?? false;
}

class CabinAssignmentFormView extends StatefulWidget {
  const CabinAssignmentFormView({super.key});

  @override
  State<CabinAssignmentFormView> createState() => _CabinAssignmentFormViewState();
}

class _CabinAssignmentFormViewState extends State<CabinAssignmentFormView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormFieldState<Medicine>> _medicineFieldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Consumer<CabinAssignmentFormNotifier>(
      builder: (context, notifier, _) {
        return RegistrationDialog(
          title: 'Malzeme Seçimi',
          maxHeight: 500,
          width: 600,
          isLoading: notifier.isLoading(notifier.submitOp),
          onSave: () async {
            if (_formKey.currentState!.validate()) {
              await notifier.submit(
                onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
                onSuccess: (msg) {
                  MessageUtils.showSuccessSnackbar(context, msg);
                  context.pop(true);
                },
              );
            }
          },
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PharmedSegmentedButton(
                  labels: StockType.values.map((s) => s.label).toList(),
                  selectedIndex: notifier.selectedIndex,
                  onChanged: (index) {
                    _medicineFieldKey.currentState?.didChange(null);
                    notifier.setStockType(StockType.values.elementAt(index));
                  },
                ),
                const SizedBox(height: 24),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Column(
                    children: [
                      _MaterialField(notifier, _medicineFieldKey),
                      const SizedBox(height: 16),
                      Row(
                        children: const [
                          Expanded(child: _MinQuantityField()),
                          SizedBox(width: 16),
                          Expanded(child: _MaxQuantityField()),
                          SizedBox(width: 16),
                          Expanded(child: _CritQuantityField()),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MaterialField extends StatefulWidget {
  const _MaterialField(this.notifier, this.formKey);

  final CabinAssignmentFormNotifier notifier;
  final GlobalKey<FormFieldState<Medicine>> formKey;

  @override
  State<_MaterialField> createState() => _MaterialFieldState();
}

class _MaterialFieldState extends State<_MaterialField> {
  late final ValueNotifier<DialogFuture<Medicine>> _futureNotifier;
  late final ValueNotifier<bool> _showEquivalent;

  @override
  void initState() {
    super.initState();
    _showEquivalent = ValueNotifier(true);
    _futureNotifier = ValueNotifier(_resolveFuture());
  }

  @override
  void dispose() {
    _showEquivalent.dispose();
    _futureNotifier.dispose();
    super.dispose();
  }

  DialogFuture<Medicine> _resolveFuture() {
    if (widget.notifier.canSelectEquivalent && _showEquivalent.value) {
      final medicineId = widget.notifier.assignment.medicine?.id ?? 0;
      return () => context.read<IMedicineRepository>().getEquivalentMedicines(medicineId);
    }
    return widget.notifier.stockType == StockType.drug
        ? () => context.read<IMedicineRepository>().getDrugs()
        : () => context.read<IMedicineRepository>().getMedicalConsumables();
  }

  void _toggleFuture() {
    _showEquivalent.value = !_showEquivalent.value;
    _futureNotifier.value = _resolveFuture();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CabinAssignmentFormNotifier>(
      builder: (context, vm, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: _showEquivalent,
          builder: (context, showEquivalent, child) {
            return DialogInputField<Medicine>(
              key: widget.formKey,
              label: 'Malzeme',
              dialogTitle: showEquivalent ? 'Eşdeğer İlaçlar' : 'Tüm İlaçlar',
              futureNotifier: _futureNotifier,
              validator: (value) => Validators.cannotBlankValidator(value?.name),
              initialValue: vm.assignment.medicine,
              labelBuilder: (value) => value?.name,
              onSelected: (value) => vm.setMaterial(value),
              actions: [
                if (vm.canSelectEquivalent)
                  TextButton(onPressed: _toggleFuture, child: Text(showEquivalent ? 'Tüm İlaçlar' : 'Eşdeğer İlaçlar')),
              ],
            );
          },
        );
      },
    );
  }
}

class _MinQuantityField extends StatelessWidget {
  const _MinQuantityField();

  @override
  Widget build(BuildContext context) {
    return Consumer<CabinAssignmentFormNotifier>(
      builder: (context, vm, _) {
        return TextInputField(
          label: 'Min',
          initialValue: vm.assignment.minQuantityFromBackend.formatFractional,
          validator: (value) => Validators.cannotBlankValidator(value),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) => vm.setMinQuantity(value),
          keyboardType: TextInputType.number,
          suffix: Text('Adet'),
        );
      },
    );
  }
}

class _MaxQuantityField extends StatelessWidget {
  const _MaxQuantityField();

  @override
  Widget build(BuildContext context) {
    return Consumer<CabinAssignmentFormNotifier>(
      builder: (context, vm, _) {
        return TextInputField(
          label: 'Max',
          initialValue: vm.assignment.maxQuantityFromBackend.formatFractional,
          validator: (value) => Validators.cannotBlankValidator(value),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) => vm.setMaxQuantity(value),
          keyboardType: TextInputType.number,
          suffix: Text('Adet'),
        );
      },
    );
  }
}

class _CritQuantityField extends StatelessWidget {
  const _CritQuantityField();

  @override
  Widget build(BuildContext context) {
    return Consumer<CabinAssignmentFormNotifier>(
      builder: (context, vm, _) {
        return TextInputField(
          label: 'Kritik',
          initialValue: vm.assignment.critQuantityFromBackend.formatFractional,
          validator: (value) => Validators.cannotBlankValidator(value),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) => vm.setCriticQuantity(value),
          keyboardType: TextInputType.number,
          suffix: Text('Adet'),
        );
      },
    );
  }
}
