import '../../domain/entity/mail_preference.dart';

class MailPreferenceDTO {
  final String? id;

  // SMTP / Gönderici Bilgileri
  final String? mailAddress;
  final String? password;
  final String? senderName;

  // Şablon / İçerik Bilgileri
  final String? title;
  final String? body;
  final List<String>? recipientIds;

  // Gönderim durumu
  final bool sent;

  const MailPreferenceDTO({
    this.id,
    this.mailAddress,
    this.password,
    this.senderName,
    this.title,
    this.body,
    this.recipientIds,
    this.sent = false,
  });

  factory MailPreferenceDTO.fromJson(Map<String, dynamic> json) {
    return MailPreferenceDTO(
      id: json['id'] as String?,
      mailAddress: json['mailAddress'] as String?,
      password: json['password'] as String?,
      senderName: json['senderName'] as String?,
      title: json['title'] as String?,
      body: json['body'] as String?,
      recipientIds: (json['recipientIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const <String>[],
      sent: json['sent'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'mailAddress': mailAddress,
        'password': password,
        'senderName': senderName,
        'title': title,
        'body': body,
        'recipientIds': recipientIds ?? const <String>[],
        'sent': sent,
      };

  MailPreferenceDTO copyWith({
    String? id,
    String? mailAddress,
    String? password,
    String? senderName,
    String? title,
    String? body,
    List<String>? recipientIds,
    bool? sent,
  }) {
    return MailPreferenceDTO(
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

  MailPreference toEntity() => MailPreference(
        id: id,
        mailAddress: mailAddress,
        password: password,
        senderName: senderName,
        title: title,
        body: body,
        recipientIds: recipientIds ?? const <String>[],
        sent: sent,
      );

  /// Mock factory for test data generation
  static MailPreferenceDTO mockFactory(int id) {
    return MailPreferenceDTO(
      id: id.toString(),
      mailAddress: 'kullanici$id@hastane.com',
      password: 'password$id',
      senderName: 'Gönderici $id',
      title: 'Başlık $id',
      body: 'İçerik $id',
      recipientIds: ['1', '2', '3'],
      sent: true,
    );
  }
}
