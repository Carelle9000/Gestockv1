import 'package:flutter/material.dart';
import '../../shared/models/product.dart';
import '../../core/stock/product_service.dart';
import 'package:intl/intl.dart';
import 'add_product_page.dart';

class ProductPage extends StatefulWidget {
  final ProductService productService;
  const ProductPage({super.key, required this.productService});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  late List<Product> _products;
  final _currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA', decimalDigits: 0);

  final List<String> _stockTips = [
    "Utilisez la méthode FIFO (Premier entré, Premier sorti) pour éviter les pertes de produits périssables.",
    "Organisez votre stock par catégories claires pour retrouver vos produits en un clin d'œil.",
    "Réalisez un inventaire physique complet au moins une fois par mois pour corriger les écarts.",
    "Placez les articles les plus vendus près de l'entrée de votre zone de stockage.",
    "Étiquetez précisément vos étagères et vos bacs pour faciliter le rangement.",
    "Maintenez une zone de réception propre pour éviter d'endommager les nouveaux produits.",
    "Surveillez vos seuils de réapprovisionnement pour ne jamais être en rupture.",
    "Utilisez des bacs transparents pour identifier le contenu sans avoir à les ouvrir.",
  ];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() {
    setState(() {
      _products = widget.productService.getAllProducts();
    });
  }

  void _deleteProduct(Product product) {
    showDialog(
      context: context,
      builder: (context) {
        final navigator = Navigator.of(context);
        final scaffoldMessenger = ScaffoldMessenger.of(context);
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text('Supprimer le produit', style: TextStyle(color: Colors.white)),
          content: Text('Voulez-vous vraiment supprimer "${product.name}" ?', style: const TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => navigator.pop(),
              child: const Text('ANNULER', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              onPressed: () async {
                await widget.productService.deleteProduct(product.id);
                if (mounted) {
                  navigator.pop();
                  _loadProducts();
                  scaffoldMessenger.showSnackBar(
                    SnackBar(content: Text('${product.name} supprimé')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              child: const Text('SUPPRIMER', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _navigateToForm({Product? product}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddProductPage(
          productService: widget.productService,
          productToEdit: product,
        ),
      ),
    );

    if (result == true) {
      _loadProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Gestion du Stock', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProducts,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _products.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _products.length,
                    itemBuilder: (context, index) {
                      final product = _products[index];
                      return _buildProductCard(product);
                    },
                  ),
          ),
          _buildDailyTip(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(),
        backgroundColor: Colors.cyanAccent,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    bool isLowStock = product.quantity <= product.minStock;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.withValues(alpha: 0.1),
            Colors.white.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isLowStock ? Colors.redAccent.withValues(alpha: 0.5) : Colors.blueAccent.withValues(alpha: 0.3),
        ),
      ),
      child: InkWell(
        onTap: () => _navigateToForm(product: product),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isLowStock ? Colors.redAccent.withValues(alpha: 0.1) : Colors.cyanAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  Icons.inventory_2,
                  color: isLowStock ? Colors.redAccent : Colors.cyanAccent,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      softWrap: true,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "${product.category} • ${_currencyFormat.format(product.price)}",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isLowStock ? Colors.redAccent.withValues(alpha: 0.1) : Colors.greenAccent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isLowStock ? Colors.redAccent.withValues(alpha: 0.3) : Colors.greenAccent.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        "Stock: ${product.quantity}",
                        style: TextStyle(
                          color: isLowStock ? Colors.redAccent : Colors.greenAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.cyanAccent, size: 20),
                    onPressed: () => _navigateToForm(product: product),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(8),
                    tooltip: 'Modifier',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                    onPressed: () => _deleteProduct(product),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(8),
                    tooltip: 'Supprimer',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDailyTip() {
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    final tip = _stockTips[dayOfYear % _stockTips.length];

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.cyanAccent.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.cyanAccent, size: 20),
              SizedBox(width: 8),
              Text(
                "CONSEIL DU JOUR",
                style: TextStyle(
                  color: Colors.cyanAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            tip,
            style: const TextStyle(color: Colors.white70, fontSize: 14, fontStyle: FontStyle.italic),
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
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.white.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          const Text("Aucun produit en stock", style: TextStyle(color: Colors.white54)),
        ],
      ),
    );
  }
}
