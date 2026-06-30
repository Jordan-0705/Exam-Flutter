import 'package:flutter/material.dart';
import 'package:exam_flutter/services/api_service.dart';
import 'package:exam_flutter/models/transaction.dart';

class TransferProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  bool _isLoading = false;
  String? _error;
  Transaction? _lastTransaction;

  bool get isLoading => _isLoading;
  String? get error => _error;
  Transaction? get lastTransaction => _lastTransaction;

  Future<Transaction?> transfer({
    required String senderPhone,
    required String receiverPhone,
    required double amount,
    String? description,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final transaction = await _apiService.transfer(
        senderPhone: senderPhone,
        receiverPhone: receiverPhone,
        amount: amount,
      );
      
      _lastTransaction = transaction;
      _isLoading = false;
      notifyListeners();
      return transaction;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}