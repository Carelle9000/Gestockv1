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
  List<Client> _filteredClients = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadClients();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _filteredClients = _clients
          .where((client) => client.name.toLowerCase().contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  void _loadClients() {
    setState(() {
      _clients = widget.clientRepository.getAll();
      _filteredClients = _clients;
      if (_searchController.text.isNotEmpty) {
        _onSearchChanged();
      }
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isEditing ? 'Modifier le client' : 'Nouveau client',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                  SnackBar(
                    content: Text(isEditing ? 'Client mis à jour' : 'Client ajouté'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyanAccent,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
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
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                SnackBar(
                  content: Text('Client ${client.name} supprimé'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
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
      appBar: AppBar(
        title: const Text('Gestion des Clients', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Rechercher un client...',
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.search, color: Colors.cyanAccent),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          Expanded(
            child: _filteredClients.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredClients.length,
                    itemBuilder: (context, index) {
                      final client = _filteredClients[index];
                      return _buildClientCard(client);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showClientDialog(),
        backgroundColor: Colors.cyanAccent,
        icon: const Icon(Icons.person_add_alt_1, color: Colors.black),
        label: const Text('NOUVEAU CLIENT', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
            Icon(
              _searchController.text.isEmpty ? Icons.people_outline : Icons.search_off,
              size: 80,
              color: Colors.white.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isEmpty ? "Aucun client enregistré" : "Aucun client trouvé pour \"${_searchController.text}\"",
              style: const TextStyle(color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }
}
