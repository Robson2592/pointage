import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../Provider/providers.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(clockingProvider.notifier).fetchHistory());
  }

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(clockingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pointage Électronique'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(clockingProvider.notifier).fetchHistory(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => ref.read(clockingProvider.notifier).clock('in', 'manual'),
                  icon: const Icon(Icons.login),
                  label: const Text('Entrée'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                ),
                ElevatedButton.icon(
                  onPressed: () => ref.read(clockingProvider.notifier).clock('out', 'manual'),
                  icon: const Icon(Icons.logout),
                  label: const Text('Sortie'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                ),
              ],
            ),
          ),
          const Divider(),
          const Text('Historique', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Expanded(
            child: historyAsync.when(
              data: (history) => ListView.builder(
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final item = history[index];
                  return ListTile(
                    title: Text(item.type == 'in' ? 'Entrée' : 'Sortie'),
                    subtitle: Text('Méthode: ${item.method}'),
                    trailing: Text(item.clockTime.toLocal().toString().split('.')[0]),
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Erreur: $e')),
            ),
          ),
        ],
      ),
    );
  }
}
