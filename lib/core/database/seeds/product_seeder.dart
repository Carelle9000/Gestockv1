import 'package:uuid/uuid.dart';
import '../../../shared/models/product.dart';
import '../../../repositories/product_repository.dart';

class ProductSeeder {
  final ProductRepository _productRepository;

  ProductSeeder(this._productRepository);

  Future<void> seed() async {
    if (_productRepository.getAll().isNotEmpty) return;

    final List<Product> initialProducts = [
      Product(
        id: const Uuid().v4(),
        name: "Riz Long Grain (50kg)",
        price: 22500,
        quantity: 10,
        minStock: 2,
        supplierId: "SUP_AZUR",
        category: "Céréales",
        createdAt: DateTime.now(),
      ),
      Product(
        id: const Uuid().v4(),
        name: "Huile Mayor (1L)",
        price: 1500,
        quantity: 24,
        minStock: 5,
        supplierId: "SUP_MAYOR",
        category: "Huilerie",
        createdAt: DateTime.now(),
      ),
      Product(
        id: const Uuid().v4(),
        name: "Savon Azur (400g)",
        price: 450,
        quantity: 50,
        minStock: 10,
        supplierId: "SUP_AZUR",
        category: "Entretien",
        createdAt: DateTime.now(),
      ),
    ];

    for (var product in initialProducts) {
      await _productRepository.add(product.id, product);
    }
  }
}
