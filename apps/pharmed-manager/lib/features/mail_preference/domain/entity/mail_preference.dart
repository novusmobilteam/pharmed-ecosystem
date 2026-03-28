import '../../../../core/core.dart';
import '../../data/model/mail_preference_dto.dart';

class MailPreference implements TableData {
  final String? id;

  // SMTP / Gönderici Bilgileri
  final String? mailAddress;
  final String? password;
  final String? senderName;

  // Şablon / İçerik Bilgileri
  final String? title;
  final String? body;
  final List<String> recipientIds;

  // Gönderim durumu
  final bool sent;

  const MailPreference({
    this.id,
    this.mailAddress,
    this.password,
    this.senderName,
    this.title,
    this.body,
    this.recipientIds = const <String>[],
    this.sent = false,
  });

  MailPreference copyWith({
    String? id,
    String? mailAddress,
    String? password,
    String? senderName,
    String? title,
    String? body,
    List<String>? recipientIds,
    bool? sent,
  }) {
    return MailPreference(
      id: id ?? this.id,
      mailAddress: mailAddress ?? this.mailAddress,
      password: password ?? this.password,
      senderName: senderName ?? this.senderName,
      title: title ?? this.title,
      body: body ?? this.body,
      recipientIds: recipientIds ?? this.recipientIds,
      sent: sent ?? this.sent,
    );
  }

  /// TableData
  @override
  List<String?> get titles => ['Başlık', 'Gönderen Kullanıcı'];

  @override
  List<String?> get content => [title, senderName];

  @override
  List<String?> get rawContent => content;

  MailPreferenceDTO toDTO() => MailPreferenceDTO(
    id: id,
    mailAddress: mailAddress,
    password: password,
    senderName: senderName,
    title: title,
    body: body,
    recipientIds: recipientIds,
    sent: sent,
  );
}
