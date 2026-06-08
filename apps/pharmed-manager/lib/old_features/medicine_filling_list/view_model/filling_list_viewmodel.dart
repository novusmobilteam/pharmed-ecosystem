// import 'package:flutter/material.dart';

// import '../../../core/core.dart';

// import '../../cabin/domain/entity/cabin_input_data.dart';

// class FillingListViewModel extends ChangeNotifier with ApiRequestMixin, SearchMixin<RefillList> {
//   final FillingListRepository _fillingListRepository;

//   FillingListViewModel({required FillingListRepository fillingListRepository})
//     : _fillingListRepository = fillingListRepository;

//   // Operation Keys
//   OperationKey fetchMedicineKey = OperationKey.fetch();
//   OperationKey fetchDetailKey = OperationKey.custom('medicine-info');

//   // Status
//   bool get isError => isFailed(fetchMedicineKey) || allItems.isEmpty;

//   // State
//   List<RefillListDetail> _allDetails = [];
//   List<RefillListDetail> _details = [];
//   List<RefillListDetail> get details => _details;

//   void searchDetails(String query) {
//     if (query.isEmpty) {
//       _details = List.from(_allDetails);
//     } else {
//       final normalizedQuery = query.toLowerCase();
//       _details = _allDetails.where((detail) {
//         final drugName = detail.medicine?.name?.toLowerCase() ?? '';
//         final barcode = detail.medicine?.barcode.toString() ?? '';

//         return drugName.contains(normalizedQuery) || barcode.contains(normalizedQuery);
//       }).toList();
//     }
//     notifyListeners();
//   }

//   // Functions
//   void fetchFillingRecords() async {
//     await execute(
//       fetchMedicineKey,
//       operation: () => _fillingListRepository.getCurrentStationFillingLists(),
//       onData: (data) => allItems = data,
//     );
//   }

//   void fetchFillingDetail(int recordId) async {
//     await executeVoid(
//       fetchDetailKey,
//       operation: () async {
//         final response = await _fillingListRepository.getFillingListDetail(recordId);
//         _allDetails = response.data ?? [];
//         _details = List.from(_allDetails);
//         return response;
//       },
//     );
//   }

//   Future<Result<void>> fillCabin(List<CabinInputData> inputs, int id) async {
//     final data = inputs.map((e) {
//       return FillingListRefillParams(
//         id: id,
//         cabinDrawerDetailId: e.cabinDrawerDetailId ?? 0,
//         quantity: e.quantity,
//         censusQuantity: e.censusQuantity,
//         miadDate: e.miadDate,
//       );
//     }).toList();

//     return await _fillingListRepository.fill(data);
//   }
// }
