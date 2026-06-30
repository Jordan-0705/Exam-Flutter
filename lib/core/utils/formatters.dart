import 'package:intl/intl.dart';

String formatCurrency(double amount) {
  final formatter = NumberFormat('#,##0', 'fr_FR');
  return '${formatter.format(amount)} XOF';
}

String formatPhone(String phone) {
  if (phone.isEmpty) return '';
  final cleaned = phone.replaceAll(RegExp(r'[\s\-+]'), '');
  if (cleaned.length == 12 && cleaned.startsWith('221')) {
    final national = cleaned.substring(3);
    return '+221 ${national.substring(0, 2)} ${national.substring(2, 5)} ${national.substring(5, 7)} ${national.substring(7, 9)}';
  }
  if (cleaned.length == 9 && cleaned.startsWith('77')) {
    return '${cleaned.substring(0, 2)} ${cleaned.substring(2, 5)} ${cleaned.substring(5, 7)} ${cleaned.substring(7, 9)}';
  }
  return phone;
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
    return 'À l\'instant';
  }
}

String formatTransactionType(String type) {
  switch (type.toUpperCase()) {
    case 'DEPOSIT': return 'Dépôt';
    case 'WITHDRAWAL': return 'Retrait';
    case 'TRANSFER': return 'Transfert';
    case 'PAYMENT': return 'Paiement';
    default: return type;
  }
}