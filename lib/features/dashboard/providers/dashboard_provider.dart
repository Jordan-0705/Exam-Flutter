import 'package:flutter/material.dart';
import 'package:exam_flutter/services/api_service.dart';
import 'package:exam_flutter/models/wallet.dart';
import 'package:exam_flutter/models/transaction.dart';

class DashboardProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  Wallet? _wallet;
  List<Transaction> _recentTransactions = [];
  bool _isLoading = false;
  String? _error;

  Wallet? get wallet => _wallet;
  List<Transaction> get recentTransactions => _recentTransactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadDashboard(String phone, String walletCode) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Charger le wallet avec le solde à jour
      _wallet = await _apiService.getWallet(phone);
      
      // Charger les transactions récentes
      final allTransactions = await _apiService.getTransactions(phone);
      _recentTransactions = allTransactions.take(5).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshBalance(String phone) async {
    try {
      final balance = await _apiService.getBalance(phone);
      if (_wallet != null) {
        _wallet = Wallet(
          id: _wallet!.id,
          phoneNumber: _wallet!.phoneNumber,
          email: _wallet!.email,
          code: _wallet!.code,
          balance: balance,
          currency: _wallet!.currency,
          createdAt: _wallet!.createdAt,
        );
        notifyListeners();
      }
    } catch (e) {
      print('Erreur refresh solde: $e');
    }
  }

  void updateBalance(double newBalance) {
    if (_wallet != null) {
      _wallet = Wallet(
        id: _wallet!.id,
        phoneNumber: _wallet!.phoneNumber,
        email: _wallet!.email,
        code: _wallet!.code,
        balance: newBalance,
        currency: _wallet!.currency,
        createdAt: _wallet!.createdAt,
      );
      notifyListeners();
    }
  }

  void addTransaction(Transaction transaction) {
    _recentTransactions.insert(0, transaction);
    if (_recentTransactions.length > 5) {
      _recentTransactions = _recentTransactions.take(5).toList();
    }
    notifyListeners();
  }
}