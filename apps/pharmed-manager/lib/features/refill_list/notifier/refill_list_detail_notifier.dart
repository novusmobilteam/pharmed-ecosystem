import 'package:flutter/material.dart';

import '../../../core/core.dart';

import '../../../old_features/cabin/domain/entity/cabin_input_data.dart';

class RefillListDetailNotifier extends ChangeNotifier with ApiRequestMixin, SearchMixin<RefillList> {
  final GetCurrentStationRefillListsUseCase _getCurrentStationRefillList;
  final GetRefillListDetailUseCase _getRefillListDetail;
  final RefillListRefillUseCase _refill;

  RefillListDetailNotifier({
    required GetCurrentStationRefillListsUseCase getCurrentStationRefillList,
    required GetRefillListDetailUseCase getRefillListDetail,
    required RefillListRefillUseCase refill,
  }) : _getCurrentStationRefillList = getCurrentStationRefillList,
       _getRefillListDetail = getRefillListDetail,
       _refill = refill;

  OperationKey fetchOp = OperationKey.fetch();
  OperationKey fetchDetailOp = OperationKey.custom('fetch-detail');

  RefillList? _fillingList;
  RefillList? get fillingList => _fillingList;

  List<RefillObject> _details = [];
  List<RefillObject> get details => _details;

  void getRefillLists() async {
    await execute(
      fetchOp,
      operation: () => _getCurrentStationRefillList.call(),
      onData: (data) {
        allItems = data;
      },
    );
  }

  void selectRefillList(RefillList entity, {Function(String? msg)? onFailed, VoidCallback? onSuccess}) {
    _fillingList = entity;
    notifyListeners();
    getRefillListDetail(onFailed: (msg) => onFailed?.call(msg), onSuccess: () => onSuccess?.call());
  }

  void getRefillListDetail({Function(String? msg)? onFailed, VoidCallback? onSuccess}) async {
    final id = _fillingList?.id;
    if (id == null) return;
    await execute(
      fetchDetailOp,
      operation: () => _getRefillListDetail.call(id),
      onData: (data) {
        _details = data;
        onSuccess?.call();
        notifyListeners();
      },
      onFailed: (error) => onFailed?.call(error.message),
    );
  }

  Future<Result<void>> refill(List<CabinInputData> inputs, int id) async {
    final data = inputs.map((e) {
      return FillingListRefillParams(
        id: id,
        cabinDrawerDetailId: e.cabinDrawerDetailId ?? 0,
        quantity: e.quantity,
        censusQuantity: e.censusQuantity,
        miadDate: e.miadDate,
      );
    }).toList();

    return await _refill.call(data);
  }
}
