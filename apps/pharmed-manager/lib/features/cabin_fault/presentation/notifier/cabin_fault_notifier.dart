import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';
import '../../../cabin/domain/usecase/get_cabin_layout_usecase.dart';
import '../../../cabin/domain/usecase/get_cabins_usecase.dart';
import '../../../cabin/shared/widgets/cabin_editor/cabin_editor_mixin.dart';

import '../../../cabin/domain/entity/drawer_group.dart';
import '../../domain/entity/cabin_fault.dart';
import '../../domain/usecase/get_cabin_faults_usecase.dart';

class CabinFaultNotifier extends ChangeNotifier with ApiRequestMixin, CabinEditorMixin {
  @override
  final GetCabinsUseCase cabinsUseCase;
  @override
  final GetCabinLayoutUseCase layoutUseCase;
  final GetCabinFaultsUseCase _getFaultsUseCase;

  CabinFaultNotifier({
    required this.cabinsUseCase,
    required this.layoutUseCase,
    required GetCabinFaultsUseCase getFaultsUseCase,
  }) : _getFaultsUseCase = getFaultsUseCase;

  List<CabinFault> _faults = [];
  List<CabinFault> get faults => _faults;

  @override
  void onLayoutRefreshed(List<DrawerGroup> groups) {
    _fetchFaults();
  }

  Future<void> _fetchFaults() async {
    if (selectedCabin == null) return;

    final res = await _getFaultsUseCase.call();
    res.when(
      ok: (data) {
        _faults = data;
        notifyListeners();
      },
      error: (e) => debugPrint("Arıza çekme hatası: $e"),
    );
  }

  /// Belirli bir slot'un AKTİF (endDate == null) arıza durumunu döner
  CabinFault? getFaultForSlot(int? slotId) {
    if (slotId == null) return null;

    // 1. Önce o slot'a ait tüm kayıtları filtrele
    // 2. Bunlar arasından endDate'i null olan (aktif olan) ilk kaydı bul
    try {
      return _faults.firstWhere((f) => f.slotId == slotId && f.endDate == null);
    } catch (e) {
      // Eğer aktif kayıt yoksa, varsayılan olarak "Çalışıyor" dön
      return CabinFault(slotId: slotId, workingStatus: CabinWorkingStatus.working);
    }
  }

  /// Belirli bir slot'un TÜM arıza geçmişini döner
  List<CabinFault> getActiveFaultsForSlot(int? slotId) {
    if (slotId == null) return [];

    // 1. Önce sadece o slotId'ye ait olanları filtrele
    final filteredList = _faults.where((f) => f.slotId == slotId).toList();

    // 2. Filtrelenmiş listeyi ters çevirip (en yeni en üstte) dön
    return filteredList.reversed.toList();
  }
}
