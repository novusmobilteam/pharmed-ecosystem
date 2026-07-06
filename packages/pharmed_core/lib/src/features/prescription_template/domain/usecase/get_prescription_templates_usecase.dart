import 'package:pharmed_core/pharmed_core.dart';

class GetPrescriptionTemplatesUseCase {
  final IPrescriptionTemplateRepository _repository;

  GetPrescriptionTemplatesUseCase(this._repository);

  Future<Result<List<PrescriptionTemplate>>> call() async {
    return _repository.getPrescriptionTemplates();
  }
}
