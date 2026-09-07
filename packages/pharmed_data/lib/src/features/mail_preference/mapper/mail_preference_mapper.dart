import 'package:pharmed_core/pharmed_core.dart';

class MailPreferenceMapper {
  const MailPreferenceMapper();

  MailPreference toEntity(MailPreferenceDTO dto) {
    return MailPreference(
      id: dto.id,
      mailAddress: dto.mailAddress,
      password: dto.password,
      senderName: dto.senderName,
      title: dto.title,
      body: dto.body,
      sent: dto.sent,
    );
  }

  MailPreferenceDTO toDto(MailPreference entity) {
    return MailPreferenceDTO(
      id: entity.id,
      mailAddress: entity.mailAddress,
      password: entity.password,
      senderName: entity.senderName,
      title: entity.title,
      body: entity.body,
      sent: entity.sent,
    );
  }

  List<MailPreference> toEntityList(List<MailPreferenceDTO> dtos) => dtos.map(toEntity).toList();
}
