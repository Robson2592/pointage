import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../Provider/providers.dart';
import '../Models/models.dart';
import '../Widgets/momento_theme.dart';

class ClockingView extends ConsumerStatefulWidget {
  const ClockingView({super.key});

  @override
  ConsumerState<ClockingView> createState() => _ClockingViewState();
}

class _ClockingViewState extends ConsumerState<ClockingView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(clockingProvider.notifier).fetchHistory();
      ref.read(statsProvider.notifier).fetchStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final historyState = ref.watch(clockingProvider);
    final statsState = ref.watch(statsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: MomentoBackground(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(clockingProvider.notifier).fetchHistory();
            await ref.read(statsProvider.notifier).fetchStats();
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _buildPremiumHeader(context, statsState),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                sliver: SliverToBoxAdapter(
                  child: _buildActionButtons(context, ref),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Historique Récent',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      TextButton(onPressed: () {}, child: const Text('Voir tout')),
                    ],
                  ),
                ),
              ),
              historyState.when(
                data: (history) => SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildHistoryItem(history[index]),
                      childCount: history.length > 5 ? 5 : history.length,
                    ),
                  ),
                ),
                loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
                error: (e, _) => SliverToBoxAdapter(
                  child: Center(child: Text('Erreur: $e')),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumHeader(BuildContext context, AsyncValue<UserStats> stats) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFA020F0), Color(0xFF6A0DAD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bonjour,', style: TextStyle(color: Colors.white70, fontSize: 16)),
                  Text(
                    'Prêt pour le travail ?',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(15)),
                child: IconButton(
                  icon: const Icon(Icons.notifications_none, color: Colors.white),
                  onPressed: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
              ],
            ),
            child: Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 80,
                      width: 80,
                      child: CircularProgressIndicator(
                        value: stats.when(data: (s) => (s.hoursToday / 8.0).clamp(0, 1), error: (_, __) => 0, loading: () => 0.1),
                        strokeWidth: 8,
                        backgroundColor: Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFA020F0)),
                      ),
                    ),
                    Text(
                      stats.when(data: (s) => '${s.hoursToday}h', error: (_, __) => '--', loading: () => '...'),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ],
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Objectif du jour', style: TextStyle(color: Colors.grey, fontSize: 14)),
                      const Text('8.0 heures', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: stats.when(
                            data: (s) => s.status == 'clocked_in' ? Colors.green[50] : Colors.orange[50],
                            error: (_, __) => Colors.grey[50],
                            loading: () => Colors.grey[50],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          stats.when(
                            data: (s) => s.status == 'clocked_in' ? 'EN POSTE' : 'SORTIE',
                            error: (_, __) => 'INCONNU',
                            loading: () => 'CHARGE',
                          ),
                          style: TextStyle(
                            color: stats.when(
                              data: (s) => s.status == 'clocked_in' ? Colors.green : Colors.orange,
                              error: (_, __) => Colors.grey,
                              loading: () => Colors.grey,
                            ),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: _buildPointageModule(
            context,
            'Entrée',
            Icons.login,
            const Color(0xFFA020F0),
            () => _showPointageOptions(context, ref, 'in'),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildPointageModule(
            context,
            'Sortie',
            Icons.logout,
            Colors.orange,
            () => _showPointageOptions(context, ref, 'out'),
          ),
        ),
      ],
    );
  }

  Widget _buildPointageModule(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  void _showPointageOptions(BuildContext context, WidgetRef ref, String type) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              type == 'in' ? 'Pointer une Entrée' : 'Pointer une Sortie',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildOptionItem(context, Icons.qr_code_scanner, 'Scanner QR Code', () async {
              Navigator.pop(context);
              _simulateScanning(context, ref, type, 'qr');
            }),
            _buildOptionItem(context, Icons.nfc, 'Pointage NFC', () {
              Navigator.pop(context);
              _simulateScanning(context, ref, type, 'nfc');
            }),
            _buildOptionItem(context, Icons.location_on_outlined, 'Géolocalisation', () {
              Navigator.pop(context);
              ref.read(clockingProvider.notifier).clock(type, 'geo');
            }),
            _buildOptionItem(context, Icons.touch_app_outlined, 'Manuel', () {
              Navigator.pop(context);
              ref.read(clockingProvider.notifier).clock(type, 'manual');
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFA020F0)),
      title: Text(title),
      onTap: onTap,
    );
  }

  void _simulateScanning(BuildContext context, WidgetRef ref, String type, String method) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            SizedBox(
              height: 100,
              width: 100,
              child: CircularProgressIndicator(color: method == 'qr' ? Colors.blue : Colors.purple),
            ),
            const SizedBox(height: 20),
            Text(method == 'qr' ? 'Recherche du QR Code...' : 'Approchez votre badge NFC...'),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
      ref.read(clockingProvider.notifier).clock(type, method);
      ref.read(statsProvider.notifier).fetchStats();
    });
  }

  Widget _buildHistoryItem(Clocking item) {
    final bool isIn = item.type == 'in';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
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
                  'Via ${item.method.toUpperCase()}',
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
