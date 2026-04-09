import 'package:pharmed_core/pharmed_core.dart';

class UpdateKitContentUseCase {
  final IKitContentRepository _repository;

  UpdateKitContentUseCase(this._repository);

  Future<Result<void>> call(KitContent content) {
    return _repository.updateKitContent(content);
  }
}
