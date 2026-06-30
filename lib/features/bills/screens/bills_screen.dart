import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:exam_flutter/core/theme/app_theme.dart';
import 'package:exam_flutter/core/utils/formatters.dart';
import 'package:exam_flutter/core/widgets/loading_widget.dart';
import 'package:exam_flutter/core/widgets/error_widget.dart';
import 'package:exam_flutter/features/bills/providers/bills_provider.dart';
import 'package:exam_flutter/features/auth/providers/auth_provider.dart';
import 'package:exam_flutter/features/dashboard/providers/dashboard_provider.dart';

class BillsScreen extends StatefulWidget {
  const BillsScreen({super.key});

  @override
  State<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends State<BillsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBills();
    });
  }

  Future<void> _loadBills() async {
    final authProvider = context.read<AuthProvider>();
    final billsProvider = context.read<BillsProvider>();
    
    final walletCode = authProvider.walletCode;
    if (walletCode != null) {
      await billsProvider.loadBills(walletCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paiement de factures'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (context.watch<BillsProvider>().selectedReferences.isNotEmpty)
            TextButton(
              onPressed: _paySelectedBills,
              child: const Text(
                'Payer',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadBills,
        child: Consumer<BillsProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: LoadingWidget());
            }

            if (provider.error != null) {
              return ErrorDisplayWidget(
                message: provider.error!,
                onRetry: _loadBills,
              );
            }

            if (provider.factures.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Aucune facture impayée',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Vous n\'avez pas de factures à payer pour le moment',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total sélectionné:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        formatCurrency(provider.totalAmount),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
                
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: provider.factures.length,
                    itemBuilder: (context, index) {
                      final facture = provider.factures[index];
                      final isSelected = provider.isSelected(facture.reference);
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: CheckboxListTile(
                          value: isSelected,
                          onChanged: (_) {
                            provider.toggleSelection(facture.reference);
                          },
                          title: Row(
                            children: [
                              Text(
                                facture.providerIcon,
                                style: const TextStyle(fontSize: 24),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      facture.provider,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      facture.reference,
                                      style: AppTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          subtitle: Text(
                            'Échéance: ${formatDate(facture.dueDate)}',
                            style: AppTheme.bodySmall,
                          ),
                          // ✅ CORRECTION: trailing -> secondary
                          secondary: Text(
                            formatCurrency(facture.amount),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          controlAffinity: ListTileControlAffinity.leading,
                          activeColor: Colors.green,
                          checkColor: Colors.white,
                        ),
                      );
                    },
                  ),
                ),
                
                if (provider.selectedReferences.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          // ✅ CORRECTION: withOpacity -> withValues
                          color: Colors.grey.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _paySelectedBills,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Payer ${provider.selectedReferences.length} facture(s)',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _paySelectedBills() async {
    final authProvider = context.read<AuthProvider>();
    final billsProvider = context.read<BillsProvider>();
    final dashboardProvider = context.read<DashboardProvider>();
    
    final phoneNumber = authProvider.userPhone;
    if (phoneNumber == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmation'),
        content: Text(
          'Voulez-vous payer ${billsProvider.selectedReferences.length} facture(s) pour un total de ${formatCurrency(billsProvider.totalAmount)} ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Confirmer',
              style: TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final result = await billsProvider.paySelectedBills(phoneNumber);
    
    if (mounted) {
      if (result != null) {
        await dashboardProvider.refreshBalance(phoneNumber);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$result'),
            backgroundColor: Colors.green,
          ),
        );
        await _loadBills();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${billsProvider.error ?? "Erreur lors du paiement"}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}