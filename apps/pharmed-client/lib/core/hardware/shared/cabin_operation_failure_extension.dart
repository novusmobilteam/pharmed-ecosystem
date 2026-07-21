import 'package:flutter/material.dart';

import '../cabin/master_drawer/master_drawer_failure_extension.dart';
import '../hardware.dart';
import '../cabin/mobile_drawer/mobile_drawer_failure_extension.dart';
import '../rfid/rfid_failure_extension.dart';

extension CabinOperationFailureX on CabinOperationFailure {
  String message(BuildContext context) {
    return switch (this) {
      CabinDrawerFailure(:final failure, :final detail) => failure.message(context, detail: detail),
      CabinRfidFailure(:final failure, :final detail) => failure.message(context, detail: detail),
      CabinMasterDrawerFailure(:final failure, :final detail) => failure.message(context, detail: detail),
      CabinApiFailure(:final message) => message,
      CabinValidationFailure(:final reason) => reason.message(context),
    };
  }
}
