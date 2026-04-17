import 'package:pharmed_core/pharmed_core.dart';

abstract interface class FaultPanelState {
  bool get isNewRecord;
  bool get canSubmit;
  CabinWorkingStatus get selectedStatus;
  String? get description;
  List<IFaultRecord> get faultHistory;
  IFaultRecord? get activeFault;
}
