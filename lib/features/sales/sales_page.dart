import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/sales/sales_service.dart';
import '../../core/stock/product_service.dart';
import '../../core/transaction/transaction_service.dart';
import '../../repositories/client_repository.dart';
import '../../shared/models/sales.dart';
import 'add_sales_page.dart';

class SalesPage extends StatefulWidget {
  final SalesService salesService;
  final ProductService productService;
  final ClientRepository clientRepository;
  final TransactionService transactionService;

  const SalesPage({
    super.key,
    required this.salesService,
    required this.productService,
    required this.clientRepository,
    required this.transactionService,
  });

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  late List<Sales> _sales;
  List<Sales> _filteredSales = [];
  final TextEditingController _searchController = TextEditingController();
  final _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  @override
  void initState() {
    super.initState();
    _loadSales();
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
      _filteredSales = _sales.where((sale) {
        final clientName = _getClientName(sale.clientId).toLowerCase();
        final searchTerm = _searchController.text.toLowerCase();
        return clientName.contains(searchTerm) || sale.id.toLowerCase().contains(searchTerm);
      }).toList();
    });
  }

  void _loadSales() {
    setState(() {
      _sales = widget.salesService.getAllSales();
      _filteredSales = _sales;
      if (_searchController.text.isNotEmpty) {
        _onSearchChanged();
      }
    });
  }

  String _getClientName(String clientId) {
    final client = widget.clientRepository.get(clientId);
    return client?.name ?? 'Client inconnu';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Gestion des Ventes', style: TextStyle(fontWeight: FontWeight.bold)),
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
                hintText: 'Rechercher par client ou N°...',
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
                'HISTORIQUE DES VENTES',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2),
              ),
            ),
          ),
          Expanded(
            child: _filteredSales.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredSales.length,
                    itemBuilder: (context, index) {
                      final sale = _filteredSales[index];
                      return _buildSaleCard(sale);
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
              builder: (context) => AddSalesPage(
                salesService: widget.salesService,
                productService: widget.productService,
                clientRepository: widget.clientRepository,
                transactionService: widget.transactionService,
              ),
            ),
          );
          if (result == true) {
            _loadSales();
          }
        },
        backgroundColor: Colors.cyanAccent,
        icon: const Icon(Icons.add_shopping_cart, color: Colors.black),
        label: const Text('NOUVELLE VENTE',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSaleCard(Sales sale) {
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
          backgroundColor: Colors.greenAccent.withValues(alpha: 0.1),
          child: const Icon(Icons.receipt_long, color: Colors.greenAccent),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                _getClientName(sale.clientId),
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '${sale.totalAmount.toStringAsFixed(0)} FCFA',
              style: const TextStyle(
                  color: Colors.cyanAccent, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: Colors.white54),
                const SizedBox(width: 8),
                Text(_dateFormat.format(sale.date),
                    style: const TextStyle(color: Colors.white54)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.payment, size: 14, color: Colors.white54),
                const SizedBox(width: 8),
                Text(sale.paymentMethod,
                    style: const TextStyle(color: Colors.white54)),
              ],
            ),
          ],
        ),
        onTap: () => _showSaleDetails(sale),
      ),
    );
  }

  void _showSaleDetails(Sales sale) {
    final items = widget.salesService.getItemsForSale(sale.id);

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Détails de la vente',
              style: TextStyle(
                  color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(color: Colors.white12, height: 32),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final product = widget.productService.getProduct(item.productId);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(product?.name ?? 'Produit inconnu',
                                  style: const TextStyle(color: Colors.white)),
                              Text(
                                  '${item.quantity} x ${item.price.toStringAsFixed(0)} FCFA',
                                  style: const TextStyle(
                                      color: Colors.white54, fontSize: 12)),
                            ],
                          ),
                        ),
                        Text(
                          '${(item.quantity * item.price).toStringAsFixed(0)} FCFA',
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const Divider(color: Colors.white12, height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('TOTAL',
                    style: TextStyle(
                        color: Colors.white70, fontWeight: FontWeight.bold)),
                Text(
                  '${sale.totalAmount.toStringAsFixed(0)} FCFA',
                  style: const TextStyle(
                      color: Colors.cyanAccent,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
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
            _searchController.text.isEmpty ? "Aucune vente enregistrée" : "Aucune vente trouvée pour \"${_searchController.text}\"",
            style: const TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }
}
