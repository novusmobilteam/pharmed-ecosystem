import 'package:flutter/material.dart';

import '../../../../core/core.dart';

import '../../../cabin/domain/entity/cabin_input_data.dart';
import '../../domain/entity/filling_list.dart';
import '../../domain/entity/filling_object.dart';
import '../../domain/useacase/filling_list_refill_usecase.dart';
import '../../domain/useacase/get_current_station_filling_lists_usecase.dart';
import '../../domain/useacase/get_filling_list_detail_usecase.dart';

class FillingListViewNotifier extends ChangeNotifier with ApiRequestMixin, SearchMixin<FillingList> {
  final GetCurrentStationFillingListsUseCase _getCurrentStationFillingListsUseCase;
  final GetFillingListDetailUseCase _getFillingListDetailUseCase;
  final FillingListRefillUseCase _refillUseCase;

  FillingListViewNotifier({
    required GetCurrentStationFillingListsUseCase getCurrentStationFillingListsUseCase,
    required GetFillingListDetailUseCase getFillingListDetailUseCase,
    required FillingListRefillUseCase refillUseCase,
  }) : _getCurrentStationFillingListsUseCase = getCurrentStationFillingListsUseCase,
       _getFillingListDetailUseCase = getFillingListDetailUseCase,
       _refillUseCase = refillUseCase;

  OperationKey fetchOp = OperationKey.fetch();
  OperationKey fetchDetailOp = OperationKey.custom('fetch-detail');

  FillingList? _fillingList;
  FillingList? get fillingList => _fillingList;

  List<FillingObject> _details = [];
  List<FillingObject> get details => _details;

  void getFillingLists() async {
    await execute(
      fetchOp,
      operation: () => _getCurrentStationFillingListsUseCase.call(),
      onData: (data) {
        allItems = data;
      },
    );
  }

  void selectFillingList(FillingList entity, {Function(String? msg)? onFailed, VoidCallback? onSuccess}) {
    _fillingList = entity;
    notifyListeners();
    getFillingListDetail(onFailed: (msg) => onFailed?.call(msg), onSuccess: () => onSuccess?.call());
  }

  void getFillingListDetail({Function(String? msg)? onFailed, VoidCallback? onSuccess}) async {
    final id = _fillingList?.id;
    if (id == null) return;
    await execute(
      fetchDetailOp,
      operation: () => _getFillingListDetailUseCase.call(id),
      onData: (data) {
        _details = data;
        onSuccess?.call();
        notifyListeners();
      },
      onFailed: (error) => onFailed?.call(error.message),
    );
  }

  Future<Result<void>> fillCabin(List<CabinInputData> inputs, int id) async {
    final data = inputs.map((e) {
      return FillingListRefillParams(
        id: id,
        cabinDrawerDetailId: e.cabinDrawerDetailId ?? 0,
        quantity: e.quantity,
        censusQuantity: e.censusQuantity,
        miadDate: e.miadDate,
      );
    }).toList();

    return await _refillUseCase.call(data);
  }
}
