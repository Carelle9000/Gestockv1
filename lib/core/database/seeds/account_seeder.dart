import '../../../shared/models/account.dart';
import '../../../repositories/account_repository.dart';

class AccountSeeder {
  final AccountRepository _accountRepository;

  AccountSeeder(this._accountRepository);

  Future<void> seed() async {
    // Si la boîte de données n'est pas vide, on ne fait rien
    if (_accountRepository.getAll().isNotEmpty) return;

    final defaultAccounts = [
      Account(
        id: 'ACC-001',
        name: 'Caisse Centrale',
        balance: 50000,
        type: 'CASH',
      ),
      Account(
        id: 'ACC-002',
        name: 'Orange Money',
        balance: 150000,
        type: 'MOBILE_MONEY',
      ),
      Account(
        id: 'ACC-003',
        name: 'MTN Mobile Money',
        balance: 75000,
        type: 'MOBILE_MONEY',
      ),
      Account(
        id: 'ACC-004',
        name: 'Compte Banque (UBA)',
        balance: 1200000,
        type: 'BANK',
      ),
    ];

    for (var account in defaultAccounts) {
      await _accountRepository.add(account.id, account);
    }
  }
}
