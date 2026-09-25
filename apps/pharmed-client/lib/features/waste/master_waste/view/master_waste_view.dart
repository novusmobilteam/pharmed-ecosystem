import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/widgets/empty_widgets/no_data_view.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../widgets/empty_widgets/empty_selection_view.dart';
import '../../../../widgets/hospitalization_panel/hospitalization_panel.dart';
import '../../../../widgets/widgets.dart';
import '../../../dashboard/dashboard.dart';
import '../notifier/master_waste_selection_notifier.dart';
import '../notifier/waste_medicine_group.dart';

part 'master_waste_selection_view.dart';

class MasterWasteView extends ConsumerStatefulWidget {
  const MasterWasteView({super.key, required this.stationContext});

  final StationCabinsContext stationContext;

  @override
  ConsumerState<MasterWasteView> createState() => _MasterWasteViewState();
}

class _MasterWasteViewState extends ConsumerState<MasterWasteView> {
  @override
  void initState() {
    super.initState();

    final notifier = ref.read(masterWasteSelectionNotifierProvider.notifier);

    notifier.setCallbacks(
      key: notifier.submitOp,
      onError: (msg) {
        if (!mounted) return;
        MessageUtils.showErrorSnackbar(context, msg);
      },
      onSuccess: (msg) {
        if (!mounted) return;
        MessageUtils.showSuccessSnackbar(context, msg);
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      notifier.init(widget.stationContext);
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(masterWasteSelectionNotifierProvider);

    return MasterWasteSelectionView2(menu: widget.stationContext.menu, notifier: notifier);
  }
}
