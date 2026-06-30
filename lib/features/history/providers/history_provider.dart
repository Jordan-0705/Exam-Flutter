import 'package:flutter/material.dart';
import 'package:exam_flutter/services/api_service.dart';
import 'package:exam_flutter/models/transaction.dart';

class HistoryProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Transaction> _transactions = [];
  bool _isLoading = false;
  String? _error;

  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadHistory(String phone) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _transactions = await _apiService.getTransactions(phone);
      _transactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Transaction> filterByType(TransactionType? type) {
    if (type == null) return _transactions;
    return _transactions.where((t) => t.type == type).toList();
  }

  double get totalCredits {
    return _transactions
        .where((t) => t.isCredit)
        .fold(0, (sum, t) => sum + t.amount.abs());
  }

  double get totalDebits {
    return _transactions
        .where((t) => !t.isCredit)
        .fold(0, (sum, t) => sum + t.amount.abs());
  }
}