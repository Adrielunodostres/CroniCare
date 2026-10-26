import 'package:flutter/material.dart';
import '../models/medicion_model.dart';
import '../models/metrica_tipo.dart';

/// Tarjeta de métrica individual para el grid 2x2 de la pantalla "Mi Salud Hoy".
class MetricCard extends StatelessWidget {
  final CategoriaMetrica categoria;
  final MedicionModel? medicion;
  final VoidCallback? onTap;

  const MetricCard({
    super.key,
    required this.categoria,
    this.medicion,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Configuración visual según categoría
    final _VisualConfig config = _getConfig(categoria, medicion);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: config.borderColor,
            width: config.hasAccentBorder ? 1.4 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.025),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Fila superior: Ícono y Nombre de la métrica
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: config.iconBgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    config.icon,
                    size: 19,
                    color: config.iconColor,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    config.label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF334155),
                      height: 1.15,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            // Fila de Valor y Unidad
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  medicion != null ? medicion!.valorFormateado : '--',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: config.valueColor,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  categoria.unidad,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),

            // Fila inferior: Timestamp
            Row(
              children: [
                if (config.showClockIcon) ...[
                  Icon(
                    Icons.access_time_rounded,
                    size: 13,
                    color: config.clockColor,
                  ),
                  const SizedBox(width: 3),
                ],
                Text(
                  medicion != null ? medicion!.tiempoResumenDashboard : 'Sin registro',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: config.showClockIcon ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _VisualConfig _getConfig(CategoriaMetrica cat, MedicionModel? m) {
    switch (cat) {
      case CategoriaMetrica.glucosa:
        final esAlerta = m != null && m.esAlerta;
        return _VisualConfig(
          label: 'Glucosa',
          icon: Icons.water_drop_outlined,
          iconBgColor: esAlerta ? const Color(0xFFFEF3C7) : const Color(0xFFE0F2FE),
          iconColor: esAlerta ? const Color(0xFFD97706) : const Color(0xFF0284C7),
          valueColor: esAlerta ? const Color(0xFFD97706) : const Color(0xFF1E293B),
          borderColor: esAlerta ? const Color(0xFFFDE68A) : const Color(0xFFF1F5F9),
          hasAccentBorder: esAlerta,
          showClockIcon: false,
        );

      case CategoriaMetrica.presion:
        // En la captura tiene borde cálido y valor en naranja
        return const _VisualConfig(
          label: 'Presión',
          icon: Icons.show_chart_rounded,
          iconBgColor: Color(0xFFFFF7ED),
          iconColor: Color(0xFFEA580C),
          valueColor: Color(0xFFEA580C),
          borderColor: Color(0xFFFED7AA),
          hasAccentBorder: true,
          showClockIcon: true,
          clockColor: Color(0xFFEA580C),
        );

      case CategoriaMetrica.frecuenciaCardiaca:
        return const _VisualConfig(
          label: 'Frec.\nCardiaca',
          icon: Icons.favorite_border_rounded,
          iconBgColor: Color(0xFFFCE7F3),
          iconColor: Color(0xFFEC4899),
          valueColor: Color(0xFF1E293B),
          borderColor: Color(0xFFF1F5F9),
          hasAccentBorder: false,
          showClockIcon: false,
        );

      case CategoriaMetrica.peso:
        return const _VisualConfig(
          label: 'Peso',
          icon: Icons.balance_rounded,
          iconBgColor: Color(0xFFD1FAE5),
          iconColor: Color(0xFF10B981),
          valueColor: Color(0xFF1E293B),
          borderColor: Color(0xFFF1F5F9),
          hasAccentBorder: false,
          showClockIcon: false,
        );
    }
  }
}

class _VisualConfig {
  final String label;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final Color valueColor;
  final Color borderColor;
  final bool hasAccentBorder;
  final bool showClockIcon;
  final Color clockColor;

  const _VisualConfig({
    required this.label,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.valueColor,
    required this.borderColor,
    this.hasAccentBorder = false,
    this.showClockIcon = false,
    this.clockColor = const Color(0xFF94A3B8),
  });
}
