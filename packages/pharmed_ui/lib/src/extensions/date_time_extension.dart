import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime? {
  String get formattedDate {
    final formatter = DateFormat('dd/MM/yyyy');
    if (this != null) {
      return formatter.format(this!);
    } else {
      return '';
    }
  }

  String get formattedTime {
    final formatter = DateFormat('HH:mm');
    if (this != null) {
      return formatter.format(this!);
    } else {
      return '';
    }
  }

  String get formattedDateTime {
    final formatter = DateFormat('dd/MM/yyyy HH:mm');
    if (this != null) {
      return formatter.format(this!);
    } else {
      return '';
    }
  }

  TimeOfDay? get toTimeOfDay {
    if (this != null) {
      return TimeOfDay(hour: this!.hour, minute: this!.minute);
    }
    return null;
  }
}
