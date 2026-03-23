import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/transaction/transaction_service.dart';
import '../../shared/models/transaction.dart';

class ReportsPage extends StatefulWidget {
  final TransactionService transactionService;

  const ReportsPage({super.key, required this.transactionService});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allTransactions = widget.transactionService.getAllTransactions();

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Bilans & Rapports'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.cyanAccent,
          tabs: const [
            Tab(text: 'Journalier'),
            Tab(text: 'Mensuel'),
            Tab(text: 'Annuel'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDailyReport(allTransactions),
          _buildMonthlyReport(allTransactions),
          _buildAnnualReport(allTransactions),
        ],
      ),
    );
  }

  Widget _buildDailyReport(List<Transaction> transactions) {
    final now = DateTime.now();
    final todayTransactions = transactions.where((t) => 
      t.date.year == now.year && t.date.month == now.month && t.date.day == now.day
    ).toList();

    return _buildReportList(todayTransactions, "Aujourd'hui");
  }

  Widget _buildMonthlyReport(List<Transaction> transactions) {
    final now = DateTime.now();
    final monthTransactions = transactions.where((t) => 
      t.date.year == now.year && t.date.month == now.month
    ).toList();

    return _buildReportList(monthTransactions, DateFormat('MMMM yyyy', 'fr').format(now));
  }

  Widget _buildAnnualReport(List<Transaction> transactions) {
    final now = DateTime.now();
    final yearTransactions = transactions.where((t) => 
      t.date.year == now.year
    ).toList();

    return _buildReportList(yearTransactions, "Année ${now.year}");
  }

  Widget _buildReportList(List<Transaction> transactions, String period) {
    final income = transactions.where((t) => t.type == 'INCOME').fold(0.0, (sum, t) => sum + t.amount);
    final expense = transactions.where((t) => t.type == 'EXPENSE').fold(0.0, (sum, t) => sum + t.amount);
    final balance = income - expense;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard(period, income, expense, balance),
          const SizedBox(height: 30),
          const Text('Détails des flux', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          if (transactions.isEmpty)
            const Center(child: Padding(
              padding: EdgeInsets.all(40.0),
              child: Text('Aucune transaction pour cette période', style: TextStyle(color: Colors.white54)),
            ))
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transactions.length,
              separatorBuilder: (_, __) => const Divider(color: Colors.white10),
              itemBuilder: (context, index) {
                final t = transactions[index];
                final isIncome = t.type == 'INCOME';
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: isIncome ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                    child: Icon(isIncome ? Icons.arrow_downward : Icons.arrow_upward, 
                               color: isIncome ? Colors.greenAccent : Colors.redAccent, size: 20),
                  ),
                  title: Text(t.description, style: const TextStyle(color: Colors.white, fontSize: 14)),
                  subtitle: Text(DateFormat('dd/MM/yyyy HH:mm').format(t.date), style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  trailing: Text(
                    '${isIncome ? "+" : "-"}${_currencyFormat.format(t.amount)}',
                    style: TextStyle(
                      color: isIncome ? Colors.greenAccent : Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, double income, double expense, double balance) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          const SizedBox(height: 20),
          Text(
            _currencyFormat.format(balance),
            style: TextStyle(
              color: balance >= 0 ? Colors.greenAccent : Colors.redAccent,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text('Bénéfice Net', style: TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem('Entrées', income, Colors.greenAccent),
              Container(width: 1, height: 40, color: Colors.white10),
              _buildSummaryItem('Sorties', expense, Colors.redAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, double amount, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          _currencyFormat.format(amount),
          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }
}
