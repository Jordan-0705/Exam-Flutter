// lib/models/transaction.dart
import 'package:flutter/material.dart';
import 'wallet.dart';

enum TransactionType { deposit, withdrawal, transfer, payment }
enum TransactionStatus { pending, completed, failed }

class Transaction {
  final int id;
  final int walletId;
  final TransactionType type;
  final double amount;
  final double fee;
  final String reference;
  final String description;
  final TransactionStatus status;
  final DateTime createdAt;
  final Wallet? wallet;           // Emetteur
  final Wallet? receiverWallet;   // Destinataire

  Transaction({
    required this.id,
    required this.walletId,
    required this.type,
    required this.amount,
    required this.fee,
    required this.reference,
    required this.description,
    required this.status,
    required this.createdAt,
    this.wallet,
    this.receiverWallet,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    // Recuperer les wallets depuis le JSON
    Wallet? wallet;
    Wallet? receiverWallet;
    
    if (json['wallet'] != null) {
      wallet = Wallet.fromJson(json['wallet']);
    }
    if (json['receiverWallet'] != null) {
      receiverWallet = Wallet.fromJson(json['receiverWallet']);
    }
    
    // Si receiverWallet n'existe pas, essayer de le recuperer depuis le champ 'receiver'
    if (receiverWallet == null && json['receiver'] != null) {
      receiverWallet = Wallet.fromJson(json['receiver']);
    }
    
    return Transaction(
      id: json['id'] ?? 0,
      walletId: json['walletId'] ?? json['wallet']?['id'] ?? 0,
      type: _parseTransactionType(json['type']),
      amount: (json['amount'] ?? 0).toDouble(),
      fee: (json['fee'] ?? 0).toDouble(),
      reference: json['reference'] ?? '',
      description: json['description'] ?? '',
      status: _parseTransactionStatus(json['status']),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      wallet: wallet,
      receiverWallet: receiverWallet,
    );
  }

  static TransactionType _parseTransactionType(String? type) {
    switch (type?.toUpperCase()) {
      case 'DEPOSIT': return TransactionType.deposit;
      case 'WITHDRAWAL': return TransactionType.withdrawal;
      case 'TRANSFER': return TransactionType.transfer;
      case 'PAYMENT': return TransactionType.payment;
      default: return TransactionType.payment;
    }
  }

  static TransactionStatus _parseTransactionStatus(String? status) {
    switch (status?.toUpperCase()) {
      case 'PENDING': return TransactionStatus.pending;
      case 'COMPLETED': return TransactionStatus.completed;
      case 'FAILED': return TransactionStatus.failed;
      default: return TransactionStatus.pending;
    }
  }

  // Determiner si c'est un credit ou un debit
  bool get isCredit {
    switch (type) {
      case TransactionType.deposit:
        return true;
      case TransactionType.transfer:
        // Si on est le destinataire, c'est un credit
        if (receiverWallet != null && receiverWallet!.id == walletId) {
          return true;
        }
        // Si on est l'emetteur, c'est un debit
        if (wallet != null && wallet!.id == walletId) {
          return false;
        }
        // Fallback : si le montant est positif, c'est un credit
        return amount > 0;
      case TransactionType.payment:
      case TransactionType.withdrawal:
        return false;
    }
  }

  // Montant absolu (positif)
  double get absoluteAmount {
    return amount.abs();
  }

  String get typeLabel {
    switch (type) {
      case TransactionType.deposit: return 'Depot';
      case TransactionType.withdrawal: return 'Retrait';
      case TransactionType.transfer: 
        return isCredit ? 'Recu' : 'Envoye';
      case TransactionType.payment: return 'Paiement';
    }
  }

  Color get color {
    if (status == TransactionStatus.failed) return Colors.red.shade300;
    return isCredit ? Colors.green.shade600 : Colors.red.shade600;
  }

  // Description formatee pour l'affichage
  String get formattedDescription {
    switch (type) {
      case TransactionType.transfer:
        if (isCredit && receiverWallet != null) {
          return 'Recu de ${_formatPhone(receiverWallet!.phoneNumber)}';
        } else if (!isCredit && wallet != null) {
          return 'Envoye a ${_formatPhone(wallet!.phoneNumber)}';
        }
        return description;
      default:
        return description;
    }
  }

  // Formater le numero de telephone pour l'affichage
  String _formatPhone(String phone) {
    if (phone.isEmpty) return phone;
    final cleaned = phone.replaceAll(RegExp(r'[\s\-]'), '');
    if (cleaned.length >= 13 && cleaned.startsWith('221')) {
      return '+${cleaned.substring(0, 3)} ${cleaned.substring(3, 5)} ${cleaned.substring(5, 8)} ${cleaned.substring(8, 10)} ${cleaned.substring(10, 12)}';
    }
    if (cleaned.length >= 12 && cleaned.startsWith('221')) {
      return '+${cleaned.substring(0, 3)} ${cleaned.substring(3, 5)} ${cleaned.substring(5, 8)} ${cleaned.substring(8, 10)} ${cleaned.substring(10)}';
    }
    return phone;
  }
}