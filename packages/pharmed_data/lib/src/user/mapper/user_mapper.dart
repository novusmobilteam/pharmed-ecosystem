// packages/pharmed_data/lib/src/user/mapper/user_mapper.dart
//
// [SWREQ-DATA-USER-MAP-001]
// UserDTO ↔ User dönüşümleri tek yer.
// Repository bu mapper'ı kullanır — datasource DTO'da kalır.
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class UserMapper {
  const UserMapper();

  User toEntity(UserDTO dto) => User(
    id: dto.id,
    registrationNumber: dto.registrationNumber,
    name: dto.name,
    surname: dto.surname,
    role: dto.roleId != null || dto.role != null ? Role(id: dto.roleId, name: dto.role) : null,
    isActive: dto.isActive,
    type: UserType.fromId(dto.type),
    validUntil: dto.validUntil,
    email: dto.email,
    isNotOrdered: dto.isNotOrdered,
    isWitnessedStationEntry: dto.isWitnessedStationEntry,
    kitPurchase: dto.kitPurchase,
    userName: dto.userName,
    password: dto.password,
    stationIds: dto.stationIds,
    isAdmin: dto.isAdmin,
  );

  User? toEntityOrNull(UserDTO? dto) => dto == null ? null : toEntity(dto);

  UserDTO? toDtoOrNull(User? entity) => entity == null ? null : toDto(entity);

  List<User> toEntityList(List<UserDTO> dtos) => dtos.map(toEntity).toList();

  UserDTO toDto(User entity) => UserDTO(
    id: entity.id,
    registrationNumber: entity.registrationNumber,
    name: entity.name,
    surname: entity.surname,
    roleId: entity.role?.id,
    role: entity.role?.name,
    isActive: entity.isActive,
    type: entity.type?.id,
    validUntil: entity.validUntil,
    email: entity.email,
    isNotOrdered: entity.isNotOrdered,
    isWitnessedStationEntry: entity.isWitnessedStationEntry,
    kitPurchase: entity.kitPurchase,
    userName: entity.userName,
    password: entity.password,
    stationIds: entity.stationIds,
  );

  User fromAppUser(AppUser appUser) => User(
    id: appUser.id,
    email: appUser.email,
    name: appUser.fullName.split(' ').firstOrNull,
    surname: appUser.fullName.split(' ').skip(1).join(' '),
    isNotOrdered: appUser.isNotOrdered,
    isAdmin: appUser.isAdmin,
  );

  User? fromAppUserOrNull(AppUser? appUser) => appUser == null ? null : fromAppUser(appUser);

  AppUser fromUser(User user) => AppUser(
    id: user.id ?? 0,
    email: user.email ?? '',
    fullName: [user.name, user.surname].whereType<String>().join(' ').trim(),
    role: user.role?.name ?? '',
    isNotOrdered: user.isNotOrdered,
    isAdmin: user.isAdmin ?? false,
  );

  AppUser? fromUserOrNull(User? user) => user == null ? null : fromUser(user);
}
