import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../shared/models/product.dart';

class ProductWidget extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProductWidget({
    super.key,
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA', decimalDigits: 0);
    final isLowStock = product.quantity <= product.minStock;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isLowStock ? Colors.redAccent.withValues(alpha: 0.3) : Colors.white10,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (isLowStock ? Colors.redAccent : Colors.blueAccent).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isLowStock ? Icons.warning_amber_rounded : Icons.inventory_2_outlined,
              color: isLowStock ? Colors.redAccent : Colors.blueAccent,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  product.category,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                currencyFormat.format(product.price),
                style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold),
              ),
              Text(
                'Stock: ${product.quantity}',
                style: TextStyle(
                  color: isLowStock ? Colors.redAccent : Colors.greenAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white54),
            color: const Color(0xFF1E293B),
            onSelected: (value) {
              if (value == 'edit') onEdit();
              if (value == 'delete') onDelete();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, color: Colors.cyanAccent, size: 18),
                    SizedBox(width: 8),
                    Text('Modifier', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.redAccent, size: 18),
                    SizedBox(width: 8),
                    Text('Supprimer', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
