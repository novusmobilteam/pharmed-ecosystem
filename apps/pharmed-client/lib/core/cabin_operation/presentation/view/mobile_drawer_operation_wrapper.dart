// [SWREQ-CLI-CABIN-OP-004] [IEC 62304 §5.5]
// Mobil çekmece operasyonlarını saran widget.
//
// Tüm feature'lar (refill / pickup / return / fault) bu wrapper'ı kullanır.
// Sadece görsel sarımlayıcıdır — süreç mantığı MobileDrawerSessionNotifier'da,
// RFID ihtiyacı varsa RfidScanSessionNotifier ayrı yönetilir.
//
// Sınıf: Class A (görsel; karar üretmez)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../notifier/mobile_drawer_session_notifier.dart';
import '../widgets/mobile_drawer_status_banner.dart';

class MobileDrawerOperationWrapper extends ConsumerWidget {
  const MobileDrawerOperationWrapper({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stage = ref.watch(mobileDrawerSessionProvider).stage;

    return Stack(
      children: [
        Positioned.fill(child: child),
        Positioned(left: 20, bottom: 20, child: MobileDrawerStatusBanner(stage: stage)),
      ],
    );
  }
}
