import '../../../domain/entity/station.dart';

abstract class StationPersistence {
  /// Kullanıcının o an işlem yaptığı istasyon
  Station? get currentStation;
  Future<void> saveStation(Station? station);

  Future<void> clear();
}
