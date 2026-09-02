import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/core/providers/usecase_providers.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../../core/mixins/api_request_mixin.dart';
import '../../../core/mixins/pagination_mixin.dart';

final drugActivityNotifierProvider = ChangeNotifierProvider<DrugActivityNotifier>((ref) {
  return DrugActivityNotifier(
    getCurrentStationDrugActivityUseCase: ref.watch(getCurrentStationDrugActivityUseCaseProvider),
  );
});

class DrugActivityNotifier extends ChangeNotifier with ApiRequestMixin, PaginationMixin<PrescriptionItemMovement> {
  final GetCurrentStationDrugActivityUseCase _getCurrentStationDrugActivityUseCase;

  DrugActivityNotifier({required GetCurrentStationDrugActivityUseCase getCurrentStationDrugActivityUseCase})
    : _getCurrentStationDrugActivityUseCase = getCurrentStationDrugActivityUseCase {
    fetch();
  }

  OperationKey fetchOp = OperationKey.fetch();

  @override
  Future<void> fetch() async {
    await fetchPagedData(
      op: fetchOp,
      fetchMethod: (skip, take) => _getCurrentStationDrugActivityUseCase.call(
        params: PagedQueryParams(
          skip: skip,
          take: take,
          searchQuery: searchQuery,
          startDate: startDate,
          endDate: endDate,
        ),
      ),
    );
  }
}
