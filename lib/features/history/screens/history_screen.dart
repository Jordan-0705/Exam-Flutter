import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:exam_flutter/core/theme/app_theme.dart';
import 'package:exam_flutter/core/utils/formatters.dart';
import 'package:exam_flutter/core/widgets/loading_widget.dart';
import 'package:exam_flutter/core/widgets/error_widget.dart';
import 'package:exam_flutter/features/history/providers/history_provider.dart';
import 'package:exam_flutter/features/auth/providers/auth_provider.dart';
import 'package:exam_flutter/models/transaction.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  TransactionType? _filterType;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHistory();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final authProvider = context.read<AuthProvider>();
    final historyProvider = context.read<HistoryProvider>();
    
    final phone = authProvider.userPhone;
    if (phone != null) {
      await historyProvider.loadHistory(phone);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des transactions'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          PopupMenuButton<TransactionType?>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _filterType = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Text('Toutes'),
              ),
              const PopupMenuItem(
                value: TransactionType.deposit,
                child: Text('Dépôts'),
              ),
              const PopupMenuItem(
                value: TransactionType.withdrawal,
                child: Text('Retraits'),
              ),
              const PopupMenuItem(
                value: TransactionType.transfer,
                child: Text('Transferts'),
              ),
              const PopupMenuItem(
                value: TransactionType.payment,
                child: Text('Paiements'),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadHistory,
        child: Consumer<HistoryProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: LoadingWidget());
            }

            if (provider.error != null) {
              return ErrorDisplayWidget(
                message: provider.error!,
                onRetry: _loadHistory,
              );
            }

            final transactions = _filterType != null
                ? provider.filterByType(_filterType)
                : provider.transactions;

            if (transactions.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Aucune transaction',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Vos transactions apparaîtront ici',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                return _buildTransactionItem(transaction);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          // ✅ CORRECTION: withOpacity -> withValues
          backgroundColor: transaction.color.withValues(alpha: 0.2),
          child: Icon(
            transaction.isCredit ? Icons.arrow_downward : Icons.arrow_upward,
            color: transaction.color,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.typeLabel,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    transaction.description,
                    style: AppTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${transaction.isCredit ? '+' : '-'} ${formatCurrency(transaction.amount.abs())}',
                  style: TextStyle(
                    color: transaction.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Frais: ${formatCurrency(transaction.fee)}',
                  style: AppTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              transaction.reference,
              style: AppTheme.bodySmall,
            ),
            Text(
              formatDate(transaction.createdAt),
              style: AppTheme.bodySmall,
            ),
          ],
        ),
        //CORRECTION: error_circle -> cancel, retirer const problématique
        trailing: transaction.status == TransactionStatus.completed
            ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
            : transaction.status == TransactionStatus.failed
                ? const Icon(Icons.cancel, color: Colors.red, size: 20)
                : const Icon(Icons.pending, color: Colors.orange, size: 20),
      ),
    );
  }
}