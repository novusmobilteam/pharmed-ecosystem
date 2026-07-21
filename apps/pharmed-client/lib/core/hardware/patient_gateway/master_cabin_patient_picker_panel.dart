// [SWREQ-CLI-PATIENT-007] [IEC 62304 §5.5]
// Master kabin işlemleri (alım / iade / fire-imha) için ORTAK hasta seçim
// PANELİ. PatientSelectionView'ın dialog yerine OperationPanelBase içinde
// yaşayan, yeniden kullanılabilir sürümüdür.
//
// Mantık PatientSelectionNotifier'da KALIR (order modu, servis, filtre,
// Hastalarım, arama, acil hasta). Bu widget yalnızca o notifier'ın panel-içi
// arayüzüdür ve seçilen hastayı + türetilen IntakeType'ı dışarı verir.
//
// Kullanım (her master işlem ekranı kendi notifier'ına bağlar):
//
//   OperationPanelBase(
//     mode: CabinOperationMode.intake,
//     child: switch (state) {
//       XxxNoPatient() => CabinPatientPickerPanel(
//         onPatientSelected: ref.read(xxxNotifierProvider.notifier).selectPatient,
//       ),
//       _ => ...,
//     },
//   );
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../hardware.dart';

class CabinPatientPickerPanel extends ConsumerStatefulWidget {
  const CabinPatientPickerPanel({super.key, required this.onPatientSelected});

  /// Hasta seçildiğinde (veya acil hasta oluşturulduğunda) tetiklenir.
  /// IntakeType, o anki order modundan (orderless/ordered) türetilir.
  final void Function(Hospitalization hospitalization, IntakeType intakeType) onPatientSelected;

  @override
  ConsumerState<CabinPatientPickerPanel> createState() => _CabinPatientPickerPanelState();
}

class _CabinPatientPickerPanelState extends ConsumerState<CabinPatientPickerPanel> {
  @override
  void initState() {
    super.initState();
    // Panel açıldığında listeyi tazele (her giriş/değiştir'de güncel liste).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(patientSelectionNotifierProvider.notifier).init();
    });
  }

  void _emit(Hospitalization hospitalization) {
    final s = ref.read(patientSelectionNotifierProvider);
    final isOrderless = s is PatientSelectionReady && s.isOrderless;
    widget.onPatientSelected(hospitalization, isOrderless ? IntakeType.orderless : IntakeType.ordered);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(patientSelectionNotifierProvider);
    final notifier = ref.read(patientSelectionNotifierProvider.notifier);

    ref.listen(patientSelectionNotifierProvider, (_, next) {
      if (next is PatientSelectionError) {
        MessageUtils.showErrorSnackbar(context, next.message);
        notifier.dismissError();
      }
    });

    final ready = switch (state) {
      PatientSelectionReady r => r,
      PatientSelectionError(previousState: PatientSelectionReady r) => r,
      _ => null,
    };

    if (ready == null) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Toolbar(state: ready, notifier: notifier),
        if (ready.isOrderless && ready.viewType == PatientViewType.allPatients) ...[
          const SizedBox(height: 10),
          _ServiceFilterBar(state: ready, notifier: notifier),
        ],
        const SizedBox(height: 12),
        Expanded(
          child: _PatientList(state: ready, onSelected: _emit),
        ),
        if (ready.isUrgentPatientButtonVisible) ...[
          const SizedBox(height: 8),
          _UrgentBar(state: ready, notifier: notifier, onCreated: _emit),
        ],
      ],
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({required this.state, required this.notifier});

  final PatientSelectionReady state;
  final PatientSelectionNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 10,
      children: [
        MedTextInputField(
          initialValue: state.search,
          hintText: context.l10n.patientPicker_searchHint,
          prefixIcon: Icon(PhosphorIcons.magnifyingGlass(), color: MedColors.text3),
          onChanged: (v) => notifier.onSearchChanged(v ?? ''),
        ),
        Row(
          spacing: 8,
          children: [
            if (state.isStatusButtonVisible)
              MedToggleButton(
                label: state.isOrderless
                    ? context.l10n.patientPicker_orderlessToggleLabel
                    : context.l10n.patientPicker_orderedToggleLabel,
                onTap: notifier.toggleOrderlessStatus,
              ),
            MedToggleButton(
              label: context.l10n.patientPicker_myPatientsToggleLabel,
              onTap: notifier.togglePatientView,
              size: MedToggleSize.sm,
              selected: state.viewType == PatientViewType.myPatients,
            ),
            if (!state.isOrderless) _FilterMenu(filter: state.filter, onChanged: notifier.changeFilter),
          ],
        ),
      ],
    );
  }
}

class _FilterMenu extends StatelessWidget {
  const _FilterMenu({required this.filter, required this.onChanged});

  final PatientFilterType filter;
  final ValueChanged<PatientFilterType> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<PatientFilterType>(
      onSelected: onChanged,
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(borderRadius: MedRadius.mdAll),
      itemBuilder: (context) =>
          PatientFilterType.values.map((f) => PopupMenuItem(value: f, child: Text(f.label))).toList(),
      child: MedToggleButton(label: filter.label, selected: false, size: MedToggleSize.sm),
    );
  }
}

class _ServiceFilterBar extends StatelessWidget {
  const _ServiceFilterBar({required this.state, required this.notifier});

  final PatientSelectionReady state;
  final PatientSelectionNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final services = state.availableServices;
    if (services.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: services.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final service = services[i];
          final selected = state.selectedService?.id == service.id;
          return MedToggleButton(
            label: service.name ?? '—',
            selected: selected,
            size: MedToggleSize.sm,
            onTap: () => notifier.toggleService(service),
          );
        },
      ),
    );
  }
}

// ── Hasta listesi (panel dar olduğu için tek kolon) ──────────────────────────────

class _PatientList extends StatelessWidget {
  const _PatientList({required this.state, required this.onSelected});

  final PatientSelectionReady state;
  final ValueChanged<Hospitalization> onSelected;

  @override
  Widget build(BuildContext context) {
    if (state.isFetching) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    final patients = state.visiblePatients;
    if (patients.isEmpty) {
      return const EmptyStateWidget(variant: EmptyStateVariant.noData);
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: patients.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, i) => _PatientRow(hospitalization: patients[i], onTap: () => onSelected(patients[i])),
    );
  }
}

class _PatientRow extends StatelessWidget {
  const _PatientRow({required this.hospitalization, required this.onTap});

  final Hospitalization hospitalization;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final patient = hospitalization.patient;
    final name = patient?.fullName ?? '—';
    final bed = hospitalization.bed;
    final location = [if (bed?.room?.name != null) bed!.room!.name!, if (bed?.name != null) bed!.name!].join(' · ');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: MedSpacing.insetLg,
        decoration: BoxDecoration(
          color: MedColors.surface,
          borderRadius: MedRadius.lgAll,
          border: Border.all(color: MedColors.border),
          boxShadow: MedShadows.sm,
        ),
        child: Row(
          spacing: 12,
          children: [
            MedAvatar(initials: patient?.initials ?? '?', palette: AvatarPalette.blue, size: 38),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(name, style: MedTextStyles.titleSm(), maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (location.trim().isNotEmpty) Text(location, style: MedTextStyles.monoXs(color: MedColors.text3)),
                ],
              ),
            ),
            Icon(PhosphorIcons.caretRight(PhosphorIconsStyle.bold), size: 16, color: MedColors.text4),
          ],
        ),
      ),
    );
  }
}

// ── Acil hasta oluştur barı ──────────────────────────────────────────────────────

class _UrgentBar extends StatelessWidget {
  const _UrgentBar({required this.state, required this.notifier, required this.onCreated});

  final PatientSelectionReady state;
  final PatientSelectionNotifier notifier;
  final ValueChanged<Hospitalization> onCreated;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(PhosphorIcons.warningCircle(), size: 16, color: MedColors.text3),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            context.l10n.patientPicker_urgentPatientHint,
            style: MedTextStyles.bodySm(color: MedColors.text3),
          ),
        ),
        const SizedBox(width: 12),
        MedButton(
          label: context.l10n.patientPicker_createUrgentPatientButton,
          size: MedButtonSize.sm,
          isLoading: state.isCreatingUrgent,
          onPressed: () => notifier.createUrgentPatient(
            onSuccess: (h) {
              MessageUtils.showSuccessSnackbar(context, context.l10n.patientPicker_urgentPatientCreatedMessage);
              onCreated(h);
            },
            onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
          ),
        ),
      ],
    );
  }
}
