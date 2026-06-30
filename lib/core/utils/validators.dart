import 'formatters.dart';

class Validators {
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Veuillez entrer un numero de telephone';
    }
    
    final normalized = PhoneFormatter.normalizePhone(value);
    if (!PhoneFormatter.isValidPhone(normalized)) {
      return 'Numero de telephone invalide';
    }
    return null;
  }
  
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Veuillez entrer un email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
      return 'Email invalide';
    }
    return null;
  }
  
  static String? validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Veuillez entrer un montant';
    }
    final amount = double.tryParse(value.trim());
    if (amount == null || amount <= 0) {
      return 'Montant invalide';
    }
    return null;
  }
}