import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../shared/models/client.dart';
import '../../repositories/client_repository.dart';

class ClientPage extends StatefulWidget {
  final ClientRepository clientRepository;
  const ClientPage({super.key, required this.clientRepository});

  @override
  State<ClientPage> createState() => _ClientPageState();
}

class _ClientPageState extends State<ClientPage> {
  late List<Client> _clients;

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  void _loadClients() {
    setState(() {
      _clients = widget.clientRepository.getAll();
    });
  }

  Future<void> _showClientDialog([Client? client]) async {
    final isEditing = client != null;
    final nameController = TextEditingController(text: client?.name ?? '');
    final phoneController = TextEditingController(text: client?.phone ?? '');
    final addressController = TextEditingController(text: client?.address ?? '');

    return showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text(
          isEditing ? 'Modifier le client' : 'Ajouter un client',
          style: const TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(nameController, 'Nom complet', Icons.person_outline),
              const SizedBox(height: 16),
              _buildTextField(phoneController, 'Téléphone', Icons.phone_outlined, keyboardType: TextInputType.phone),
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
              if (nameController.text.isEmpty || phoneController.text.isEmpty) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(content: Text('Veuillez remplir le nom et le téléphone')),
                );
                return;
              }

              final messenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(dialogContext);

              final newClient = Client(
                id: client?.id ?? const Uuid().v4(),
                name: nameController.text.trim(),
                phone: phoneController.text.trim(),
                address: addressController.text.trim(),
                createdAt: client?.createdAt ?? DateTime.now(),
              );

              if (isEditing) {
                await widget.clientRepository.update(newClient.id, newClient);
              } else {
                await widget.clientRepository.add(newClient.id, newClient);
              }

              if (mounted) {
                _loadClients();
                navigator.pop();
                messenger.showSnackBar(
                  SnackBar(content: Text(isEditing ? 'Client mis à jour' : 'Client ajouté')),
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

  void _deleteClient(Client client) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Supprimer le client', style: TextStyle(color: Colors.white)),
        content: Text('Voulez-vous vraiment supprimer "${client.name}" ?', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('ANNULER', style: TextStyle(color: Colors.white.withValues(alpha: 0.5))),
          ),
          ElevatedButton(
            onPressed: () {
              widget.clientRepository.delete(client.id);
              Navigator.pop(dialogContext);
              _loadClients();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Client ${client.name} supprimé')),
              );
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
      body: _clients.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _clients.length,
              itemBuilder: (context, index) {
                final client = _clients[index];
                return _buildClientCard(client);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showClientDialog(),
        backgroundColor: Colors.cyanAccent,
        child: const Icon(Icons.person_add, color: Colors.black),
      ),
    );
  }

  Widget _buildClientCard(Client client) {
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
          backgroundColor: Colors.cyanAccent.withValues(alpha: 0.1),
          child: Text(
            client.name.isNotEmpty ? client.name.substring(0, 1).toUpperCase() : '?',
            style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          client.name,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              const Icon(Icons.phone, size: 14, color: Colors.cyanAccent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  client.phone,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.cyanAccent, size: 20),
              onPressed: () => _showClientDialog(client),
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(8),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
              onPressed: () => _deleteClient(client),
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
            Icon(Icons.people_outline, size: 80, color: Colors.white.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            const Text("Aucun client enregistré", style: TextStyle(color: Colors.white54)),
          ],
        ),
      ),
    );
  }
}
