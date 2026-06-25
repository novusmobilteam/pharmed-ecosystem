import 'dart:convert';

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class PrescriptionTemplateRemoteDataSource extends BaseRemoteDataSource {
  static const String _base = '/PrescriptionTemplate';
  static const String _detailBase = '/PrescriptionTemplateDetail';

  PrescriptionTemplateRemoteDataSource({required super.apiManager});

  @override
  String get logSwreq => 'SWREQ-DATA-PRESCRIPTIONTEMPLATE-001';

  @override
  String get logUnit => 'SW-UNIT-PRESCRIPTIONTEMPLATE';

  Future<Result<PrescriptionTemplateDto?>> createPrescriptionTemplate(PrescriptionTemplateDto dto) {
    return postRequest<PrescriptionTemplateDto?>(
      path: _base,
      body: dto.toJson(),
      parser: BaseRemoteDataSource.singleParser(PrescriptionTemplateDto.fromJson),
      successLog: 'Prescription template created',
      envelope: ResponseEnvelope.apiResponse,
    );
  }

  Future<Result<void>> createPrescriptionTemplateItems(List<PrescriptionTemplateItemDto> items) {
    final body = items.map((e) => e.toJson()).toList();
    print('[TPL] encoded body: ${jsonEncode(body)}');

    return postRequest<void>(
      path: '$_detailBase/bulk',
      body: body,
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Prescription template items created',
    );
  }

  Future<Result<List<PrescriptionTemplateDto>?>> getPrescriptionTemplates() async {
    return fetchRequest(
      path: _base,
      parser: BaseRemoteDataSource.listParser(PrescriptionTemplateDto.fromJson),
      successLog: 'Prescription template created',
      envelope: ResponseEnvelope.apiResponse,
    );
  }

  Future<Result<List<PrescriptionTemplateItemDto>?>> getPrescriptionTemplateItems(int templateId) {
    return fetchRequest<List<PrescriptionTemplateItemDto>>(
      path: '$_detailBase/$templateId',
      parser: BaseRemoteDataSource.listParser(PrescriptionTemplateItemDto.fromJson),
      successLog: 'Prescription template items fetched',
      emptyLog: 'No prescription template items',
    );
  }
}
