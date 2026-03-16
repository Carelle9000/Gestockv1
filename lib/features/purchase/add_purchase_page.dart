import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/purchase/purchase_service.dart';
import '../../core/supplier/supplier_service.dart';
import '../../core/stock/product_service.dart';
import '../../core/transaction/transaction_service.dart';
import '../../shared/models/purchase.dart';
import '../../shared/models/product.dart';
import '../../shared/models/supplier.dart';
import '../../shared/models/account.dart';

class AddPurchasePage extends StatefulWidget {
  final PurchaseService purchaseService;
  final SupplierService supplierService;
  final ProductService productService;
  final TransactionService transactionService;

  const AddPurchasePage({
    super.key,
    required this.purchaseService,
    required this.supplierService,
    required this.productService,
    required this.transactionService,
  });

  @override
  State<AddPurchasePage> createState() => _AddPurchasePageState();
}

class _AddPurchasePageState extends State<AddPurchasePage> {
  final _formKey = GlobalKey<FormState>();
  Supplier? _selectedSupplier;
  Account? _selectedAccount;
  final Map<Product, int> _selectedProducts = {};
  final _currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA');

  double get _totalAmount {
    return _selectedProducts.entries.fold(0, (sum, entry) => sum + (entry.key.price * entry.value));
  }

  void _addProduct() async {
    if (_selectedSupplier == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez d\'abord sélectionner un fournisseur')),
      );
      return;
    }

    final products = widget.productService.getProductsBySupplier(_selectedSupplier!.id);
    
    if (products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucun produit n\'est enregistré pour ce fournisseur')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Produits de ${_selectedSupplier!.name}', 
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ListTile(
                      title: Text(product.name),
                      subtitle: Text('Prix: ${_currencyFormat.format(product.price)} - Stock: ${product.quantity}'),
                      onTap: () {
                        setState(() {
                          if (_selectedProducts.containsKey(product)) {
                            _selectedProducts[product] = _selectedProducts[product]! + 1;
                          } else {
                            _selectedProducts[product] = 1;
                          }
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _submit() async {
    if (_selectedSupplier == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez sélectionner un fournisseur')));
      return;
    }
    if (_selectedAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez sélectionner un compte de paiement')));
      return;
    }
    if (_selectedProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez ajouter au moins un produit')));
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      final purchase = Purchase(
        id: 'PUR-${DateTime.now().millisecondsSinceEpoch}',
        supplierId: _selectedSupplier!.id,
        date: DateTime.now(),
        totalAmount: _totalAmount,
        status: 'Reçu',
      );

      await widget.purchaseService.processPurchase(
        purchase: purchase,
        productsPurchased: _selectedProducts,
        accountId: _selectedAccount!.id,
      );

      navigator.pop(true);
      messenger.showSnackBar(const SnackBar(content: Text('Achat enregistré avec succès')));
      
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final suppliers = widget.supplierService.getAllSuppliers();
    final accounts = widget.transactionService.getAllAccounts();

    return Scaffold(
      appBar: AppBar(title: const Text('Nouvel Achat')),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: DropdownButtonFormField<Supplier>(
                decoration: const InputDecoration(
                  labelText: 'Fournisseur',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                initialValue: _selectedSupplier,
                items: suppliers.map((s) {
                  return DropdownMenuItem(value: s, child: Text(s.name));
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedSupplier = val;
                    _selectedProducts.clear();
                  });
                },
                validator: (val) => val == null ? 'Champ obligatoire' : null,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: DropdownButtonFormField<Account>(
                decoration: const InputDecoration(
                  labelText: 'Compte de paiement',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.account_balance_wallet),
                ),
                initialValue: _selectedAccount,
                items: accounts.map((acc) {
                  return DropdownMenuItem(value: acc, child: Text('${acc.name} (${_currencyFormat.format(acc.balance)})'));
                }).toList(),
                onChanged: (val) => setState(() => _selectedAccount = val),
                validator: (val) => val == null ? 'Champ obligatoire' : null,
              ),
            ),
            const SizedBox(height: 10),
            if (_selectedSupplier != null && widget.productService.getProductsBySupplier(_selectedSupplier!.id).isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Attention : Ce fournisseur n\'a aucun produit associé.',
                  style: TextStyle(color: Colors.orange, fontSize: 12),
                ),
              ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Produits achetés',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _addProduct,
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _selectedProducts.length,
                itemBuilder: (context, index) {
                  final product = _selectedProducts.keys.elementAt(index);
                  final quantity = _selectedProducts[product]!;
                  return ListTile(
                    title: Text(product.name),
                    subtitle: Text('PU: ${_currencyFormat.format(product.price)}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () {
                            setState(() {
                              if (quantity > 1) {
                                _selectedProducts[product] = quantity - 1;
                              } else {
                                _selectedProducts.remove(product);
                              }
                            });
                          },
                        ),
                        Text('$quantity', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () {
                            setState(() {
                              _selectedProducts[product] = quantity + 1;
                            });
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, -5))],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('TOTAL', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 10),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            _currencyFormat.format(_totalAmount),
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.cyanAccent),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyanAccent,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('VALIDER L\'ACHAT', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
