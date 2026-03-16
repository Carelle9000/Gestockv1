import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/transaction/transaction_service.dart';
import '../../core/need/need_service.dart';
import '../../shared/models/transaction.dart';
import '../../shared/models/need.dart';
import '../../shared/models/account.dart';

class TransactionPage extends StatefulWidget {
  final TransactionService transactionService;
  final NeedService needService;

  const TransactionPage({
    super.key,
    required this.transactionService,
    required this.needService,
  });

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Transaction> _transactions = [];
  List<Need> _pendingNeeds = [];
  List<Account> _accounts = [];
  bool _isLoading = true;
  final _currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  void _loadData() {
    try {
      setState(() => _isLoading = true);
      final txs = widget.transactionService.getAllTransactions();
      final needs = widget.needService.getAllNeeds().where((n) => n.status != 'Payé').toList();
      final accs = widget.transactionService.getAllAccounts();
      
      setState(() {
        _transactions = txs;
        _pendingNeeds = needs;
        _accounts = accs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("Erreur lors du chargement des transactions: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Transactions & Finance'),
        backgroundColor: const Color(0xFF0F172A),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.cyanAccent,
          labelColor: Colors.cyanAccent,
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(text: 'Historique', icon: Icon(Icons.history)),
            Tab(text: 'Besoins en attente', icon: Icon(Icons.pending_actions)),
          ],
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Colors.cyanAccent))
        : TabBarView(
            controller: _tabController,
            children: [
              _buildTransactionHistory(),
              _buildPendingNeeds(),
            ],
          ),
    );
  }

  Widget _buildTransactionHistory() {
    if (_transactions.isEmpty && _accounts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_balance_wallet_outlined, size: 64, color: Colors.white24),
            const SizedBox(height: 16),
            const Text('Aucun compte configuré', style: TextStyle(color: Colors.white70, fontSize: 18)),
            const SizedBox(height: 8),
            const Text('Veuillez créer un compte dans les paramètres', style: TextStyle(color: Colors.white54)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadData,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent, foregroundColor: Colors.black),
              child: const Text('Actualiser'),
            )
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildBalanceSummary(),
        Expanded(
          child: _transactions.isEmpty 
            ? const Center(child: Text('Aucune transaction enregistrée', style: TextStyle(color: Colors.white54)))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _transactions.length,
                itemBuilder: (context, index) {
                  final tx = _transactions[index];
                  final isIncome = tx.type == 'INCOME';
                  return Card(
                    color: Colors.white.withValues(alpha: 0.05),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: (isIncome ? Colors.green : Colors.red).withValues(alpha: 0.1),
                        child: Icon(
                          isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                          color: isIncome ? Colors.green : Colors.redAccent,
                        ),
                      ),
                      title: Text(tx.description, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      subtitle: Text(DateFormat('dd/MM/yyyy HH:mm').format(tx.date), style: const TextStyle(color: Colors.white54)),
                      trailing: Text(
                        '${isIncome ? "+" : "-"}${_currencyFormat.format(tx.amount)}',
                        style: TextStyle(
                          color: isIncome ? Colors.greenAccent : Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
        ),
      ],
    );
  }

  Widget _buildBalanceSummary() {
    final balance = widget.transactionService.getTotalBalance();
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1E3A8A), Color(0xFF1E40AF)]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Solde Actuel', style: TextStyle(color: Colors.white70, fontSize: 14)),
              SizedBox(height: 4),
              Text('Total en caisse', style: TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
          Text(
            _currencyFormat.format(balance),
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingNeeds() {
    if (_pendingNeeds.isEmpty) {
      return const Center(child: Text('Aucun besoin en attente', style: TextStyle(color: Colors.white54)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _pendingNeeds.length,
      itemBuilder: (context, index) {
        final need = _pendingNeeds[index];
        return Card(
          color: Colors.white.withValues(alpha: 0.05),
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(need.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: Text('Coût estimé: ${_currencyFormat.format(need.estimatedCost)}', style: const TextStyle(color: Colors.white70)),
            trailing: ElevatedButton(
              onPressed: () => _confirmPayment(need),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyanAccent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              child: const Text('PAYER', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        );
      },
    );
  }

  void _confirmPayment(Need need) {
    if (_accounts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez d\'abord créer un compte financier')),
      );
      return;
    }

    Account? selectedAccount = _accounts.first;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text('Confirmer le paiement', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Voulez-vous enregistrer une dépense de ${_currencyFormat.format(need.estimatedCost)} pour "${need.title}" ?', style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 20),
              DropdownButtonFormField<Account>(
                initialValue: selectedAccount,
                dropdownColor: const Color(0xFF1E293B),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Compte de débit',
                  labelStyle: TextStyle(color: Colors.cyanAccent),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                ),
                items: _accounts.map((acc) => DropdownMenuItem(
                  value: acc,
                  child: Text('${acc.name} (${_currencyFormat.format(acc.balance)})'),
                )).toList(),
                onChanged: (val) => setDialogState(() => selectedAccount = val),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ANNULER')),
            ElevatedButton(
              onPressed: () async {
                if (selectedAccount == null) return;
                
                final messenger = ScaffoldMessenger.of(context);
                final navigator = Navigator.of(ctx);
                
                try {
                  await widget.transactionService.payNeed(need, selectedAccount!.id);
                  _loadData();
                  navigator.pop();
                  messenger.showSnackBar(const SnackBar(content: Text('Paiement effectué et transaction enregistrée')));
                } catch (e) {
                  messenger.showSnackBar(SnackBar(content: Text('Erreur: $e')));
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent, foregroundColor: Colors.black),
              child: const Text('CONFIRMER'),
            ),
          ],
        ),
      ),
    );
  }
}
