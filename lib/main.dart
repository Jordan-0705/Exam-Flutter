// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:exam_flutter/core/theme/app_theme.dart';
import 'package:exam_flutter/features/auth/providers/auth_provider.dart';
import 'package:exam_flutter/features/dashboard/providers/dashboard_provider.dart';
import 'package:exam_flutter/features/transfers/providers/transfer_provider.dart';
import 'package:exam_flutter/features/bills/providers/bills_provider.dart';
import 'package:exam_flutter/features/history/providers/history_provider.dart';
import 'package:exam_flutter/features/auth/screens/splash_screen.dart';
import 'package:exam_flutter/features/auth/screens/login_screen.dart';
import 'package:exam_flutter/features/dashboard/screens/dashboard_screen.dart';
import 'package:exam_flutter/features/transfers/screens/transfer_screen.dart';
import 'package:exam_flutter/features/bills/screens/bills_screen.dart';
import 'package:exam_flutter/features/history/screens/history_screen.dart';

void main() {
  runApp(const BadWalletApp());
}

class BadWalletApp extends StatelessWidget {
  const BadWalletApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => TransferProvider()),
        ChangeNotifierProvider(create: (_) => BillsProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
      ],
      child: MaterialApp(
        title: 'BadWallet',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          '/transfer': (context) => const TransferScreen(),
          '/bills': (context) => const BillsScreen(),
          '/history': (context) => const HistoryScreen(),
        },
      ),
    );
  }
}