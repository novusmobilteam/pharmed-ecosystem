import 'package:flutter/material.dart';

abstract class FormMixin extends ChangeNotifier {
  final Map<String, dynamic> _formValues = {};
  final Map<String, String?> _formErrors = {};

  Map<String, dynamic> get formValues => Map.unmodifiable(_formValues);
  Map<String, String?> get formErrors => Map.unmodifiable(_formErrors);

  bool get isFormValid => _formErrors.values.every((e) => e == null);

  void updateFormField(String key, dynamic value) {
    _formValues[key] = value;
    _validateField(key, value);
    notifyListeners();
  }

  void _validateField(String key, dynamic value) {
    // Bu metod alt sınıflarda implemente edilecek
    // Veya FormFieldMetadata'dan validator kullanılacak
    _formErrors[key] = null;
  }

  void clearForm() {
    _formValues.clear();
    _formErrors.clear();
    notifyListeners();
  }
}
