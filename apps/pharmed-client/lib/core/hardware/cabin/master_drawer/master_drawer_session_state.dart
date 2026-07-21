import 'master_drawer_stage.dart';

class MasterDrawerSessionState {
  const MasterDrawerSessionState({required this.stage});
  const MasterDrawerSessionState.initial() : stage = const MasterDrawerIdle();

  final MasterDrawerStage stage;

  MasterDrawerSessionState copyWith({MasterDrawerStage? stage}) => MasterDrawerSessionState(stage: stage ?? this.stage);
}
