// [IEC 62304 §5.5]
// Çekmece oturum olayları — UI bağımsız minimal event seti.
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

sealed class DrawerSessionEvent {
  const DrawerSessionEvent();
}

/// Mobile drawer — step bilgisi yok.
final class DrawerOpening extends DrawerSessionEvent {
  const DrawerOpening();
}

/// Master drawer — adım adım durum bilgisi taşır.
final class DrawerOpeningWithStep extends DrawerSessionEvent {
  const DrawerOpeningWithStep({required this.step});

  final MasterDrawerOpeningStep step;
}

final class DrawerWaitingForPull extends DrawerSessionEvent {
  const DrawerWaitingForPull();
}

final class DrawerOpened extends DrawerSessionEvent {
  const DrawerOpened();
}

final class DrawerClosed extends DrawerSessionEvent {
  const DrawerClosed();
}

final class DrawerFailed extends DrawerSessionEvent {
  const DrawerFailed({required this.failure, this.detail});

  final Enum failure;
  final String? detail;
}
