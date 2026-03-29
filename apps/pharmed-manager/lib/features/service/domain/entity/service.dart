import '../../../../core/core.dart';
import '../../../branch/domain/entity/branch.dart';
import '../../data/model/service_dto.dart';

class HospitalService extends Selectable implements TableData {
  final String? name;
  final Branch? branch;
  final User? user;
  final bool isActive;

  HospitalService({super.id, this.name, this.branch, this.user, this.isActive = true}) : super(title: name.toString());

  Status get status => isActive ? Status.active : Status.passive;

  @override
  String? get subtitle => branch?.name;

  @override
  List<String?> get content => [
    id?.toCustomString(),
    name ?? '-',
    branch?.name ?? '-',
    user?.name ?? "-",
    status.label,
  ];

  @override
  List get rawContent => content;

  @override
  List<String> get titles => const ['Servis Kodu', 'Servis Adı', 'Branş', 'Servis Sorumlusu', 'Durum'];

  static HospitalService? fromIdAndName({int? id, String? name}) {
    final hasId = id != null;
    final hasName = name != null && name.trim().isNotEmpty;
    if (!hasId && !hasName) return null;

    return HospitalService(id: id, name: name);
  }

  HospitalService copyWith({int? id, String? name, Branch? branch, User? user, bool? isActive}) {
    return HospitalService(
      id: id ?? this.id,
      name: name ?? this.name,
      branch: branch ?? this.branch,
      user: user ?? this.user,
      isActive: isActive ?? this.isActive,
    );
  }

  ServiceDTO toDTO() => ServiceDTO(
    id: id,
    name: name,
    branchId: branch?.id,
    branch: branch?.toDTO(),
    userId: user?.id,
    user: const UserMapper().toDtoOrNull(user),
    isActive: isActive,
  );
}
