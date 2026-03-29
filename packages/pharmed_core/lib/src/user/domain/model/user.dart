import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';

class User extends Selectable implements TableData {
  final String? registrationNumber;
  final UserType? type;
  final String? name;
  final String? surname;
  final bool isActive;
  final DateTime? validUntil;
  final String? email;
  final bool isNotOrdered;
  final bool isWitnessedStationEntry;
  final bool kitPurchase;
  final String? userName;
  final String? password;
  final List<int>? stationIds;
  final Role? role;
  final bool? isAdmin;

  User({
    super.id,
    this.registrationNumber,
    this.name,
    this.surname,
    this.role,
    this.isActive = true,
    this.type,
    this.validUntil,
    this.email,
    this.isNotOrdered = true,
    this.isWitnessedStationEntry = true,
    this.kitPurchase = true,
    this.userName,
    this.password,
    this.stationIds,
    this.isAdmin,
  }) : super(title: '$name $surname', subtitle: email);

  /// id ve "Ad Soyad" stringinden güvenli şekilde User üretir.
  /// Her ikisi de boş/none ise null döner.
  static User? fromIdAndFullName({int? id, String? fullName}) {
    final hasId = id != null;
    final hasName = fullName != null && fullName.trim().isNotEmpty;
    if (!hasId && !hasName) return null;

    final parts = (fullName ?? '').trim().split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
    final first = parts.isNotEmpty ? parts.first : null;
    final last = parts.length > 1 ? parts.sublist(1).join(' ') : null;

    return User(id: id, name: first, surname: last);
  }

  String get fullName => '$name $surname';

  Status get status => statusFromBool(isActive);

  int? get remainingDay => validUntil?.difference(DateTime.now()).inDays;

  @override
  List<String?> get titles => ['Adı', 'Soyadı', 'Meslek Tipi', 'Son Geçerlilik Tarihi', 'Kalan Gün', 'Durumu'];

  @override
  List<String?> get content => [
    name ?? "-",
    surname ?? "-",
    role?.name,
    validUntil.formattedDate,
    remainingDay?.toCustomString(),
    status.label,
  ];

  @override
  List get rawContent => content;

  User copyWith({
    int? id,
    String? registrationNumber,
    String? name,
    String? surname,
    Role? role,
    bool? isActive,
    UserType? type,
    DateTime? validUntil,
    String? email,
    bool? isNotOrdered,
    bool? isWitnessedStationEntry,
    bool? kitPurchase,
    String? userName,
    String? password,
    List<int>? stationIds,
  }) {
    return User(
      id: id ?? this.id,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      type: type ?? this.type,
      validUntil: validUntil ?? this.validUntil,
      email: email ?? this.email,
      isNotOrdered: isNotOrdered ?? this.isNotOrdered,
      isWitnessedStationEntry: isWitnessedStationEntry ?? this.isWitnessedStationEntry,
      kitPurchase: kitPurchase ?? this.kitPurchase,
      userName: userName ?? this.userName,
      password: password ?? this.password,
      stationIds: stationIds ?? this.stationIds,
    );
  }
}
