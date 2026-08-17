// lib/features/unscanned_barcodes/notifier/unscanned_barcodes_notifier.dart

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:pharmed_client/core/mixins/api_request_mixin.dart';
import 'package:pharmed_client/core/mixins/pagination_mixin.dart';
import 'package:pharmed_core/pharmed_core.dart';

class UnscannedBarcodesNotifier extends ChangeNotifier with ApiRequestMixin, PaginationMixin<PrescriptionItem> {
  UnscannedBarcodesNotifier({required GetUnscannedBarcodesUseCase useCase}) : _useCase = useCase {
    unawaited(fetch());
  }

  final GetUnscannedBarcodesUseCase _useCase;

  final OperationKey loadOp = OperationKey.custom('load-unscanned');

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
