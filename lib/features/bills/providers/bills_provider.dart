import 'package:flutter/material.dart';
import 'package:exam_flutter/services/api_service.dart';
import 'package:exam_flutter/models/facture.dart';

class BillsProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Facture> _factures = [];
  List<String> _selectedReferences = [];
  bool _isLoading = false;
  String? _error;

  List<Facture> get factures => _factures;
  List<String> get selectedReferences => _selectedReferences;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double get totalAmount {
    double total = 0;
    for (final ref in _selectedReferences) {
      final facture = _factures.firstWhere(
        (f) => f.reference == ref,
        orElse: () => throw Exception('Facture non trouvée'),
      );
      total += facture.amount;
    }
    return total;
  }

  Future<void> loadBills(String walletCode) async {
    _isLoading = true;
    _error = null;
    _selectedReferences = [];
    notifyListeners();

    try {
      _factures = await _apiService.getCurrentBills(walletCode);
      _factures = _factures.where((f) => f.isUnpaid).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleSelection(String reference) {
    if (_selectedReferences.contains(reference)) {
      _selectedReferences.remove(reference);
    } else {
      _selectedReferences.add(reference);
    }
    notifyListeners();
  }

  bool isSelected(String reference) {
    return _selectedReferences.contains(reference);
  }

  void clearSelection() {
    _selectedReferences = [];
    notifyListeners();
  }

  Future<String?> paySelectedBills(String phoneNumber) async {
    if (_selectedReferences.isEmpty) return null;

    try {
      final result = await _apiService.paySpecificBills(
        phoneNumber: phoneNumber,
        factureReferences: _selectedReferences,
      );
      
      // Marquer les factures comme payées
      for (final ref in _selectedReferences) {
        final index = _factures.indexWhere((f) => f.reference == ref);
        if (index != -1) {
          _factures[index] = Facture(
            id: _factures[index].id,
            walletCode: _factures[index].walletCode,
            provider: _factures[index].provider,
            reference: _factures[index].reference,
            amount: _factures[index].amount,
            dueDate: _factures[index].dueDate,
            status: FactureStatus.paid,
            createdAt: _factures[index].createdAt,
          );
        }
      }
      
      _selectedReferences = [];
      notifyListeners();
      return result;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }
}