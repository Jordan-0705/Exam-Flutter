import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:exam_flutter/models/wallet.dart';
import 'package:exam_flutter/models/transaction.dart';
import 'package:exam_flutter/models/facture.dart';

class ApiService {
  // static const String baseUrl = 'http://10.0.2.2:8080'; // Pour émulateur Android
  static const String baseUrl = 'http://localhost:8080'; // Pour iOS
  
  final http.Client _client = http.Client();

  // Headers
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // ============================================
  // 1. WALLET ENDPOINTS
  // ============================================

  // 1.1 Get wallet by phone
  Future<Wallet> getWallet(String phone) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/wallets/$phone'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return Wallet.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erreur lors de la récupération du portefeuille');
    }
  }

  // 1.2 Get balance
  Future<double> getBalance(String phone) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/wallets/$phone/balance'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return double.parse(response.body);
    } else {
      throw Exception('Erreur lors de la récupération du solde');
    }
  }

  // 1.3 Get transactions
  Future<List<Transaction>> getTransactions(String phone) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/wallets/$phone/transactions'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Transaction.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors de la récupération de l\'historique');
    }
  }

  // 1.4 Transfer
  Future<Transaction> transfer({
    required String senderPhone,
    required String receiverPhone,
    required double amount,
  }) async {
    final body = jsonEncode({
      'senderPhone': senderPhone,
      'receiverPhone': receiverPhone,
      'amount': amount,
    });

    final response = await _client.post(
      Uri.parse('$baseUrl/api/wallets/transfer'),
      headers: _headers,
      body: body,
    );

    if (response.statusCode == 200) {
      return Transaction.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erreur lors du transfert: ${response.body}');
    }
  }

  // 1.5 Deposit
  Future<Transaction> deposit({
    required int walletId,
    required double amount,
    required String paymentMethod,
  }) async {
    final body = jsonEncode({
      'amount': amount,
      'paymentMethod': paymentMethod,
    });

    final response = await _client.post(
      Uri.parse('$baseUrl/api/wallets/$walletId/deposit'),
      headers: _headers,
      body: body,
    );

    if (response.statusCode == 200) {
      return Transaction.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erreur lors du dépôt: ${response.body}');
    }
  }

  // 1.6 Withdraw
  Future<Transaction> withdraw({
    required String phoneNumber,
    required double amount,
  }) async {
    final body = jsonEncode({
      'phoneNumber': phoneNumber,
      'amount': amount,
    });

    final response = await _client.post(
      Uri.parse('$baseUrl/api/wallets/withdraw'),
      headers: _headers,
      body: body,
    );

    if (response.statusCode == 200) {
      return Transaction.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erreur lors du retrait: ${response.body}');
    }
  }

  // ============================================
  // 2. BILLS ENDPOINTS
  // ============================================

  // 2.1 Get current unpaid bills
  Future<List<Facture>> getCurrentBills(String walletCode) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/external/factures/$walletCode/current'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Facture.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors de la récupération des factures');
    }
  }

  // 2.2 Get current unpaid bills by provider
  Future<List<Facture>> getCurrentBillsByProvider(
    String walletCode,
    String provider,
  ) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/external/factures/$walletCode/current?unite=$provider'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Facture.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors de la récupération des factures');
    }
  }

  // 2.3 Pay current bill
  Future<String> payCurrentBill({
    required String phoneNumber,
    required String serviceName,
  }) async {
    final body = jsonEncode({
      'phoneNumber': phoneNumber,
      'serviceName': serviceName,
    });

    final response = await _client.post(
      Uri.parse('$baseUrl/api/wallets/pay'),
      headers: _headers,
      body: body,
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Erreur lors du paiement: ${response.body}');
    }
  }

  // 2.4 Pay specific bills
  Future<String> paySpecificBills({
    required String phoneNumber,
    required List<String> factureReferences,
  }) async {
    final body = jsonEncode({
      'phoneNumber': phoneNumber,
      'factureReferences': factureReferences,
    });

    final response = await _client.post(
      Uri.parse('$baseUrl/api/wallets/pay-factures'),
      headers: _headers,
      body: body,
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Erreur lors du paiement: ${response.body}');
    }
  }
}