import 'package:pharmed_core/pharmed_core.dart';

abstract interface class IOverdueDescriptionRepository {
  Future<Result<List<OverdueDescription>>> getTemplates({String? search});

  Future<Result<OverdueDescription?>> createTemplate(OverdueDescription template);

  Future<Result<OverdueDescription?>> updateTemplate(OverdueDescription template);

  Future<Result<void>> deleteTemplate(int id);
}
