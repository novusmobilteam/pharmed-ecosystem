import '../../../../core/core.dart';

import '../entity/kit_content.dart';
import '../repository/i_kit_content_repository.dart';

class GetKitContentUseCase implements UseCase<List<KitContent>, int> {
  final IKitContentRepository _repository;

  GetKitContentUseCase(this._repository);

  @override
  Future<Result<List<KitContent>>> call(int kitId) {
    return _repository.getKitContent(kitId);
  }
}
