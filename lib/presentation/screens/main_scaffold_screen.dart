import 'package:flutter/material.dart';
import 'home_dashboard_screen.dart';
import '../../features/clientes/presentation/screens/clientes_list_screen.dart';
import '../../features/encargos/presentation/screens/encargos_list_screen.dart';
import '../../features/reportes/presentation/screens/reportes_screen.dart';
import 'gestion_hub_screen.dart';

class MainScaffoldScreen extends StatefulWidget {
  const MainScaffoldScreen({super.key});

  @override
  State<MainScaffoldScreen> createState() => _MainScaffoldScreenState();
}

class _MainScaffoldScreenState extends State<MainScaffoldScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeDashboardScreen(),
    const ClientesListScreen(),
    const EncargosListScreen(),
    const ReportesScreen(),
    const GestionHubScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFC1512F);
    const indicatorColor = Color(0xFFFDF2F0);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, -4))
          ],
        ),
        child: NavigationBar(
          height: 72,
          backgroundColor: Colors.white,
          elevation: 0,
          indicatorColor: indicatorColor,
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() => _currentIndex = index);
          },
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: Color(0xFF8A7863)),
              selectedIcon: Icon(Icons.home_rounded, color: primaryColor),
              label: 'Inicio',
            ),
            NavigationDestination(
              icon: Icon(Icons.people_outline_rounded, color: Color(0xFF8A7863)),
              selectedIcon: Icon(Icons.people_rounded, color: primaryColor),
              label: 'Clientes',
            ),
            NavigationDestination(
              icon: Icon(Icons.assignment_outlined, color: Color(0xFF8A7863)),
              selectedIcon: Icon(Icons.assignment_rounded, color: primaryColor),
              label: 'Encargos',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined, color: Color(0xFF8A7863)),
              selectedIcon: Icon(Icons.bar_chart_rounded, color: primaryColor),
              label: 'Reportes',
            ),
            NavigationDestination(
              icon: Icon(Icons.more_horiz_outlined, color: Color(0xFF8A7863)),
              selectedIcon: Icon(Icons.more_horiz_rounded, color: primaryColor),
              label: 'Más',
            ),
          ],
        ),
      ),
    );
  }
}
