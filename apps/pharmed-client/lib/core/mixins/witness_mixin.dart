import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../cache/witness_session_store.dart';

mixin WitnessMixin<T> on ChangeNotifier {
  int? get currentWitnessUserId;
  WitnessSessionStore get witnessStore;

  int idOf(T item);
  WitnessContext witnessContextOf(T item);
  T withWitness(T item, User witness);
  bool needsWitness(T item);

  List<User> get _confirmedWitnesses => witnessStore.witnessesFor(currentWitnessUserId);

  bool canWitness(T item, User user) {
    final witnesses = witnessContextOf(item).witnesses;
    return witnesses.isEmpty || witnesses.any((w) => w.id == user.id);
  }

  /// [target], dialog'un açıldığı kalem — koşulsuz atanır. [pool]'daki diğer
  /// tüm kalemler arasında, şahidi olmayan ve bu şahide uygun olan HER kaleme
  /// (seçili olsun olmasın) otomatik yayılır.
  List<T> applyWitness({required T target, required User user, required List<T> pool}) {
    if (user.id != null && user.id == currentWitnessUserId) return pool;
    witnessStore.remember(currentWitnessUserId, user);

    return pool.map((item) {
      if (!needsWitness(item)) return item;
      if (idOf(item) == idOf(target)) return withWitness(item, user);
      if (witnessContextOf(item).witness != null) return item;
      return canWitness(item, user) ? withWitness(item, user) : item;
    }).toList();
  }

  /// Yeni fetch'ten gelen listeye, oturumdaki şahitleri (dialog açılmadan) uygular.
  List<T> reapplyConfirmedWitnesses(List<T> items) {
    final confirmed = _confirmedWitnesses;
    if (confirmed.isEmpty) return items;
    return items.map((item) {
      if (!needsWitness(item)) return item;
      if (witnessContextOf(item).witness != null) return item;
      final matching = confirmed.firstWhereOrNull(
        (w) => !(w.id != null && w.id == currentWitnessUserId) && canWitness(item, w),
      );
      return matching == null ? item : withWitness(item, matching);
    }).toList();
  }

  User? resolveExistingWitness(T? target) {
    if (target == null) return null;
    return _confirmedWitnesses.firstWhereOrNull(
      (w) => !(w.id != null && w.id == currentWitnessUserId) && canWitness(target, w),
    );
  }

  /// Bir kalemin witnessContext'ine değil, DOĞRUDAN bir witnesses listesine
  /// göre oturumdaki şahitlerden uygun olanı bulur. Muadil seçiminde gerekir —
  /// seçilen muadilin witnesses listesi orijinal kalemin witnessContext'inden
  /// bağımsızdır.
  User? resolveWitnessForList(List<User> witnesses) {
    return _confirmedWitnesses.firstWhereOrNull(
      (w) =>
          !(w.id != null && w.id == currentWitnessUserId) && (witnesses.isEmpty || witnesses.any((x) => x.id == w.id)),
    );
  }

  void clearWitnesses() => _confirmedWitnesses.clear();
}
