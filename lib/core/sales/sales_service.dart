import 'package:uuid/uuid.dart';
import '../../shared/models/sales.dart';
import '../../shared/models/sale_item.dart';
import '../../shared/models/product.dart';
import '../../shared/models/transaction.dart';
import '../../repositories/sales_repository.dart';
import '../../repositories/sale_item_repository.dart';
import '../../repositories/product_repository.dart';
import '../../repositories/transaction_repository.dart';
import '../../repositories/account_repository.dart';

class SalesService {
  final SalesRepository _salesRepository;
  final SaleItemRepository _saleItemRepository;
  final ProductRepository _productRepository;
  final TransactionRepository _transactionRepository;
  final AccountRepository _accountRepository;

  SalesService({
    required SalesRepository salesRepository,
    required SaleItemRepository saleItemRepository,
    required ProductRepository productRepository,
    required TransactionRepository transactionRepository,
    required AccountRepository accountRepository,
  })  : _salesRepository = salesRepository,
        _saleItemRepository = saleItemRepository,
        _productRepository = productRepository,
        _transactionRepository = transactionRepository,
        _accountRepository = accountRepository;

  Future<void> createSale({
    required String clientId,
    required String paymentMethod,
    required List<Map<String, dynamic>> items,
    required String accountId,
  }) async {
    final saleId = const Uuid().v4();
    double totalAmount = 0;

    // 1. Gérer les articles et le stock
    for (var item in items) {
      final product = item['product'] as Product;
      final quantity = item['quantity'] as int;
      totalAmount += product.price * quantity;

      final saleItem = SaleItem(
        id: const Uuid().v4(),
        saleId: saleId,
        productId: product.id,
        quantity: quantity,
        price: product.price,
      );
      await _saleItemRepository.add(saleItem.id, saleItem);

      product.quantity -= quantity;
      await _productRepository.update(product.id, product);
    }

    // 2. Créer la vente
    final sale = Sales(
      id: saleId,
      date: DateTime.now(),
      totalAmount: totalAmount,
      paymentMethod: paymentMethod,
      clientId: clientId,
    );
    await _salesRepository.add(sale.id, sale);

    // 3. Créer la transaction automatique (Entrée de fonds)
    // On représente la vente comme une rentrée d'argent dans la caisse
    final transaction = Transaction(
      id: 'TR-SALE-$saleId',
      type: 'INCOME',
      amount: totalAmount,
      description: 'Vente #$saleId ($paymentMethod)',
      date: DateTime.now(),
      accountId: accountId,
    );
    await _transactionRepository.add(transaction.id, transaction);

    // 4. Mettre à jour le solde du compte (Caisse)
    final account = _accountRepository.get(accountId);
    if (account != null) {
      account.balance += totalAmount;
      await _accountRepository.update(account.id, account);
    } else {
      throw Exception("Le compte de destination (ID: $accountId) est introuvable.");
    }
  }

  List<Sales> getAllSales() {
    final sales = List<Sales>.from(_salesRepository.getAll());
    sales.sort((a, b) => b.date.compareTo(a.date));
    return sales;
  }

  List<SaleItem> getItemsForSale(String saleId) {
    return _saleItemRepository.getAll().where((item) => item.saleId == saleId).toList();
  }
}
