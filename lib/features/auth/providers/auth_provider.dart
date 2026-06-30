// lib/features/auth/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:exam_flutter/services/api_service.dart';
import 'package:exam_flutter/services/storage_service.dart';
import 'package:exam_flutter/models/wallet.dart';
import 'package:exam_flutter/core/utils/formatters.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  String? _userPhone;
  String? _walletCode;
  int? _walletId;
  Wallet? _wallet;
  bool _isLoading = false;
  String? _error;

  String? get userPhone => _userPhone;
  String? get walletCode => _walletCode;
  int? get walletId => _walletId;
  Wallet? get wallet => _wallet;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> checkLoginStatus() async {
    final phone = await StorageService.getPhone();
    if (phone != null && phone.isNotEmpty) {
      _userPhone = phone;
      _walletCode = await StorageService.getWalletCode();
      _walletId = await StorageService.getWalletId();
      return true;
    }
    return false;
  }

  Future<bool> login(String phone) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Normaliser le numéro de téléphone
      final normalizedPhone = PhoneFormatter.normalizePhone(phone.trim());
      print('Tentative de connexion avec: $normalizedPhone');
      
      final wallet = await _apiService.getWallet(normalizedPhone);
      _userPhone = normalizedPhone;
      _wallet = wallet;
      _walletCode = wallet.code;
      _walletId = wallet.id;

      await StorageService.savePhone(normalizedPhone);
      await StorageService.saveWalletCode(wallet.code);
      await StorageService.saveWalletId(wallet.id);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('Erreur de connexion: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await StorageService.clear();
    _userPhone = null;
    _walletCode = null;
    _walletId = null;
    _wallet = null;
    notifyListeners();
  }

  void updateWalletBalance(double newBalance) {
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
}