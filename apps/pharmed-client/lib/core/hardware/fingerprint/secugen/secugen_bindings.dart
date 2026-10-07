// pharmed-client/lib/core/hardware/fingerprint/secugen/secugen_bindings.dart
//
// [SWREQ-FP-050]
// SecuGen FDx SDK Pro for Windows 4.3.1 — sgfplib.dll FFI bağlaması (C API, SGFPM_*).
//
// Kaynak: Inc/sgfplib.h ve "FDx SDK Pro Programming Manual (SG1-0030A-026)".
// Yalnızca kullanılan fonksiyonlar bağlandı. SDK sürümü değişirse imzalar header ile
// yeniden karşılaştırılmalıdır.
//
// Tipler: DWORD = uint32, WORD = uint16, BOOL = int32, C++ bool = 1 bayt (Bool).
// WINAPI (__stdcall) x64'te yok sayılır.
//
// Sınıf: Class B

// ignore_for_file: library_private_types_in_public_api

import 'dart:ffi';
import 'dart:typed_data';

/// `HSGFPM` (`void*`).
typedef HSGFPM = Pointer<Void>;

/// sgfplib.h sabitleri.
abstract final class Sg {
  // ── SGFDxErrorCode ─────────────────────────────────────────────────────
  static const errNone = 0;
  static const errCreationFailed = 1;
  static const errFunctionFailed = 2;
  static const errInvalidParam = 3;
  static const errDllLoadFailed = 5;
  static const errDllLoadFailedDrv = 6; // cihaz sürücüsü yüklenemedi
  static const errDllLoadFailedAlgo = 7; // sgfpamx.dll bulunamadı
  static const errDllLoadFailedWsq = 9; // sgwsqlib.dll bulunamadı
  static const errSysLoadFailed = 51;
  static const errInitializeFailed = 52;
  static const errLineDropped = 53;
  static const errTimeOut = 54;
  static const errDeviceNotFound = 55;
  static const errDrvLoadFailed = 56;
  static const errWrongImage = 57;
  static const errLackOfBandwidth = 58;
  static const errDevAlreadyOpen = 59;
  static const errGetSnFailed = 60;
  static const errUnsupportedDev = 61;
  static const errFakeFinger = 62;
  static const errFakeInitializeFailed = 63;
  static const errFeatNumber = 101; // çok az minutia
  static const errInvalidTemplateType = 102;
  static const errExtractFail = 105;
  static const errLicenseLoad = 501;
  static const errLicenseKey = 502;
  static const errLicenseExpired = 503;

  // ── SGFDxDeviceName ────────────────────────────────────────────────────
  static const devAuto = 0xFF;
  static const devFdu05 = 0x06; // U20
  static const devFdu06 = 0x07; // UPx
  static const devFdu07 = 0x08; // U10
  static const devFdu07a = 0x09; // U10-AP
  static const devFdu08 = 0x0A; // U20-A
  static const devFdu06p = 0x0C; // UPx-P
  static const devFdu08x = 0x0F; // U20-ASFX
  static const devFdu08a = 0x11; // U20-AP
  static const devFdu09a = 0x12; // U30
  static const devFdu10a = 0x13; // U-AIR
  static const devFdu06ap = 0x16; // UPx-AP (Hamster Pro v2)
  static const devFdu08al = 0x17; // U20-AL

  // ── SGPPPortAddr ───────────────────────────────────────────────────────
  static const usbAutoDetect = 0x3BC + 1;

  // ── SGFDxTemplateFormat ────────────────────────────────────────────────
  static const templateFormatAnsi378 = 0x0100;
  static const templateFormatSg400 = 0x0200;
  static const templateFormatIso19794 = 0x0300;

  // ── SGImpressionType / SGFingerPosition ────────────────────────────────
  static const impressionLivePlain = 0x00;
  static const fingerUnknown = 0x00;

  // ── Yapı boyutları (x64, 4 bayt hizalı) ────────────────────────────────
  /// SGDeviceInfoParam: DeviceID(4) DeviceSN[16] ComPort(4) ComSpeed(4) ImageWidth(4)
  /// ImageHeight(4) Contrast(4) Brightness(4) Gain(4) ImageDPI(4) FWVersion(4) = 56
  static const deviceInfoSize = 56;
  static const deviceInfoSnOffset = 4;
  static const deviceInfoWidthOffset = 28;
  static const deviceInfoHeightOffset = 32;
  static const deviceInfoDpiOffset = 48;
  static const deviceInfoFwOffset = 52;

  /// SGDeviceList: DevName(4) DevID(4) DevType(2) DevSN[16] → 26, hizalama ile 28.
  static const deviceListDevNameOffset = 0;
  static const deviceListSnOffset = 10;
  static const deviceListSize = 28;

  /// SGFingerInfo: FingerNumber, ViewNumber, ImpressionType, ImageQuality (4 × WORD).
  static const fingerInfoSize = 8;

  static const snLength = 15;
}

// ── C imzaları ───────────────────────────────────────────────────────────

typedef _CreateC = Uint32 Function(Pointer<HSGFPM>);
typedef _CreateD = int Function(Pointer<HSGFPM>);

typedef _HC = Uint32 Function(HSGFPM);
typedef _HD = int Function(HSGFPM);

typedef _HU32C = Uint32 Function(HSGFPM, Uint32);
typedef _HU32D = int Function(HSGFPM, int);

typedef _HU16C = Uint32 Function(HSGFPM, Uint16);
typedef _HU16D = int Function(HSGFPM, int);

typedef _HI32C = Uint32 Function(HSGFPM, Int32);
typedef _HI32D = int Function(HSGFPM, int);

typedef _HBoolC = Uint32 Function(HSGFPM, Bool);
typedef _HBoolD = int Function(HSGFPM, bool);

typedef _HPtrC = Uint32 Function(HSGFPM, Pointer<Uint8>);
typedef _HPtrD = int Function(HSGFPM, Pointer<Uint8>);

typedef _HU32PtrC = Uint32 Function(HSGFPM, Pointer<Uint32>);
typedef _HU32PtrD = int Function(HSGFPM, Pointer<Uint32>);

typedef _EnumerateC = Uint32 Function(HSGFPM, Pointer<Uint32> ndevs, Pointer<Pointer<Uint8>> devList);
typedef _EnumerateD = int Function(HSGFPM, Pointer<Uint32> ndevs, Pointer<Pointer<Uint8>> devList);

typedef _GetImageExC =
    Uint32 Function(HSGFPM, Pointer<Uint8> buffer, Uint32 timeout, Pointer<Void> dispWnd, Uint32 quality);
typedef _GetImageExD = int Function(HSGFPM, Pointer<Uint8> buffer, int timeout, Pointer<Void> dispWnd, int quality);

typedef _ImageQualityC =
    Uint32 Function(HSGFPM, Uint32 width, Uint32 height, Pointer<Uint8> imgBuf, Pointer<Uint32> quality);
typedef _ImageQualityD = int Function(HSGFPM, int width, int height, Pointer<Uint8> imgBuf, Pointer<Uint32> quality);

typedef _CreateTemplateC =
    Uint32 Function(HSGFPM, Pointer<Uint8> fingerInfo, Pointer<Uint8> rawImage, Pointer<Uint8> minTemplate);
typedef _CreateTemplateD =
    int Function(HSGFPM, Pointer<Uint8> fingerInfo, Pointer<Uint8> rawImage, Pointer<Uint8> minTemplate);

typedef _TemplateSizeC = Uint32 Function(HSGFPM, Pointer<Uint8> minTemplate, Pointer<Uint32> size);
typedef _TemplateSizeD = int Function(HSGFPM, Pointer<Uint8> minTemplate, Pointer<Uint32> size);

/// sgfplib.dll fonksiyonları. Kurucu, eksik bir sembol varsa [ArgumentError] fırlatır.
class SecuGenBindings {
  SecuGenBindings(DynamicLibrary lib)
    : create = lib.lookupFunction<_CreateC, _CreateD>('SGFPM_Create'),
      terminate = lib.lookupFunction<_HC, _HD>('SGFPM_Terminate'),
      init = lib.lookupFunction<_HU32C, _HU32D>('SGFPM_Init'),
      enumerateDevice = lib.lookupFunction<_EnumerateC, _EnumerateD>('SGFPM_EnumerateDevice'),
      openDevice = lib.lookupFunction<_HU32C, _HU32D>('SGFPM_OpenDevice'),
      closeDevice = lib.lookupFunction<_HC, _HD>('SGFPM_CloseDevice'),
      getDeviceInfo = lib.lookupFunction<_HPtrC, _HPtrD>('SGFPM_GetDeviceInfo'),
      setTemplateFormat = lib.lookupFunction<_HU16C, _HU16D>('SGFPM_SetTemplateFormat'),
      getMaxTemplateSize = lib.lookupFunction<_HU32PtrC, _HU32PtrD>('SGFPM_GetMaxTemplateSize'),
      getImage = lib.lookupFunction<_HPtrC, _HPtrD>('SGFPM_GetImage'),
      getImageEx = lib.lookupFunction<_GetImageExC, _GetImageExD>('SGFPM_GetImageEx'),
      getImageQuality = lib.lookupFunction<_ImageQualityC, _ImageQualityD>('SGFPM_GetImageQuality'),
      createTemplate = lib.lookupFunction<_CreateTemplateC, _CreateTemplateD>('SGFPM_CreateTemplate'),
      getTemplateSize = lib.lookupFunction<_TemplateSizeC, _TemplateSizeD>('SGFPM_GetTemplateSize'),
      enableCheckOfFingerLiveness = lib.lookupFunction<_HI32C, _HI32D>('SGFPM_EnableCheckOfFingerLiveness'),
      setFakeDetectionLevel = lib.lookupFunction<_HI32C, _HI32D>('SGFPM_SetFakeDetectionLevel'),
      enableSmartCapture = lib.lookupFunction<_HBoolC, _HBoolD>('SGFPM_EnableSmartCapture'),
      setBrightness = lib.lookupFunction<_HU32C, _HU32D>('SGFPM_SetBrightness');

  final _CreateD create;
  final _HD terminate;
  final _HU32D init;
  final _EnumerateD enumerateDevice;
  final _HU32D openDevice;
  final _HD closeDevice;
  final _HPtrD getDeviceInfo;
  final _HU16D setTemplateFormat;
  final _HU32PtrD getMaxTemplateSize;
  final _HPtrD getImage;
  final _GetImageExD getImageEx;
  final _ImageQualityD getImageQuality;
  final _CreateTemplateD createTemplate;
  final _TemplateSizeD getTemplateSize;
  final _HI32D enableCheckOfFingerLiveness;
  final _HI32D setFakeDetectionLevel;
  final _HBoolD enableSmartCapture;
  final _HU32D setBrightness;
}

/// Native bellekten küçük-endian okuma yardımcıları (yapıları elle çözmek için).
int readU32(Pointer<Uint8> base, int offset) =>
    ByteData.sublistView(base.asTypedList(offset + 4)).getUint32(offset, Endian.little);

String? readAsciiSn(Pointer<Uint8> base, int offset) {
  final bytes = base.asTypedList(offset + Sg.snLength + 1).sublist(offset, offset + Sg.snLength + 1);
  final end = bytes.indexOf(0);
  final s = String.fromCharCodes(bytes.sublist(0, end < 0 ? bytes.length : end)).trim();
  return s.isNotEmpty && s.codeUnits.every((c) => c >= 0x20 && c < 0x7F) ? s : null;
}

/// SDK cihaz kodunu model adına çevirir.
String secuGenModelName(int devName) => switch (devName) {
  Sg.devFdu05 => 'SecuGen U20',
  Sg.devFdu06 => 'SecuGen UPx',
  Sg.devFdu07 => 'SecuGen U10',
  Sg.devFdu07a => 'SecuGen U10-AP',
  Sg.devFdu08 => 'SecuGen U20-A',
  Sg.devFdu06p => 'SecuGen UPx-P',
  Sg.devFdu08x => 'SecuGen U20-ASFX',
  Sg.devFdu08a => 'SecuGen U20-AP',
  Sg.devFdu09a => 'SecuGen U30',
  Sg.devFdu10a => 'SecuGen U-AIR',
  Sg.devFdu06ap => 'SecuGen UPx-AP',
  Sg.devFdu08al => 'SecuGen U20-AL',
  _ => 'SecuGen (devName 0x${devName.toRadixString(16)})',
};

/// Kılavuz: "Fake detection functions currently only available for U20-based device."
/// Diğer modellerde EnableCheckOfFingerLiveness hata vermese bile canlılık kontrolü
/// YAPILDIĞI varsayılmaz.
bool secuGenSupportsLiveness(int devName) => switch (devName) {
  Sg.devFdu05 || Sg.devFdu08 || Sg.devFdu08x || Sg.devFdu08a || Sg.devFdu08al => true,
  _ => false,
};
