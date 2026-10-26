import 'package:flutter/material.dart';

import '../models/metrica_tipo.dart';
import 'register_metric_input_screen.dart';

/// Pantalla "Registrar Medición" correspondiente a la segunda captura.
class RegisterMeasurementScreen extends StatelessWidget {
  final ValueChanged<int>? onNavigateTab;

  const RegisterMeasurementScreen({
    super.key,
    this.onNavigateTab,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // ── Título Superior ─────────────────────────────────────
              const Text(
                'Registrar Medición',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 36),

              // ── Subtítulo / Pregunta ────────────────────────────────
              const Center(
                child: Text(
                  '¿Qué deseas registrar?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ── Opciones de medición ────────────────────────────────
              _buildOptionCard(
                context: context,
                categoria: CategoriaMetrica.glucosa,
                label: 'Glucosa',
                icon: Icons.water_drop_outlined,
                iconBgColor: const Color(0xFFE0F2FE),
                iconColor: const Color(0xFF2563EB),
              ),

              const SizedBox(height: 16),

              _buildOptionCard(
                context: context,
                categoria: CategoriaMetrica.presion,
                label: 'Presión',
                icon: Icons.show_chart_rounded,
                iconBgColor: const Color(0xFFFFECEB),
                iconColor: const Color(0xFFEA580C),
              ),

              const SizedBox(height: 16),

              _buildOptionCard(
                context: context,
                categoria: CategoriaMetrica.frecuenciaCardiaca,
                label: 'Frec. Cardiaca',
                icon: Icons.favorite_border_rounded,
                iconBgColor: const Color(0xFFFCE7F3),
                iconColor: const Color(0xFFEC4899),
              ),

              const SizedBox(height: 16),

              _buildOptionCard(
                context: context,
                categoria: CategoriaMetrica.peso,
                label: 'Peso',
                icon: Icons.balance_rounded,
                iconBgColor: const Color(0xFFD1FAE5),
                iconColor: const Color(0xFF10B981),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required BuildContext context,
    required CategoriaMetrica categoria,
    required String label,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
  }) {
    return Container(
      height: 74,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFF1F5F9),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            final saved = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (_) => RegisterMetricInputScreen(categoria: categoria),
              ),
            );
            if (saved == true && onNavigateTab != null) {
              // Navegar al historial para ver el resultado
              onNavigateTab!(1);
            }
          },
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Ícono circular
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 24,
                    color: iconColor,
                  ),
                ),

                const SizedBox(width: 16),

                // Nombre de la métrica
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),

                // Flecha chevron a la derecha
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF94A3B8),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
