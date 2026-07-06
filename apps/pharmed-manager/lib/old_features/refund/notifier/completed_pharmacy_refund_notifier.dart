import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

class CompletedPharmacyRefundNotifier extends ChangeNotifier with ApiRequestMixin, SearchMixin<Refund> {
  final GetCompletedPharmacyRefundsUseCase _getCompletedPharmacyRefundsUseCase;

  CompletedPharmacyRefundNotifier({required GetCompletedPharmacyRefundsUseCase getCompletedPharmacyRefundsUseCase})
    : _getCompletedPharmacyRefundsUseCase = getCompletedPharmacyRefundsUseCase;

  OperationKey fetchOp = OperationKey.fetch();

  bool get isFetching => isLoading(fetchOp);

  List<Refund> get refunds => filteredItems;

  // Functions
  Future<void> getCompletedRefunds() async {
    await execute(
      fetchOp,
      operation: () => _getCompletedPharmacyRefundsUseCase.call(),
      onData: (data) => allItems = data,
    );
  }
}
