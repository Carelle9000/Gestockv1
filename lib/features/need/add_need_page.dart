import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../shared/models/need.dart';
import '../../core/need/need_service.dart';

class AddNeedPage extends StatefulWidget {
  final NeedService needService;
  final Need? needToEdit;

  const AddNeedPage({
    super.key,
    required this.needService,
    this.needToEdit,
  });

  @override
  State<AddNeedPage> createState() => _AddNeedPageState();
}

class _AddNeedPageState extends State<AddNeedPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _costController;
  String _status = 'En attente';

  bool get _isEditing => widget.needToEdit != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.needToEdit?.title ?? '');
    _descriptionController = TextEditingController(text: widget.needToEdit?.description ?? '');
    _costController = TextEditingController(text: widget.needToEdit?.estimatedCost.toString() ?? '');
    if (_isEditing) {
      _status = widget.needToEdit!.status;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _costController.dispose();
    super.dispose();
  }

  Future<void> _saveNeed() async {
    if (_formKey.currentState!.validate()) {
      final need = Need(
        id: _isEditing ? widget.needToEdit!.id : const Uuid().v4(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        estimatedCost: double.parse(_costController.text),
        status: _status,
        date: widget.needToEdit?.date ?? DateTime.now(),
      );

      try {
        if (_isEditing) {
          await widget.needService.updateNeed(need.id, need);
        } else {
          await widget.needService.addNeed(need);
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
        title: Text(_isEditing ? 'Modifier le Besoin' : 'Nouveau Besoin'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(_titleController, 'Titre du besoin', Icons.label_outline),
              const SizedBox(height: 15),
              _buildTextField(_descriptionController, 'Description', Icons.description_outlined, maxLines: 3),
              const SizedBox(height: 15),
              _buildTextField(_costController, 'Coût estimé (FCFA)', Icons.payments_outlined, isNumber: true),
              const SizedBox(height: 20),
              const Text('Statut', style: TextStyle(color: Colors.white70, fontSize: 16)),
              const SizedBox(height: 10),
              _buildStatusDropdown(),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _saveNeed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyanAccent,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(_isEditing ? 'METTRE À JOUR' : 'ENREGISTRER LE BESOIN', 
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, 
      {bool isNumber = false, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
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

  Widget _buildStatusDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _status,
          dropdownColor: const Color(0xFF1E293B),
          style: const TextStyle(color: Colors.white),
          isExpanded: true,
          items: ['En attente', 'Validé', 'Refusé', 'Terminé'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _status = newValue!;
            });
          },
        ),
      ),
    );
  }
}
