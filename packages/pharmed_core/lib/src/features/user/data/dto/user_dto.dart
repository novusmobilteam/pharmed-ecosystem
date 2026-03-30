class UserDTO {
  final int? id;
  final int? type;
  final String? registrationNumber;
  final String? name;
  final String? surname;
  final int? roleId;
  final String? role;
  final bool isActive;
  final DateTime? validUntil;
  final String? email;
  final bool isNotOrdered;
  final bool isWitnessedStationEntry;
  final bool kitPurchase;
  final String? userName;
  final String? password;
  final List<int>? stationIds;
  final bool? isAdmin;

  const UserDTO({
    this.id,
    this.type,
    this.registrationNumber,
    this.name,
    this.surname,
    this.roleId,
    this.role,
    this.isActive = true,
    this.validUntil,
    this.email,
    this.isNotOrdered = true,
    this.isWitnessedStationEntry = true,
    this.kitPurchase = true,
    this.userName,
    this.password,
    this.stationIds,
    this.isAdmin,
  });

  factory UserDTO.fromJson(Map<String, dynamic> json) {
    return UserDTO(
      id: json['id'],
      registrationNumber: json['registrationNumber'] as String?,
      name: json['name'] as String?,
      surname: json['surname'] as String?,
      roleId: json['roleId'] as int?,
      role: json['role'] as String?,
      isActive: (json['isActive'] as bool?) ?? false,
      type: json['usageKind'] as int?,
      validUntil: json['validUntil'] != null ? DateTime.tryParse(json['validUntil']) : null,
      email: json['email'] as String?,
      isNotOrdered: (json['isNotOrdered'] as bool?) ?? false,
      isWitnessedStationEntry: (json['isWitnessedStationEntry'] as bool?) ?? false,
      kitPurchase: (json['kitPurchase'] as bool?) ?? false,
      userName: json['userName'] as String?,
      password: json['password'] as String?,
      stationIds: json['stationIds'] is List ? (json['stationIds'] as List).whereType<int>().toList() : null,
      isAdmin: json['isAdmin'] is bool ? json['isAdmin'] as bool : false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'registrationNumber': registrationNumber.toString(),
    'name': name,
    'surname': surname,
    'roleId': roleId,
    'isActive': isActive,
    'usageKind': type,
    'validUntil': validUntil?.toIso8601String(),
    'email': email,
    'isNotOrdered': isNotOrdered,
    'isWitnessedStationEntry': isWitnessedStationEntry,
    'kitPurchase': kitPurchase,
    'userName': userName,
    'password': password,
    'stationIds': stationIds,
  };
}
