import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/core.dart';
import 'station_persistence.dart';

class LocalStorageStationPersistence implements StationPersistence {
  final SharedPreferences _prefs;

  LocalStorageStationPersistence(this._prefs);

  static const _keyStation = 'station';

  @override
  Station? get currentStation {
    final String? jsonString = _prefs.getString(_keyStation);
    if (jsonString == null) return null;
    final Map<String, dynamic> map = jsonDecode(jsonString);

    return Station(
      id: map['id'],
      name: map['name'],
      drugStatus: OrderStatus.values.byName(map['drugStatus']),
      medicalConsumableStatus: OrderStatus.values.byName(map['medicalConsumableStatus']),
      services: (map['services'] as List).map((s) => HospitalService(id: s['id'], name: s['name'])).toList(),
    );
  }

  @override
  Future<void> saveStation(Station? station) async {
    if (station == null) {
      await _prefs.remove(_keyStation);
    } else {
      final mStation = {
        'id': station.id,
        'name': station.name,
        'drugStatus': station.drugStatus.name,
        'medicalConsumableStatus': station.medicalConsumableStatus.name,
        'services': station.services.map((s) => {'id': s.id, 'name': s.name}).toList(),
      };

      await _prefs.setString(_keyStation, jsonEncode(mStation));
    }
  }

  @override
  Future<void> clear() async {
    await _prefs.remove(_keyStation);
  }
}
