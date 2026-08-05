import 'package:pharmed_core/pharmed_core.dart';

class RedirectedPatientGroup {
  const RedirectedPatientGroup({
    required this.hospitalizationId,
    required this.patientFullName,
    this.patientTcNo,
    required this.orders,
  });

  final int hospitalizationId;
  final String patientFullName;
  final String? patientTcNo;
  final List<RedirectedIntakeOrder> orders;

  int get pendingCount => orders.where((o) => o.isPending).length;
}
