import '../../shared/models/purchase.dart';
import '../../shared/models/product.dart';
import '../../shared/models/transaction.dart';
import '../../repositories/purchase_repository.dart';
import '../../repositories/product_repository.dart';
import '../../repositories/transaction_repository.dart';
import '../../repositories/account_repository.dart';

class PurchaseService {
  final PurchaseRepository _purchaseRepository;
  final ProductRepository _productRepository;
  final TransactionRepository _transactionRepository;
  final AccountRepository _accountRepository;

  PurchaseService({
    required PurchaseRepository purchaseRepository,
    required ProductRepository productRepository,
    required TransactionRepository transactionRepository,
    required AccountRepository accountRepository,
  })  : _purchaseRepository = purchaseRepository,
        _productRepository = productRepository,
        _transactionRepository = transactionRepository,
        _accountRepository = accountRepository;

  // --- CRUD Opérations ---

  List<Purchase> getAllPurchases() => _purchaseRepository.getAll();

  Future<void> deletePurchase(String id) async {
    await _purchaseRepository.delete(id);
  }

  // --- Logique Métier : Effectuer un achat ---

  Future<void> processPurchase({
    required Purchase purchase,
    required Map<Product, int> productsPurchased,
    required String accountId,
  }) async {
    // 1. Vérifier le compte
    final account = _accountRepository.get(accountId);
    if (account == null) throw Exception("Compte introuvable");
    if (account.balance < purchase.totalAmount) {
      throw Exception("Solde insuffisant sur le compte ${account.name}");
    }

    // 2. Enregistrer l'achat
    await _purchaseRepository.add(purchase.id, purchase);

    // 3. Mettre à jour le stock
    for (var entry in productsPurchased.entries) {
      final product = entry.key;
      product.quantity += entry.value;
      await _productRepository.update(product.id, product);
    }

    // 4. Créer la transaction de dépense
    final transaction = Transaction(
      id: 'TR-PUR-${purchase.id}',
      type: 'EXPENSE',
      amount: purchase.totalAmount,
      description: 'Achat chez fournisseur (ID: ${purchase.supplierId})',
      date: purchase.date,
      accountId: accountId,
    );
    await _transactionRepository.add(transaction.id, transaction);

    // 5. Mettre à jour le solde du compte
    account.balance -= purchase.totalAmount;
    await _accountRepository.update(account.id, account);
  }

  List<Purchase> getPurchasesBySupplier(String supplierId) {
    return _purchaseRepository.getAll().where((p) => p.supplierId == supplierId).toList();
  }
}
