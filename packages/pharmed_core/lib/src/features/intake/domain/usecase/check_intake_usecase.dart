import 'package:pharmed_core/pharmed_core.dart';

class CheckIntakeParams {
  final IntakeType type;
  final int userId;
  final int? hospitalizationId;
  final int? prescriptionDetailId;
  final MedicineAssignment assignment;
  final double dosePiece;

  CheckIntakeParams({
    required this.type,
    required this.userId,
    this.hospitalizationId,
    this.prescriptionDetailId,
    required this.assignment,
    required this.dosePiece,
  });
}

class CheckIntakeUseCase {
  final IIntakeRepository _repository;

  CheckIntakeUseCase(this._repository);

  Future<Result<List<IntakeDetail>>> call(CheckIntakeParams params) async {
    final type = params.type;

    switch (type) {
      case IntakeType.ordered:
        return await _checkOrdered(params);
      case IntakeType.orderless:
      case IntakeType.urgent:
        return await _checkOrderless(params);
      case IntakeType.free:
        return await _checkFree(params);
    }
  }

  Future<Result<List<IntakeDetail>>> _checkOrdered(CheckIntakeParams params) async {
    final details = _prepareWithdrawDetails(params.assignment, params.dosePiece);

    final withdrawParams = IntakeParams(
      type: params.type,
      details: details,
      prescriptionDetailId: params.prescriptionDetailId,
      userId: params.userId,
    );

    final result = await _repository.checkOrderedIntake(withdrawParams.toJson());
    return result.when(ok: (_) => Result.ok(details), error: Result.error);
  }

  Future<Result<List<IntakeDetail>>> _checkOrderless(CheckIntakeParams params) async {
    final details = _prepareWithdrawDetails(params.assignment, params.dosePiece);

    final withdrawParams = IntakeParams(
      hospitalizationId: params.hospitalizationId,
      type: params.type,
      details: details,
      userId: params.userId,
    );

    final result = await _repository.checkOrderlessIntake(withdrawParams.toJson());
    return result.when(ok: (_) => Result.ok(details), error: Result.error);
  }

  Future<Result<List<IntakeDetail>>> _checkFree(CheckIntakeParams params) async {
    final details = _prepareWithdrawDetails(params.assignment, params.dosePiece);

    final withdrawParams = IntakeParams(type: params.type, details: details, userId: params.userId);

    final result = await _repository.checkFreeIntake(withdrawParams.toJson());
    return result.when(ok: (_) => Result.ok(details), error: Result.error);
  }

  List<IntakeDetail> _prepareWithdrawDetails(MedicineAssignment assignment, double amount) {
    final List<IntakeDetail> requestList = [];
    double remainingQty = amount;

    final sortedDetails = List.from(assignment.cabinDrawerDetail ?? [])
      ..sort((a, b) => (a.stepNo ?? 0).compareTo(b.stepNo ?? 0));

    for (var detail in sortedDetails) {
      if (remainingQty <= 0) break;

      final stocksInCell = (assignment.stocks ?? []).where((s) => s.cabinDrawerDetailId == detail.id).toList();

      if (stocksInCell.isEmpty) continue;

      for (var stock in stocksInCell) {
        if (remainingQty <= 0) break;

        final double currentStockQty = (stock.quantity ?? 0).toDouble();

        if (currentStockQty <= 0) continue;

        final double takeFromThisStock = currentStockQty < remainingQty ? currentStockQty : remainingQty;

        requestList.add(IntakeDetail(stockId: stock.id ?? 0, dosePiece: takeFromThisStock));

        remainingQty -= takeFromThisStock;
      }
    }

    return requestList;
  }
}
