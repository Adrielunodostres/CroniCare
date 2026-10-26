import 'package:flutter/material.dart';
import '../models/medicion_model.dart';
import '../models/metrica_tipo.dart';

/// Tarjeta de elemento de historial de medición según el diseño de "Mi Historial".
class HistoryCard extends StatelessWidget {
  final MedicionModel medicion;
  final VoidCallback? onTap;

  const HistoryCard({
    super.key,
    required this.medicion,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final visual = _getVisualProps(medicion);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF1F5F9),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Ícono circular coloreado
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: visual.bgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    visual.icon,
                    size: 22,
                    color: visual.iconColor,
                  ),
                ),

                const SizedBox(width: 14),

                // Textos centrales (Nombre y fecha)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medicion.titulo,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        medicion.fechaFormateadaRelativa,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),

                // Valor y unidad a la derecha
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      medicion.valorFormateado,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: visual.valueColor,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      medicion.unidad,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _HistoryVisual _getVisualProps(MedicionModel m) {
    switch (m.categoria) {
      case CategoriaMetrica.glucosa:
        if (m.esAlerta) {
          // Valor alto de glucosa (ej. 110 mg/dL de la captura)
          return const _HistoryVisual(
            icon: Icons.water_drop_outlined,
            bgColor: Color(0xFFFEF3C7),
            iconColor: Color(0xFFD97706),
            valueColor: Color(0xFFD97706),
          );
        }
        return const _HistoryVisual(
          icon: Icons.water_drop_outlined,
          bgColor: Color(0xFFE0F2FE),
          iconColor: Color(0xFF2563EB),
          valueColor: Color(0xFF1E293B),
        );

      case CategoriaMetrica.presion:
        // Presión arterial destacada en naranja
        return const _HistoryVisual(
          icon: Icons.show_chart_rounded,
          bgColor: Color(0xFFFFEDD5),
          iconColor: Color(0xFFF97316),
          valueColor: Color(0xFFEA580C),
        );

      case CategoriaMetrica.frecuenciaCardiaca:
        return const _HistoryVisual(
          icon: Icons.favorite_border_rounded,
          bgColor: Color(0xFFFCE7F3),
          iconColor: Color(0xFFEC4899),
          valueColor: Color(0xFF1E293B),
        );

      case CategoriaMetrica.peso:
        return const _HistoryVisual(
          icon: Icons.balance_rounded,
          bgColor: Color(0xFFD1FAE5),
          iconColor: Color(0xFF10B981),
          valueColor: Color(0xFF1E293B),
        );
    }
  }
}

class _HistoryVisual {
  final IconData icon;
  final Color bgColor;
  final Color iconColor;
  final Color valueColor;

  const _HistoryVisual({
    required this.icon,
    required this.bgColor,
    required this.iconColor,
    required this.valueColor,
  });
}
