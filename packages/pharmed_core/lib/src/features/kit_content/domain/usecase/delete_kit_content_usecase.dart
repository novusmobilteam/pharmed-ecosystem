import 'package:pharmed_core/pharmed_core.dart';

class DeleteKitContentUseCase {
  final IKitContentRepository _repository;

  DeleteKitContentUseCase(this._repository);

  Future<Result<void>> call(KitContent content) {
    return _repository.deleteKitContent(content);
  }
}
