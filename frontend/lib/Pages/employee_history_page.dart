import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../Provider/providers.dart';
import '../Models/models.dart';
import '../Widgets/momento_theme.dart';

class EmployeeHistoryPage extends ConsumerStatefulWidget {
  final User user;
  const EmployeeHistoryPage({super.key, required this.user});

  @override
  ConsumerState<EmployeeHistoryPage> createState() => _EmployeeHistoryPageState();
}

class _EmployeeHistoryPageState extends ConsumerState<EmployeeHistoryPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(adminUserHistoryProvider.notifier).fetchUserHistory(widget.user.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final historyState = ref.watch(adminUserHistoryProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Historique : ${widget.user.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: MomentoBackground(
        child: historyState.when(
          data: (history) => history.isEmpty 
            ? const Center(child: Text('Aucun historique pour cet employé.'))
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: history.length,
                itemBuilder: (context, index) => _buildHistoryItem(history[index]),
              ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Erreur: $e')),
        ),
      ),
    );
  }

  Widget _buildHistoryItem(Clocking item) {
    final bool isIn = item.type == 'in';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isIn ? Colors.purple[50] : Colors.orange[50],
              shape: BoxShape.circle,
            ),
            child: Icon(isIn ? Icons.login : Icons.logout, color: isIn ? Colors.purple : Colors.orange, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isIn ? 'Arrivée au bureau' : 'Départ du bureau',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Text(
                  'Via ${item.method.toUpperCase()} • ${DateFormat('dd MMM yyyy').format(item.clockTime.toLocal())}',
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                ),
              ],
            ),
          ),
          Text(
            DateFormat('HH:mm').format(item.clockTime.toLocal()),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
