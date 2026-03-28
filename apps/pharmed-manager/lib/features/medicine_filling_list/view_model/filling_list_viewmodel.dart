import 'package:flutter/material.dart';

import '../../../core/core.dart';
import 'package:pharmed_manager/core/core.dart';

import '../../cabin/domain/entity/cabin_input_data.dart';
import '../../filling_list/data/repository/filling_list_repository.dart';
import '../../filling_list/domain/entity/filling_detail.dart';
import '../../filling_list/domain/entity/filling_list.dart';
import '../../filling_list/domain/useacase/filling_list_refill_usecase.dart';

class FillingListViewModel extends ChangeNotifier with ApiRequestMixin, SearchMixin<FillingList> {
  final FillingListRepository _fillingListRepository;

  FillingListViewModel({required FillingListRepository fillingListRepository})
    : _fillingListRepository = fillingListRepository;

  // Operation Keys
  OperationKey fetchMedicineKey = OperationKey.fetch();
  OperationKey fetchDetailKey = OperationKey.custom('medicine-info');

  // Status
  bool get isError => isFailed(fetchMedicineKey) || allItems.isEmpty;

  // State
  List<FillingDetail> _allDetails = [];
  List<FillingDetail> _details = [];
  List<FillingDetail> get details => _details;

  void searchDetails(String query) {
    if (query.isEmpty) {
      _details = List.from(_allDetails);
    } else {
      final normalizedQuery = query.toLowerCase();
      _details = _allDetails.where((detail) {
        final drugName = detail.medicine?.name?.toLowerCase() ?? '';
        final barcode = detail.medicine?.barcode.toString() ?? '';

        return drugName.contains(normalizedQuery) || barcode.contains(normalizedQuery);
      }).toList();
    }
    notifyListeners();
  }

  // Functions
  void fetchFillingRecords() async {
    await execute(
      fetchMedicineKey,
      operation: () => _fillingListRepository.getCurrentStationFillingLists(),
      onData: (data) => allItems = data,
    );
  }

  void fetchFillingDetail(int recordId) async {
    await executeVoid(
      fetchDetailKey,
      operation: () async {
        final response = await _fillingListRepository.getFillingListDetail(recordId);
        _allDetails = response.data ?? [];
        _details = List.from(_allDetails);
        return response;
      },
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

    return await _fillingListRepository.fill(data);
  }
}
