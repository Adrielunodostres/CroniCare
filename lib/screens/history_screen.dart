import 'package:flutter/material.dart';

import '../models/metrica_tipo.dart';
import '../services/metricas_service.dart';
import '../widgets/history_card.dart';
import 'register_metric_input_screen.dart';

/// Pantalla "Mi Historial" correspondiente a la tercera captura.
///
/// Carga las mediciones desde el backend Laravel (`GET /api/metricas-pacientes`)
/// al iniciarse. Incluye pull-to-refresh y un botón de recarga manual.
/// Si el servidor no está disponible, muestra los datos locales del servicio.
class HistoryScreen extends StatefulWidget {
  final ValueChanged<int>? onNavigateTab;

  const HistoryScreen({
    super.key,
    this.onNavigateTab,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // Filtro activo: null = "Todos"
  CategoriaMetrica? _filtroSeleccionado;
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    _cargarHistorial();
  }

  Future<void> _cargarHistorial() async {
    final metricasService = MetricasService();
    await metricasService.cargarHistorialDesdeServidor();
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
        final mediciones = metricasService.filtrarHistorial(_filtroSeleccionado);

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Encabezado fijo ───────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Mi Historial',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A8A),
                          letterSpacing: -0.5,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Indicador de conexión
                          _buildMiniConnectionBadge(metricasService),
                          const SizedBox(width: 4),
                          // Botón para refrescar
                          IconButton(
                            onPressed: metricasService.isLoading
                                ? null
                                : () async {
                                    await metricasService.cargarHistorialDesdeServidor();
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            Icon(
                                              metricasService.isOnline
                                                  ? Icons.cloud_done_rounded
                                                  : Icons.cloud_off_rounded,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              metricasService.isOnline
                                                  ? 'Historial sincronizado con el servidor'
                                                  : 'Sin conexión — mostrando datos locales',
                                            ),
                                          ],
                                        ),
                                        backgroundColor: metricasService.isOnline
                                            ? const Color(0xFF10B981)
                                            : const Color(0xFFD97706),
                                        duration: const Duration(seconds: 2),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    );
                                  },
                            icon: metricasService.isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF64748B),
                                    ),
                                  )
                                : const Icon(
                                    Icons.refresh_rounded,
                                    color: Color(0xFF64748B),
                                  ),
                            tooltip: 'Recargar desde servidor',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ── Barra de carga durante sincronización ─────────────
                if (_isFirstLoad && metricasService.isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: LinearProgressIndicator(
                      color: Color(0xFF2563EB),
                      backgroundColor: Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                  ),

                const SizedBox(height: 10),

                // ── Filtros horizontales (Chips) ──────────────────────
                SizedBox(
                  height: 42,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      _buildFilterChip(
                        label: 'Todos',
                        isSelected: _filtroSeleccionado == null,
                        onTap: () => setState(() => _filtroSeleccionado = null),
                      ),
                      const SizedBox(width: 10),
                      _buildFilterChip(
                        label: 'Glucosa',
                        isSelected: _filtroSeleccionado == CategoriaMetrica.glucosa,
                        onTap: () => setState(
                          () => _filtroSeleccionado = CategoriaMetrica.glucosa,
                        ),
                      ),
                      const SizedBox(width: 10),
                      _buildFilterChip(
                        label: 'Presión',
                        isSelected: _filtroSeleccionado == CategoriaMetrica.presion,
                        onTap: () => setState(
                          () => _filtroSeleccionado = CategoriaMetrica.presion,
                        ),
                      ),
                      const SizedBox(width: 10),
                      _buildFilterChip(
                        label: 'Frec. Cardiaca',
                        isSelected: _filtroSeleccionado == CategoriaMetrica.frecuenciaCardiaca,
                        onTap: () => setState(
                          () => _filtroSeleccionado = CategoriaMetrica.frecuenciaCardiaca,
                        ),
                      ),
                      const SizedBox(width: 10),
                      _buildFilterChip(
                        label: 'Peso',
                        isSelected: _filtroSeleccionado == CategoriaMetrica.peso,
                        onTap: () => setState(
                          () => _filtroSeleccionado = CategoriaMetrica.peso,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Lista de historial ────────────────────────────────
                Expanded(
                  child: mediciones.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: _cargarHistorial,
                          color: const Color(0xFF2563EB),
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                            itemCount: mediciones.length,
                            itemBuilder: (context, index) {
                              final m = mediciones[index];
                              return Dismissible(
                                key: ValueKey(m.id ?? index),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.only(right: 20),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEF4444),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    Icons.delete_outline_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                confirmDismiss: (_) => _confirmarEliminacion(m),
                                onDismissed: (_) {
                                  if (m.id != null) {
                                    MetricasService().eliminarMedicion(m.id!);
                                  }
                                },
                                child: HistoryCard(
                                  medicion: m,
                                  onTap: () {
                                    _mostrarDetalleMedicion(m);
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMiniConnectionBadge(MetricasService service) {
    if (service.isLoading) return const SizedBox.shrink();
    return Tooltip(
      message: service.isOnline
          ? 'Datos del servidor'
          : 'Datos locales (${service.lastError ?? "sin conexión"})',
      child: Icon(
        service.isOnline ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
        size: 16,
        color: service.isOnline ? const Color(0xFF10B981) : const Color(0xFFD97706),
      ),
    );
  }

  Future<bool?> _confirmarEliminacion(dynamic medicion) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar medición'),
        content: Text(
          '¿Estás seguro de eliminar esta medición de ${medicion.titulo}?\n\n'
          'Valor: ${medicion.valorFormateado} ${medicion.unidad}\n'
          'Fecha: ${medicion.fechaFormateadaRelativa}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFEF4444)),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2563EB) : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.assignment_late_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'No hay mediciones registradas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Registra tu primera medición tocando el botón "+".',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 20),
            if (_filtroSeleccionado != null)
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RegisterMetricInputScreen(
                        categoria: _filtroSeleccionado!,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.add_rounded),
                label: Text('Registrar ${_filtroSeleccionado!.label}'),
              ),
          ],
        ),
      ),
    );
  }

  void _mostrarDetalleMedicion(dynamic m) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Expanded(child: Text(m.titulo)),
            if (m.esAlerta)
              const Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706), size: 22),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Valor: ${m.valorFormateado} ${m.unidad}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text('Fecha: ${m.fechaFormateadaRelativa}'),
            if (m.notas != null && m.notas!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Notas: ${m.notas}',
                  style: const TextStyle(fontStyle: FontStyle.italic)),
            ],
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: m.esAlerta ? const Color(0xFFFFFBEB) : const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                m.esAlerta
                    ? '⚠️ Valor fuera del rango recomendado'
                    : '✅ Valor dentro de parámetros normales',
                style: TextStyle(
                  color: m.esAlerta ? const Color(0xFFD97706) : const Color(0xFF10B981),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        actions: [
          // Botón eliminar
          if (m.id != null)
            TextButton.icon(
              onPressed: () async {
                Navigator.pop(ctx);
                final confirmar = await _confirmarEliminacion(m);
                if (confirmar == true && m.id != null) {
                  MetricasService().eliminarMedicion(m.id!);
                }
              },
              icon: const Icon(Icons.delete_outline_rounded, size: 18),
              label: const Text('Eliminar'),
              style: TextButton.styleFrom(foregroundColor: const Color(0xFFEF4444)),
            ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
