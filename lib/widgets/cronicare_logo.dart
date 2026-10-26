import 'package:flutter/material.dart';

/// Logotipo vectorial de CroniCare que replica fielmente el diseño de la imagen:
/// Contenedor redondeado con gradiente azul, sombra difusa y corazón con onda ECG en color blanco.
class CroniCareLogo extends StatelessWidget {
  final double size;
  final bool showShadow;
  final BorderRadius? borderRadius;

  const CroniCareLogo({
    super.key,
    this.size = 84,
    this.showShadow = true,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(size * 0.28);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: const LinearGradient(
          colors: [
            Color(0xFF3B82F6), // Azul cielo vibrante superior
            Color(0xFF2563EB), // Azul rey CroniCare
            Color(0xFF1D4ED8), // Azul profundo inferior
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.38),
                  blurRadius: size * 0.22,
                  spreadRadius: 1,
                  offset: Offset(0, size * 0.10),
                ),
                BoxShadow(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.20),
                  blurRadius: size * 0.12,
                  offset: Offset(0, size * 0.04),
                ),
              ]
            : null,
      ),
      child: Center(
        child: CustomPaint(
          size: Size(size * 0.62, size * 0.62),
          painter: _HeartPulsePainter(),
        ),
      ),
    );
  }
}

/// Dibuja el corazón blanco con la línea de pulso cardíaco (ECG) recortada en el centro.
class _HeartPulsePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Pintura blanca para el corazón
    final heartPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Pintura para la línea de pulso ECG (gruesa, con extremos y uniones redondeadas)
    final pulsePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.105
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    // 1. Silueta superior del corazón (los dos lóbulos superiores)
    final topPath = Path();
    topPath.moveTo(w * 0.50, h * 0.32);
    // Lóbulo izquierdo
    topPath.cubicTo(
      w * 0.40, h * 0.12,
      w * 0.10, h * 0.12,
      w * 0.10, h * 0.38,
    );
    topPath.cubicTo(
      w * 0.10, h * 0.48,
      w * 0.18, h * 0.54,
      w * 0.24, h * 0.54,
    );
    topPath.lineTo(w * 0.76, h * 0.54);
    // Lóbulo derecho
    topPath.cubicTo(
      w * 0.82, h * 0.54,
      w * 0.90, h * 0.48,
      w * 0.90, h * 0.38,
    );
    topPath.cubicTo(
      w * 0.90, h * 0.12,
      w * 0.60, h * 0.12,
      w * 0.50, h * 0.32,
    );
    topPath.close();

    // 2. Silueta inferior del corazón (punta inferior)
    final bottomPath = Path();
    bottomPath.moveTo(w * 0.18, h * 0.58);
    bottomPath.lineTo(w * 0.82, h * 0.58);
    bottomPath.cubicTo(
      w * 0.78, h * 0.70,
      w * 0.62, h * 0.82,
      w * 0.50, h * 0.94,
    );
    bottomPath.cubicTo(
      w * 0.38, h * 0.82,
      w * 0.22, h * 0.70,
      w * 0.18, h * 0.58,
    );
    bottomPath.close();

    // Dibujar ambas mitades del corazón
    canvas.drawPath(topPath, heartPaint);
    canvas.drawPath(bottomPath, heartPaint);

    // 3. Trazado de la onda del electrocardiograma (ECG)
    final pulsePath = Path();
    pulsePath.moveTo(w * 0.08, h * 0.56);
    pulsePath.lineTo(w * 0.32, h * 0.56);
    pulsePath.lineTo(w * 0.41, h * 0.40);
    pulsePath.lineTo(w * 0.52, h * 0.74);
    pulsePath.lineTo(w * 0.61, h * 0.34);
    pulsePath.lineTo(w * 0.69, h * 0.56);
    pulsePath.lineTo(w * 0.92, h * 0.56);

    canvas.drawPath(pulsePath, pulsePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
