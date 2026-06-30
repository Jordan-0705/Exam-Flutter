import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:exam_flutter/core/theme/app_theme.dart';
import 'package:exam_flutter/core/widgets/loading_widget.dart';
import 'package:exam_flutter/core/utils/validators.dart';
// import 'package:exam_flutter/core/utils/formatters.dart';
import 'package:exam_flutter/features/auth/providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _login() async {
    final phone = _phoneController.text.trim();
    
    // Validation avec le validateur
    final validationError = Validators.validatePhone(phone);
    if (validationError != null) {
      setState(() {
        _errorMessage = validationError;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final authProvider = context.read<AuthProvider>();
      // Le numéro sera normalisé dans AuthProvider
      final success = await authProvider.login(phone);
      
      if (mounted) {
        if (success) {
          Navigator.pushReplacementNamed(context, '/dashboard');
        } else {
          setState(() {
            _errorMessage = 'Numero non trouve. Veuillez reessayer.';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Erreur: ${e.toString()}';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.account_balance_wallet,
                              size: 40,
                              color: Color(0xFF667eea),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Bienvenue sur BadWallet',
                            style: AppTheme.headlineMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Connectez-vous pour acceder a votre portefeuille',
                            style: AppTheme.bodyLarge.copyWith(
                              color: Colors.white70,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 40),
                          Card(
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                children: [
                                  TextField(
                                    controller: _phoneController,
                                    keyboardType: TextInputType.phone,
                                    decoration: InputDecoration(
                                      prefixIcon: const Icon(Icons.phone),
                                      labelText: 'Numero de telephone',
                                      hintText: '77 000 00 01',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
                                    ),
                                    onChanged: (_) {
                                      if (_errorMessage.isNotEmpty) {
                                        setState(() => _errorMessage = '');
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  if (_isLoading)
                                    const LoadingWidget()
                                  else
                                    ElevatedButton(
                                      onPressed: _login,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF667eea),
                                        minimumSize: const Size(double.infinity, 50),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: const Text(
                                        'Se connecter',
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
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Toutes vos donnees sont securisees',
                            style: AppTheme.bodySmall.copyWith(
                              color: Colors.white60,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}