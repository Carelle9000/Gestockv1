import '../../../shared/models/supplier.dart';
import '../../../repositories/supplier_repository.dart';

class SupplierSeeder {
  final SupplierRepository _supplierRepository;

  SupplierSeeder(this._supplierRepository);

  Future<void> seed() async {
    if (_supplierRepository.getAll().isNotEmpty) return;

    final List<Supplier> initialSuppliers = [
      Supplier(
        id: "SUP_AZUR",
        name: "Société AZUR",
        phone: "+237 600 000 000",
        address: "Littoral, Douala",
        email: "contact@azur.cm",
        createdAt: DateTime.now(),
      ),
      Supplier(
        id: "SUP_MAYOR",
        name: "MAYOR S.A.",
        phone: "+237 600 111 222",
        address: "Zone Industrielle Magzi",
        email: "mayor@mayor.cm",
        createdAt: DateTime.now(),
      ),
      Supplier(
        id: "SUP_SOSUCAM",
        name: "SOSUCAM",
        phone: "+237 222 333 444",
        address: "Mbandjock",
        email: "info@sosucam.com",
        createdAt: DateTime.now(),
      ),
    ];

    for (var supplier in initialSuppliers) {
      await _supplierRepository.add(supplier.id, supplier);
    }
  }
}
