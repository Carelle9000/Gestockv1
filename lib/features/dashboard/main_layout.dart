import 'package:flutter/material.dart';
import '../stock/product_page.dart';
import '../clients/client_page.dart';
import '../need/need_page.dart';
import '../suppliers/supplier_page.dart';
import '../sales/sales_page.dart';
import '../purchase/purchase_page.dart';
import '../transaction/transaction_page.dart';
import '../transaction/accounts_page.dart';
import '../auth/profile_page.dart';
import 'dashboard_page.dart';
import '../../core/stock/product_service.dart';
import '../../core/need/need_service.dart';
import '../../core/auth/auth_service.dart';
import '../../core/supplier/supplier_service.dart';
import '../../core/sales/sales_service.dart';
import '../../core/purchase/purchase_service.dart';
import '../../core/transaction/transaction_service.dart';
import '../../repositories/client_repository.dart';

class MainLayout extends StatefulWidget {
  final ProductService productService;
  final ClientRepository clientRepository;
  final NeedService needService;
  final AuthService authService;
  final SupplierService supplierService;
  final SalesService salesService;
  final PurchaseService purchaseService;
  final TransactionService transactionService;

  const MainLayout({
    super.key, 
    required this.productService,
    required this.clientRepository,
    required this.needService,
    required this.authService,
    required this.supplierService,
    required this.salesService,
    required this.purchaseService,
    required this.transactionService,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      DashboardPage(
        productService: widget.productService,
        salesService: widget.salesService,
        clientRepository: widget.clientRepository,
        authService: widget.authService,
        transactionService: widget.transactionService,
      ),
      ProductPage(productService: widget.productService),
      ClientPage(clientRepository: widget.clientRepository),
      NeedPage(needService: widget.needService),
      SupplierPage(supplierService: widget.supplierService),
      SalesPage(
        salesService: widget.salesService,
        productService: widget.productService,
        clientRepository: widget.clientRepository,
        transactionService: widget.transactionService,
      ),
      PurchasePage(
        purchaseService: widget.purchaseService,
        supplierService: widget.supplierService,
        productService: widget.productService,
        transactionService: widget.transactionService,
      ),
      TransactionPage(
        transactionService: widget.transactionService,
        needService: widget.needService,
      ),
      AccountsPage(transactionService: widget.transactionService),
      ProfilePage(authService: widget.authService),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context); // Ferme le drawer
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('gestock', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFF0F172A),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF1E3A8A),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inventory_2_outlined, size: 50, color: Colors.cyanAccent),
                    SizedBox(height: 10),
                    Text('GESTOCK', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            _buildDrawerItem(0, Icons.dashboard_outlined, 'Dashboard'),
            _buildDrawerItem(1, Icons.inventory_2_outlined, 'Produits'),
            _buildDrawerItem(2, Icons.people_outline, 'Clients'),
            _buildDrawerItem(3, Icons.assignment_outlined, 'Besoins'),
            _buildDrawerItem(4, Icons.local_shipping_outlined, 'Fournisseurs'),
            _buildDrawerItem(5, Icons.shopping_cart_outlined, 'Ventes'),
            _buildDrawerItem(6, Icons.add_business_outlined, 'Achats'),
            _buildDrawerItem(7, Icons.receipt_long_outlined, 'Transactions'),
            _buildDrawerItem(8, Icons.account_balance_wallet_outlined, 'Comptes & Caisse'),
            _buildDrawerItem(9, Icons.person_outline, 'Mon Profil'),
            const Divider(color: Colors.white12),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Déconnexion', style: TextStyle(color: Colors.redAccent)),
              onTap: () async {
                final navigator = Navigator.of(context);
                await widget.authService.logout();
                navigator.pushNamedAndRemoveUntil('/', (route) => false);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
    );
  }

  Widget _buildDrawerItem(int index, IconData icon, String title) {
    final isSelected = _selectedIndex == index;
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.cyanAccent : Colors.white70),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.cyanAccent : Colors.white70,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onTap: () => _onItemTapped(index),
    );
  }
}
