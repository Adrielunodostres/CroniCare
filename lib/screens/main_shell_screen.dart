import 'package:flutter/material.dart';

import '../widgets/cronicare_bottom_nav_bar.dart';
import 'dashboard_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import 'progress_screen.dart';
import 'register_measurement_screen.dart';

/// Contenedor principal con barra de navegación inferior persistente.
///
/// Gestiona la navegación entre:
///   - 0: Inicio ("Mi Salud Hoy" - Captura 1)
///   - 1: Historial ("Mi Historial" - Captura 3)
///   - 2: Registrar ("Registrar Medición" - Captura 2)
///   - 3: Progreso ("Mi Progreso")
///   - 4: Perfil ("Mi Perfil")
class MainShellScreen extends StatefulWidget {
  final int initialIndex;

  const MainShellScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabTapped(int index) {
    if (_currentIndex != index) {
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // 0: Inicio
          DashboardScreen(onNavigateTab: _onTabTapped),
          // 1: Historial
          HistoryScreen(onNavigateTab: _onTabTapped),
          // 2: Registrar
          RegisterMeasurementScreen(onNavigateTab: _onTabTapped),
          // 3: Progreso
          ProgressScreen(onNavigateTab: _onTabTapped),
          // 4: Perfil
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: CroniCareBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
