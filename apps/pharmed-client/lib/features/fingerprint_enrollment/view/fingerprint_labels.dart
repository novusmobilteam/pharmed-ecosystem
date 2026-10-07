// Parmak izi ekranlarının ortak etiketleri (ARB: fingerprint_*).

import 'package:flutter/widgets.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

extension FingerPositionLabel on FingerPosition {
  /// "Sağ başparmak"
  String label(BuildContext context) {
    final l = context.l10n;
    return switch (this) {
      FingerPosition.rightThumb => l.fingerprint_finger_rightThumb,
      FingerPosition.rightIndex => l.fingerprint_finger_rightIndex,
      FingerPosition.rightMiddle => l.fingerprint_finger_rightMiddle,
      FingerPosition.rightRing => l.fingerprint_finger_rightRing,
      FingerPosition.rightLittle => l.fingerprint_finger_rightLittle,
      FingerPosition.leftThumb => l.fingerprint_finger_leftThumb,
      FingerPosition.leftIndex => l.fingerprint_finger_leftIndex,
      FingerPosition.leftMiddle => l.fingerprint_finger_leftMiddle,
      FingerPosition.leftRing => l.fingerprint_finger_leftRing,
      FingerPosition.leftLittle => l.fingerprint_finger_leftLittle,
    };
  }

  /// El başlığı altında kısa ad: "Başparmak"
  String shortLabel(BuildContext context) {
    final l = context.l10n;
    return switch (this) {
      FingerPosition.rightThumb || FingerPosition.leftThumb => l.fingerprint_finger_thumbShort,
      FingerPosition.rightIndex || FingerPosition.leftIndex => l.fingerprint_finger_indexShort,
      FingerPosition.rightMiddle || FingerPosition.leftMiddle => l.fingerprint_finger_middleShort,
      FingerPosition.rightRing || FingerPosition.leftRing => l.fingerprint_finger_ringShort,
      FingerPosition.rightLittle || FingerPosition.leftLittle => l.fingerprint_finger_littleShort,
    };
  }
}

extension FingerprintFailureLabel on FingerprintFailureReason {
  String label(BuildContext context) {
    final l = context.l10n;
    return switch (this) {
      FingerprintFailureReason.libraryNotFound => l.fingerprint_error_libraryNotFound,
      FingerprintFailureReason.deviceNotFound => l.fingerprint_error_deviceNotFound,
      FingerprintFailureReason.deviceDisconnected => l.fingerprint_error_deviceDisconnected,
      FingerprintFailureReason.notOpen => l.fingerprint_error_notOpen,
      FingerprintFailureReason.busy => l.fingerprint_error_busy,
      FingerprintFailureReason.timeout => l.fingerprint_error_timeout,
      FingerprintFailureReason.cancelled => l.fingerprint_error_cancelled,
      FingerprintFailureReason.fingerOnSensor => l.fingerprint_error_fingerOnSensor,
      FingerprintFailureReason.fakeFinger => l.fingerprint_error_fakeFinger,
      FingerprintFailureReason.lowQuality => l.fingerprint_error_lowQuality,
      FingerprintFailureReason.extractionFailed => l.fingerprint_error_extractionFailed,
      FingerprintFailureReason.sensorDirty => l.fingerprint_error_sensorDirty,
      FingerprintFailureReason.unexpected => l.fingerprint_error_unexpected,
    };
  }
}

/// Elin parmakları, ekranda gösterilecek sırayla (başparmak önce).
List<FingerPosition> fingersOf(FingerHand hand) =>
    FingerPosition.values.where((p) => p.hand == hand).toList(growable: false);
