// [SWREQ-CLI-CABIN-OP-001]
// Mobil çekmece oturumunun anlık durumu.
// Wrapper bunu izler, banner render eder. Feature notifier'ları stage geçişlerini
// ref.listen ile yakalar.
//
// Sınıf: Class B

import 'mobile_drawer_stage.dart';

class MobileDrawerSessionState {
  const MobileDrawerSessionState({required this.stage});

  const MobileDrawerSessionState.initial() : stage = const MobileDrawerIdle();

  final MobileDrawerStage stage;

  MobileDrawerSessionState copyWith({MobileDrawerStage? stage}) {
    return MobileDrawerSessionState(stage: stage ?? this.stage);
  }
}
