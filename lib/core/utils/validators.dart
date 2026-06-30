bool isValidPhone(String phone) {
  final cleaned = phone.replaceAll(RegExp(r'[\s\-+]'), '');
  // Accepte: 770000001, 221770000001, +221770000001
  return RegExp(r'^(?:77[0-9]{7}|22177[0-9]{7})$').hasMatch(cleaned);
}

bool isValidEmail(String email) {
  return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
}

String? validatePhone(String? value) {
  if (value == null || value.isEmpty) {
    return 'Veuillez entrer un numéro de téléphone';
  }
  if (!isValidPhone(value)) {
    return 'Numéro de téléphone invalide';
  }
  return null;
}

String? validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'Veuillez entrer un email';
  }
  if (!isValidEmail(value)) {
    return 'Email invalide';
  }
  return null;
}