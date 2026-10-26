import 'package:flutter/material.dart';

import '../models/metrica_tipo.dart';
import '../services/metricas_service.dart';
import '../widgets/history_card.dart';
import 'register_metric_input_screen.dart';

/// Pantalla "Mi Historial" correspondiente a la tercera captura.
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
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
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
                      // Botón para refrescar
                      IconButton(
                        onPressed: () {
                          metricasService.cargarHistorialDesdeServidor();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Historial sincronizado'),
                              duration: Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.refresh_rounded,
                          color: Color(0xFF64748B),
                        ),
                        tooltip: 'Recargar',
                      ),
                    ],
                  ),
                ),

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
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                          itemCount: mediciones.length,
                          itemBuilder: (context, index) {
                            final m = mediciones[index];
                            return HistoryCard(
                              medicion: m,
                              onTap: () {
                                _mostrarDetalleMedicion(m);
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
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
        title: Text(m.titulo),
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
            const SizedBox(height: 8),
            Text(
              m.esAlerta
                  ? '⚠️ Valor fuera del rango recomendado'
                  : '✅ Valor dentro de parámetros normales',
              style: TextStyle(
                color: m.esAlerta ? const Color(0xFFD97706) : const Color(0xFF10B981),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
