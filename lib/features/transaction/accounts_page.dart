import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../shared/models/account.dart';
import '../../core/transaction/transaction_service.dart';

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
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: color.withValues(alpha: 0.2),
                      child: Icon(_getIcon(acc.type), color: color),
                    ),
                    title: Text(acc.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    subtitle: Text(acc.type.replaceAll('_', ' '), style: TextStyle(color: color.withValues(alpha: 0.7), fontSize: 12)),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _currencyFormat.format(acc.balance),
                          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.white54),
                              onPressed: () => _showAccountDialog(account: acc),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                              onPressed: () => _confirmDelete(acc),
                            ),
                          ],
                        )
                      ],
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
