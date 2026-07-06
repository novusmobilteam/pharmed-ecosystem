import 'package:pharmed_core/pharmed_core.dart';

import '../prescription_template.dart';

class PrescriptionTemplateRepositoryImpl implements IPrescriptionTemplateRepository {
  PrescriptionTemplateRepositoryImpl({
    required PrescriptionTemplateRemoteDataSource dataSource,
    required PrescriptionTemplateMapper templateMapper,
    required PrescriptionTemplateItemMapper itemMapper,
  }) : _dataSource = dataSource,
       _templateMapper = templateMapper,
       _itemMapper = itemMapper;

  final PrescriptionTemplateRemoteDataSource _dataSource;
  final PrescriptionTemplateMapper _templateMapper;
  final PrescriptionTemplateItemMapper _itemMapper;

  @override
  Future<Result<PrescriptionTemplate?>> createPrescriptionTemplate(PrescriptionTemplate template) async {
    final result = await _dataSource.createPrescriptionTemplate(_templateMapper.toDto(template));
    return result.when(ok: (dto) => Result.ok(_templateMapper.toEntityOrNull(dto)), error: (e) => Result.error(e));
  }

  @override
  Future<Result<void>> createPrescriptionTemplateItems(List<PrescriptionTemplateItem> itens) async {
    final result = await _dataSource.createPrescriptionTemplateItems(_itemMapper.toDtoList(itens));
    return result.when(ok: (_) => Result.ok(null), error: (e) => Result.error(e));
  }

  @override
  Future<Result<List<PrescriptionTemplateItem>>> getPrescriptionTemplateItems(int templateId) async {
    final result = await _dataSource.getPrescriptionTemplateItems(templateId);
    return result.when(ok: (dtos) => Result.ok(_itemMapper.toEntityList(dtos ?? [])), error: (e) => Result.error(e));
  }

  @override
  Future<Result<List<PrescriptionTemplate>>> getPrescriptionTemplates() async {
    final result = await _dataSource.getPrescriptionTemplates();
    return result.when(
      ok: (dtos) => Result.ok(_templateMapper.toEntityList(dtos ?? [])),
      error: (e) => Result.error(e),
    );
  }
}
