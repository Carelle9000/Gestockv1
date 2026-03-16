import 'package:flutter/material.dart';
import '../../core/sales/sales_service.dart';
import '../../core/stock/product_service.dart';
import '../../core/transaction/transaction_service.dart';
import '../../repositories/client_repository.dart';
import '../../shared/models/product.dart';
import '../../shared/models/client.dart';
import '../../shared/models/account.dart';

class AddSalesPage extends StatefulWidget {
  final SalesService salesService;
  final ProductService productService;
  final ClientRepository clientRepository;
  final TransactionService transactionService;

  const AddSalesPage({
    super.key,
    required this.salesService,
    required this.productService,
    required this.clientRepository,
    required this.transactionService,
  });

  @override
  State<AddSalesPage> createState() => _AddSalesPageState();
}

class _AddSalesPageState extends State<AddSalesPage> {
  Client? _selectedClient;
  Account? _selectedAccount;
  final List<Map<String, dynamic>> _cart = [];
  String _selectedPaymentMethod = 'Espèces';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _paymentMethods = [
    'Espèces',
    'Orange Money',
    'Mobile Money',
  ];

  void _addToCart(Product product) {
    setState(() {
      final index = _cart.indexWhere((item) => item['product'].id == product.id);
      if (index >= 0) {
        if (_cart[index]['quantity'] < product.quantity) {
          _cart[index]['quantity']++;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Stock insuffisant')),
          );
        }
      } else {
        if (product.quantity > 0) {
          _cart.add({'product': product, 'quantity': 1});
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Produit en rupture de stock')),
          );
        }
      }
    });
  }

  void _removeFromCart(Product product) {
    setState(() {
      final index = _cart.indexWhere((item) => item['product'].id == product.id);
      if (index >= 0) {
        if (_cart[index]['quantity'] > 1) {
          _cart[index]['quantity']--;
        } else {
          _cart.removeAt(index);
        }
      }
    });
  }

  double get _totalAmount {
    return _cart.fold(0, (sum, item) => sum + (item['product'].price * item['quantity']));
  }

  Future<void> _submitSale() async {
    if (_selectedClient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un client')),
      );
      return;
    }
    if (_selectedAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un compte d\'encaissement')),
      );
      return;
    }
    if (_cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le panier est vide')),
      );
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      await widget.salesService.createSale(
        clientId: _selectedClient!.id,
        paymentMethod: _selectedPaymentMethod,
        items: _cart,
        accountId: _selectedAccount!.id,
      );
      if (mounted) {
        navigator.pop(true);
        messenger.showSnackBar(
          const SnackBar(content: Text('Vente enregistrée avec succès')),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clients = widget.clientRepository.getAll();
    final accounts = widget.transactionService.getAllAccounts();
    final filteredProducts = widget.productService.searchProducts(_searchQuery);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Nouvelle Vente'),
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      body: Column(
        children: [
          // 1. Sélection Client, Paiement et Compte
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<Client>(
                        dropdownColor: const Color(0xFF1E293B),
                        decoration: _inputDecoration('Client', Icons.person_outline),
                        initialValue: _selectedClient,
                        items: clients.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
                        onChanged: (val) => setState(() => _selectedClient = val),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: DropdownButtonFormField<String>(
                        dropdownColor: const Color(0xFF1E293B),
                        decoration: _inputDecoration('Paiement', Icons.payment),
                        initialValue: _selectedPaymentMethod,
                        items: _paymentMethods.map((m) => DropdownMenuItem(value: m, child: Text(m, style: const TextStyle(fontSize: 12)))).toList(),
                        onChanged: (val) => setState(() => _selectedPaymentMethod = val!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<Account>(
                  dropdownColor: const Color(0xFF1E293B),
                  decoration: _inputDecoration('Compte d\'encaissement', Icons.account_balance_wallet),
                  initialValue: _selectedAccount,
                  items: accounts.map((acc) => DropdownMenuItem(value: acc, child: Text('${acc.name} (${acc.balance.toStringAsFixed(0)} FCFA)'))).toList(),
                  onChanged: (val) => setState(() => _selectedAccount = val),
                ),
              ],
            ),
          ),

          // 2. Barre de Recherche de Produits
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Rechercher un produit...',
                hintStyle: const TextStyle(color: Colors.white24),
                prefixIcon: const Icon(Icons.search, color: Colors.cyanAccent),
                suffixIcon: _searchQuery.isNotEmpty 
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.white54),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
                filled: true,
                fillColor: Colors.white.withAlpha(13),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
          ),

          // 3. Liste des produits filtrés ou Panier
          Expanded(
            child: _searchQuery.isNotEmpty 
              ? _buildProductSearchResults(filteredProducts)
              : _buildCartList(),
          ),

          // 4. Résumé et Bouton
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFF1E293B),
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('TOTAL', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                        Text('${_cart.length} article(s)', style: const TextStyle(color: Colors.white38, fontSize: 12)),
                      ],
                    ),
                    Text('${_totalAmount.toStringAsFixed(0)} FCFA', style: const TextStyle(color: Colors.cyanAccent, fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _submitSale,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyanAccent,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text('VALIDER LA VENTE', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductSearchResults(List<Product> products) {
    if (products.isEmpty) {
      return const Center(child: Text("Aucun produit trouvé", style: TextStyle(color: Colors.white24)));
    }
    return ListView.builder(
      itemCount: products.length,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        final product = products[index];
        return Card(
          color: Colors.white.withAlpha(13),
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(product.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: Text('Stock: ${product.quantity} | ${product.price.toStringAsFixed(0)} FCFA', style: const TextStyle(color: Colors.white54)),
            trailing: IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.cyanAccent),
              onPressed: () => _addToCart(product),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCartList() {
    if (_cart.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_basket_outlined, size: 64, color: Colors.white.withAlpha(20)),
            const SizedBox(height: 16),
            const Text("Le panier est vide", style: TextStyle(color: Colors.white24)),
            const Text("Recherchez des produits pour les ajouter", style: TextStyle(color: Colors.white12, fontSize: 12)),
          ],
        ),
      );
    }
    return ListView.builder(
      itemCount: _cart.length,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        final item = _cart[index];
        final product = item['product'] as Product;
        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(product.name, style: const TextStyle(color: Colors.white)),
          subtitle: Text('${product.price.toStringAsFixed(0)} FCFA x ${item['quantity']}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent), onPressed: () => _removeFromCart(product)),
              Text('${item['quantity']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.add_circle_outline, color: Colors.greenAccent), onPressed: () => _addToCart(product)),
            ],
          ),
        );
      },
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70, fontSize: 12),
      prefixIcon: Icon(icon, color: Colors.cyanAccent, size: 20),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white12)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.cyanAccent)),
    );
  }
}
