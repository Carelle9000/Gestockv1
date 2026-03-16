import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tableau de Bord',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
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
                _buildStatCard('Produits', '124', Icons.inventory_2, Colors.blue),
                _buildStatCard('Ventes', '45.000 FCFA', Icons.shopping_cart, Colors.green),
                _buildStatCard('Clients', '12', Icons.people, Colors.orange),
                _buildStatCard('Alertes', '5', Icons.warning, Colors.red),
              ],
            ),
            const SizedBox(height: 30),
            const Text(
              'Activités Récentes',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 15),
            _buildRecentActivity(),
          ],
        ),
      ),
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
            overflow: TextOverflow.ellipsis,
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

  Widget _buildRecentActivity() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        separatorBuilder: (_, __) => const Divider(color: Colors.white12),
        itemBuilder: (context, index) {
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
            leading: const CircleAvatar(
              backgroundColor: Colors.blue, 
              radius: 18,
              child: Icon(Icons.add, color: Colors.white, size: 18)
            ),
            title: const Text(
              'Vente de Sucre', 
              style: TextStyle(color: Colors.white, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: const Text('Il y a 5 min', style: TextStyle(color: Colors.white54, fontSize: 12)),
            trailing: const Text(
              '+500 FCFA', 
              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)
            ),
          );
        },
      ),
    );
  }
}
