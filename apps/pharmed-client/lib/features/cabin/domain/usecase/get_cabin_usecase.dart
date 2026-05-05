import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../../../core/providers/providers.dart';

final getCabinUseCaseProvider = Provider<GetCabinUseCase>((ref) {
  return GetCabinUseCase(ref.read(cabinRepositoryProvider));
});

class GetCabinUseCase {
  final ICabinRepository _repository;

  GetCabinUseCase(this._repository);

  Future<RepoResult<Cabin?>> call(int cabinId) async {
    return _repository.getCabin(cabinId);
  }
}
