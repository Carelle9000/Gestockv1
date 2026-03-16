import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../shared/models/supplier.dart';
import '../../core/supplier/supplier_service.dart';

class SupplierPage extends StatefulWidget {
  final SupplierService supplierService;
  const SupplierPage({super.key, required this.supplierService});

  @override
  State<SupplierPage> createState() => _SupplierPageState();
}

class _SupplierPageState extends State<SupplierPage> {
  late List<Supplier> _suppliers;

  @override
  void initState() {
    super.initState();
    _loadSuppliers();
  }

  void _loadSuppliers() {
    setState(() {
      _suppliers = widget.supplierService.getAllSuppliers();
    });
  }

  Future<void> _showSupplierDialog([Supplier? supplier]) async {
    final isEditing = supplier != null;
    final nameController = TextEditingController(text: supplier?.name ?? '');
    final phoneController = TextEditingController(text: supplier?.phone ?? '');
    final emailController = TextEditingController(text: supplier?.email ?? '');
    final addressController = TextEditingController(text: supplier?.address ?? '');

    return showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text(
          isEditing ? 'Modifier le fournisseur' : 'Ajouter un fournisseur',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(nameController, 'Nom de l\'entreprise', Icons.business_outlined),
              const SizedBox(height: 16),
              _buildTextField(phoneController, 'Téléphone', Icons.phone_outlined, keyboardType: TextInputType.phone),
              const SizedBox(height: 16),
              _buildTextField(emailController, 'Email', Icons.email_outlined, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),
              _buildTextField(addressController, 'Adresse', Icons.location_on_outlined),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('ANNULER', style: TextStyle(color: Colors.white.withValues(alpha: 0.7))),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final phone = phoneController.text.trim();

              if (name.isEmpty || phone.isEmpty) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(content: Text('Nom et téléphone requis')),
                );
                return;
              }

              final messenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(dialogContext);

              final newSupplier = Supplier(
                id: supplier?.id ?? const Uuid().v4(),
                name: name,
                phone: phone,
                email: emailController.text.trim(),
                address: addressController.text.trim(),
                createdAt: supplier?.createdAt ?? DateTime.now(),
              );

              if (isEditing) {
                await widget.supplierService.updateSupplier(newSupplier);
              } else {
                await widget.supplierService.addSupplier(newSupplier);
              }

              if (mounted) {
                _loadSuppliers();
                if (dialogContext.mounted) {
                  navigator.pop();
                }
                messenger.showSnackBar(
                  SnackBar(content: Text(isEditing ? 'Fournisseur mis à jour' : 'Fournisseur ajouté')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent, foregroundColor: Colors.black),
            child: Text(isEditing ? 'ENREGISTRER' : 'AJOUTER'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.cyanAccent),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.cyanAccent),
        ),
      ),
    );
  }

  void _deleteSupplier(Supplier supplier) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Supprimer le fournisseur', style: TextStyle(color: Colors.white)),
        content: Text('Voulez-vous supprimer "${supplier.name}" ?', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('ANNULER', style: TextStyle(color: Colors.white.withValues(alpha: 0.5))),
          ),
          ElevatedButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(dialogContext);

              await widget.supplierService.deleteSupplier(supplier.id);
              
              if (mounted) {
                if (dialogContext.mounted) {
                  navigator.pop();
                }
                _loadSuppliers();
                messenger.showSnackBar(
                  const SnackBar(content: Text('Fournisseur supprimé'), backgroundColor: Colors.redAccent),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('SUPPRIMER', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: _suppliers.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _suppliers.length,
              itemBuilder: (context, index) {
                final supplier = _suppliers[index];
                return _buildSupplierCard(supplier);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSupplierDialog(),
        backgroundColor: Colors.cyanAccent,
        icon: const Icon(Icons.add_business, color: Colors.black),
        label: const Text('NOUVEAU FOURNISSEUR', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSupplierCard(Supplier supplier) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: Colors.cyanAccent.withValues(alpha: 0.1),
          child: const Icon(Icons.business, color: Colors.cyanAccent),
        ),
        title: Text(
          supplier.name,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.phone, size: 14, color: Colors.cyanAccent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    supplier.phone, 
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.email_outlined, size: 14, color: Colors.white54),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    supplier.email, 
                    style: const TextStyle(color: Colors.white54, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.cyanAccent, size: 20),
              onPressed: () => _showSupplierDialog(supplier),
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(8),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
              onPressed: () => _deleteSupplier(supplier),
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(8),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.business_outlined, size: 80, color: Colors.white.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            const Text("Aucun fournisseur enregistré", style: TextStyle(color: Colors.white54)),
          ],
        ),
      ),
    );
  }
}
