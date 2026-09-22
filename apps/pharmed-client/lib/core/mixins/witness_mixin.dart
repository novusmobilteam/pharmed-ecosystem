import 'package:flutter/widgets.dart';
import 'package:pharmed_core/pharmed_core.dart';

mixin WitnessMixin<T> on ChangeNotifier {
  int? get currentWitnessUserId;

  int idOf(T item);
  WitnessContext witnessContextOf(T item);
  T withWitness(T item, User witness);
  bool needsWitness(T item);

  final List<User> _confirmedWitnesses = [];

  bool canWitness(T item, User user) {
    final witnesses = witnessContextOf(item).witnesses;
    return witnesses.isEmpty || witnesses.any((w) => w.id == user.id);
  }

  void _remember(User user) {
    _confirmedWitnesses.removeWhere((w) => w.id == user.id);
    _confirmedWitnesses.insert(0, user);
    if (_confirmedWitnesses.length > 10) _confirmedWitnesses.removeLast();
  }

  /// [target], dialog'un açıldığı kalem — koşulsuz atanır. [pool]'daki diğer
  /// tüm kalemler arasında, şahidi olmayan ve bu şahide uygun olan HER kaleme
  /// (seçili olsun olmasın) otomatik yayılır.
  List<T> applyWitness({required T target, required User user, required List<T> pool}) {
    if (user.id != null && user.id == currentWitnessUserId) return pool;
    _remember(user);

    return pool.map((item) {
      if (idOf(item) == idOf(target)) {
        if (!needsWitness(item)) return item;
        return withWitness(item, user);
      }
      if (!needsWitness(item)) return item; // ← EKLENDİ — şahit gerekmeyen kalem hiç dokunulmaz
      if (witnessContextOf(item).witness != null) return item;
      return canWitness(item, user) ? withWitness(item, user) : item;
    }).toList();
  }

  /// Yeni fetch'ten gelen listeye, oturumdaki şahitleri (dialog açılmadan) uygular.
  List<T> reapplyConfirmedWitnesses(List<T> items) {
    if (_confirmedWitnesses.isEmpty) return items;
    return items.map((item) {
      if (witnessContextOf(item).witness != null) return item;
      if (!needsWitness(item)) return item;
      final matching = _confirmedWitnesses.cast<User?>().firstWhere((w) => canWitness(item, w!), orElse: () => null);
      return matching == null ? item : withWitness(item, matching);
    }).toList();
  }

  User? resolveExistingWitness(T? target) {
    if (target == null) return null;
    for (final w in _confirmedWitnesses) {
      if (w.id != null && w.id == currentWitnessUserId) continue;
      if (canWitness(target, w)) return w;
    }
    return null;
  }

  /// Bir kalemin witnessContext'ine değil, DOĞRUDAN bir witnesses listesine
  /// göre oturumdaki şahitlerden uygun olanı bulur. Muadil seçiminde gerekir —
  /// seçilen muadilin witnesses listesi orijinal kalemin witnessContext'inden
  /// bağımsızdır.
  User? resolveWitnessForList(List<User> witnesses) {
    for (final w in _confirmedWitnesses) {
      if (w.id != null && w.id == currentWitnessUserId) continue;
      if (witnesses.isEmpty || witnesses.any((x) => x.id == w.id)) return w;
    }
    return null;
  }

  void clearWitnesses() => _confirmedWitnesses.clear();
}
