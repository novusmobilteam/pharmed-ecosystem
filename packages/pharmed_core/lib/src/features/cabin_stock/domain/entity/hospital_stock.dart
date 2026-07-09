import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';

class HospitalStock implements TableData {
  final int? serviceId;
  final String? serviceName;
  final int? materialId;
  final String? materialName;
  final String? code;
  final num? quantity;

  HospitalStock({this.serviceId, this.serviceName, this.materialId, this.materialName, this.quantity, this.code});

  @override
  List<dynamic> get content => [serviceName, code, materialName, quantity?.formatFractional];

  @override
  List<dynamic> get rawContent => [serviceName, code, materialName, quantity?.formatFractional];

  @override
  List<String?> get titles => [
    contextlessL10n().assignment_serviceLabel,
    contextlessL10n().medicine_fieldCode,
    contextlessL10n().medicalConsumable_fieldName,
    contextlessL10n().movement_quantityLabel,
  ];
}
