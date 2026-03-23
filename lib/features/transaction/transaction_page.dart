import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/transaction/transaction_service.dart';
import '../../core/need/need_service.dart';
import '../../core/notification/notification_service.dart';
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
  List<Transaction> _filteredTransactions = [];
  List<Need> _pendingNeeds = [];
  List<Account> _accounts = [];
  bool _isLoading = true;
  
  String _selectedPeriod = 'Tout';
  final List<String> _periods = ['Tout', 'Jour', 'Semaine', 'Mois', 'Année'];
  final TextEditingController _searchController = TextEditingController();

  final _currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(_applyFilters);
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
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
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("Erreur lors du chargement des transactions: $e");
    }
  }

  void _applyFilters() {
    final now = DateTime.now();
    final query = _searchController.text.toLowerCase();

    setState(() {
      _filteredTransactions = _transactions.where((tx) {
        // Filtre par texte (description ou catégorie)
        final matchesSearch = tx.description.toLowerCase().contains(query) || 
                             tx.category.toLowerCase().contains(query);
        
        if (!matchesSearch) return false;

        // Filtre par période
        switch (_selectedPeriod) {
          case 'Jour':
            return tx.date.year == now.year && tx.date.month == now.month && tx.date.day == now.day;
          case 'Semaine':
            final weekStart = now.subtract(Duration(days: now.weekday - 1));
            final startOfToday = DateTime(weekStart.year, weekStart.month, weekStart.day);
            return tx.date.isAfter(startOfToday.subtract(const Duration(seconds: 1)));
          case 'Mois':
            return tx.date.year == now.year && tx.date.month == now.month;
          case 'Année':
            return tx.date.year == now.year;
          default:
            return true;
        }
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Transactions & Finance', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.cyanAccent,
          labelColor: Colors.cyanAccent,
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(text: 'Historique', icon: Icon(Icons.history)),
            Tab(text: 'Besoins', icon: Icon(Icons.pending_actions)),
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
        _buildSearchAndFilters(),
        Expanded(
          child: _filteredTransactions.isEmpty 
            ? _buildEmptyState()
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filteredTransactions.length,
                itemBuilder: (context, index) {
                  final tx = _filteredTransactions[index];
                  return _buildTransactionCard(tx);
                },
              ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Rechercher une transaction...',
              hintStyle: const TextStyle(color: Colors.white38),
              prefixIcon: const Icon(Icons.search, color: Colors.cyanAccent),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _periods.length,
            itemBuilder: (context, index) {
              final period = _periods[index];
              final isSelected = _selectedPeriod == period;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(period),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedPeriod = period;
                        _applyFilters();
                      });
                    }
                  },
                  backgroundColor: Colors.white.withValues(alpha: 0.05),
                  selectedColor: Colors.cyanAccent,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.black : Colors.white70,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  side: BorderSide.none,
                  showCheckmark: false,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildTransactionCard(Transaction tx) {
    final isIncome = tx.type == 'INCOME';
    final isSale = tx.category == 'SALE';
    final displayColor = (isIncome || isSale) ? Colors.greenAccent : Colors.redAccent;
    final displayIcon = (isIncome || isSale) ? Icons.arrow_downward : Icons.arrow_upward;
    final displayPrefix = (isIncome || isSale) ? "+" : "-";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: displayColor.withValues(alpha: 0.1),
          child: Icon(displayIcon, color: displayColor, size: 20),
        ),
        title: Text(
          tx.description, 
          maxLines: 1, 
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Text(DateFormat('dd/MM HH:mm').format(tx.date), style: const TextStyle(color: Colors.white54, fontSize: 11)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getCategoryColor(tx.category).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  tx.category,
                  style: TextStyle(color: _getCategoryColor(tx.category), fontSize: 9, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        trailing: Text(
          '$displayPrefix${_currencyFormat.format(tx.amount)}',
          style: TextStyle(
            color: displayColor,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'SALE': return Colors.greenAccent;
      case 'PURCHASE': return Colors.orangeAccent;
      case 'EXPENSE': return Colors.redAccent;
      case 'REFUND': return Colors.blueAccent;
      case 'CLIENT_PAYMENT': return Colors.cyanAccent;
      default: return Colors.white54;
    }
  }

  Widget _buildBalanceSummary() {
    final balance = widget.transactionService.getTotalBalance();
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1E3A8A), Color(0xFF1E40AF)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Solde Total', style: TextStyle(color: Colors.white70, fontSize: 14)),
              SizedBox(height: 4),
              Text('En caisse', style: TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                _currencyFormat.format(balance),
                style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _searchController.text.isEmpty && _selectedPeriod == 'Tout' 
              ? Icons.receipt_long_outlined 
              : Icons.search_off,
            size: 80, 
            color: Colors.white.withValues(alpha: 0.1)
          ),
          const SizedBox(height: 16),
          Text(
            _searchController.text.isEmpty && _selectedPeriod == 'Tout'
              ? "Aucune transaction enregistrée"
              : "Aucun résultat pour cette recherche",
            style: const TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingNeeds() {
    if (_pendingNeeds.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.done_all, size: 80, color: Colors.greenAccent.withValues(alpha: 0.1)),
            const SizedBox(height: 16),
            const Text('Tous les besoins sont payés !', style: TextStyle(color: Colors.white54)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _pendingNeeds.length,
      itemBuilder: (context, index) {
        final need = _pendingNeeds[index];
        return Card(
          color: Colors.white.withValues(alpha: 0.05),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(need.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: Text('Coût: ${_currencyFormat.format(need.estimatedCost)}', style: const TextStyle(color: Colors.white70)),
            trailing: ElevatedButton(
              onPressed: () => _confirmPayment(need),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyanAccent,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
      NotificationService.showSnackBar(context, 'Veuillez d\'abord créer un compte financier', isError: true);
      return;
    }

    Account? selectedAccount = _accounts.first;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Confirmer le paiement', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Voulez-vous payer ${_currencyFormat.format(need.estimatedCost)} pour "${need.title}" ?', 
                style: const TextStyle(color: Colors.white70)
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<Account>(
                isExpanded: true,
                initialValue: selectedAccount,
                dropdownColor: const Color(0xFF1E293B),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Compte de débit',
                  labelStyle: const TextStyle(color: Colors.cyanAccent),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                items: _accounts.map((acc) => DropdownMenuItem(
                  value: acc,
                  child: Text(
                    '${acc.name} (${_currencyFormat.format(acc.balance)})',
                    overflow: TextOverflow.ellipsis,
                  ),
                )).toList(),
                onChanged: (val) => setDialogState(() => selectedAccount = val),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx), 
              child: Text('ANNULER', style: TextStyle(color: Colors.white.withValues(alpha: 0.5)))
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedAccount == null) return;
                
                try {
                  await widget.transactionService.payNeed(need, selectedAccount!.id);
                  if (!mounted) return;
                  _loadData();
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    NotificationService.showSuccessDialog(
                      context, 
                      title: 'Paiement Réussi', 
                      desc: 'La transaction a été enregistrée sur le compte ${selectedAccount!.name}.'
                    );
                  }
                } catch (e) {
                  if (ctx.mounted) {
                    NotificationService.showErrorDialog(
                      context, 
                      title: 'Échec du Paiement', 
                      desc: e.toString()
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyanAccent, 
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('CONFIRMER'),
            ),
          ],
        ),
      ),
    );
  }
}
