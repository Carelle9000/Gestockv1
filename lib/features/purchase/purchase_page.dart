import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/purchase/purchase_service.dart';
import '../../core/supplier/supplier_service.dart';
import '../../core/transaction/transaction_service.dart';
import '../../shared/models/purchase.dart';
import 'add_purchase_page.dart';
import '../../core/stock/product_service.dart';

class PurchasePage extends StatefulWidget {
  final PurchaseService purchaseService;
  final SupplierService supplierService;
  final ProductService productService;
  final TransactionService transactionService;

  const PurchasePage({
    super.key,
    required this.purchaseService,
    required this.supplierService,
    required this.productService,
    required this.transactionService,
  });

  @override
  State<PurchasePage> createState() => _PurchasePageState();
}

class _PurchasePageState extends State<PurchasePage> {
  List<Purchase> _purchases = [];
  final _currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA');

  @override
  void initState() {
    super.initState();
    _loadPurchases();
  }

  void _loadPurchases() {
    setState(() {
      _purchases = widget.purchaseService.getAllPurchases();
      // Trier par date décroissante
      _purchases.sort((a, b) => b.date.compareTo(a.date));
    });
  }

  String _getSupplierName(String id) {
    final supplier = widget.supplierService.getSupplier(id);
    return supplier?.name ?? 'Inconnu';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'reçu':
      case 'completed':
        return Colors.green;
      case 'en attente':
      case 'pending':
        return Colors.orange;
      case 'annulé':
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Achats Fournisseurs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPurchases,
          ),
        ],
      ),
      body: _purchases.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey[600]),
                  const SizedBox(height: 16),
                  const Text('Aucun achat enregistré'),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _purchases.length,
              itemBuilder: (context, index) {
                final purchase = _purchases[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getStatusColor(purchase.status).withValues(alpha: 0.2),
                      child: Icon(Icons.local_shipping, color: _getStatusColor(purchase.status)),
                    ),
                    title: Text(
                      _getSupplierName(purchase.supplierId),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(DateFormat('dd/MM/yyyy HH:mm').format(purchase.date)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getStatusColor(purchase.status).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            purchase.status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              color: _getStatusColor(purchase.status),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _currencyFormat.format(purchase.totalAmount),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.cyanAccent,
                          ),
                        ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                    onTap: () {
                      // Afficher les détails si nécessaire
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddPurchasePage(
                purchaseService: widget.purchaseService,
                supplierService: widget.supplierService,
                productService: widget.productService,
                transactionService: widget.transactionService,
              ),
            ),
          );
          if (result == true) {
            _loadPurchases();
          }
        },
        child: const Icon(Icons.add_shopping_cart),
      ),
    );
  }
}
