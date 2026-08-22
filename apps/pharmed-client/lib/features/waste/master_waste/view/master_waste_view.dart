import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../core/hardware/hardware.dart';
import '../../../dashboard/dashboard.dart';
import '../notifier/master_waste_notifier.dart';
import '../notifier/master_waste_state.dart';
import 'master_waste_selection_view.dart';

class MasterWasteView extends ConsumerStatefulWidget {
  const MasterWasteView({super.key, required this.stationContext});

  final StationCabinsContext stationContext;

  @override
  ConsumerState<MasterWasteView> createState() => _MasterWasteViewState();
}

class _MasterWasteViewState extends ConsumerState<MasterWasteView> {
  // Hasta seçimi değiştiğinde tekrar terkar loading göstermemek için kullanılan flag.
  bool _hasBooted = false;

  bool _isPatientReady(PatientSelectionState s) => switch (s) {
    PatientSelectionReady() => true,
    PatientSelectionError() => true,
    _ => false,
  };

  @override
  void initState() {
    super.initState();

    final notifier = ref.read(masterWasteNotifierProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      notifier.init(widget.stationContext);
    });
  }

  @override
  Widget build(BuildContext context) {
    final patientState = ref.watch(patientSelectionNotifierProvider);
    final notifier = ref.read(masterWasteNotifierProvider.notifier);

    ref.listen(masterWasteNotifierProvider, (_, next) {
      // Donanım kuyruğu yok → isQueueError dalı gerekmiyor, refund/intake'in
      // aksine tek tip hata dinleme yeterli.
      if (next is MasterWasteError) {
        MessageUtils.showErrorSnackbar(context, next.failure.message(context));
        notifier.dismissError();
      }
    });

    if (!_hasBooted) {
      if (!_isPatientReady(patientState)) {
        // selectionView'ı (ve içindeki patient-selection init tetikleyicisini)
        // Offstage ile MOUNT EDİLMİŞ tutuyoruz — aksi halde
        // PatientSelectionNotifier'ın initState'teki init() çağrısı hiç
        // tetiklenmez ve _isPatientReady sonsuza kadar false kalır.
        return Stack(
          children: [
            Offstage(offstage: true, child: MasterWasteSelectionView()),
            const Center(child: MedLoadingIndicator()),
          ],
        );
      }
      _hasBooted = true;
    }

    return MasterWasteSelectionView();
  }
}
