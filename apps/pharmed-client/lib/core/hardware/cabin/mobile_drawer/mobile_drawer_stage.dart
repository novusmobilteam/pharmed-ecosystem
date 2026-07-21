// [SWREQ-CABIN-OP-001] [IEC 62304 §5.5]
// Mobil kabin çekmece operasyon oturumunun aşamaları.
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

sealed class MobileDrawerStage {
  const MobileDrawerStage();
}

final class MobileDrawerIdle extends MobileDrawerStage {
  const MobileDrawerIdle();
}

final class MobileDrawerOpening extends MobileDrawerStage {
  const MobileDrawerOpening({required this.port, required this.slotId});
  final int port;
  final int slotId;
}

final class MobileDrawerOpened extends MobileDrawerStage {
  const MobileDrawerOpened({required this.port, required this.slotId});
  final int port;
  final int slotId;
}

final class MobileDrawerClosed extends MobileDrawerStage {
  const MobileDrawerClosed({required this.port, required this.slotId});
  final int port;
  final int slotId;
}

final class MobileDrawerFailed extends MobileDrawerStage {
  const MobileDrawerFailed({required this.failure, this.detail, this.port, this.slotId});

  final MobileDrawerFailure failure;
  final String? detail;
  final int? port;
  final int? slotId;
}

extension MobileDrawerStageX on MobileDrawerStage {
  bool get isIdle => this is MobileDrawerIdle;
  bool get isOpening => this is MobileDrawerOpening;
  bool get isOpened => this is MobileDrawerOpened;
  bool get isClosed => this is MobileDrawerClosed;
  bool get isFailed => this is MobileDrawerFailed;
  bool get isActive => isOpening || isOpened || isClosed;
}
