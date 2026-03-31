import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';
import '../../domain/usecase/get_critical_stocks_usecase.dart';

import '../../../medicine_refund/domain/entity/refund.dart';
import '../../../prescription/domain/entity/prescription.dart';
import '../../domain/usecase/get_expiring_materials_usecase.dart';
import '../../domain/usecase/get_refunds_usecase.dart';
import '../../domain/usecase/get_unapplied_prescriptions_usecase.dart';

class ManagerDashboardNotifier extends ChangeNotifier with ApiRequestMixin {
  final GetExpiringMaterialsUseCase _getExpiringMaterialsUseCase;
  final GetUnappliedPrescriptionsUseCase _getUnappliedPrescriptionsUseCase;
  final GetRefundsUseCase _getRefundsUseCase;
  final GetCriticalStocksUseCase _getCriticalStocksUseCase;

  ManagerDashboardNotifier({
    required GetExpiringMaterialsUseCase getExpiringMaterialsUseCase,
    required GetUnappliedPrescriptionsUseCase getUnappliedPrescriptionsUseCase,
    required GetRefundsUseCase getRefundsUseCase,
    required GetCriticalStocksUseCase getCriticalStocksUseCase,
  }) : _getExpiringMaterialsUseCase = getExpiringMaterialsUseCase,
       _getUnappliedPrescriptionsUseCase = getUnappliedPrescriptionsUseCase,
       _getRefundsUseCase = getRefundsUseCase,
       _getCriticalStocksUseCase = getCriticalStocksUseCase;

  Timer? _timer;

  OperationKey expiringOp = OperationKey.fetch();
  OperationKey unappliedOp = OperationKey.fetch();
  OperationKey refundOp = OperationKey.fetch();
  OperationKey criticOp = OperationKey.fetch();

  List<CabinStock> _expiringMaterials = [];
  List<CabinStock> get expiringMaterials => _expiringMaterials;

  List<Prescription> _unappliedPrescriptions = [];
  List<Prescription> get unappliedPrescriptions => _unappliedPrescriptions;

  List<Refund> _refunds = [];
  List<Refund> get refunds => _refunds;

  List<CabinStock> _criticStocks = [];
  List<CabinStock> get criticStocks => _criticStocks;

  Future<void> fetch() async {
    _timer?.cancel();

    await _fetchAllData();

    _timer = Timer.periodic(const Duration(minutes: 5), (timer) async {
      await _fetchAllData();
    });
  }

  Future<void> _fetchAllData() async {
    await Future.wait([_getExpiringMaterials(), _getUnappliedPrescriptions(), _getRefunds(), _getCriticalStocks()]);
  }

  Future _getExpiringMaterials() async {
    return execute(
      expiringOp,
      operation: () => _getExpiringMaterialsUseCase.call(),
      onData: (data) => _expiringMaterials = data,
    );
  }

  Future _getUnappliedPrescriptions() async {
    return execute(
      unappliedOp,
      operation: () => _getUnappliedPrescriptionsUseCase.call(),
      onData: (data) => _unappliedPrescriptions = data,
    );
  }

  Future _getRefunds() async {
    return execute(refundOp, operation: () => _getRefundsUseCase.call(), onData: (data) => _refunds = data);
  }

  Future _getCriticalStocks() async {
    return execute(
      criticOp,
      operation: () => _getCriticalStocksUseCase.call(false),
      onData: (data) => _criticStocks = data,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
