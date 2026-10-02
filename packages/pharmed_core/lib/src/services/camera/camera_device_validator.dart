import 'package:pharmed_core/pharmed_core.dart';

/// Kamera tanımının iş kurallarını doğrular (UI'dan bağımsız, saf). [SWREQ-CAM-051]
/// Mesajlar log içindir; kullanıcıya gösterilecek metni UI `field` ve
/// `value` üzerinden ARB'den üretir.
class CameraDeviceValidator {
  const CameraDeviceValidator();

  static final _ipv4 = RegExp(r'^(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}$');
  static final _hostname = RegExp(
    r'^(?=.{1,253}$)([A-Za-z0-9]([A-Za-z0-9-]{0,61}[A-Za-z0-9])?)(\.[A-Za-z0-9]([A-Za-z0-9-]{0,61}[A-Za-z0-9])?)*$',
  );

  /// [others]: istasyondaki DİĞER kameralar (düzenlenen kamera hariç).
  Result<void> validate(CameraDevice device, {required List<CameraDevice> others}) {
    if (device.name.trim().isEmpty) {
      return _invalid('name', device.name, 'Name is required');
    }
    final host = device.host.trim();
    if (!_ipv4.hasMatch(host) && !_hostname.hasMatch(host)) {
      return _invalid('host', device.host, 'Invalid IP address or hostname');
    }
    if (device.rtspPort < 1 || device.rtspPort > 65535) {
      return _invalid('rtspPort', device.rtspPort, 'Port must be 1-65535');
    }
    if (device.channel <= 0) {
      return _invalid('channel', device.channel, 'Channel must be positive');
    }
    if (device.username.trim().isEmpty) {
      return _invalid('username', device.username, 'Username is required');
    }
    if (device.cabinIds.isEmpty) {
      return _invalid('cabinIds', device.cabinIds, 'At least one cabin is required');
    }
    for (final other in others) {
      // Çakışmalarda value = çakışılan kamera; UI adını mesajda gösterebilir.
      if (other.host.trim() == host && other.channel == device.channel) {
        return _invalid('host', other, 'Same address and channel as camera ${other.id}');
      }
      if (other.cabinIds.intersection(device.cabinIds).isNotEmpty) {
        // Bir kabin en fazla bir kameraya atanabilir.
        return _invalid('cabinIds', other, 'Cabin already assigned to camera ${other.id}');
      }
    }
    return const Result.ok(null);
  }

  static Result<void> _invalid(String field, Object? value, String message) =>
      Result.error(ValidationException(message: message, field: field, value: value));
}
