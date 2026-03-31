// [SWREQ-SETUP-DATA-001] [IEC 62304 §5.5]
// Mock istasyon repository — AppFlavor.mock için.
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class MockStationRepository implements IStationRepository {
  static final _stations = [
    Station(id: 1, name: 'Kardiyoloji'),
    Station(id: 2, name: 'Nöroloji'),
    Station(id: 3, name: 'Ortopedi'),
    Station(id: 4, name: 'Dahiliye'),
    Station(id: 5, name: 'Genel Cerrahi'),
  ];

  @override
  Future<Result<ApiResponse<List<Station>>>> getStations({int? skip, int? take, String? search}) async {
    await Future.delayed(const Duration(milliseconds: 600));

    var result = _stations;

    if (search != null && search.isNotEmpty) {
      result = result.where((s) => s.name?.toLowerCase().contains(search.toLowerCase()) ?? false).toList();
    }

    return Result.ok(ApiResponse(data: result, statusCode: 200, isSuccess: true, totalCount: result.length));
  }

  @override
  Future<Result<Station?>> getStation(int stationId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final station = _stations.where((s) => s.id == stationId).firstOrNull;
    return Result.ok(station);
  }

  @override
  Future<Result<Station?>> getCurrentStation() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return Result.ok(_stations.first);
  }

  @override
  Future<Result<void>> createStation(Station station) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return const Result.ok(null);
  }

  @override
  Future<Result<void>> updateStation(Station station) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return const Result.ok(null);
  }

  @override
  Future<Result<void>> deleteStation(Station station) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return const Result.ok(null);
  }

  @override
  Future<Result<void>> updateStationMacAddress(int stationId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return const Result.ok(null);
  }
}
