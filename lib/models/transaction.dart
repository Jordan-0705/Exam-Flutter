// lib/models/transaction.dart
import 'package:flutter/material.dart';

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
  final int? senderWalletId;
  final int? receiverWalletId;

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
    this.senderWalletId,
    this.receiverWalletId,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    // Récupérer les IDs depuis le JSON
    int? senderId;
    int? receiverId;
    
    if (json['sender'] != null) {
      senderId = json['sender']['id'] ?? json['senderId'];
    }
    if (json['receiver'] != null) {
      receiverId = json['receiver']['id'] ?? json['receiverId'];
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
      senderWalletId: senderId,
      receiverWalletId: receiverId,
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

  bool get isCredit {
    switch (type) {
      case TransactionType.deposit:
        return true;
      case TransactionType.transfer:
        // Si c'est un transfert, c'est un crédit si le walletId correspond au receiver
        // ou si le montant est positif (dans le cas où l'API renvoie un montant positif)
        if (receiverWalletId != null && receiverWalletId == walletId) {
          return true;
        }
        if (senderWalletId != null && senderWalletId == walletId) {
          return false;
        }
        // Fallback : si le montant est positif, c'est un crédit
        return amount > 0;
      case TransactionType.payment:
      case TransactionType.withdrawal:
        return false;
    }
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
}