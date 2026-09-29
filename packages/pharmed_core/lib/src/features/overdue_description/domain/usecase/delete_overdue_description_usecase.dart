import 'package:pharmed_core/pharmed_core.dart';

class DeleteOverdueDescriptionUseCase {
  const DeleteOverdueDescriptionUseCase(this._repository);

  final IOverdueDescriptionRepository _repository;

  Future<Result<void>> call(OverdueDescription template) => _repository.deleteTemplate(template.id ?? 0);
}
