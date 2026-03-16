import '../../shared/models/supplier.dart';
import '../../repositories/supplier_repository.dart';

class SupplierService {
  final SupplierRepository _supplierRepository;

  SupplierService(this._supplierRepository);

  Future<void> addSupplier(Supplier supplier) async {
    await _supplierRepository.add(supplier.id, supplier);
  }

  List<Supplier> getAllSuppliers() {
    return _supplierRepository.getAll();
  }

  Supplier? getSupplier(String id) {
    return _supplierRepository.get(id);
  }

  Future<void> updateSupplier(Supplier supplier) async {
    await _supplierRepository.update(supplier.id, supplier);
  }

  Future<void> deleteSupplier(String id) async {
    await _supplierRepository.delete(id);
  }
}
