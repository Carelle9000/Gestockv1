import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/auth/auth_service.dart';
import '../../shared/models/user.dart' as model;

class ProfilePage extends StatefulWidget {
  final AuthService authService;
  const ProfilePage({super.key, required this.authService});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  model.User? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  void _loadUserInfo() async {
    final user = await widget.authService.checkAuthState();
    if (mounted) {
      setState(() {
        _user = user;
        _isLoading = false;
      });
    }
  }

  Future<void> _showEditDialog() async {
    if (_user == null) return;

    final nameController = TextEditingController(text: _user!.name);
    final emailController = TextEditingController(text: _user!.email);
    final phoneController = TextEditingController(text: _user!.phone);

    return showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Modifier le profil', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildEditField(nameController, 'Nom complet', Icons.person_outline),
              const SizedBox(height: 16),
              _buildEditField(emailController, 'Email', Icons.email_outlined),
              const SizedBox(height: 16),
              _buildEditField(phoneController, 'Téléphone', Icons.phone_outlined),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('ANNULER', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () async {
              final updatedUser = model.User(
                id: _user!.id,
                name: nameController.text.trim(),
                email: emailController.text.trim(),
                phone: phoneController.text.trim(),
                password: _user!.password,
                createdAt: _user!.createdAt,
              );

              // On capture les instances avant l'await pour éviter l'utilisation du contexte après une pause asynchrone
              final messenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(dialogContext);

              await widget.authService.updateUser(updatedUser);
              
              if (mounted) {
                setState(() => _user = updatedUser);
                navigator.pop();
                messenger.showSnackBar(
                  const SnackBar(content: Text('Profil mis à jour !')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
            child: const Text('ENREGISTRER'),
          ),
        ],
      ),
    );
  }

  Widget _buildEditField(TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F172A),
        body: Center(child: CircularProgressIndicator(color: Colors.cyanAccent)),
      );
    }

    if (_user == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F172A),
        body: Center(child: Text("Utilisateur non trouvé", style: TextStyle(color: Colors.white))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Avatar
            Center(
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.cyanAccent, width: 2),
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.blueAccent.withAlpha(25),
                  child: const Icon(Icons.person, size: 80, color: Colors.cyanAccent),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _user!.name,
              style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
            ),
            Text(
              "Administrateur Stock",
              style: TextStyle(color: Colors.cyanAccent.withAlpha(178), fontSize: 16),
            ),
            const SizedBox(height: 40),
            
            // Infos Cards
            _buildInfoCard(Icons.email_outlined, "Email", _user!.email),
            const SizedBox(height: 16),
            _buildInfoCard(Icons.phone_outlined, "Téléphone", _user!.phone),
            const SizedBox(height: 16),
            _buildInfoCard(
              Icons.calendar_today_outlined, 
              "Membre depuis", 
              DateFormat('dd MMMM yyyy', 'fr_FR').format(_user!.createdAt)
            ),
            
            const SizedBox(height: 40),
            // Actions
            ElevatedButton.icon(
              onPressed: _showEditDialog,
              icon: const Icon(Icons.edit_outlined),
              label: const Text("MODIFIER LE PROFIL"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent.withAlpha(25),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: BorderSide(color: Colors.blueAccent.withAlpha(76)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(13),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withAlpha(25)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.cyanAccent, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.white.withAlpha(127), fontSize: 12)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
