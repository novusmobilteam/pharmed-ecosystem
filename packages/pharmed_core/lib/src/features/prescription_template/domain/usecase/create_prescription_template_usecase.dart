import 'package:pharmed_core/pharmed_core.dart';

class CreatePrescriptionTemplateUseCase {
  final IPrescriptionTemplateRepository _repository;

  CreatePrescriptionTemplateUseCase(this._repository);

  Future<Result<List<PrescriptionTemplateItem>>> call({
    required PrescriptionTemplate template,
    required List<PrescriptionTemplateItem> items,
  }) async {
    final rCreate = await _repository.createPrescriptionTemplate(template);

    return rCreate.when(
      error: Result.error,
      ok: (created) async {
        final templateId = created?.id;

        if (templateId == null) {
          return Result.error(
            CustomException(message: 'Şablon oluşturulurken bir hata oluştu. Lütfen daha sonra tekrar deneyiniz.'),
          );
        }

        final rItems = await _repository.createPrescriptionTemplateItems(
          items.map((i) => i.copyWith(templateId: templateId)).toList(),
        );
        return rItems.when(ok: (_) => Result.ok(items), error: Result.error);
      },
    );
  }
}
