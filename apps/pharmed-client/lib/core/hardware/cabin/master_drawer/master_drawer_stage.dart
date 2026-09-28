// [SWREQ-CLI-CABIN-OP-010] [IEC 62304 §5.5]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

sealed class MasterDrawerStage {
  const MasterDrawerStage();

  bool get isActive => switch (this) {
    MasterDrawerIdle() => false,
    MasterDrawerClosed() => false,
    MasterDrawerFailed() => false,
    _ => true,
  };
}

final class MasterDrawerIdle extends MasterDrawerStage {
  const MasterDrawerIdle();
}

final class MasterDrawerOpening extends MasterDrawerStage {
  const MasterDrawerOpening({required this.step});

  final MasterDrawerOpeningStep step;
}

final class MasterDrawerWaitingForPull extends MasterDrawerStage {
  const MasterDrawerWaitingForPull();
}

final class MasterDrawerOpeningLid extends MasterDrawerStage {
  const MasterDrawerOpeningLid();
}

final class MasterDrawerOpened extends MasterDrawerStage {
  const MasterDrawerOpened();
}

final class MasterDrawerWaitingForClose extends MasterDrawerStage {
  const MasterDrawerWaitingForClose();
}

final class MasterDrawerClosed extends MasterDrawerStage {
  const MasterDrawerClosed();
}

/// Kübik: kullanıcı gözü onayladı, kapağın fiziksel kapanması bekleniyor.
final class MasterDrawerWaitingForLidClose extends MasterDrawerStage {
  const MasterDrawerWaitingForLidClose();
}

/// Kübik: aktif gözün kapağı fiziksel olarak kapandı (ac → kp). Ana çekmece
/// hâlâ açık — terminal DEĞİL.
final class MasterDrawerLidClosed extends MasterDrawerStage {
  const MasterDrawerLidClosed();
}

final class MasterDrawerLidFailed extends MasterDrawerStage {
  const MasterDrawerLidFailed({required this.failure, this.detail});

  final MasterDrawerFailure failure;
  final String? detail;
}

final class MasterDrawerFailed extends MasterDrawerStage {
  const MasterDrawerFailed({required this.failure, this.detail});

  final MasterDrawerFailure failure;
  final String? detail;
}
