import 'package:pharmed_core/pharmed_core.dart';

class GetKitContentUseCase {
  final IKitContentRepository _repository;

  GetKitContentUseCase(this._repository);

  Future<Result<List<KitContent>>> call(int kitId) {
    return _repository.getKitContent(kitId);
  }
}
