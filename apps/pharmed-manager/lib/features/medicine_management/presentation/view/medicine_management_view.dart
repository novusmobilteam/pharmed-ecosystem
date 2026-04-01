import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/core.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/hospitalization_card.dart';
import '../../../medicine_define/presentation/view/patient_medicine_define_view.dart';
import '../../../medicine_withdraw/presentation/view/custom_withdraw_view.dart';
import '../../../medicine_withdraw/presentation/view/withdraw_view.dart';
import '../notifier/medicine_management_notifier.dart';
import '../../../medicine_disposal/presentation/view/disposal_view.dart';
import '../../../medicine_refund/presentation/view/medicine_refund_view.dart';
import '../../../menu/menu.dart';

part 'filter_view.dart';
part 'operation_selection_view.dart';
part 'hospitalization_grid_view.dart';
part 'service_filter_view.dart';
part '../widgets/toggle_button.dart';
part '../widgets/action_button.dart';

// Eğer istasyon ordersız tanımlandıysa ordersız işlem yapılacak. (OrderlessStationView)
// Eğer istasyon orderlı tanımlandıysa ve kullanıcının ordersız işlem yapmaya yetkisi yoksa
// orderlı işlem yapılacak. (OrderedStationView)
class MedicineManagementView extends StatelessWidget {
  const MedicineManagementView({super.key});

  // Orderlı → Mavi, Ordersız → Turuncu
  static const _orderedColor = Color(0xFF1565C0);
  static const _orderlessColor = Color(0xFFE65100);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MedicineManagementNotifier(
        authPersistence: context.read(),
        getHospitalizationsUseCase: context.read(),
        filteredHospitalizationsUseCase: context.read(),
        getCurrentStationUseCase: context.read(),
        createUrgentPatientUseCase: context.read(),
        getMyPatientsUseCase: context.read(),
      )..initialize(),
      child: Consumer<MedicineManagementNotifier>(
        builder: (context, notifier, _) {
          final isOrderless = notifier.viewOrderStatus.isOrderless;
          final accentColor = isOrderless ? _orderlessColor : _orderedColor;

          return AnimatedTheme(
            duration: const Duration(milliseconds: 300),
            data: Theme.of(context).copyWith(),
            child: CustomDialog(
              title: _buildTitle(notifier),
              showSearch: true,
              width: context.width * 0.8,
              maxHeight: context.height * 0.9,
              onSearchChanged: notifier.search,
              actions: [
                if (!isOrderless)
                  IconButton(onPressed: () => showFilterView(context), icon: Icon(PhosphorIcons.funnel())),
              ],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (isOrderless) ...[
                        _ServiceFilterBar(
                          services: notifier.availableServices,
                          selectedService: notifier.selectedService,
                          accentColor: accentColor,
                          onToggle: notifier.toggleService,
                          managementType: notifier.managementType,
                        ),
                      ],
                      _ServiceChip(
                        icon: PhosphorIcons.user(),
                        label: 'Hastalarım',
                        isSelected: notifier.managementType == MedicineManagementType.myPatients,
                        accentColor: context.colorScheme.primary,
                        onTap: () => notifier.togglePatientView(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(child: _buildChild(notifier)),
                  _ActionBar(notifier: notifier, accentColor: accentColor, isOrderless: isOrderless),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _buildTitle(MedicineManagementNotifier notifier) {
    if (!notifier.viewOrderStatus.isOrderless) return 'Reçeteli Hasta Listesi';
    return 'Yatan Hasta Listesi';
  }

  Widget _buildChild(MedicineManagementNotifier notifier) {
    bool isLoading =
        notifier.isLoading(notifier.initOp) ||
        notifier.isLoading(notifier.fetchOp) ||
        notifier.isLoading(notifier.fetchMyPatientsOp);
    final items = notifier.filteredItems;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (!isLoading && items.isEmpty) {
      return Center(child: CommonEmptyStates.noData());
    }

    return HospitalizationGridView();
  }
}
