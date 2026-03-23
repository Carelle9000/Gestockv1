import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../shared/models/product.dart';
import '../../core/stock/product_service.dart';
import 'package:intl/intl.dart';
import 'add_product_page.dart';
import 'product_widget.dart';

class ProductPage extends StatefulWidget {
  final ProductService productService;
  const ProductPage({super.key, required this.productService});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  late List<Product> _products;
  List<Product> _filteredProducts = [];
  final TextEditingController _searchController = TextEditingController();
  final _currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA', decimalDigits: 0);
  final AudioPlayer _audioPlayer = AudioPlayer();

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
    _checkStockAlerts();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _filteredProducts = _products
          .where((product) => product.name.toLowerCase().contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  void _loadProducts() {
    setState(() {
      _products = widget.productService.getAllProducts();
      _filteredProducts = _products;
      if (_searchController.text.isNotEmpty) {
        _onSearchChanged();
      }
    });
  }

  void _checkStockAlerts() async {
    final lowStockProducts = widget.productService.getLowStockProducts();
    if (lowStockProducts.isNotEmpty) {
      try {
        await _audioPlayer.play(AssetSource('sounds/alert.mp3'));
      } catch (e) {
        debugPrint("Erreur audio: $e");
      }
    }
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
      _checkStockAlerts();
    }
  }

  Future<void> _generatePdf() async {
    final pdf = pw.Document();
    final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('INVENTAIRE DES PRODUITS - GESTOCK', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18)),
                  pw.Text(dateStr),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.TableHelper.fromTextArray(
              headers: ['Produit', 'Catégorie', 'Prix (FCFA)', 'Stock'],
              data: _products.map((p) => [
                p.name,
                p.category,
                _currencyFormat.format(p.price),
                p.quantity.toString(),
              ]).toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
              cellAlignment: pw.Alignment.centerLeft,
              cellAlignments: {
                2: pw.Alignment.centerRight,
                3: pw.Alignment.center,
              },
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'inventaire_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
    );
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
            icon: const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
            tooltip: 'Générer l\'inventaire PDF',
            onPressed: _generatePdf,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDailyTip(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Rechercher un produit...',
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
                'LISTE DES PRODUITS',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2),
              ),
            ),
          ),
          Expanded(
            child: _filteredProducts.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];
                      return ProductWidget(
                        product: product,
                        onEdit: () => _navigateToForm(product: product),
                        onDelete: () => _deleteProduct(product),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _navigateToForm(),
                icon: const Icon(Icons.add, size: 22),
                label: const Text(
                  'AJOUTER UN PRODUIT',
                  style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyanAccent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ),
          ),
        ],
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
          Icon(
            _searchController.text.isEmpty ? Icons.inventory_2_outlined : Icons.search_off,
            size: 80, 
            color: Colors.white.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          Text(
            _searchController.text.isEmpty ? "Aucun produit en stock" : "Aucun produit trouvé pour \"${_searchController.text}\"",
            style: const TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }
}
