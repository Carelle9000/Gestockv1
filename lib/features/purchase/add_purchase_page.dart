import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/purchase/purchase_service.dart';
import '../../core/supplier/supplier_service.dart';
import '../../core/stock/product_service.dart';
import '../../core/transaction/transaction_service.dart';
import '../../core/notification/notification_service.dart';
import '../../shared/models/purchase.dart';
import '../../shared/models/product.dart';
import '../../shared/models/supplier.dart';
import '../../shared/models/account.dart';

class AddPurchasePage extends StatefulWidget {
  final PurchaseService purchaseService;
  final SupplierService supplierService;
  final ProductService productService;
  final TransactionService transactionService;

  const AddPurchasePage({
    super.key,
    required this.purchaseService,
    required this.supplierService,
    required this.productService,
    required this.transactionService,
  });

  @override
  State<AddPurchasePage> createState() => _AddPurchasePageState();
}

class _AddPurchasePageState extends State<AddPurchasePage> {
  final _formKey = GlobalKey<FormState>();
  Supplier? _selectedSupplier;
  Account? _selectedAccount;
  final Map<Product, int> _selectedProducts = {};
  File? _receiptImage;
  final _currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA', decimalDigits: 0);

  double get _totalAmount {
    return _selectedProducts.entries.fold(0, (sum, entry) => sum + (entry.key.price * entry.value));
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.cyanAccent),
              title: const Text('Prendre une photo', style: TextStyle(color: Colors.white)),
              onTap: () async {
                final pickedFile = await picker.pickImage(source: ImageSource.camera);
                if (pickedFile != null) {
                  setState(() => _receiptImage = File(pickedFile.path));
                }
                if (mounted) Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.cyanAccent),
              title: const Text('Choisir depuis la galerie', style: TextStyle(color: Colors.white)),
              onTap: () async {
                final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  setState(() => _receiptImage = File(pickedFile.path));
                }
                if (mounted) Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _addProduct() async {
    if (_selectedSupplier == null) {
      NotificationService.showSnackBar(context, 'Veuillez d\'abord sélectionner un fournisseur', isError: true);
      return;
    }

    final products = widget.productService.getProductsBySupplier(_selectedSupplier!.id);
    
    if (products.isEmpty) {
      NotificationService.showSnackBar(context, 'Aucun produit enregistré pour ce fournisseur', isError: true);
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Produits de ${_selectedSupplier!.name}', 
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ListTile(
                      title: Text(product.name, style: const TextStyle(color: Colors.white)),
                      subtitle: Text('Prix: ${_currencyFormat.format(product.price)} - Stock: ${product.quantity}', style: const TextStyle(color: Colors.white54)),
                      trailing: const Icon(Icons.add_circle_outline, color: Colors.cyanAccent),
                      onTap: () {
                        setState(() {
                          if (_selectedProducts.containsKey(product)) {
                            _selectedProducts[product] = _selectedProducts[product]! + 1;
                          } else {
                            _selectedProducts[product] = 1;
                          }
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _submit() async {
    if (_selectedSupplier == null) {
      NotificationService.showSnackBar(context, 'Veuillez sélectionner un fournisseur', isError: true);
      return;
    }
    if (_selectedAccount == null) {
      NotificationService.showSnackBar(context, 'Veuillez sélectionner un compte de paiement', isError: true);
      return;
    }
    if (_selectedProducts.isEmpty) {
      NotificationService.showSnackBar(context, 'Veuillez ajouter au moins un produit', isError: true);
      return;
    }

    try {
      final purchase = Purchase(
        id: 'PUR-${DateTime.now().millisecondsSinceEpoch}',
        supplierId: _selectedSupplier!.id,
        date: DateTime.now(),
        totalAmount: _totalAmount,
        status: 'Reçu',
        receiptImagePath: _receiptImage?.path,
      );

      final productQuantities = _selectedProducts.map(
        (product, quantity) => MapEntry(product.id, quantity)
      );

      await widget.purchaseService.processPurchase(
        purchase: purchase,
        productQuantities: productQuantities,
        accountId: _selectedAccount!.id,
      );

      if (mounted) {
        NotificationService.showSuccessDialog(
          context, 
          title: 'Achat Réussi', 
          desc: 'Le stock a été augmenté et le compte ${_selectedAccount!.name} a été débité.'
        );
        Navigator.of(context).pop(true);
      }
      
    } catch (e) {
      if (mounted) {
        NotificationService.showErrorDialog(
          context, 
          title: 'Erreur d\'achat', 
          desc: e.toString()
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final suppliers = widget.supplierService.getAllSuppliers();
    final accounts = widget.transactionService.getAllAccounts();

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Nouvel Achat'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    DropdownButtonFormField<Supplier>(
                      dropdownColor: const Color(0xFF1E293B),
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration('Fournisseur', Icons.person),
                      initialValue: _selectedSupplier,
                      items: suppliers.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedSupplier = val;
                          _selectedProducts.clear();
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<Account>(
                      dropdownColor: const Color(0xFF1E293B),
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration('Compte de paiement', Icons.account_balance_wallet),
                      initialValue: _selectedAccount,
                      items: accounts.map((acc) {
                        return DropdownMenuItem(value: acc, child: Text('${acc.name} (${_currencyFormat.format(acc.balance)})'));
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedAccount = val),
                    ),
                    const SizedBox(height: 20),
                    
                    // Zone d'importation du bon
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: double.infinity,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.white12, style: BorderStyle.solid),
                        ),
                        child: _receiptImage == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.cloud_upload_outlined, color: Colors.cyanAccent, size: 40),
                                  const SizedBox(height: 8),
                                  Text('Importer le bon fournisseur', style: TextStyle(color: Colors.white.withValues(alpha: 0.7))),
                                ],
                              )
                            : Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Image.file(_receiptImage!, width: double.infinity, height: 120, fit: BoxFit.cover),
                                  ),
                                  Positioned(
                                    right: 8,
                                    top: 8,
                                    child: GestureDetector(
                                      onTap: () => setState(() => _receiptImage = null),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                        child: const Icon(Icons.close, color: Colors.white, size: 16),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'PRODUITS À ACHETER',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white70, letterSpacing: 1.2),
                        ),
                        ElevatedButton.icon(
                          onPressed: _addProduct,
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('AJOUTER'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withValues(alpha: 0.1),
                            foregroundColor: Colors.cyanAccent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (_selectedProducts.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Column(
                          children: [
                            Icon(Icons.shopping_basket_outlined, size: 60, color: Colors.white.withValues(alpha: 0.1)),
                            const SizedBox(height: 8),
                            const Text('Aucun produit sélectionné', style: TextStyle(color: Colors.white24)),
                          ],
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _selectedProducts.length,
                        itemBuilder: (context, index) {
                          final product = _selectedProducts.keys.elementAt(index);
                          final quantity = _selectedProducts[product]!;
                          return Card(
                            color: Colors.white.withValues(alpha: 0.05),
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(product.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              subtitle: Text('PU: ${_currencyFormat.format(product.price)}', style: const TextStyle(color: Colors.white54)),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 20),
                                    onPressed: () {
                                      setState(() {
                                        if (quantity > 1) {
                                          _selectedProducts[product] = quantity - 1;
                                        } else {
                                          _selectedProducts.remove(product);
                                        }
                                      });
                                    },
                                  ),
                                  Text('$quantity', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline, color: Colors.greenAccent, size: 20),
                                    onPressed: () {
                                      setState(() {
                                        _selectedProducts[product] = quantity + 1;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFF1E293B),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('TOTAL ACHAT', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70)),
                      Text(
                        _currencyFormat.format(_totalAmount),
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.cyanAccent),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyanAccent,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: const Text('CONFIRMER L\'ACHAT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: Colors.cyanAccent),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.white12)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.cyanAccent)),
    );
  }
}
