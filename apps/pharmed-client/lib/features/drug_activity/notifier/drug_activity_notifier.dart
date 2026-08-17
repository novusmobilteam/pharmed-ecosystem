// lib/features/drug_activity/presentation/notifier/drug_activity_notifier.dart

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:pharmed_client/core/mixins/api_request_mixin.dart';
import 'package:pharmed_client/core/mixins/pagination_mixin.dart';
import 'package:pharmed_core/pharmed_core.dart';

class DrugActivityNotifier extends ChangeNotifier with ApiRequestMixin, PaginationMixin<PrescriptionItemMovement> {
  DrugActivityNotifier({required GetCurrentStationDrugActivityUseCase useCase}) : _useCase = useCase {
    unawaited(fetch());
  }

  final GetCurrentStationDrugActivityUseCase _useCase;

  final OperationKey loadOp = OperationKey.custom('load-drug-activity');

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  @override
  Future<void> fetch() async {
    await fetchPagedData(
      fetchMethod: (skip, take) => _useCase.call(skip: skip, take: take, startDate: startDate, endDate: endDate),
    );
  }
}
