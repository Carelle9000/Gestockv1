import 'package:flutter/material.dart';
import '../../core/auth/auth_service.dart';
import '../../core/stock/product_service.dart';
import '../../core/need/need_service.dart';
import '../../core/supplier/supplier_service.dart';
import '../../core/sales/sales_service.dart';
import '../../core/purchase/purchase_service.dart';
import '../../core/transaction/transaction_service.dart';
import '../../repositories/client_repository.dart';
import '../dashboard/main_layout.dart';

class LoginPage extends StatefulWidget {
  final AuthService authService;
  final ProductService productService;
  final ClientRepository clientRepository;
  final NeedService needService;
  final SupplierService supplierService;
  final SalesService salesService;
  final PurchaseService purchaseService;
  final TransactionService transactionService;

  const LoginPage({
    super.key,
    required this.authService,
    required this.productService,
    required this.clientRepository,
    required this.needService,
    required this.supplierService,
    required this.salesService,
    required this.purchaseService,
    required this.transactionService,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      final user = await widget.authService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
      
      if (user != null) {
        navigator.pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => MainLayout(
              productService: widget.productService,
              clientRepository: widget.clientRepository,
              needService: widget.needService,
              authService: widget.authService,
              supplierService: widget.supplierService,
              salesService: widget.salesService,
              purchaseService: widget.purchaseService,
              transactionService: widget.transactionService,
            ),
          ),
          (route) => false,
        );
        
        messenger.showSnackBar(
          const SnackBar(content: Text('Connexion réussie !')),
        );
      } else {
        messenger.showSnackBar(
          const SnackBar(content: Text('Identifiants incorrects')),
        );
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connexion'),
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      body: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F172A), Color(0xFF020617)],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Bon retour !',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Connectez-vous pour gérer votre stock.',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
              ),
              const SizedBox(height: 40),
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _passwordController,
                label: 'Mot de passe',
                icon: Icons.lock_outline,
                obscureText: true,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                  shadowColor: Colors.blueAccent.withValues(alpha: 0.5),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'SE CONNECTER',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 1.2,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
        prefixIcon: Icon(icon, color: Colors.cyanAccent),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.cyanAccent),
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
      ),
    );
  }
}
