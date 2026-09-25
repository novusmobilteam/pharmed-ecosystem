import 'package:flutter_riverpod/flutter_riverpod.dart';

/// [HAZ-009] Oturum zaman aşımı uyarısının kalan saniyesi. `null` = uyarı yok.
/// YALNIZCA AuthNotifier yazar; UI (banner) sadece okur.
final sessionCountdownProvider = NotifierProvider<SessionCountdownNotifier, int?>(SessionCountdownNotifier.new);

class SessionCountdownNotifier extends Notifier<int?> {
  @override
  int? build() => null;

  void set(int? seconds) => state = seconds;
}
