import '../../../../core/core.dart';

import '../entity/kit_content.dart';
import '../repository/i_kit_content_repository.dart';

class DeleteKitContentUseCase implements UseCase<void, KitContent> {
  final IKitContentRepository _repository;

  DeleteKitContentUseCase(this._repository);

  @override
  Future<Result<void>> call(KitContent content) {
    return _repository.deleteKitContent(content);
  }
}
