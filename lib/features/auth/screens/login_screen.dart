import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:exam_flutter/core/theme/app_theme.dart';
import 'package:exam_flutter/core/widgets/loading_widget.dart';
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
    
    if (phone.isEmpty) {
      setState(() {
        _errorMessage = 'Veuillez entrer votre numéro de téléphone';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.login(phone);
      
      if (mounted) {
        if (success) {
          Navigator.pushReplacementNamed(context, '/dashboard');
        } else {
          setState(() {
            _errorMessage = 'Numéro non trouvé. Veuillez réessayer.';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Erreur de connexion: $e';
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
                ),
                const SizedBox(height: 10),
                Text(
                  'Connectez-vous pour accéder à votre portefeuille',
                  style: AppTheme.bodyLarge.copyWith(
                    color: Colors.white70,
                  ),
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
                            labelText: 'Numéro de téléphone',
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
                // Text(
                //   '🔒 Toutes vos données sont sécurisées',
                //   style: AppTheme.bodySmall.copyWith(
                //     color: Colors.white60,
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}