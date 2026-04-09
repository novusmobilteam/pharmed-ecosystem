import 'package:pharmed_core/pharmed_core.dart';

class CreateKitContentUseCase {
  final IKitContentRepository _repository;

  CreateKitContentUseCase(this._repository);

  Future<Result<void>> call(KitContent content) {
    return _repository.createKitContent(content);
  }
}
