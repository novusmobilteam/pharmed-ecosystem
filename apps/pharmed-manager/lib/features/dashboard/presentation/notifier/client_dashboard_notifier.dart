import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';
import '../../domain/usecase/get_critical_stocks_usecase.dart';

import '../../../cabin_stock/domain/entity/cabin_stock.dart';
import '../../../prescription/domain/entity/prescription_item.dart';
import '../../domain/usecase/get_upcoming_treatmens_usecase.dart';

class ClientDashboardNotifier extends ChangeNotifier with ApiRequestMixin {
  final GetCriticalStocksUseCase _getCriticalStocksUseCase;
  final GetUpcomingTreatmensUseCase _getUpcomingTreatmensUseCase;

  ClientDashboardNotifier({
    required GetCriticalStocksUseCase getCriticalStocksUseCase,
    required GetUpcomingTreatmensUseCase getUpcomingTreatmensUseCase,
  }) : _getCriticalStocksUseCase = getCriticalStocksUseCase,
       _getUpcomingTreatmensUseCase = getUpcomingTreatmensUseCase;

  Timer? _timer;

  OperationKey criticOp = OperationKey.fetch();
  OperationKey upcomingOp = OperationKey.fetch();

  List<CabinStock> _criticStocks = [];
  List<CabinStock> get criticStocks => _criticStocks;

  List<PrescriptionItem> _treatments = [];
  List<PrescriptionItem> get treatments => _treatments;

  Future<void> fetch() async {
    _timer?.cancel();

    await _fetchAllData();

    _timer = Timer.periodic(const Duration(minutes: 5), (timer) async {
      await _fetchAllData();
    });
  }

  Future<void> _fetchAllData() async {
    await Future.wait([_getCriticalStocks(), _getUpcomingTreatments()]);
  }

  Future _getCriticalStocks() async {
    return execute(
      criticOp,
      operation: () => _getCriticalStocksUseCase.call(false),
      onData: (data) => _criticStocks = data,
    );
  }

  Future _getUpcomingTreatments() async {
    return execute(
      criticOp,
      operation: () => _getUpcomingTreatmensUseCase.call(),
      onData: (data) => _treatments = data,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
