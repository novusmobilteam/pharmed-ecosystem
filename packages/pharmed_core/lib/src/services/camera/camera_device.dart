import 'package:equatable/equatable.dart';

/// İstasyondaki bir IP kamera ve hizmet verdiği kabinler. [SWREQ-CAM-050]
///
/// - Bir kamera birden fazla kabine hizmet verebilir; bir kabin ise EN FAZLA
///   bir kameraya atanabilir (bkz. CameraDeviceValidator).
/// - Şifre bu modelde YOKTUR: ICameraSecretStore'da kamera id'siyle tutulur.
///   Böylece model loglansa / serileştirilse / sunucuya gitse de şifre sızmaz.
class CameraDevice extends Equatable {
  const CameraDevice({
    required this.id,
    required this.name,
    required this.host,
    required this.username,
    required this.cabinIds,
    this.rtspPort = 554,
    this.channel = 101,
    this.enabled = true,
  });

  /// Lokal üretilen kalıcı kimlik (dosya adlarında ve upload'da kullanılır).
  final String id;
  final String name;
  final String host;
  final String username;
  final Set<int> cabinIds;
  final int rtspPort;

  /// 101 = ana akış, 102 = alt akış.
  final int channel;

  /// false ise kayıt alınmaz ama tanım ve kabin atamaları korunur.
  final bool enabled;

  bool servesAny(Set<int> cabins) => enabled && cabinIds.any(cabins.contains);

  CameraDevice copyWith({
    String? name,
    String? host,
    String? username,
    Set<int>? cabinIds,
    int? rtspPort,
    int? channel,
    bool? enabled,
  }) => CameraDevice(
    id: id,
    name: name ?? this.name,
    host: host ?? this.host,
    username: username ?? this.username,
    cabinIds: cabinIds ?? this.cabinIds,
    rtspPort: rtspPort ?? this.rtspPort,
    channel: channel ?? this.channel,
    enabled: enabled ?? this.enabled,
  );

  @override
  List<Object?> get props => [id, name, host, username, cabinIds, rtspPort, channel, enabled];
}
