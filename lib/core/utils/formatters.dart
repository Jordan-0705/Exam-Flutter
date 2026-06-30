import 'package:intl/intl.dart';

class PhoneFormatter {
  // Normalise un numéro de téléphone vers le format +22177XXXXXXX
  static String normalizePhone(String phone) {
    if (phone.isEmpty) return phone;
    
    // Supprimer tous les espaces, tirets, parenthèses
    String cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    // Si le numéro commence par +, on garde
    if (cleaned.startsWith('+')) {
      // Si c'est +22177XXXXXXX, on garde
      if (cleaned.startsWith('+22177') && cleaned.length == 13) {
        return cleaned;
      }
      // Sinon on enlève le + pour traiter
      cleaned = cleaned.substring(1);
    }
    
    // Si le numéro commence par 22177 (format international sans +)
    if (cleaned.startsWith('22177') && cleaned.length == 12) {
      return '+$cleaned';
    }
    
    // Si le numéro commence par 77 (format national)
    if (cleaned.startsWith('77') && cleaned.length == 9) {
      return '+221$cleaned';
    }
    
    // Si le numéro commence par 7 (format sans le 7 final ?)
    if (cleaned.startsWith('7') && cleaned.length == 8) {
      return '+2217$cleaned';
    }
    
    // Si c'est déjà un format avec 221 mais sans +
    if (cleaned.startsWith('221') && cleaned.length == 12) {
      return '+$cleaned';
    }
    
    // Fallback: retourner tel quel
    return phone;
  }
  
  // Vérifie si un numéro est valide après normalisation
  static bool isValidPhone(String phone) {
    final normalized = normalizePhone(phone);
    final cleaned = normalized.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');
    return RegExp(r'^22177[0-9]{7}$').hasMatch(cleaned);
  }
  
  // Formate un numéro pour l'affichage
  static String formatPhoneForDisplay(String phone) {
    final normalized = normalizePhone(phone);
    if (normalized.startsWith('+221') && normalized.length == 13) {
      final national = normalized.substring(4);
      return '+221 ${national.substring(0, 2)} ${national.substring(2, 5)} ${national.substring(5, 7)} ${national.substring(7, 9)}';
    }
    return phone;
  }
}

// Garder les autres formateurs
String formatCurrency(double amount) {
  final formatter = NumberFormat('#,##0', 'fr_FR');
  return '${formatter.format(amount)} XOF';
}

String formatDate(DateTime date) {
  final now = DateTime.now();
  final difference = now.difference(date);

  if (difference.inDays > 7) {
    return DateFormat('dd/MM/yyyy').format(date);
  } else if (difference.inDays > 0) {
    return 'Il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
  } else if (difference.inHours > 0) {
    return 'Il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
  } else if (difference.inMinutes > 0) {
    return 'Il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
  } else {
    return 'A l\'instant';
  }
}

String formatTransactionType(String type) {
  switch (type.toUpperCase()) {
    case 'DEPOSIT': return 'Depot';
    case 'WITHDRAWAL': return 'Retrait';
    case 'TRANSFER': return 'Transfert';
    case 'PAYMENT': return 'Paiement';
    default: return type;
  }
}