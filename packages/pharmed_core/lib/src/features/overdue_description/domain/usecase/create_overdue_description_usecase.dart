import 'package:pharmed_core/pharmed_core.dart';

class CreateOverdueDescriptionUseCase {
  const CreateOverdueDescriptionUseCase(this._repository);

  final IOverdueDescriptionRepository _repository;

  Future<Result<OverdueDescription?>> call(OverdueDescription template) => _repository.createTemplate(template);
}
