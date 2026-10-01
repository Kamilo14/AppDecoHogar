import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'home_dashboard_screen.dart';
import '../../features/clientes/presentation/screens/clientes_list_screen.dart';
import '../../features/reportes/presentation/screens/reportes_screen.dart';
import '../../features/ventas/presentation/screens/ventas_list_screen.dart';
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
    const VentasListScreen(),
    const ReportesScreen(),
    const GestionHubScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, -4),
            )
          ],
        ),
        child: NavigationBar(
          height: 72,
          backgroundColor: AppColors.surface,
          elevation: 0,
          indicatorColor: AppColors.primary.withOpacity(0.1),
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() => _currentIndex = index);
          },
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: AppColors.textSecondary),
              selectedIcon: Icon(Icons.home_rounded, color: AppColors.primary),
              label: 'Inicio',
            ),
            NavigationDestination(
              icon: Icon(Icons.people_outline_rounded,
                  color: AppColors.textSecondary),
              selectedIcon:
                  Icon(Icons.people_rounded, color: AppColors.primary),
              label: 'Clientes',
            ),
            NavigationDestination(
              icon: Icon(Icons.point_of_sale_outlined,
                  color: AppColors.textSecondary),
              selectedIcon:
                  Icon(Icons.point_of_sale_rounded, color: AppColors.primary),
              label: 'Ventas',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined,
                  color: AppColors.textSecondary),
              selectedIcon:
                  Icon(Icons.bar_chart_rounded, color: AppColors.primary),
              label: 'Reportes',
            ),
            NavigationDestination(
              icon: Icon(Icons.more_horiz_outlined,
                  color: AppColors.textSecondary),
              selectedIcon:
                  Icon(Icons.more_horiz_rounded, color: AppColors.primary),
              label: 'Más',
            ),
          ],
        ),
      ),
    );
  }
}
