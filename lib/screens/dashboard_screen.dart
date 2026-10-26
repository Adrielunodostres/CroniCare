import 'package:flutter/material.dart';

import '../models/metrica_tipo.dart';
import '../services/metricas_service.dart';
import '../widgets/metric_card.dart';
import 'register_metric_input_screen.dart';

/// Pantalla principal "Mi Salud Hoy" correspondiente a la primera captura.
///
/// Al montarse, intenta cargar los datos del resumen del día desde el backend
/// Laravel (`GET /api/pacientes/resumen-hoy`). Si no hay conexión, muestra
/// los datos mock locales almacenados en `MetricasService`.
class DashboardScreen extends StatefulWidget {
  final ValueChanged<int>? onNavigateTab;

  const DashboardScreen({
    super.key,
    this.onNavigateTab,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    // Cargar datos del servidor al abrir la pantalla de inicio
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final metricasService = MetricasService();
    await metricasService.cargarResumenHoy();
    if (mounted) {
      setState(() => _isFirstLoad = false);
    }
  }

  Future<void> _refrescarDatos() async {
    final metricasService = MetricasService();
    await metricasService.cargarResumenHoy();
  }

  @override
  Widget build(BuildContext context) {
    final metricasService = MetricasService();

    return ListenableBuilder(
      listenable: metricasService,
      builder: (context, _) {
        final paciente = metricasService.paciente;
        final recordatorio = metricasService.recordatorio;

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: SafeArea(
            bottom: false,
            child: RefreshIndicator(
              onRefresh: _refrescarDatos,
              color: const Color(0xFF2563EB),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // ── Encabezado ──────────────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Mi Salud Hoy',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E3A8A),
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '¡Buenos días, ${paciente.primerNombre}!',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Indicador de estado de conexión
                        _buildConnectionBadge(metricasService),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ── Indicador de carga inicial ─────────────────────────
                    if (_isFirstLoad && metricasService.isLoading)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: LinearProgressIndicator(
                          color: Color(0xFF2563EB),
                          backgroundColor: Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        ),
                      ),

                    // ── Tarjeta de Estado General ───────────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F8F0),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: const Color(0xFFC3EED1),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Círculo verde con check
                          Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 14),
                          // Textos del estado
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  metricasService.estadoGeneralTitulo,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF065F46),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  metricasService.estadoGeneralMensaje,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF047857),
                                    height: 1.25,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 26),

                    // ── Título Sección "Resumen de hoy" ─────────────────────
                    const Text(
                      'Resumen de hoy',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ── Grid 2x2 de métricas ────────────────────────────────
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 1.15,
                      children: [
                        // 1. Glucosa
                        MetricCard(
                          categoria: CategoriaMetrica.glucosa,
                          medicion: metricasService.glucosaHoy,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterMetricInputScreen.glucosa(),
                            ),
                          ),
                        ),
                        // 2. Presión
                        MetricCard(
                          categoria: CategoriaMetrica.presion,
                          medicion: metricasService.presionHoy,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterMetricInputScreen.presion(),
                            ),
                          ),
                        ),
                        // 3. Frec. Cardiaca
                        MetricCard(
                          categoria: CategoriaMetrica.frecuenciaCardiaca,
                          medicion: metricasService.frecuenciaCardiacaHoy,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterMetricInputScreen.frecuenciaCardiaca(),
                            ),
                          ),
                        ),
                        // 4. Peso
                        MetricCard(
                          categoria: CategoriaMetrica.peso,
                          medicion: metricasService.pesoHoy,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterMetricInputScreen.peso(),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ── Tarjeta de Recordatorio ─────────────────────────────
                    if (recordatorio != null && recordatorio.activo) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFDBEAFE),
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.notifications_none_rounded,
                              size: 24,
                              color: Color(0xFF2563EB),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                recordatorio.mensaje,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF1E40AF),
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

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

  /// Badge pequeño que indica si la app está conectada al servidor o en modo local
  Widget _buildConnectionBadge(MetricasService service) {
    if (service.isLoading) {
      return const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Color(0xFF2563EB),
        ),
      );
    }

    final isOnline = service.isOnline;
    return Tooltip(
      message: isOnline ? 'Conectado al servidor' : 'Modo local (${service.lastError ?? "sin conexión"})',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isOnline ? const Color(0xFFECFDF5) : const Color(0xFFFEF3C7),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isOnline ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
              size: 14,
              color: isOnline ? const Color(0xFF10B981) : const Color(0xFFD97706),
            ),
            const SizedBox(width: 4),
            Text(
              isOnline ? 'En línea' : 'Local',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isOnline ? const Color(0xFF10B981) : const Color(0xFFD97706),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
