import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:exam_flutter/core/theme/app_theme.dart';
import 'package:exam_flutter/core/utils/formatters.dart';
import 'package:exam_flutter/core/widgets/loading_widget.dart';
import 'package:exam_flutter/features/transfers/providers/transfer_provider.dart';
import 'package:exam_flutter/features/auth/providers/auth_provider.dart';
import 'package:exam_flutter/features/dashboard/providers/dashboard_provider.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transférer'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Champ destinataire
            TextField(
              controller: _recipientController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Numéro du destinataire',
                hintText: '77 000 00 01',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: _recipientController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _recipientController.clear(),
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _errorMessage = '';
                });
              },
            ),
            const SizedBox(height: 16),

            // Montant
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  Text(
                    'Montant à transférer',
                    style: AppTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _amountController.text.isEmpty
                        ? '0 XOF'
                        : formatCurrency(double.tryParse(_amountController.text) ?? 0),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildNumericKeypad(),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Description
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description (optionnel)',
                hintText: 'Motif du transfert',
                prefixIcon: const Icon(Icons.note),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Erreur
            if (_errorMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ),
              ),
            
            const Spacer(),

            // Bouton de transfert
            if (_isLoading)
              const LoadingWidget()
            else
              ElevatedButton(
                onPressed: _validateAndTransfer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF667eea),
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Transférer',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumericKeypad() {
    const keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['clear', '0', 'backspace'],
    ];

    return Column(
      children: keys.map((row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: row.map((key) {
            return _buildKey(key);
          }).toList(),
        );
      }).toList(),
    );
  }

  Widget _buildKey(String key) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onKeyPressed(key),
        borderRadius: BorderRadius.circular(50),
        child: Container(
          width: 60,
          height: 60,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: key == 'clear' || key == 'backspace' 
                ? Colors.grey.shade200 
                : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: key == 'clear'
              ? Icon(Icons.clear, color: Colors.grey.shade800)
              : key == 'backspace'
                  ? Icon(Icons.backspace, color: Colors.grey.shade800)
                  : Text(
                      key,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
        ),
      ),
    );
  }

  void _onKeyPressed(String key) {
    setState(() {
      if (key == 'backspace') {
        if (_amountController.text.isNotEmpty) {
          _amountController.text = _amountController.text.substring(
            0,
            _amountController.text.length - 1,
          );
        }
      } else if (key == 'clear') {
        _amountController.text = '';
      } else if (key == '.') {
        if (!_amountController.text.contains('.')) {
          _amountController.text += '.';
        }
      } else {
        if (_amountController.text.replaceAll('.', '').length < 10) {
          _amountController.text += key;
        }
      }
      _errorMessage = '';
    });
  }

  Future<void> _validateAndTransfer() async {
    final recipient = _recipientController.text.trim();
    final amountText = _amountController.text.trim();

    // Validation
    if (recipient.isEmpty) {
      setState(() => _errorMessage = 'Veuillez entrer un numéro de destinataire');
      return;
    }

    final normalizedRecipient = PhoneFormatter.normalizePhone(recipient);
    if (!PhoneFormatter.isValidPhone(normalizedRecipient)) {
      setState(() => _errorMessage = 'Numero de telephone invalide');
      return;
    }

    if (amountText.isEmpty || double.tryParse(amountText) == null) {
      setState(() => _errorMessage = 'Veuillez entrer un montant valide');
      return;
    }

    final amount = double.parse(amountText);
    if (amount <= 0) {
      setState(() => _errorMessage = 'Le montant doit être supérieur à 0');
      return;
    }

    // Normaliser le numéro
    // String normalizedRecipient = recipient.replaceAll(RegExp(r'[\s\-]'), '');
    // if (!normalizedRecipient.startsWith('+')) {
    //   if (normalizedRecipient.startsWith('77')) {
    //     normalizedRecipient = '+221$normalizedRecipient';
    //   } else if (normalizedRecipient.startsWith('221')) {
    //     normalizedRecipient = '+$normalizedRecipient';
    //   }
    // }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final transferProvider = context.read<TransferProvider>();
      final dashboardProvider = context.read<DashboardProvider>();
      
      final senderPhone = authProvider.userPhone;
      if (senderPhone == null) {
        throw Exception('Utilisateur non connecté');
      }

      final result = await transferProvider.transfer(
        senderPhone: senderPhone,
        receiverPhone: normalizedRecipient,
        amount: amount,
        description: _descriptionController.text.trim(),
      );

      if (mounted && result != null) {
        await dashboardProvider.refreshBalance(senderPhone);
      
        dashboardProvider.addTransaction(result);

        // Vider les champs
        _recipientController.clear();
        _amountController.clear();
        _descriptionController.clear();

        // Afficher succès
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transfert effectué avec succès !'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
      } else if (mounted) {
        setState(() {
          _errorMessage = transferProvider.error ?? 'Erreur lors du transfert';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Erreur: ${e.toString()}';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _recipientController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}