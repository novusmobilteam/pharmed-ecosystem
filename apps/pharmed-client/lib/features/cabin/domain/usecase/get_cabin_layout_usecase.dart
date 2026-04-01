// [SWREQ-CORE-CABIN-UC-003]
// Sınıf: Class B

import 'package:pharmed_client/features/cabin_fault/domain/repository/i_cabin_fault_repository.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../../cabin_fault/domain/model/cabin_fault.dart';

class GetCabinLayoutUseCase {
  final ICabinRepository _repository;
  final ICabinFaultRepository _faultRepository;

  GetCabinLayoutUseCase(this._repository, this._faultRepository);

  Future<Result<List<DrawerGroup>>> call(int cabinId) async {
    try {
      // 1. Çekmece Yuvalarını (Slots) Çek
      final results = await Future.wait([
        _repository.getCabinSlots(cabinId),
        _faultRepository.getCabinFaultRecords(), // Arıza kayıtları
      ]);

      final slotsResult = results[0] as Result<List<DrawerSlot>>;
      final faultsResult = results[1] as Result<List<CabinFault>>;

      return slotsResult.when(
        error: Result.error,
        ok: (slots) async {
          if (slots.isEmpty) return Result.ok([]);

          final Map<int, CabinWorkingStatus> faultMap = {};

          faultsResult.when(
            ok: (faults) {
              for (var f in faults) {
                if (f.slotId != null && f.workingStatus != null && f.endDate == null) {
                  faultMap[f.slotId!] = f.workingStatus!;
                }
              }
            },
            error: (_) => {}, // Arıza kayıtları çekilemezse boş devam et (varsayılan working)
          );

          // 2. Sadece ID'si olan slot'lar için unit isteği yap
          final validSlots = slots.where((slot) => slot.id != null).toList();
          final unitRequests = validSlots.map((slot) => _repository.getDrawerUnits(slot.id!)).toList();
          final unitResults = await Future.wait(unitRequests);

          final drawerGroups = <DrawerGroup>[];

          for (int i = 0; i < validSlots.length; i++) {
            final slot = validSlots[i];
            final unitResult = unitResults[i];

            final List<DrawerUnit> units = unitResult.when(
              success: (data) {
                return data.map((unit) {
                  final status = faultMap[unit.id] ?? CabinWorkingStatus.working;

                  return unit.copyWith(workingStatus: status);
                }).toList();
              },
              stale: (data, savedAt) {
                return data.map((unit) {
                  final status = faultMap[unit.id] ?? CabinWorkingStatus.working;

                  return unit.copyWith(workingStatus: status);
                }).toList();
              },
              failure: (error) => [],
            );

            units.sort((a, b) => (a.compartmentNo ?? 0).compareTo(b.compartmentNo ?? 0));

            // Slot'un kendi statüsü, içindeki herhangi bir unit arızalıysa 'faulty' görünebilir
            // veya slot seviyesini tamamen bağımsız bırakabilirsin.
            drawerGroups.add(DrawerGroup(slot: slot, units: units));
          }

          drawerGroups.sort((a, b) => a.orderNumber.compareTo(b.orderNumber));
          return Result.ok(drawerGroups);
        },
      );
    } catch (e) {
      return Result.error(ServiceException(message: 'Kabin düzeni alınamadı: ${e.toString()}', statusCode: 404));
    }
  }
}
