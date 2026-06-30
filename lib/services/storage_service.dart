// lib/services/storage_service.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  
  // Clés de stockage
  static const String keyPhone = 'user_phone';
  static const String keyWalletCode = 'wallet_code';
  static const String keyWalletId = 'wallet_id';

  // Sauvegarder le téléphone
  static Future<void> savePhone(String phone) async {
    await _secureStorage.write(key: keyPhone, value: phone);
  }

  // Récupérer le téléphone
  static Future<String?> getPhone() async {
    return await _secureStorage.read(key: keyPhone);
  }

  // Sauvegarder le code wallet
  static Future<void> saveWalletCode(String code) async {
    await _secureStorage.write(key: keyWalletCode, value: code);
  }

  // Récupérer le code wallet
  static Future<String?> getWalletCode() async {
    return await _secureStorage.read(key: keyWalletCode);
  }

  // Sauvegarder l'ID wallet
  static Future<void> saveWalletId(int id) async {
    await _secureStorage.write(key: keyWalletId, value: id.toString());
  }

  // Récupérer l'ID wallet
  static Future<int?> getWalletId() async {
    final value = await _secureStorage.read(key: keyWalletId);
    return value != null ? int.parse(value) : null;
  }

  // Effacer toutes les données
  static Future<void> clear() async {
    await _secureStorage.delete(key: keyPhone);
    await _secureStorage.delete(key: keyWalletCode);
    await _secureStorage.delete(key: keyWalletId);
  }

  // Vérifier si l'utilisateur est connecté
  static Future<bool> isLoggedIn() async {
    final phone = await getPhone();
    return phone != null && phone.isNotEmpty;
  }
}