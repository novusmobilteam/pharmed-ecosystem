// features/intake/patient_selection/view/intake_patient_selection_panel.dart
//
// [SWREQ-CLI-MINTAKE-XXX] [IEC 62304 §5.5]

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../notifier/patient_selection_notifier.dart';
import '../notifier/patient_selection_state.dart';

import 'patient_selection_guide.dart';
part 'urgent_patient_sheet.dart';

class IntakePatientSelectionPanel extends ConsumerStatefulWidget {
  const IntakePatientSelectionPanel({
    super.key,
    required this.onPatientSelected,
    required this.selectedPatient,
    this.isLocked = false,
  });

  /// Hasta seçildiğinde (normal tıklama veya acil hasta oluşturma sonrası)
  /// tetiklenir. Tab bilgisi burada verilir çünkü artık iki tab TEK panelde
  /// yaşıyor — çağıran view hangi downstream notifier'a (masterIntake /
  /// redirectedIntakeOrders) yönleneceğine bununla karar verir.
  final void Function(Hospitalization hospitalization, IntakePatientTab tab, bool isOrderless) onPatientSelected;

  final Hospitalization? selectedPatient;
  final bool isLocked;

  @override
  ConsumerState<IntakePatientSelectionPanel> createState() => _IntakePatientSelectionPanelState();
}

class _IntakePatientSelectionPanelState extends ConsumerState<IntakePatientSelectionPanel>
    with SingleTickerProviderStateMixin {
  bool _isCreateSheetOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final current = ref.read(intakePatientSelectionNotifierProvider);
      // Remount her zaman "temiz başlangıç" anlamına gelmiyor — alım
      // kuyruğu bitip RootExecuting → RootSelection'a dönüldüğünde bu
      // widget yeniden mount edilir ama hasta seçim state'i (tab, filtre,
      // arama, viewType) korunmalıdır. Yalnızca provider hiç init
      // edilmemişse (uygulama açılışı / ekran ilk kez kuruluyor) fetch
      // tetiklenir.
      if (current is IntakePatientSelectionLoading) {
        ref.read(intakePatientSelectionNotifierProvider.notifier).init();
      }
    });
  }

  void _openCreateSheet() => setState(() => _isCreateSheetOpen = true);
  void _closeCreateSheet() => setState(() => _isCreateSheetOpen = false);

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(intakePatientSelectionNotifierProvider);
    final notifier = ref.read(intakePatientSelectionNotifierProvider.notifier);

    ref.listen(intakePatientSelectionNotifierProvider, (_, next) {
      if (next is IntakePatientSelectionError) {
        MessageUtils.showErrorSnackbar(context, next.message);
        notifier.dismissError();
      }
    });

    final ready = switch (state) {
      IntakePatientSelectionReady r => r,
      IntakePatientSelectionError(previousState: final r) => r,
      _ => null,
    };

    // MasterCabinRootScaffold'un extraBootGate'i hazır olana kadar bu panel
    // Offstage ile mount tutulur — buraya normalde düşülmemeli.
    if (ready == null) return const SizedBox.shrink();

    return ClipRRect(
      borderRadius: MedRadius.lgAll,
      child: Stack(
        children: [
          IntakePatientSelectionGuide(
            state: ready,
            selectedPatient: widget.selectedPatient,
            isLocked: widget.isLocked || ready.isFetching,
            onTabChanged: notifier.switchTab,
            onSearchChanged: notifier.onSearchChanged,
            onTogglePatientView: notifier.togglePatientView,
            onToggleOrderlessStatus: notifier.toggleOrderlessStatus,
            onPatientTap: (h) => widget.onPatientSelected(h, ready.tab, ready.isOrderless),
            onServiceFilterApply: (result) {
              if (result.containsKey('service')) notifier.toggleService(result['service'] as HospitalService?);
              if (result.containsKey('filter')) notifier.changeFilter(result['filter'] as PatientFilterType);
            },
            onEnterUrgentTab: notifier.enterUrgentCreateMode,
            onExitUrgentTab: notifier.exitUrgentCreateMode,
            onOpenCreateSheet: _openCreateSheet,
            // onCreateUrgentPatient: () => notifier.createUrgentPatient(
            //   onCreated: (h) {
            //     MessageUtils.showSuccessSnackbar(context, context.l10n.patientPicker_urgentPatientCreatedMessage);
            //     widget.onPatientSelected(h, IntakePatientTab.prescriptions, true);
            //   },
            //   onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
            // ),
          ),

          if (_isCreateSheetOpen) ...[
            Positioned.fill(
              child: GestureDetector(
                onTap: _closeCreateSheet,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 180),
                  opacity: 1,
                  child: Container(color: Colors.black.withValues(alpha: 0.05)),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: TweenAnimationBuilder<Offset>(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                tween: Tween(begin: const Offset(0, 1), end: Offset.zero),
                builder: (context, offset, child) => FractionalTranslation(translation: offset, child: child),
                child: _UrgentPatientCreateSheetContent(
                  services: ready.availableServices,
                  onCancel: _closeCreateSheet,
                  onCreated: (h) {
                    _closeCreateSheet();
                    widget.onPatientSelected(h, IntakePatientTab.prescriptions, true);
                  },
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
