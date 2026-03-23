import '../../shared/models/purchase.dart';
//import '../../shared/models/product.dart';
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

  List<Purchase> getAllPurchases() {
    final purchases = List<Purchase>.from(_purchaseRepository.getAll());
    purchases.sort((a, b) => b.date.compareTo(a.date));
    return purchases;
  }

  Future<void> deletePurchase(String id) async {
    await _purchaseRepository.delete(id);
  }

  // --- Logique Métier : Effectuer un achat ---

  Future<void> processPurchase({
    required Purchase purchase,
    required Map<String, int> productQuantities, // ID du produit -> Quantité
    required String accountId,
  }) async {
    // 1. Vérifier le compte
    final account = _accountRepository.get(accountId);
    if (account == null) throw Exception("Compte introuvable");
    
    if (account.balance < purchase.totalAmount) {
      throw Exception("Solde insuffisant sur le compte ${account.name} (${account.balance} FCFA)");
    }

    // 2. Mettre à jour le stock pour chaque produit
    for (var entry in productQuantities.entries) {
      final productId = entry.key;
      final quantityToAdd = entry.value;
      
      final product = _productRepository.get(productId);
      if (product != null) {
        product.quantity += quantityToAdd;
        await _productRepository.update(product.id, product);
      }
    }

    // 3. Enregistrer l'achat
    await _purchaseRepository.add(purchase.id, purchase);

    // 4. Créer la transaction automatique de dépense
    final transaction = Transaction(
      id: 'TR-PUR-${purchase.id}',
      type: 'EXPENSE',
      category: 'PURCHASE',
      amount: purchase.totalAmount,
      description: 'Achat fournisseur #${purchase.id}',
      date: purchase.date,
      accountId: accountId,
      referenceId: purchase.id,
      personId: purchase.supplierId,
    );
    await _transactionRepository.add(transaction.id, transaction);

    // 5. Mettre à jour le solde du compte (Débit)
    account.balance -= purchase.totalAmount;
    await _accountRepository.update(account.id, account);
  }

  List<Purchase> getPurchasesBySupplier(String supplierId) {
    return _purchaseRepository.getAll().where((p) => p.supplierId == supplierId).toList();
  }
}
