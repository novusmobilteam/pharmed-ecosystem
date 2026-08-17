import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:pharmed_client/core/mixins/api_request_mixin.dart';
import 'package:pharmed_client/core/mixins/pagination_mixin.dart';
import 'package:pharmed_core/pharmed_core.dart';

class ExpiringItemsNotifier extends ChangeNotifier with ApiRequestMixin, PaginationMixin<CabinStock> {
  ExpiringItemsNotifier({required GetExpiringStocksUseCase useCase}) : _useCase = useCase {
    unawaited(fetch());
  }

  final GetExpiringStocksUseCase _useCase;

  final OperationKey loadOp = OperationKey.custom('load-expiring-items');

  @override
  Future<void> fetch() async {
    await fetchPagedData(
      op: loadOp,
      fetchMethod: (skip, take) => _useCase.call(
        params: PagedQueryParams(skip: skip, take: take, startDate: startDate, endDate: endDate),
      ),
    );
  }
}
