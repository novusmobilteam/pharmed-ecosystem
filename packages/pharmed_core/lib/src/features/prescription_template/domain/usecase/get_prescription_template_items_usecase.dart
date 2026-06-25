import 'package:pharmed_core/pharmed_core.dart';

class GetPrescriptionTemplateItemsUseCase {
  final IPrescriptionTemplateRepository _repository;

  GetPrescriptionTemplateItemsUseCase(this._repository);

  Future<Result<List<PrescriptionTemplateItem>?>> call(int templateId) async {
    return _repository.getPrescriptionTemplateItems(templateId);
  }
}
