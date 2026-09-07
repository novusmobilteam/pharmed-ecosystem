class MailPreferenceDTO {
  final int? id;

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
      id: json['id'] as int?,
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
}
