import 'package:flutter/material.dart';

enum FactureStatus { unpaid, paid }

class Facture {
  final int id;
  final String walletCode;
  final String provider;
  final String reference;
  final double amount;
  final DateTime dueDate;
  final FactureStatus status;
  final DateTime createdAt;

  Facture({
    required this.id,
    required this.walletCode,
    required this.provider,
    required this.reference,
    required this.amount,
    required this.dueDate,
    required this.status,
    required this.createdAt,
  });

  factory Facture.fromJson(Map<String, dynamic> json) {
    return Facture(
      id: json['id'] ?? 0,
      walletCode: json['walletCode'] ?? '',
      provider: json['provider'] ?? '',
      reference: json['reference'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      dueDate: DateTime.parse(json['dueDate'] ?? DateTime.now().toIso8601String()),
      status: json['status'] == 'PAID' ? FactureStatus.paid : FactureStatus.unpaid,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  bool get isUnpaid => status == FactureStatus.unpaid;

  String get providerIcon {
    switch (provider.toUpperCase()) {
      case 'ISM': return '📚';
      case 'WOYAFAL': return '📱';
      case 'RAPIDO': return '🛵';
      case 'SENELEC': return '⚡';
      default: return '📄';
    }
  }

  Color get providerColor {
    switch (provider.toUpperCase()) {
      case 'ISM': return Colors.blue.shade600;
      case 'WOYAFAL': return Colors.orange.shade600;
      case 'RAPIDO': return Colors.red.shade600;
      case 'SENELEC': return Colors.green.shade600;
      default: return Colors.grey.shade600;
    }
  }
}