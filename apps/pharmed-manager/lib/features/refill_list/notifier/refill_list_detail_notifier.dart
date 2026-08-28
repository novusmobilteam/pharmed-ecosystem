import 'package:flutter/material.dart';

import '../../../core/core.dart';

class RefillListDetailNotifier extends ChangeNotifier with ApiRequestMixin {
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

  List<RefillList> _items = [];
  List<RefillList> get items => _items;

  void getRefillLists() async {
    await execute(
      fetchOp,
      operation: () => _getCurrentStationRefillList.call(),
      onData: (data) {
        _items = data;
        notifyListeners();
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

class CabinInputData {
  final int materialId;
  final int? cabinDrawerDetailId; // Hangi detay ID'ye kayıt atılacak
  final int? cabinDrawerId;
  final double quantity; // Girilen Dolum Miktarı
  final double censusQuantity; // Girilen Sayım Miktarı
  final DateTime? miadDate; // Seçilen Tarih (boş göz için null)
  final int? shelfNo; // Raf/Sıra No (Standart çekmeceler için 1,2,3...)
  final int? compartmentNo;
  final int? stockId;
  final MedicineAssignment? assignment;

  CabinInputData({
    required this.materialId,
    required this.cabinDrawerDetailId,
    required this.quantity,
    required this.censusQuantity,
    this.miadDate,
    this.cabinDrawerId,
    this.shelfNo,
    this.compartmentNo,
    this.stockId,
    this.assignment,
  });

  Map<String, dynamic> toJson() {
    return {
      "materialId": materialId,
      "cabinDrawerDetailId": cabinDrawerDetailId,
      "quantity": quantity,
      "censusQuantity": censusQuantity,
      "miadDate": miadDate,
      "shelfNo": shelfNo,
      "compartmentNo": compartmentNo,
      "stockId": stockId,
      "cabinDrawerId": cabinDrawerId,
      //"assignment": assignment?.toDTO(),
    };
  }
}
