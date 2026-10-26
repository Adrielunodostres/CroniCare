import 'package:flutter/material.dart';
import 'main_shell_screen.dart';

/// Pantalla principal de CroniCare.
///
/// Redirige al contenedor [MainShellScreen] que contiene la barra de navegación
/// y las nuevas pantallas del paciente:
///   - "Mi Salud Hoy"
///   - "Registrar Medición"
///   - "Mi Historial"
///   - "Mi Progreso"
///   - "Mi Perfil"
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainShellScreen();
  }
}
