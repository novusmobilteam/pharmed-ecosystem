import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/core/mixins/mixins.dart';
import 'package:pharmed_client/core/providers/providers.dart';
import 'package:pharmed_core/pharmed_core.dart';

final expiringItemsNotifierProvider = ChangeNotifierProvider.autoDispose<ExpiringItemsNotifier>((ref) {
  return ExpiringItemsNotifier(getExpiringStocksUseCase: ref.read(getExpiringStocksUseCaseProvider));
});

class ExpiringItemsNotifier extends ChangeNotifier with ApiRequestMixin, PaginationMixin<CabinStock> {
  final GetExpiringStocksUseCase _getExpiringStocksUseCase;

  ExpiringItemsNotifier({required GetExpiringStocksUseCase getExpiringStocksUseCase})
    : _getExpiringStocksUseCase = getExpiringStocksUseCase {
    fetch();
  }

  final OperationKey fetchOp = OperationKey.fetch();

  @override
  Future<void> fetch() async {
    await fetchPagedData(
      fetchMethod: (skip, take) => _getExpiringStocksUseCase.call(
        params: PagedQueryParams(skip: skip, take: take, startDate: startDate, endDate: endDate),
      ),
    );
  }
}
