import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../core/core.dart';
import '../../../core/storage/auth/auth.dart';
import '../../../core/widgets/hospitalization_card.dart';
import '../../hospitalization/domain/entity/hospitalization.dart';
import '../notifier/add_patient_notifier.dart';
import '../notifier/my_patients_notifier.dart';

part 'add_patient_view.dart';

class MyPatientsView extends StatelessWidget {
  const MyPatientsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyPatientsNotifier(
        getMyPatientsUseCase: context.read(),
        removePatientUseCase: context.read(),
      )..fetchMyPatients(),
      builder: (context, child) {
        return Consumer<MyPatientsNotifier>(
          builder: (context, notifier, child) {
            return CustomDialog(
              title: 'Hastalarım',
              width: context.width * 0.7,
              maxHeight: context.height * 0.8,
              showAdd: true,
              showSearch: true,
              onSearchChanged: notifier.search,
              actions: [
                if (notifier.selectedItems.isNotEmpty)
                  IconButton(
                    onPressed: () => _onDelete(context, notifier),
                    icon: Icon(
                      PhosphorIcons.trash(),
                      color: Colors.red,
                    ),
                  ),
              ],
              isLoading: notifier.isLoading(notifier.removeOp),
              onAddPressed: () => _onAdd(context, notifier),
              child: _buildContent(context, notifier),
            );
          },
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, MyPatientsNotifier notifier) {
    if (notifier.isFetching && notifier.isEmpty) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (notifier.isEmpty) {
      return CommonEmptyStates.noPatient();
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        mainAxisExtent: 200,
      ),
      itemCount: notifier.filteredItems.length,
      itemBuilder: (BuildContext context, int index) {
        final item = notifier.filteredItems.elementAt(index);
        return GestureDetector(
          onTap: () => notifier.selectItem(item),
          child: HospitalizationCard(
            isSelected: notifier.selectedItems.contains(item),
            hospitalization: item.hospitalization ?? Hospitalization(),
          ),
        );
      },
    );
  }
}

void _onAdd(BuildContext context, MyPatientsNotifier notifier) async {
  final userId = context.read<AuthStorageNotifier>().user?.id ?? 0;
  final result = await showAddPatientDialog(
    context,
    userId,
    initiallySelected: notifier.allItems.map((i) => i.hospitalization ?? Hospitalization()).toList(),
  );

  if (result && context.mounted == true) {
    context.read<MyPatientsNotifier>().fetchMyPatients();
  }
}

void _onDelete(BuildContext context, MyPatientsNotifier notifier) async {
  MessageUtils.showConfirmDialog(
    context: context,
    action: ConfirmAction.delete,
    customTitle: 'Silme Onayı',
    customMessage: 'Seçili hastalar hastalarınızdan kaldırılacak. Onaylıyor musunuz?',
    onConfirm: () => notifier.removePatients(
      onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
      onSuccess: (msg) => MessageUtils.showSuccessSnackbar(context, msg),
    ),
  );
}
