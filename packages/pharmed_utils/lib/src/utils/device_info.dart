import 'package:device_info_plus/device_info_plus.dart';

// "B4CD266B-D2B0-4263-ADFA-A0E0F923B123"
class DeviceInfo {
  static Future<String> getMacAddress() async {
    final plugin = DeviceInfoPlugin();
    final deviceInfo = await plugin.deviceInfo;
    // ignore: unused_local_variable
    final macAddressRaw = deviceInfo.data['systemGUID'] ?? deviceInfo.data['deviceId'];
    // String macResult = macAddressRaw.toString().replaceAll(RegExp(r'^\{|\}$'), '');
    // TODO : Düzelt
    String macResult = "155134BA-6ET586-4732124-9A5C-24356ASDGF2DSASS1AS8E";
    return macResult;
  }
}
