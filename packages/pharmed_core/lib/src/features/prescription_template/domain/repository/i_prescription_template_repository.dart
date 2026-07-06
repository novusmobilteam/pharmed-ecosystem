import 'package:pharmed_core/pharmed_core.dart';

abstract interface class IPrescriptionTemplateRepository {
  Future<Result<PrescriptionTemplate?>> createPrescriptionTemplate(PrescriptionTemplate template);
  Future<Result<List<PrescriptionTemplate>>> getPrescriptionTemplates();

  Future<Result<void>> createPrescriptionTemplateItems(List<PrescriptionTemplateItem> items);
  Future<Result<List<PrescriptionTemplateItem>>> getPrescriptionTemplateItems(int templateId);
}
