// pharmed-client/lib/core/hardware/fingerprint/biomini/biomini_bindings.dart
//
// [SWREQ-FP-010]
// Suprema/Xperix BioMini SDK 3.10.0 (UniFinger Engine) — UFScanner.dll FFI bağlaması.
//
// Kaynak: BioMini/include/UFScanner.h ve UFScannerDef.h (SDK paketi).
// ffigen kullanılmadı: header C++ varsayılan argümanları ve Win32 tipleri
// (HDC, BSTR) içeriyor; ayrıca SDK'nın yalnızca küçük bir alt kümesi gerekiyor.
// SDK sürümü değişirse imzalar header ile yeniden karşılaştırılmalıdır.
//
// Çağrı kuralı: header UFS_API = __stdcall der; x64'te __stdcall yok sayılır ve
// standart x64 çağrı kuralı geçerlidir. Bu yüzden ek bir ABI ayarı gerekmez.
// (32-bit build desteklenmez — kiosklar x64.)
//
// Sınıf: Class B

// ignore_for_file: library_private_types_in_public_api

import 'dart:ffi';
import 'dart:typed_data';

/// `HUFScanner` (`void*`).
typedef HUFScanner = Pointer<Void>;

/// UFScannerDef.h sabitleri. Değerler header'dan birebir alınmıştır.
abstract final class Ufs {
  // ── Durum kodları (UFS_STATUS) ─────────────────────────────────────────
  static const ok = 0;
  static const error = -1;

  static const errDeviceNotRespond = -10;
  static const errCaptureTimeout = -11;
  static const errUsbTimeout = -12;

  static const errNoLicense = -101; // "Device is not connected or License is not located"
  static const errLicenseNotMatch = -102;
  static const errLicenseExpired = -103;
  static const errNotSupported = -111;
  static const errInvalidParameters = -112;
  static const errSensorDirty = -123;

  static const errAlreadyInitialized = -201;
  static const errNotInitialized = -202;
  static const errDeviceNumberExceed = -203;
  static const errLoadScannerLibrary = -204;
  static const errCaptureRunning = -211;
  static const errCaptureFailed = -212;
  static const errFakeFinger = -221;
  static const errFingerOnSensor = -231;
  static const errTimeout = -241;

  static const errNotGoodImage = -301;
  static const errExtractionFailed = -302;
  // -351..-359: çekirdek (core) tespit edilemedi / kaymış
  // -401..-405: parmak sensörde fazla sağda/solda/yukarıda/aşağıda/uçta

  // ── Parametreler (UFS_SetParameter / UFS_GetParameter) ─────────────────
  static const paramTimeout = 201; // ms, 0 = sonsuz
  static const paramSensitivity = 203; // 0..7
  static const paramSerial = 204; // get-only
  static const paramSdkVersion = 210; // get-only
  static const paramFingerCheck = 240; // 0 = açık: okumadan önce parmağın kalkmış olmasını şart koşar
  static const paramTemplateSize = 302; // 256..1024
  static const paramLfdLevelDev = 316; // 0..5 (Slim 2S / Slim 3)
  static const paramLfdScoreDev = 318; // get-only (Slim 2S / Slim 3)
  static const paramSecurityLevelDev = 410; // 1..7 (Slim 2S / Slim 3)

  // ── Okuyucu tipleri (UFS_GetScannerType) ───────────────────────────────
  // Not: header'da bazı kodlar birden fazla model için tanımlı (1011 = SFR750/SFR800v2/BMS2S).
  static const scannerTypeBms = 1005;
  static const scannerTypeBms2 = 1008;
  static const scannerTypeBmss = 1010;
  static const scannerTypeBms2s = 1011;
  static const scannerTypeBms3 = 1012;
  static const scannerTypeBms2wh = 1013;

  // ── Şablon tipleri ─────────────────────────────────────────────────────
  static const templateTypeSuprema = 2001;
  static const templateTypeIso19794_2 = 2002;
  static const templateTypeAnsi378 = 2003;

  static const maxTemplateSize = 1024;
}

// ── C imzaları ───────────────────────────────────────────────────────────

typedef _NoArgC = Int32 Function();
typedef _NoArgD = int Function();

typedef _IntPtrC = Int32 Function(Pointer<Int32>);
typedef _IntPtrD = int Function(Pointer<Int32>);

typedef _GetHandleC = Int32 Function(Int32 index, Pointer<HUFScanner> phScanner);
typedef _GetHandleD = int Function(int index, Pointer<HUFScanner> phScanner);

typedef _HandleC = Int32 Function(HUFScanner);
typedef _HandleD = int Function(HUFScanner);

typedef _HandleIntPtrC = Int32 Function(HUFScanner, Pointer<Int32>);
typedef _HandleIntPtrD = int Function(HUFScanner, Pointer<Int32>);

typedef _HandleIntC = Int32 Function(HUFScanner, Int32);
typedef _HandleIntD = int Function(HUFScanner, int);

typedef _ParamC = Int32 Function(HUFScanner, Int32 nParam, Pointer<Void> pValue);
typedef _ParamD = int Function(HUFScanner, int nParam, Pointer<Void> pValue);

typedef _ExtractExC =
    Int32 Function(
      HUFScanner,
      Int32 nBufferSize,
      Pointer<Uint8> pTemplate,
      Pointer<Int32> pnTemplateSize,
      Pointer<Int32> pnEnrollQuality,
    );
typedef _ExtractExD =
    int Function(
      HUFScanner,
      int nBufferSize,
      Pointer<Uint8> pTemplate,
      Pointer<Int32> pnTemplateSize,
      Pointer<Int32> pnEnrollQuality,
    );

typedef _ExtractOnDeviceC =
    Int32 Function(HUFScanner, Pointer<Uint8> pTemplate, Pointer<Int32> pnTemplateSize, Pointer<Int32> pnEnrollQuality);
typedef _ExtractOnDeviceD =
    int Function(HUFScanner, Pointer<Uint8> pTemplate, Pointer<Int32> pnTemplateSize, Pointer<Int32> pnEnrollQuality);

typedef _ImageInfoC =
    Int32 Function(HUFScanner, Pointer<Int32> pnWidth, Pointer<Int32> pnHeight, Pointer<Int32> pnResolution);
typedef _ImageInfoD =
    int Function(HUFScanner, Pointer<Int32> pnWidth, Pointer<Int32> pnHeight, Pointer<Int32> pnResolution);

typedef _ImageBufferC = Int32 Function(HUFScanner, Pointer<Uint8> pImageData);
typedef _ImageBufferD = int Function(HUFScanner, Pointer<Uint8> pImageData);

typedef _ErrorStringC = Int32 Function(Int32 res, Pointer<Uint8> szErrorString);
typedef _ErrorStringD = int Function(int res, Pointer<Uint8> szErrorString);

/// UFScanner.dll fonksiyonları. Kurucu, eksik bir sembol varsa [ArgumentError] fırlatır.
class BioMiniBindings {
  BioMiniBindings(DynamicLibrary lib)
    : init = lib.lookupFunction<_NoArgC, _NoArgD>('UFS_Init'),
      update = lib.lookupFunction<_NoArgC, _NoArgD>('UFS_Update'),
      uninit = lib.lookupFunction<_NoArgC, _NoArgD>('UFS_Uninit'),
      getScannerNumber = lib.lookupFunction<_IntPtrC, _IntPtrD>('UFS_GetScannerNumber'),
      getScannerHandle = lib.lookupFunction<_GetHandleC, _GetHandleD>('UFS_GetScannerHandle'),
      getScannerType = lib.lookupFunction<_HandleIntPtrC, _HandleIntPtrD>('UFS_GetScannerType'),
      getParameter = lib.lookupFunction<_ParamC, _ParamD>('UFS_GetParameter'),
      setParameter = lib.lookupFunction<_ParamC, _ParamD>('UFS_SetParameter'),
      isFingerOn = lib.lookupFunction<_HandleIntPtrC, _HandleIntPtrD>('UFS_IsFingerOn'),
      clearCaptureImageBuffer = lib.lookupFunction<_HandleC, _HandleD>('UFS_ClearCaptureImageBuffer'),
      captureSingleImage = lib.lookupFunction<_HandleC, _HandleD>('UFS_CaptureSingleImage'),
      captureSingleImageOnDevice = lib.lookupFunction<_HandleC, _HandleD>('UFS_CaptureSingleImageOnDevice'),
      abortCapturing = lib.lookupFunction<_HandleC, _HandleD>('UFS_AbortCapturing'),
      setTemplateType = lib.lookupFunction<_HandleIntC, _HandleIntD>('UFS_SetTemplateType'),
      setDeviceTemplateType = lib.lookupFunction<_HandleIntC, _HandleIntD>('UFS_SetDeviceTemplateType'),
      extractEx = lib.lookupFunction<_ExtractExC, _ExtractExD>('UFS_ExtractEx'),
      extractOnDevice = lib.lookupFunction<_ExtractOnDeviceC, _ExtractOnDeviceD>('UFS_ExtractOnDevice'),
      getCaptureImageBufferInfo = lib.lookupFunction<_ImageInfoC, _ImageInfoD>('UFS_GetCaptureImageBufferInfo'),
      getCaptureImageBuffer = lib.lookupFunction<_ImageBufferC, _ImageBufferD>('UFS_GetCaptureImageBuffer'),
      getCaptureImageBufferFromDevice = lib.lookupFunction<_ImageBufferC, _ImageBufferD>(
        'UFS_GetCaptureImageBufferFromDevice',
      ),
      getErrorString = lib.lookupFunction<_ErrorStringC, _ErrorStringD>('UFS_GetErrorString');

  final _NoArgD init;
  final _NoArgD update;
  final _NoArgD uninit;
  final _IntPtrD getScannerNumber;
  final _GetHandleD getScannerHandle;
  final _HandleIntPtrD getScannerType;
  final _ParamD getParameter;
  final _ParamD setParameter;
  final _HandleIntPtrD isFingerOn;
  final _HandleD clearCaptureImageBuffer;
  final _HandleD captureSingleImage;
  final _HandleD captureSingleImageOnDevice;
  final _HandleD abortCapturing;
  final _HandleIntD setTemplateType;
  final _HandleIntD setDeviceTemplateType;
  final _ExtractExD extractEx;
  final _ExtractOnDeviceD extractOnDevice;
  final _ImageInfoD getCaptureImageBufferInfo;
  final _ImageBufferD getCaptureImageBuffer;
  final _ImageBufferD getCaptureImageBufferFromDevice;
  final _ErrorStringD getErrorString;
}

/// Yalnızca `UFS_AbortCapturing`. Ana isolate'te tutulur: worker isolate bir
/// capture içinde bloklanmışken iptal ancak başka bir thread'den çağrılabilir.
/// SDK 3.x tüm fonksiyonların thread-safe olduğunu belirtir.
class BioMiniAbortBinding {
  BioMiniAbortBinding(DynamicLibrary lib)
    : abortCapturing = lib.lookupFunction<_HandleC, _HandleD>('UFS_AbortCapturing');

  final _HandleD abortCapturing;
}

/// Sıfır sonlu ASCII C dizgisini okur. SDK dizgileri İngilizce/ASCII'dir;
/// geçersiz bayt gelirse istisna fırlatmak yerine olduğu gibi çevrilir.
String readCString(Pointer<Uint8> ptr, int maxLength) {
  final bytes = ptr.asTypedList(maxLength);
  final end = bytes.indexOf(0);
  return String.fromCharCodes(Uint8List.sublistView(bytes, 0, end < 0 ? maxLength : end)).trim();
}

/// SDK tip kodunu model adına çevirir. Bilinmeyen kodlar ham değerle döner.
String bioMiniModelName(int scannerType) => switch (scannerType) {
  Ufs.scannerTypeBms => 'BioMini Slim',
  Ufs.scannerTypeBms2 => 'BioMini Slim 2',
  Ufs.scannerTypeBmss => 'BioMini Slim S',
  Ufs.scannerTypeBms2s => 'BioMini Slim 2S',
  Ufs.scannerTypeBms3 => 'BioMini Slim 3',
  Ufs.scannerTypeBms2wh => 'BioMini Slim 2 (Windows Hello)',
  _ => 'BioMini (type $scannerType)',
};
