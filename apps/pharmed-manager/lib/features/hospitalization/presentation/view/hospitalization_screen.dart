import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/unified_table/unified_table_models.dart';
import '../../../../core/widgets/unified_table/unified_table_view.dart';
import 'hospitalization_form_view.dart';
import '../../../patient/presentation/view/patient_form_view.dart';
import '../../../patient/presentation/view/patient_list_view.dart';
import '../notifier/hospitalization_notifier.dart';

/// Yatan hasta listesi ekranı.
///
/// Bu ekran:
/// - Yatan hastaların listesini tablo olarak gösterir
/// - Hasta ve yatış ekleme/düzenleme işlemlerini destekler
/// - Arama ve tarih filtreleme özelliklerine sahiptir
class HospitalizationScreen extends StatefulWidget {
  const HospitalizationScreen({super.key});

  @override
  State<HospitalizationScreen> createState() => _HospitalizationScreenState();
}

class _HospitalizationScreenState extends State<HospitalizationScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) =>
          HospitalizationNotifier(hospitalizationRepository: context.read())..getHospitalizations(),
      child: Consumer<HospitalizationNotifier>(
        builder: (context, notifier, _) {
          return ResponsiveLayout(
            mobile: const MobileLayout(),
            tablet: const TabletLayout(),
            desktop: DesktopLayout(
              title: 'Hasta İşlemleri',
              onAddPressed: () => _onNewHospitalization(context),
              actions: _buildActions(context, notifier),
              child: _buildChild(context, notifier),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChild(BuildContext context, HospitalizationNotifier notifier) {
    if (notifier.isFetching && notifier.isEmpty) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (notifier.isEmpty) {
      return CommonEmptyStates.noData();
    }

    return _TableView(notifier: notifier);
  }

  List<Widget> _buildActions(BuildContext context, HospitalizationNotifier notifier) {
    return [
      // Yeni Hasta
      IconButton(
        onPressed: () => _onNewPatient(context),
        tooltip: 'Yeni Hasta Oluştur',
        icon: Icon(PhosphorIcons.userPlus()),
      ),
      // Yeni Yatış
      IconButton(
        onPressed: () => _onNewHospitalization(context),
        tooltip: 'Yeni Yatış Oluştur',
        icon: Icon(PhosphorIcons.bed()),
      ),
      // Seçili Hastayı Düzenle
      if (notifier.hasPatient)
        IconButton(
          onPressed: () => _onEditPatient(context, patient: notifier.patient),
          tooltip: 'Seçili Hastayı Düzenle',
          icon: Icon(PhosphorIcons.identificationBadge()),
        ),
      // Seçili Hastaya Yeni Yatış
      if (notifier.hasPatient)
        IconButton(
          onPressed: () => _onNewHospitalizationWithSelectedUser(context, data: notifier.patient),
          tooltip: 'Seçili Hastaya Yeni Yatış Gir',
          icon: Icon(PhosphorIcons.userCircleCheck()),
        ),
      // Yatış Düzenle
      if (notifier.hasPatient)
        IconButton(
          onPressed: () =>
              _onEditHospitalization(context, hospitalization: notifier.hospitalization, patient: notifier.patient),
          tooltip: 'Yatış Düzenle',
          icon: Icon(PhosphorIcons.pen()),
        ),
    ];
  }
}

class _TableView extends StatelessWidget {
  const _TableView({required this.notifier});

  final HospitalizationNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return UnifiedTableView<Hospitalization>(
      data: notifier.filteredItems,
      isLoading: notifier.isFetching,
      enableExcel: true,
      enableSearch: true,
      enablePDF: true,
      enableDateFilter: true,
      selectionMode: TableSelectionMode.single,
      onSearchChanged: notifier.search,
      initialDateRange: DateTimeRange(start: DateTime.now(), end: DateTime.now()),
      onDateRangeChanged: (range) {
        notifier.setStartDate(range?.start);
        notifier.setEndDate(range?.end);
      },
      onSingleSelectionChanged: (data) {
        notifier.selectHospitalization(data);
      },
    );
  }
}

// Dialog Fonksiyonları
Future<void> _onNewPatient(BuildContext context) async {
  final result = await showDialog(context: context, builder: (_) => PatientFormView());

  if (result != null && context.mounted) {
    context.read<HospitalizationNotifier>().getHospitalizations();
  }
}

Future<void> _onEditPatient(BuildContext context, {Patient? patient}) async {
  final originalPatient = patient?.copyWith();

  final result = await showDialog(
    context: context,
    builder: (_) => PatientFormView(patient: patient),
  );

  if ((result != null && result is Patient)) {
    final hasChanges = originalPatient?.isChanged(result) ?? true;
    if (hasChanges && context.mounted) {
      context.read<HospitalizationNotifier>().getHospitalizations();
      MessageUtils.showSuccessSnackbar(context, 'Hasta kayıtları güncellendi');
    }
  }
}

Future<void> _onNewHospitalization(BuildContext context) async {
  final result = await showDialog(context: context, builder: (_) => PatientListView());

  if (result == true && context.mounted) {
    context.read<HospitalizationNotifier>().getHospitalizations();
  }
}

Future<void> _onNewHospitalizationWithSelectedUser(BuildContext context, {Patient? data}) async {
  final bool? result = await showHospitalizationFormView(context, patient: data);

  if (result == true && context.mounted) {
    context.read<HospitalizationNotifier>().getHospitalizations();
  }
}

Future<void> _onEditHospitalization(BuildContext context, {Hospitalization? hospitalization, Patient? patient}) async {
  final bool? result = await showHospitalizationFormView(context, hospitalization: hospitalization, patient: patient);

  if (result == true && context.mounted) {
    context.read<HospitalizationNotifier>().getHospitalizations();
  }
}
