import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../Provider/providers.dart';
import '../Models/models.dart';
import 'employee_history_page.dart';
import '../Widgets/momento_theme.dart';

class AdminDashboard extends ConsumerStatefulWidget {
  const AdminDashboard({super.key});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(adminEmployeesProvider.notifier).fetchEmployees();
      ref.read(adminStatsProvider.notifier).fetchGlobalStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final employeesState = ref.watch(adminEmployeesProvider);
    final statsState = ref.watch(adminStatsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: MomentoBackground(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(adminEmployeesProvider.notifier).fetchEmployees();
            await ref.read(adminStatsProvider.notifier).fetchGlobalStats();
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _buildPremiumAdminHeader(statsState),
              ),
              const SliverPadding(
                padding: EdgeInsets.fromLTRB(20, 30, 20, 10),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Liste des Employés',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                ),
              ),
              employeesState.when(
                data: (employees) => SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildEmployeeCard(employees[index]),
                      childCount: employees.length,
                    ),
                  ),
                ),
                loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
                error: (e, _) => SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      children: [
                        Icon(Icons.error_outline, size: 48, color: Colors.red[200]),
                        const SizedBox(height: 16),
                        const Text(
                          'Erreur de connexion au serveur',
                          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Vérifiez votre tunnel Ngrok ou le backend.',
                          style: TextStyle(color: Colors.grey[400], fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumAdminHeader(AsyncValue<Map<String, dynamic>> statsState) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Administration',
            style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          const Text(
            'Gestion Momento',
            style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          statsState.when(
            data: (stats) => Row(
              children: [
                _buildStatCard('Total', stats['total_employees'].toString(), Colors.blue),
                const SizedBox(width: 12),
                _buildStatCard('Présents', stats['present_today'].toString(), Colors.green),
                const SizedBox(width: 12),
                _buildStatCard('Absents', stats['absent_today'].toString(), Colors.orange),
              ],
            ),
            loading: () => const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: Colors.white))),
            error: (e, _) => Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.white70),
                  SizedBox(width: 12),
                  Expanded(child: Text('Impossible de charger les statistiques globales', style: TextStyle(color: Colors.white70, fontSize: 13))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color accentColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: accentColor)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeCard(User employee) {
    final now = DateTime.now();
    final bool isPresent = employee.clockings != null && 
                          employee.clockings!.isNotEmpty && 
                          employee.clockings!.first.type == 'in' &&
                          employee.clockings!.first.clockTime.day == now.day &&
                          employee.clockings!.first.clockTime.month == now.month;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: Hero(
          tag: 'avatar-${employee.id}',
          child: CircleAvatar(
            radius: 25,
            backgroundColor: isPresent ? Colors.green[50] : Colors.grey[100],
            child: Text(
              employee.name[0].toUpperCase(), 
              style: TextStyle(color: isPresent ? Colors.green : Colors.grey[400], fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
        ),
        title: Text(
          employee.name, 
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Row(
            children: [
              Icon(Icons.work_outline, size: 14, color: Colors.grey[400]),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  employee.email, 
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isPresent ? Colors.green[50] : Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            isPresent ? 'ACTIF' : 'INACTIF',
            style: TextStyle(
              color: isPresent ? Colors.green : Colors.grey[400],
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => EmployeeHistoryPage(user: employee)),
          );
        },
      ),
    );
  }
}
