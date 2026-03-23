import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../core/stock/product_service.dart';
import '../../core/sales/sales_service.dart';
import '../../core/auth/auth_service.dart';
import '../../core/transaction/transaction_service.dart';
import '../../repositories/client_repository.dart';
import '../../shared/models/sales.dart';
import '../../shared/models/transaction.dart';
import 'reports_page.dart';

class DashboardPage extends StatelessWidget {
  final ProductService productService;
  final SalesService salesService;
  final ClientRepository clientRepository;
  final AuthService authService;
  final TransactionService transactionService;

  const DashboardPage({
    super.key,
    required this.productService,
    required this.salesService,
    required this.clientRepository,
    required this.authService,
    required this.transactionService,
  });

  @override
  Widget build(BuildContext context) {
    final allProducts = productService.getAllProducts();
    final allSales = salesService.getAllSales();
    final allTransactions = transactionService.getAllTransactions();
    final allClients = clientRepository.getAll();
    final lowStockCount = productService.getLowStockProducts().length;
    final userName = authService.currentUser?.name ?? 'Utilisateur';

    // Calcul des ventes du jour
    final now = DateTime.now();
    final todaySales = allSales.where((s) => 
      s.date.year == now.year && s.date.month == now.month && s.date.day == now.day
    );
    final todayTotal = todaySales.fold(0.0, (sum, s) => sum + s.totalAmount);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bienvenue, $userName ! 👋',
                      style: TextStyle(
                        fontSize: 16, 
                        color: Colors.cyanAccent.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Tableau de Bord',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReportsPage(transactionService: transactionService),
                      ),
                    );
                  },
                  icon: const Icon(Icons.analytics_outlined, color: Colors.cyanAccent, size: 30),
                  tooltip: 'Rapports détaillés',
                ),
              ],
            ),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 1.1,
              children: [
                _buildStatCard('Produits', '${allProducts.length}', Icons.inventory_2, Colors.blue),
                _buildStatCard('Ventes Jour', '${NumberFormat.compact().format(todayTotal)} FCFA', Icons.shopping_cart, Colors.green),
                _buildStatCard('Clients', '${allClients.length}', Icons.people, Colors.orange),
                _buildStatCard('Alertes Stock', '$lowStockCount', Icons.warning, Colors.red),
              ],
            ),
            const SizedBox(height: 30),
            _buildSectionTitle('Évolution des Ventes (7 jours)'),
            const SizedBox(height: 15),
            _buildSalesChart(allSales),
            const SizedBox(height: 30),
            _buildSectionTitle('Bilan Financier'),
            const SizedBox(height: 15),
            _buildFinancialOverview(allTransactions),
            const SizedBox(height: 30),
            _buildSectionTitle('Activités Récentes'),
            const SizedBox(height: 15),
            _buildRecentActivity(allSales),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            title, 
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value, 
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesChart(List<Sales> sales) {
    final last7Days = List.generate(7, (index) {
      return DateTime.now().subtract(Duration(days: 6 - index));
    });

    final dataPoints = last7Days.map((date) {
      final dayTotal = sales
          .where((s) => s.date.year == date.year && s.date.month == date.month && s.date.day == date.day)
          .fold(0.0, (sum, s) => sum + s.totalAmount);
      return FlSpot(last7Days.indexOf(date).toDouble(), dayTotal);
    }).toList();

    return Container(
      height: 200,
      padding: const EdgeInsets.fromLTRB(10, 20, 20, 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  int idx = value.toInt();
                  if (idx < 0 || idx >= 7) return const Text('');
                  return Text(
                    DateFormat('E', 'fr').format(last7Days[idx]),
                    style: const TextStyle(color: Colors.white54, fontSize: 10),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: dataPoints,
              isCurved: true,
              color: Colors.cyanAccent,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.cyanAccent.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialOverview(List<Transaction> transactions) {
    final now = DateTime.now();
    
    // Calculs Mensuels
    final monthTransactions = transactions.where((t) => t.date.month == now.month && t.date.year == now.year);
    final monthIncome = monthTransactions.where((t) => t.type == 'INCOME').fold(0.0, (sum, t) => sum + t.amount);
    final monthExpense = monthTransactions.where((t) => t.type == 'EXPENSE').fold(0.0, (sum, t) => sum + t.amount);
    final monthProfit = monthIncome - monthExpense;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.withValues(alpha: 0.2), Colors.purple.withValues(alpha: 0.2)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Bénéfice (Ce mois)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Text(
                '${NumberFormat.decimalPattern().format(monthProfit)} FCFA',
                style: TextStyle(
                  color: monthProfit >= 0 ? Colors.greenAccent : Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              _buildMiniStat('Entrées', monthIncome, Colors.green),
              const SizedBox(width: 20),
              _buildMiniStat('Sorties', monthExpense, Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, double amount, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            '${NumberFormat.compact().format(amount)} FCFA',
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(List<Sales> sales) {
    final recentSales = sales.take(5).toList();

    if (recentSales.isEmpty) {
      return const Center(
        child: Text('Aucune activité récente', style: TextStyle(color: Colors.white54)),
      );
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: recentSales.length,
        separatorBuilder: (_, __) => const Divider(color: Colors.white12),
        itemBuilder: (context, index) {
          final sale = recentSales[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
            leading: const CircleAvatar(
              backgroundColor: Colors.green, 
              radius: 18,
              child: Icon(Icons.shopping_bag, color: Colors.white, size: 18)
            ),
            title: Text(
              'Vente #${sale.id.substring(0, 8)}', 
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            subtitle: Text(
              DateFormat('HH:mm').format(sale.date), 
              style: const TextStyle(color: Colors.white54, fontSize: 12)
            ),
            trailing: Text(
              '${NumberFormat.decimalPattern().format(sale.totalAmount)} FCFA', 
              style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 13)
            ),
          );
        },
      ),
    );
  }
}
