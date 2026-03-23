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
  late List<Purchase> _purchases;
  List<Purchase> _filteredPurchases = [];
  final TextEditingController _searchController = TextEditingController();
  final _currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA', decimalDigits: 0);
  final _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  @override
  void initState() {
    super.initState();
    _loadPurchases();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _filteredPurchases = _purchases.where((purchase) {
        final supplierName = _getSupplierName(purchase.supplierId).toLowerCase();
        final searchTerm = _searchController.text.toLowerCase();
        return supplierName.contains(searchTerm) || purchase.id.toLowerCase().contains(searchTerm);
      }).toList();
    });
  }

  void _loadPurchases() {
    setState(() {
      _purchases = widget.purchaseService.getAllPurchases();
      _filteredPurchases = _purchases;
      if (_searchController.text.isNotEmpty) {
        _onSearchChanged();
      }
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
        return Colors.greenAccent;
      case 'en attente':
      case 'pending':
        return Colors.orangeAccent;
      case 'annulé':
      case 'cancelled':
        return Colors.redAccent;
      default:
        return Colors.blueAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Achats Fournisseurs', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Rechercher par fournisseur...',
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
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'HISTORIQUE DES ACHATS',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2),
              ),
            ),
          ),
          Expanded(
            child: _filteredPurchases.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredPurchases.length,
                    itemBuilder: (context, index) {
                      final purchase = _filteredPurchases[index];
                      final statusColor = _getStatusColor(purchase.status);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            backgroundColor: statusColor.withValues(alpha: 0.1),
                            child: Icon(Icons.local_shipping, color: statusColor),
                          ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  _getSupplierName(purchase.supplierId),
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                _currencyFormat.format(purchase.totalAmount),
                                style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Text(
                                _dateFormat.format(purchase.date),
                                style: const TextStyle(color: Colors.white54, fontSize: 13),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                                ),
                                child: Text(
                                  purchase.status.toUpperCase(),
                                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 10),
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            // Afficher les détails si nécessaire
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
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
        backgroundColor: Colors.cyanAccent,
        icon: const Icon(Icons.add_shopping_cart, color: Colors.black),
        label: const Text('NOUVEL ACHAT', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _searchController.text.isEmpty ? Icons.shopping_cart_outlined : Icons.search_off,
            size: 80, 
            color: Colors.white.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          Text(
            _searchController.text.isEmpty ? "Aucun achat enregistré" : "Aucun achat trouvé pour \"${_searchController.text}\"",
            style: const TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }
}
