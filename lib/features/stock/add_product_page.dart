import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../shared/models/product.dart';
import '../../core/stock/product_service.dart';

class AddProductPage extends StatefulWidget {
  final ProductService productService;
  final Product? productToEdit;

  const AddProductPage({
    super.key, 
    required this.productService, 
    this.productToEdit,
  });

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _quantityController;
  late TextEditingController _minStockController;
  late TextEditingController _categoryController;
  
  bool get _isEditing => widget.productToEdit != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.productToEdit?.name ?? '');
    _priceController = TextEditingController(text: widget.productToEdit?.price.toString() ?? '');
    _quantityController = TextEditingController(text: widget.productToEdit?.quantity.toString() ?? '');
    _minStockController = TextEditingController(text: widget.productToEdit?.minStock.toString() ?? '');
    _categoryController = TextEditingController(text: widget.productToEdit?.category ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _minStockController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      final product = Product(
        id: _isEditing ? widget.productToEdit!.id : const Uuid().v4(),
        name: _nameController.text.trim(),
        price: double.parse(_priceController.text),
        quantity: int.parse(_quantityController.text),
        minStock: int.parse(_minStockController.text),
        category: _categoryController.text.trim(),
        supplierId: widget.productToEdit?.supplierId ?? '',
        createdAt: widget.productToEdit?.createdAt ?? DateTime.now(),
      );

      try {
        if (_isEditing) {
          await widget.productService.updateProduct(product.id, product);
        } else {
          await widget.productService.addProduct(product);
        }
        if (mounted) Navigator.pop(context, true);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: ${e.toString()}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifier le Produit' : 'Ajouter un Produit'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(_nameController, 'Nom du produit', Icons.inventory),
              const SizedBox(height: 15),
              _buildTextField(_categoryController, 'Catégorie', Icons.category),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(child: _buildTextField(_priceController, 'Prix (FCFA)', Icons.money, isNumber: true)),
                  const SizedBox(width: 15),
                  Expanded(child: _buildTextField(_quantityController, 'Quantité', Icons.numbers, isNumber: true)),
                ],
              ),
              const SizedBox(height: 15),
              _buildTextField(_minStockController, 'Stock Minimum (Alerte)', Icons.warning_amber, isNumber: true),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _saveProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyanAccent,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(_isEditing ? 'METTRE À JOUR' : 'ENREGISTRER LE PRODUIT', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.cyanAccent),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
      validator: (value) => value == null || value.isEmpty ? 'Champ requis' : null,
    );
  }
}
