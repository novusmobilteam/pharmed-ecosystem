import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../features/auth/auth.dart';

/// Operatör oturumu boyunca onaylanmış şahitleri tutar. Ekran/notifier
/// ömründen bağımsızdır; operatör değişince kendiliğinden sıfırlanır.
class WitnessSessionStore {
  WitnessSessionStore({this.maxCount = 10});

  final int maxCount;
  int? _ownerUserId;
  final List<User> _witnesses = [];

  void _ensureOwner(int? operatorId) {
    if (_ownerUserId != operatorId) {
      _witnesses.clear();
      _ownerUserId = operatorId;
    }
  }

  List<User> witnessesFor(int? operatorId) {
    _ensureOwner(operatorId);
    return List.unmodifiable(_witnesses);
  }

  void remember(int? operatorId, User witness) {
    _ensureOwner(operatorId);
    _witnesses.removeWhere((w) => w.id == witness.id);
    _witnesses.insert(0, witness);
    if (_witnesses.length > maxCount) _witnesses.removeLast();
  }

  void clear() {
    _witnesses.clear();
    _ownerUserId = null;
  }
}

final witnessSessionStoreProvider = Provider<WitnessSessionStore>((ref) {
  final store = WitnessSessionStore();

  // Oturum hangi yoldan kapanırsa kapansın (manuel, timeout, token expiry)
  // şahit belleği temizlenir. Auth feature'ı bu store'u bilmek zorunda kalmaz.
  ref.listen(authNotifierProvider, (_, _) {
    final user = ref.read(authNotifierProvider.notifier).currentUser;
    if (user == null) store.clear();
  });

  return store;
});
