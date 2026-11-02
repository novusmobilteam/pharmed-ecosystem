import 'package:flutter/widgets.dart';

import 'package:pharmed_manager/core/core.dart';

/// Geciken uygulamalar (`Prescription/detail/overdueApplications`).
///
/// Servis reçete değil reçete KALEMİ döndüğü için Uygulanmamış Reçeteler
/// tablosundan ayrı tutulur: her satır tek bir ilaç uygulamasıdır.
class OverdueApplicationsNotifier extends ChangeNotifier with ApiRequestMixin, PaginationMixin<PrescriptionItem> {
  OverdueApplicationsNotifier({required GetOverduePrescriptionsUseCase getOverduePrescriptionsUseCase})
    : _getOverduePrescriptionsUseCase = getOverduePrescriptionsUseCase;

  final GetOverduePrescriptionsUseCase _getOverduePrescriptionsUseCase;

  OperationKey fetchOp = OperationKey.fetch();
  bool get isFetching => isLoading(fetchOp);

  @override
  Future<void> fetch() async {
    await fetchPagedData(
      fetchMethod: (skip, take) => _getOverduePrescriptionsUseCase.call(
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
