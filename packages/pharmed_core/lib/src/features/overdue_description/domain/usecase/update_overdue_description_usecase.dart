import 'package:pharmed_core/pharmed_core.dart';

class UpdateOverdueDescriptionUseCase {
  const UpdateOverdueDescriptionUseCase(this._repository);

  final IOverdueDescriptionRepository _repository;

  Future<Result<OverdueDescription?>> call(OverdueDescription template) => _repository.updateTemplate(template);
}
