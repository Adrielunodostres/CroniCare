import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/auth_service.dart';
import '../services/metricas_service.dart';
import 'login_screen.dart';
import 'register_patient_screen.dart';

/// Pantalla "Mi Perfil" (Tab 4 de la barra de navegación).
///
/// Carga los datos del paciente desde el backend Laravel (`GET /api/me`)
/// y muestra la información según las tablas `pacientes` y `usuarios` de la BD.
/// Si el servidor no está disponible, muestra los datos locales del servicio.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
  }

  Future<void> _cargarPerfil() async {
    final metricasService = MetricasService();
    await metricasService.cargarPerfilPaciente(metricasService.paciente.id);
    if (mounted) {
      setState(() => _isFirstLoad = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final metricasService = MetricasService();

    return ListenableBuilder(
      listenable: metricasService,
      builder: (context, _) {
        final paciente = metricasService.paciente;

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: SafeArea(
            bottom: false,
            child: RefreshIndicator(
              onRefresh: _cargarPerfil,
              color: const Color(0xFF2563EB),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Mi Perfil',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E3A8A),
                            letterSpacing: -0.5,
                          ),
                        ),
                        _buildConnectionBadge(metricasService),
                      ],
                    ),

                    // ── Indicador de carga inicial ─────────────────────
                    if (_isFirstLoad && metricasService.isLoading) ...[
                      const SizedBox(height: 12),
                      const LinearProgressIndicator(
                        color: Color(0xFF2563EB),
                        backgroundColor: Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // ── Tarjeta Avatar y Nombre ─────────────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 34,
                            backgroundColor: const Color(0xFFE0F2FE),
                            child: Text(
                              '${paciente.primerNombre[0]}${paciente.apellidoPaterno[0]}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  paciente.nombreCompleto,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  paciente.email,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Badge de Riesgo
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: _riesgoBgColor(paciente.nivelRiesgo),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Riesgo: ${paciente.nivelRiesgo}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: _riesgoTextColor(paciente.nivelRiesgo),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Información Médica ──────────────────────────────────
                    const Text(
                      'Datos Médicos',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 12),

                    _buildInfoTile(
                      icon: Icons.medical_services_outlined,
                      title: 'Diagnóstico Principal',
                      value: paciente.diagnosticoPrincipal,
                    ),
                    _buildInfoTile(
                      icon: Icons.person_pin_rounded,
                      title: 'Médico Asignado',
                      value: '${paciente.nombreMedico ?? "No asignado"}\n(${paciente.especialidadMedico ?? ""})',
                    ),
                    _buildInfoTile(
                      icon: Icons.phone_outlined,
                      title: 'Teléfono de Emergencia',
                      value: paciente.telefonoEmergencia,
                    ),

                    const SizedBox(height: 20),

                    // ── Datos Personales ────────────────────────────────────
                    const Text(
                      'Datos Personales',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 12),

                    _buildInfoTile(
                      icon: Icons.cake_outlined,
                      title: 'Fecha de Nacimiento',
                      value: '${DateFormat('dd/MM/yyyy').format(paciente.fechaNacimiento)} (${paciente.edad} años)',
                    ),
                    _buildInfoTile(
                      icon: Icons.transgender_rounded,
                      title: 'Sexo',
                      value: paciente.sexo,
                    ),
                    _buildInfoTile(
                      icon: Icons.height_rounded,
                      title: 'Estatura',
                      value: '${paciente.estatura} m',
                    ),

                    const SizedBox(height: 28),

                    // Botón de navegación al Registro de Paciente
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterPatientScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.person_add_alt_1_rounded),
                        label: const Text('Abrir Formulario de Registro de Paciente'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Botón de Cerrar Sesión
                    SizedBox(
                      width: double.infinity,
                      child: TextButton.icon(
                        onPressed: () => _confirmarCerrarSesion(context),
                        icon: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
                        label: const Text(
                          'Cerrar Sesión',
                          style: TextStyle(
                            color: Color(0xFFEF4444),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Confirma antes de cerrar sesión
  void _confirmarCerrarSesion(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar tu sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await AuthService().logout();
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFEF4444)),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }

  /// Badge de conexión
  Widget _buildConnectionBadge(MetricasService service) {
    if (service.isLoading) {
      return const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2563EB)),
      );
    }
    final isOnline = service.isOnline;
    return Tooltip(
      message: isOnline ? 'Datos del servidor' : 'Datos locales',
      child: Icon(
        isOnline ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
        size: 18,
        color: isOnline ? const Color(0xFF10B981) : const Color(0xFFD97706),
      ),
    );
  }

  /// Colores dinámicos según el nivel de riesgo
  Color _riesgoBgColor(String nivel) {
    switch (nivel.toLowerCase()) {
      case 'bajo':
        return const Color(0xFFECFDF5);
      case 'alto':
        return const Color(0xFFFEE2E2);
      default: // Medio
        return const Color(0xFFFEF3C7);
    }
  }

  Color _riesgoTextColor(String nivel) {
    switch (nivel.toLowerCase()) {
      case 'bajo':
        return const Color(0xFF10B981);
      case 'alto':
        return const Color(0xFFEF4444);
      default: // Medio
        return const Color(0xFFD97706);
    }
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF2563EB)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
