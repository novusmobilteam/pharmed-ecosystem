import 'package:pharmed_core/pharmed_core.dart';

class GetOverdueDescriptionsUseCase {
  const GetOverdueDescriptionsUseCase(this._repository);

  final IOverdueDescriptionRepository _repository;

  Future<Result<List<OverdueDescription>>> call({String? search}) => _repository.getTemplates(search: search);
}
