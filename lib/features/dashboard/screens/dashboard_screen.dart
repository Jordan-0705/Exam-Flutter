import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:exam_flutter/core/theme/app_theme.dart';
import 'package:exam_flutter/core/utils/formatters.dart';
import 'package:exam_flutter/core/widgets/loading_widget.dart';
import 'package:exam_flutter/core/widgets/error_widget.dart';
import 'package:exam_flutter/features/dashboard/providers/dashboard_provider.dart';
import 'package:exam_flutter/features/auth/providers/auth_provider.dart';
import 'package:exam_flutter/models/transaction.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _showBalance = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = context.read<AuthProvider>();
    if (authProvider.userPhone != null) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    final authProvider = context.read<AuthProvider>();
    final dashboardProvider = context.read<DashboardProvider>();
    
    final phone = authProvider.userPhone;
    final walletCode = authProvider.walletCode;
    
    if (phone != null && walletCode != null) {
      await dashboardProvider.loadDashboard(phone, walletCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('BadWallet'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => _logout(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: Consumer<DashboardProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: LoadingWidget());
            }

            if (provider.error != null) {
              return ErrorDisplayWidget(
                message: provider.error!,
                onRetry: _loadData,
              );
            }

            final wallet = provider.wallet;
            if (wallet == null) {
              return const Center(child: Text('Aucune donnée disponible'));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Card Solde
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Solde disponible',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  _showBalance ? Icons.visibility : Icons.visibility_off,
                                  color: Colors.white70,
                                ),
                                onPressed: () => setState(() => _showBalance = !_showBalance),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _showBalance 
                                ? formatCurrency(wallet.balance)
                                : '••••••••',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            wallet.code,
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Actions rapides
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: [
                      _buildActionCard(
                        icon: Icons.send,
                        label: 'Transférer',
                        color: Colors.blue,
                        onTap: () => Navigator.pushNamed(context, '/transfer'),
                      ),
                      _buildActionCard(
                        icon: Icons.receipt,
                        label: 'Payer',
                        color: Colors.green,
                        onTap: () => Navigator.pushNamed(context, '/bills'),
                      ),
                      _buildActionCard(
                        icon: Icons.history,
                        label: 'Historique',
                        color: Colors.orange,
                        onTap: () => Navigator.pushNamed(context, '/history'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Dernières transactions
                  if (provider.recentTransactions.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Dernières transactions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(context, '/history'),
                          child: const Text('Voir tout'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...provider.recentTransactions.take(5).map((transaction) =>
                      _buildTransactionItem(transaction),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: transaction.color.withValues(alpha: 0.2),
          child: Icon(
            transaction.isCredit ? Icons.arrow_downward : Icons.arrow_upward,
            color: transaction.color,
          ),
        ),
        title: Text(transaction.typeLabel),
        subtitle: Text(
          transaction.formattedDescription,
          style: AppTheme.bodySmall,
        ),
        trailing: Text(
          '${transaction.isCredit ? '+' : '-'} ${formatCurrency(transaction.absoluteAmount)}',
          style: TextStyle(
            color: transaction.color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Future<void> _logout() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }
}