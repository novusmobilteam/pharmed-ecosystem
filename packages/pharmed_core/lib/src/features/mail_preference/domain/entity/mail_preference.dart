class MailPreference {
  final int? id;

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
    int? id,
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
}
