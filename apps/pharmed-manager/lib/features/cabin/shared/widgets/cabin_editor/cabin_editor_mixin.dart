import 'package:flutter/material.dart';

import '../../../../../core/core.dart';

mixin CabinEditorMixin on ChangeNotifier, ApiRequestMixin {
  GetCabinsUseCase get cabinsUseCase;
  // GetCabinLayoutUseCase get layoutUseCase;

  List<Cabin> _cabins = [];
  List<Cabin> get cabins => _cabins;

  Cabin? _selectedCabin;
  Cabin? get selectedCabin => _selectedCabin;

  List<DrawerGroup> _layout = [];
  List<DrawerGroup> get layout => _layout;

  OperationKey fetchCabinOp = OperationKey.fetch();

  bool get isFetching => isLoading(fetchCabinOp);

  void setCabins(List<Cabin> list) => _cabins = list;
  void selectCabin(Cabin? cabin) => _selectedCabin = cabin;

  Future<void> initCabinContext({int? stationId, GetCabinsByStationUseCase? byStationUseCase}) async {
    await executeVoid(
      fetchCabinOp,
      operation: () async {
        final res = stationId != null && byStationUseCase != null
            ? await byStationUseCase.call(stationId)
            : await cabinsUseCase.call();

        return res.when(
          stale: (data, savedAt) async {
            _cabins = data;
            if (cabins.isNotEmpty && selectedCabin == null) {
              _selectedCabin = cabins.first;
            }
            if (selectedCabin != null) {
              await refreshLayout();
            }
            return Result.ok(null);
          },
          success: (data) async {
            _cabins = data;
            if (cabins.isNotEmpty && selectedCabin == null) {
              _selectedCabin = cabins.first;
            }
            if (selectedCabin != null) {
              await refreshLayout();
            }
            return Result.ok(null);
          },
          failure: (error) => Result.error(error),
        );
      },
    );
  }

  Future<void> refreshLayout() async {
    // if (selectedCabin == null) return;
    // final res = await layoutUseCase.call(selectedCabin!.id!);
    // res.when(
    //   ok: (data) {
    //     _layout = data;
    //     onLayoutRefreshed(data);
    //     notifyListeners();
    //   },
    //   error: (e) => debugPrint("Layout Error: $e"),
    // );
  }

  Future<void> loadLayout(int cabinId) async {
    // final res = await layoutUseCase.call(cabinId);
    // res.when(
    //   ok: (data) {
    //     _layout = data;
    //     onLayoutRefreshed(data);
    //     notifyListeners();
    //   },
    //   error: (_) {},
    // );
  }

  void onCabinChanged(Cabin cabin) {
    if (cabin.id == _selectedCabin?.id) return;
    _selectedCabin = cabin;
    loadLayout(cabin.id!);
  }

  void onLayoutRefreshed(List<DrawerGroup> groups) {}
}
