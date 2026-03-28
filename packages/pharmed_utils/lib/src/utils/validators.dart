import 'package:intl/intl.dart';

class Validators {
  Validators._();

  static String? cannotBlankValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "Bu alan boş bırakılamaz.";
    } else {
      return null;
    }
  }

  static String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "Bu alan boş bırakılamaz.";
    } else {
      return null;
    }

    // if (value == null || value.isEmpty) {
    //   return "Bu alan boş bırakılamaz.";
    // } else {
    //   bool hasUppercase = value.contains(RegExp(r'[A-Z]'));
    //   if (!hasUppercase) {
    //     return "Şifre En Az 1 Büyük Karakter İçermelidir!";
    //   }
    //   bool hasLowercase = value.contains(RegExp(r'[a-z]'));
    //   if (!hasLowercase) {
    //     return "Şifre En Az 1 Küçük Karakter İçermelidir!";
    //   }
    //   // bool hasSpecialCharacters = value.contains(RegExp(r'[!@#$%^&*();=,.?":{}|<>_]'));
    //   // if (!hasSpecialCharacters) {
    //   //   return "Şifre En Az 1 Özel Karakter İçermelidir!";
    //   // }
    //   bool hasDigits = value.contains(RegExp(r'[0-9]'));
    //   if (!hasDigits) {
    //     return "Şifre En Az 1 Sayı İçermelidir!";
    //   }
    //   bool hasMinLength = value.length > 8;
    //   if (!hasMinLength) {
    //     return "Şifre En Az 8 Karakter Olmalıdır!";
    //   }
    //   return null;
    // }
  }

  // 2) Tekrar alanı için validator:
  static String? confirmPasswordValidator(String? currentPassword, String newPassword) {
    // a) önce mevcut passwordValidator’ı çalıştır
    final pwdError = passwordValidator(currentPassword);
    if (pwdError != null) return pwdError;

    // b) sonra girilen değerle yeni şifre controller.text’ini karşılaştır
    if (currentPassword != newPassword) {
      return 'Şifreler eşleşmiyor';
    }

    return null;
  }

  static String? emailValidator(String? value) {
    final regExp = RegExp(
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
    );

    if (value != null) {
      if (regExp.hasMatch(value)) {
        return null;
      } else {
        return "Lütfen Geçerli Bir Mail Adresi Giriniz!";
      }
    } else {
      return null;
    }
  }

  static String? minLengthValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "Bu alan boş bırakılamaz.";
    }
    if (value.length < 10) {
      return "En az 10 karakter girmelisiniz.";
    }
    return null;
  }

  /// Date string must be in "dd/MM/yyyy" format.
  /// Returns null if valid, otherwise an error message.
  static String? validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Tarih boş bırakılamaz.';
    }
    if (value.length != 10) {
      return 'Tarih 10 karakter olmalı (GG/AA/YYYY).';
    }
    try {
      DateFormat('dd/MM/yyyy').parseStrict(value);
      return null; // geçerli
    } on FormatException {
      return 'Geçersiz tarih formatı (GG/AA/YYYY).';
    }
  }

  static String? taxNoValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Bu alan boş bırakılamaz';
    }
    if (value.length != 10 && value.length != 11) {
      return 'Vergi numarası 10 veya 11 haneli olmalıdır.';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Sadece rakam giriniz';
    }
    if (value.startsWith('0')) {
      return 'Vergi numarasının ilk hanesi 0 olamaz';
    }
    return null;
  }

  static String? tcValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Bu alan boş bırakılamaz';
    }

    if (value.length != 11) {
      return 'T.C Kimlik No 11 haneli olmalıdır.';
    }

    return null;
  }
}
