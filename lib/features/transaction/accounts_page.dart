import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../shared/models/account.dart';
import '../../shared/models/transaction.dart';
import '../../core/transaction/transaction_service.dart';
import '../../core/notification/notification_service.dart';

class AccountsPage extends StatefulWidget {
  final TransactionService transactionService;
  const AccountsPage({super.key, required this.transactionService});

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  List<Account> _accounts = [];
  final _currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  void _loadAccounts() {
    setState(() {
      _accounts = widget.transactionService.getAllAccounts();
    });
  }

  void _showSaleDialog(Account account) {
    final amountController = TextEditingController();
    final descController = TextEditingController(text: 'Vente directe');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text('Enregistrer une vente (${account.name})', style: const TextStyle(color: Colors.white, fontSize: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Montant de la vente',
                labelStyle: TextStyle(color: Colors.cyanAccent),
                suffixText: 'FCFA',
                suffixStyle: TextStyle(color: Colors.white54),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: descController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Description (Optionnel)',
                labelStyle: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ANNULER')),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text);
              if (amount == null || amount <= 0) {
                NotificationService.showSnackBar(context, 'Montant invalide', isError: true);
                return;
              }

              final tx = Transaction(
                id: 'TR-QUICK-SALE-${DateTime.now().millisecondsSinceEpoch}',
                type: 'INCOME',
                category: 'SALE',
                amount: amount,
                description: descController.text.trim(),
                date: DateTime.now(),
                accountId: account.id,
              );

              try {
                await widget.transactionService.addTransaction(tx);
                if (!mounted) return;
                _loadAccounts();
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  NotificationService.showSuccessDialog(
                    context, 
                    title: 'Vente enregistrée !', 
                    desc: '${_currencyFormat.format(amount)} ajoutés au compte ${account.name}.'
                  );
                }
              } catch (e) {
                if (ctx.mounted) {
                  NotificationService.showErrorDialog(context, title: 'Erreur', desc: e.toString());
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent, foregroundColor: Colors.black),
            child: const Text('VALIDER LA VENTE'),
          ),
        ],
      ),
    );
  }

  void _showAccountDialog({Account? account}) {
    final nameController = TextEditingController(text: account?.name ?? '');
    String selectedType = account?.type ?? 'CASH';
    final isEditing = account != null;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text(isEditing ? 'Modifier le compte' : 'Nouveau Compte', 
                   style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Nom du compte',
                labelStyle: TextStyle(color: Colors.white70),
                hintText: 'Ex: Orange Money, Caisse Centrale...',
                hintStyle: TextStyle(color: Colors.white24),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              initialValue: selectedType,
              dropdownColor: const Color(0xFF1E293B),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Type de compte',
                labelStyle: TextStyle(color: Colors.white70),
              ),
              items: const [
                DropdownMenuItem(value: 'CASH', child: Text('Espèces')),
                DropdownMenuItem(value: 'MOBILE_MONEY', child: Text('Mobile Money')),
                DropdownMenuItem(value: 'BANK', child: Text('Banque')),
              ],
              onChanged: (val) => selectedType = val!,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ANNULER', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isNotEmpty) {
                if (isEditing) {
                  account.name = nameController.text.trim();
                  account.type = selectedType;
                  await widget.transactionService.updateAccount(account);
                } else {
                  final newAccount = Account(
                    id: const Uuid().v4(),
                    name: nameController.text.trim(),
                    balance: 0,
                    type: selectedType,
                  );
                  await widget.transactionService.addAccount(newAccount);
                }
                
                if (!mounted) return;
                _loadAccounts();
                
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyanAccent,
              foregroundColor: Colors.black,
            ),
            child: Text(isEditing ? 'ENREGISTRER' : 'CRÉER'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Account account) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Supprimer le compte ?', style: TextStyle(color: Colors.white)),
        content: Text('Voulez-vous vraiment supprimer "${account.name}" ?\nLe solde actuel est de ${_currencyFormat.format(account.balance)}.',
                    style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ANNULER')),
          TextButton(
            onPressed: () async {
              await widget.transactionService.deleteAccount(account.id);
              
              if (!mounted) return;
              _loadAccounts();
              
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('SUPPRIMER', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Gestion des Comptes'),
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      body: _accounts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.account_balance_wallet_outlined, size: 80, color: Colors.white.withValues(alpha: 0.1)),
                  const SizedBox(height: 16),
                  const Text('Aucun compte configuré', style: TextStyle(color: Colors.white54, fontSize: 18)),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showAccountDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('AJOUTER MON PREMIER COMPTE'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent, foregroundColor: Colors.black),
                  )
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _accounts.length,
              itemBuilder: (context, index) {
                final acc = _accounts[index];
                final color = _getColor(acc.type);
                return Card(
                  color: color.withValues(alpha: 0.1),
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(color: color.withValues(alpha: 0.3), width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: color.withValues(alpha: 0.2),
                        child: Icon(_getIcon(acc.type), color: color),
                      ),
                      title: Text(acc.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(acc.type.replaceAll('_', ' '), style: TextStyle(color: color.withValues(alpha: 0.7), fontSize: 12)),
                          const SizedBox(height: 8),
                          // Utilisation d'un Wrap au lieu d'un Row pour éviter les débordements
                          Wrap(
                            spacing: 8, // Espace horizontal entre les icônes
                            runSpacing: 4, // Espace vertical si retour à la ligne
                            children: [
                              _buildActionIcon(Icons.add_shopping_cart, Colors.greenAccent, 'Vente', () => _showSaleDialog(acc)),
                              _buildActionIcon(Icons.edit_outlined, Colors.white54, 'Editer', () => _showAccountDialog(account: acc)),
                              _buildActionIcon(Icons.delete_outline, Colors.redAccent, 'Supprimer', () => _confirmDelete(acc)),
                            ],
                          ),
                        ],
                      ),
                      trailing: Text(
                        _currencyFormat.format(acc.balance),
                        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: _accounts.isNotEmpty 
        ? FloatingActionButton(
            onPressed: () => _showAccountDialog(),
            backgroundColor: Colors.cyanAccent,
            child: const Icon(Icons.add, color: Colors.black),
          )
        : null,
    );
  }

  Widget _buildActionIcon(IconData icon, Color color, String tooltip, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: color), // Réduction légère de la taille (20 -> 18)
      ),
    );
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'MOBILE_MONEY': return Icons.smartphone;
      case 'BANK': return Icons.account_balance;
      default: return Icons.payments;
    }
  }

  Color _getColor(String type) {
    switch (type) {
      case 'MOBILE_MONEY': return Colors.blueAccent;
      case 'BANK': return Colors.amberAccent;
      default: return Colors.greenAccent;
    }
  }
}
