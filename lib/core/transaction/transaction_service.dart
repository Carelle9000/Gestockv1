import '../../shared/models/transaction.dart';
import '../../repositories/transaction_repository.dart';
import '../../shared/models/need.dart';
import '../../repositories/need_repository.dart';
import '../../shared/models/account.dart';
import '../../repositories/account_repository.dart';

class TransactionService {
  final TransactionRepository _transactionRepository;
  final NeedRepository _needRepository;
  final AccountRepository _accountRepository;

  TransactionService(this._transactionRepository, this._needRepository, this._accountRepository);

  /// Récupérer toutes les transactions
  List<Transaction> getAllTransactions() {
    final transactions = List<Transaction>.from(_transactionRepository.getAll());
    transactions.sort((a, b) => b.date.compareTo(a.date));
    return transactions;
  }

  /// Ajouter une transaction et mettre à jour le solde du compte
  Future<void> addTransaction(Transaction transaction) async {
    final accountId = transaction.accountId;
    if (accountId == null) throw Exception("Cette transaction n'est associée à aucun compte");

    final account = _accountRepository.get(accountId);
    if (account == null) throw Exception("Compte introuvable");

    if (transaction.type == 'INCOME') {
      account.balance += transaction.amount;
    } else {
      if (account.balance < transaction.amount) {
        throw Exception("Solde insuffisant sur le compte ${account.name}");
      }
      account.balance -= transaction.amount;
    }

    await _transactionRepository.add(transaction.id, transaction);
    await _accountRepository.update(account.id, account);
  }

  /// Payer un besoin (Need) via une transaction
  Future<void> payNeed(Need need, String accountId) async {
    final transaction = Transaction(
      id: 'TR-NEED-${need.id}-${DateTime.now().millisecondsSinceEpoch}',
      type: 'EXPENSE',
      category: 'EXPENSE',
      amount: need.estimatedCost,
      description: 'Paiement du besoin: ${need.title}',
      date: DateTime.now(),
      accountId: accountId,
      referenceId: need.id,
    );

    await addTransaction(transaction);

    need.status = 'Payé';
    await _needRepository.update(need.id, need);
  }

  /// Supprimer une transaction (et recréditer/débiter le compte)
  Future<void> deleteTransaction(String id) async {
    final transaction = _transactionRepository.get(id);
    if (transaction != null) {
      final accountId = transaction.accountId;
      if (accountId != null) {
        final account = _accountRepository.get(accountId);
        if (account != null) {
          if (transaction.type == 'INCOME') {
            account.balance -= transaction.amount;
          } else {
            account.balance += transaction.amount;
          }
          await _accountRepository.update(account.id, account);
        }
      }
      await _transactionRepository.delete(id);
    }
  }

  List<Transaction> getTransactionsByType(String type) {
    return _transactionRepository.getAll().where((t) => t.type == type).toList();
  }

  double getTotalBalance() {
    return _accountRepository.getAll().fold(0, (sum, acc) => sum + acc.balance);
  }

  // --- Gestion des Comptes (CRUD) ---
  List<Account> getAllAccounts() => _accountRepository.getAll();
  
  Future<void> addAccount(Account account) async {
    await _accountRepository.add(account.id, account);
  }

  Future<void> updateAccount(Account account) async {
    await _accountRepository.update(account.id, account);
  }

  Future<void> deleteAccount(String accountId) async {
    // On pourrait ajouter une vérification pour empêcher la suppression
    // si des transactions sont liées à ce compte.
    await _accountRepository.delete(accountId);
  }
}
