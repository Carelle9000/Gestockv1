import '../../shared/models/product.dart';
import '../../repositories/product_repository.dart';

class ProductService {
  final ProductRepository _productRepository;

  ProductService(this._productRepository);

  /// Récupère tous les produits du stock
  List<Product> getAllProducts() {
    return _productRepository.getAll();
  }

  /// Récupère un produit par son ID
  Product? getProduct(String id) {
    return _productRepository.get(id);
  }

  /// Ajoute un nouveau produit
  Future<void> addProduct(Product product) async {
    if (product.price < 0) {
      throw Exception("Le prix ne peut pas être négatif");
    }
    // Utilisation de product.id comme clé pour le repository
    await _productRepository.add(product.id, product);
  }

  /// Met à jour un produit existant
  Future<void> updateProduct(String key, Product product) async {
    await _productRepository.update(key, product);
  }

  /// Supprime un produit
  Future<void> deleteProduct(String key) async {
    await _productRepository.delete(key);
  }

  /// Récupère les produits en rupture de stock
  List<Product> getLowStockProducts() {
    return _productRepository.getAll().where((p) => p.quantity <= p.minStock).toList();
  }

  /// Recherche des produits
  List<Product> searchProducts(String query) {
    final lowerQuery = query.toLowerCase();
    return _productRepository.getAll().where((p) => 
      p.name.toLowerCase().contains(lowerQuery) || 
      p.category.toLowerCase().contains(lowerQuery)
    ).toList();
  }

  /// Récupère les produits associés à un fournisseur spécifique
  List<Product> getProductsBySupplier(String supplierId) {
    return _productRepository
        .getAll()
        .where((p) => p.supplierId == supplierId)
        .toList();
  }
}
