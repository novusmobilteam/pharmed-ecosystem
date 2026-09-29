import 'package:pharmed_core/pharmed_core.dart';

import '../overdue_description.dart';

class OverdueDescriptionRepositoryImpl implements IOverdueDescriptionRepository {
  const OverdueDescriptionRepositoryImpl({
    required OverdueDescriptionRemoteDataSource dataSource,
    required OverdueDescriptionMapper mapper,
  }) : _dataSource = dataSource,
       _mapper = mapper;

  final OverdueDescriptionRemoteDataSource _dataSource;
  final OverdueDescriptionMapper _mapper;

  @override
  Future<Result<List<OverdueDescription>>> getTemplates({String? search}) async {
    final result = await _dataSource.getTemplates(search: search);
    return result.when(ok: (dtos) => Result.ok(_mapper.toEntityList(dtos ?? const [])), error: (e) => Result.error(e));
  }

  @override
  Future<Result<OverdueDescription?>> createTemplate(OverdueDescription template) async {
    final result = await _dataSource.createTemplate(_mapper.toDto(template));
    return result.when(ok: (dto) => Result.ok(_mapper.toEntityOrNull(dto)), error: (e) => Result.error(e));
  }

  @override
  Future<Result<OverdueDescription?>> updateTemplate(OverdueDescription template) async {
    final result = await _dataSource.updateTemplate(_mapper.toDto(template));
    return result.when(ok: (dto) => Result.ok(_mapper.toEntityOrNull(dto)), error: (e) => Result.error(e));
  }

  @override
  Future<Result<void>> deleteTemplate(int id) async {
    final result = await _dataSource.deleteTemplate(id);
    return result.when(ok: (_) => const Result.ok(null), error: (e) => Result.error(e));
  }
}
