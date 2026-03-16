import '../../repositories/product_repository.dart';
import '../../repositories/supplier_repository.dart';
import '../../repositories/client_repository.dart';
import '../../repositories/user_repository.dart';
import 'seeds/product_seeder.dart';
import 'seeds/supplier_seeder.dart';
import 'seeds/client_seeder.dart';
import 'seeds/user_seeder.dart';

class DatabaseSeedService {
  final ProductRepository _productRepository;
  final SupplierRepository _supplierRepository;
  final ClientRepository _clientRepository;
  final UserRepository _userRepository;

  DatabaseSeedService({
    required ProductRepository productRepository,
    required SupplierRepository supplierRepository,
    required ClientRepository clientRepository,
    required UserRepository userRepository,
  })  : _productRepository = productRepository,
        _supplierRepository = supplierRepository,
        _clientRepository = clientRepository,
        _userRepository = userRepository;

  /// Lance tous les seeders de l'application
  Future<void> seedAll() async {
    // Lancer les utilisateurs
    await UserSeeder(_userRepository).seed();

    // Lancer les fournisseurs en premier
    await SupplierSeeder(_supplierRepository).seed();
    
    // Lancer les produits
    await ProductSeeder(_productRepository).seed();
    
    // Lancer les clients
    await ClientSeeder(_clientRepository).seed();
  }
}
