import 'package:flutter/material.dart';
import '../../shared/models/need.dart';
import '../../core/need/need_service.dart';
import 'package:intl/intl.dart';
import 'add_need_page.dart';

class NeedPage extends StatefulWidget {
  final NeedService needService;
  const NeedPage({super.key, required this.needService});

  @override
  State<NeedPage> createState() => _NeedPageState();
}

class _NeedPageState extends State<NeedPage> {
  late List<Need> _needs;
  final _currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA', decimalDigits: 0);
  final _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _loadNeeds();
  }

  void _loadNeeds() {
    setState(() {
      _needs = widget.needService.getAllNeeds();
    });
  }

  void _deleteNeed(Need need) {
    showDialog(
      context: context,
      builder: (context) {
        final navigator = Navigator.of(context);
        final scaffoldMessenger = ScaffoldMessenger.of(context);
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text('Supprimer le besoin', style: TextStyle(color: Colors.white)),
          content: Text('Voulez-vous vraiment supprimer "${need.title}" ?', style: const TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => navigator.pop(),
              child: const Text('ANNULER', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              onPressed: () async {
                await widget.needService.deleteNeed(need.id);
                if (mounted) {
                  navigator.pop();
                  _loadNeeds();
                  scaffoldMessenger.showSnackBar(
                    SnackBar(content: Text('Besoin "${need.title}" supprimé')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              child: const Text('SUPPRIMER', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _navigateToForm({Need? need}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddNeedPage(
          needService: widget.needService,
          needToEdit: need,
        ),
      ),
    );

    if (result == true) {
      _loadNeeds();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: _needs.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _needs.length,
              itemBuilder: (context, index) {
                final need = _needs[index];
                return _buildNeedCard(need);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(),
        backgroundColor: Colors.cyanAccent,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _buildNeedCard(Need need) {
    Color statusColor;
    switch (need.status) {
      case 'Validé':
        statusColor = Colors.greenAccent;
        break;
      case 'Refusé':
        statusColor = Colors.redAccent;
        break;
      case 'Terminé':
        statusColor = Colors.blueAccent;
        break;
      default:
        statusColor = Colors.orangeAccent;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.withValues(alpha: 0.1),
            Colors.white.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
        ),
      ),
      child: InkWell(
        onTap: () => _navigateToForm(need: need),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  Icons.assignment_outlined,
                  color: statusColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      need.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      softWrap: true,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      need.description,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          _currencyFormat.format(need.estimatedCost),
                          style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        Text(
                          _dateFormat.format(need.date),
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        need.status,
                        style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.cyanAccent, size: 20),
                    onPressed: () => _navigateToForm(need: need),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(8),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                    onPressed: () => _deleteNeed(need),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(8),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 80, color: Colors.white.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          const Text("Aucun besoin enregistré", style: TextStyle(color: Colors.white54)),
        ],
      ),
    );
  }
}
