// [SWREQ-CORE-CABIN-002] [IEC 62304 §5.5]
// Tüm kabinleri listeler.
// Sınıf: Class B

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../../../core/providers/providers.dart';

final getCabinsUseCaseProvider = Provider<GetCabinsUseCase>((ref) {
  return GetCabinsUseCase(ref.read(cabinRepositoryProvider));
});

class GetCabinsUseCase {
  GetCabinsUseCase(this._repository);
  final ICabinRepository _repository;

  Future<RepoResult<List<Cabin>>> call() => _repository.getCabins();
}
