import 'package:pharmed_core/pharmed_core.dart';

class CheckWithdrawParams {
  final WithdrawType type;
  final int userId;
  final int? hospitalizationId;
  final int? prescriptionDetailId;
  final CabinAssignment assignment;
  final double dosePiece;

  CheckWithdrawParams({
    required this.type,
    required this.userId,
    this.hospitalizationId,
    this.prescriptionDetailId,
    required this.assignment,
    required this.dosePiece,
  });
}

class CheckWithdrawUseCase {
  final IWithdrawRepository _repository;

  CheckWithdrawUseCase(this._repository);

  Future<Result<List<WithdrawDetail>>> call(CheckWithdrawParams params) async {
    final type = params.type;

    switch (type) {
      case WithdrawType.ordered:
        return await _checkOrdered(params);
      case WithdrawType.orderless:
      case WithdrawType.urgent:
        return await _checkOrderless(params);
      case WithdrawType.free:
        return await _checkFree(params);
    }
  }

  Future<Result<List<WithdrawDetail>>> _checkOrdered(CheckWithdrawParams params) async {
    final details = _prepareWithdrawDetails(params.assignment, params.dosePiece);

    final withdrawParams = WithdrawParams(
      type: params.type,
      details: details,
      prescriptionDetailId: params.prescriptionDetailId,
      userId: params.userId,
    );

    final result = await _repository.checkOrderedWithdraw(withdrawParams.toJson());
    return result.when(ok: (_) => Result.ok(details), error: Result.error);
  }

  Future<Result<List<WithdrawDetail>>> _checkOrderless(CheckWithdrawParams params) async {
    final details = _prepareWithdrawDetails(params.assignment, params.dosePiece);

    final withdrawParams = WithdrawParams(
      hospitalizationId: params.hospitalizationId,
      type: params.type,
      details: details,
      userId: params.userId,
    );

    final result = await _repository.checkOrderlessWithdraw(withdrawParams.toJson());
    return result.when(ok: (_) => Result.ok(details), error: Result.error);
  }

  Future<Result<List<WithdrawDetail>>> _checkFree(CheckWithdrawParams params) async {
    final details = _prepareWithdrawDetails(params.assignment, params.dosePiece);

    final withdrawParams = WithdrawParams(type: params.type, details: details, userId: params.userId);

    final result = await _repository.checkFreeWithdraw(withdrawParams.toJson());
    return result.when(ok: (_) => Result.ok(details), error: Result.error);
  }

  List<WithdrawDetail> _prepareWithdrawDetails(CabinAssignment assignment, double amount) {
    final List<WithdrawDetail> requestList = [];
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

        requestList.add(WithdrawDetail(stockId: stock.id ?? 0, dosePiece: takeFromThisStock));

        remainingQty -= takeFromThisStock;
      }
    }

    return requestList;
  }
}
