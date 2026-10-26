import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../models/metrica_tipo.dart';
import '../services/metricas_service.dart';

/// Pantalla dedicada para registrar una métrica individual.
///
/// Diseñada con el mismo lenguaje visual de CroniCare:
/// - Un único input central, grande y fácil de entender.
/// - Identidad de color e ícono según la métrica.
/// - Retroalimentación visual inmediata del rango clínico (según `metricas` de SQL).
/// - Botón principal accesible y confirmación rápida.
class RegisterMetricInputScreen extends StatefulWidget {
  final CategoriaMetrica categoria;

  const RegisterMetricInputScreen({
    super.key,
    required this.categoria,
  });

  // Constructores nombrados convenientes para cada métrica
  const RegisterMetricInputScreen.glucosa({super.key})
      : categoria = CategoriaMetrica.glucosa;

  const RegisterMetricInputScreen.presion({super.key})
      : categoria = CategoriaMetrica.presion;

  const RegisterMetricInputScreen.frecuenciaCardiaca({super.key})
      : categoria = CategoriaMetrica.frecuenciaCardiaca;

  const RegisterMetricInputScreen.peso({super.key})
      : categoria = CategoriaMetrica.peso;

  @override
  State<RegisterMetricInputScreen> createState() =>
      _RegisterMetricInputScreenState();
}

class _RegisterMetricInputScreenState extends State<RegisterMetricInputScreen> {
  final _inputCtrl = TextEditingController();
  final _focusNode = FocusNode();
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Sugerencia de valor inicial para agilizar la interacción
    switch (widget.categoria) {
      case CategoriaMetrica.glucosa:
        _inputCtrl.text = '95';
        break;
      case CategoriaMetrica.presion:
        _inputCtrl.text = '120/80';
        break;
      case CategoriaMetrica.frecuenciaCardiaca:
        _inputCtrl.text = '72';
        break;
      case CategoriaMetrica.peso:
        _inputCtrl.text = '70.5';
        break;
    }

    _inputCtrl.addListener(() {
      if (_errorMessage != null) {
        setState(() => _errorMessage = null);
      } else {
        setState(() {}); // Actualiza feedback de rango en vivo
      }
    });

    // Autofocus en el campo numérico
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      _inputCtrl.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _inputCtrl.text.length,
      );
    });
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────
  // Guardar Medición
  // ─────────────────────────────────────────────────────────────
  Future<void> _guardar() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) {
      setState(() => _errorMessage = 'Por favor ingresa un valor');
      return;
    }

    int tipoMetricaId;
    double valor = 0.0;
    double? valorSecundario;

    switch (widget.categoria) {
      case CategoriaMetrica.glucosa:
        tipoMetricaId = TipoMetrica.glucosa.id;
        final v = double.tryParse(text);
        if (v == null || v <= 0) {
          setState(() => _errorMessage = 'Ingresa un nivel de glucosa válido');
          return;
        }
        valor = v;
        break;

      case CategoriaMetrica.presion:
        tipoMetricaId = TipoMetrica.presionSistolica.id;
        // Soporta formatos "120/80" o "120 80"
        final cleaned = text.replaceAll(' ', '/');
        final parts = cleaned.split('/');
        final sis = double.tryParse(parts[0].trim());
        final dia = parts.length > 1 ? double.tryParse(parts[1].trim()) : 80.0;

        if (sis == null || sis < 50 || sis > 260) {
          setState(() => _errorMessage = 'Presión inválida. Usa formato 120/80');
          return;
        }
        if (dia == null || dia < 30 || dia > 150) {
          setState(() => _errorMessage = 'Diastólica inválida. Usa formato 120/80');
          return;
        }
        valor = sis;
        valorSecundario = dia;
        break;

      case CategoriaMetrica.frecuenciaCardiaca:
        tipoMetricaId = TipoMetrica.frecuenciaCardiaca.id;
        final v = double.tryParse(text);
        if (v == null || v < 30 || v > 240) {
          setState(() => _errorMessage = 'Ingresa una frecuencia válida (30 - 240)');
          return;
        }
        valor = v;
        break;

      case CategoriaMetrica.peso:
        tipoMetricaId = TipoMetrica.peso.id;
        final v = double.tryParse(text);
        if (v == null || v < 20 || v > 350) {
          setState(() => _errorMessage = 'Ingresa un peso válido en kg (20 - 350)');
          return;
        }
        valor = v;
        break;
    }

    setState(() => _isSaving = true);

    final success = await MetricasService().registrarNuevaMedicion(
      tipoMetricaId: tipoMetricaId,
      valor: valor,
      valorSecundario: valorSecundario,
      fechaRegistro: DateTime.now(),
      notas: 'Registro rápido desde la app',
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      final isOnline = MetricasService().isOnline;
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isOnline ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isOnline
                      ? 'Medición de ${widget.categoria.label} guardada en el servidor'
                      : 'Medición de ${widget.categoria.label} guardada localmente',
                ),
              ),
            ],
          ),
          backgroundColor: isOnline ? const Color(0xFF10B981) : const Color(0xFFD97706),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              const Expanded(
                child: Text('Error al guardar la medición. Intenta de nuevo.'),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      );
    }
  }

  // ─────────────────────────────────────────────────────────────
  // Interfaz de Usuario
  // ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final meta = _getMetricaMeta(widget.categoria);
    final nowFormatted = DateFormat('hh:mm a', 'es').format(DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF1E3A8A),
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
            tooltip: 'Regresar',
          ),
        ),
        title: Text(
          'Registrar ${widget.categoria.label}',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E3A8A),
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 12),

                    // ── Ícono de cabecera con color de la métrica ───
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: meta.iconBgColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: meta.iconColor.withValues(alpha: 0.15),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        meta.icon,
                        size: 36,
                        color: meta.iconColor,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ── Título descriptivo ──────────────────────────
                    Text(
                      meta.questionTitle,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                        letterSpacing: -0.3,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 6),

                    Text(
                      meta.instructionSubtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 32),

                    // ── Tarjeta del Input Único ─────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 28,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: _errorMessage != null
                              ? Colors.redAccent.withValues(alpha: 0.5)
                              : meta.accentBorderColor,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Campo de entrada principal
                          TextField(
                            controller: _inputCtrl,
                            focusNode: _focusNode,
                            textAlign: TextAlign.center,
                            keyboardType: meta.keyboardType,
                            inputFormatters: meta.inputFormatters,
                            style: TextStyle(
                              fontSize: widget.categoria == CategoriaMetrica.presion ? 40 : 48,
                              fontWeight: FontWeight.bold,
                              color: meta.valueTextColor,
                              letterSpacing: -0.5,
                            ),
                            decoration: InputDecoration(
                              hintText: meta.hintText,
                              hintStyle: TextStyle(
                                fontSize: widget.categoria == CategoriaMetrica.presion ? 40 : 48,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFCBD5E1),
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),

                          const SizedBox(height: 4),

                          // Etiqueta de la unidad
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: meta.iconBgColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              widget.categoria.unidad,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: meta.iconColor,
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Indicador de rango clínico en vivo
                          _buildLiveFeedbackBadge(meta),
                        ],
                      ),
                    ),

                    if (_errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.info_outline_rounded,
                              size: 16, color: Colors.redAccent),
                          const SizedBox(width: 6),
                          Text(
                            _errorMessage!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.redAccent,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 24),

                    // ── Pill con hora automática de registro ────────
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            size: 15,
                            color: Color(0xFF64748B),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Registro de Hoy a las $nowFormatted',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // ── Botón Inferior Fijo ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  onPressed: _isSaving ? null : _guardar,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Guardar Medición',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Badge dinámico que muestra si el valor ingresado se encuentra
  /// dentro de los rangos definidos en la base de datos `metricas`.
  Widget _buildLiveFeedbackBadge(_MetricaMeta meta) {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) {
      return Text(
        meta.rangoSugeridoText,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF94A3B8),
        ),
      );
    }

    bool isNormal = true;
    String feedbackText = meta.rangoSugeridoText;

    if (widget.categoria == CategoriaMetrica.glucosa) {
      final v = double.tryParse(text);
      if (v != null) {
        if (v >= 70 && v <= 100) {
          isNormal = true;
          feedbackText = '✅ Nivel óptimo en ayunas (70 - 100 mg/dL)';
        } else if (v > 100 && v <= 125) {
          isNormal = false;
          feedbackText = '⚠️ Nivel ligeramente elevado (101 - 125 mg/dL)';
        } else if (v > 125) {
          isNormal = false;
          feedbackText = '⚠️ Nivel alto (Mayor a 125 mg/dL)';
        } else {
          isNormal = false;
          feedbackText = '⚠️ Nivel bajo (Menor a 70 mg/dL)';
        }
      }
    } else if (widget.categoria == CategoriaMetrica.presion) {
      final parts = text.split('/');
      final sis = double.tryParse(parts[0]);
      final dia = parts.length > 1 ? double.tryParse(parts[1]) : 80.0;
      if (sis != null) {
        if (sis <= 120 && (dia ?? 80) <= 80) {
          isNormal = true;
          feedbackText = '✅ Presión dentro del rango ideal (120/80 mmHg)';
        } else {
          isNormal = false;
          feedbackText = '⚠️ Presión por encima del rango ideal';
        }
      }
    } else if (widget.categoria == CategoriaMetrica.frecuenciaCardiaca) {
      final v = double.tryParse(text);
      if (v != null) {
        if (v >= 60 && v <= 100) {
          isNormal = true;
          feedbackText = '✅ Ritmo cardíaco normal (60 - 100 lpm)';
        } else {
          isNormal = false;
          feedbackText = '⚠️ Frecuencia fuera del rango normal';
        }
      }
    } else if (widget.categoria == CategoriaMetrica.peso) {
      isNormal = true;
      feedbackText = '⚖️ Registro de peso corporal';
    }

    final color = isNormal ? const Color(0xFF10B981) : const Color(0xFFD97706);
    final bgColor = isNormal ? const Color(0xFFECFDF5) : const Color(0xFFFFFBEB);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        feedbackText,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Metadatos por categoría
  // ─────────────────────────────────────────────────────────────
  _MetricaMeta _getMetricaMeta(CategoriaMetrica cat) {
    switch (cat) {
      case CategoriaMetrica.glucosa:
        return _MetricaMeta(
          icon: Icons.water_drop_outlined,
          iconBgColor: const Color(0xFFE0F2FE),
          iconColor: const Color(0xFF2563EB),
          accentBorderColor: const Color(0xFFBAE6FD),
          valueTextColor: const Color(0xFF1E293B),
          questionTitle: '¿Cuál es tu nivel de glucosa?',
          instructionSubtitle:
              'Ingresa la lectura actual obtenida en tu glucómetro.',
          hintText: '95',
          rangoSugeridoText: 'Rango normal sugerido: 70 – 100 mg/dL',
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(3),
          ],
        );

      case CategoriaMetrica.presion:
        return _MetricaMeta(
          icon: Icons.show_chart_rounded,
          iconBgColor: const Color(0xFFFFECEB),
          iconColor: const Color(0xFFEA580C),
          accentBorderColor: const Color(0xFFFED7AA),
          valueTextColor: const Color(0xFFEA580C),
          questionTitle: '¿Cuál es tu presión arterial?',
          instructionSubtitle:
              'Ingresa tu presión sistólica y diastólica (ejemplo: 120/80).',
          hintText: '120/80',
          rangoSugeridoText: 'Rango normal sugerido: 120/80 mmHg',
          keyboardType: TextInputType.datetime,
          inputFormatters: [
            _PresionInputFormatter(),
          ],
        );

      case CategoriaMetrica.frecuenciaCardiaca:
        return _MetricaMeta(
          icon: Icons.favorite_border_rounded,
          iconBgColor: const Color(0xFFFCE7F3),
          iconColor: const Color(0xFFEC4899),
          accentBorderColor: const Color(0xFFFBCFE8),
          valueTextColor: const Color(0xFF1E293B),
          questionTitle: '¿Cuál es tu frecuencia cardíaca?',
          instructionSubtitle:
              'Ingresa tus pulsaciones o latidos por minuto en reposo.',
          hintText: '72',
          rangoSugeridoText: 'Rango normal sugerido: 60 – 100 lpm',
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(3),
          ],
        );

      case CategoriaMetrica.peso:
        return _MetricaMeta(
          icon: Icons.balance_rounded,
          iconBgColor: const Color(0xFFD1FAE5),
          iconColor: const Color(0xFF10B981),
          accentBorderColor: const Color(0xFFA7F3D0),
          valueTextColor: const Color(0xFF1E293B),
          questionTitle: '¿Cuál es tu peso actual?',
          instructionSubtitle:
              'Ingresa tu peso en kilogramos con o sin decimales.',
          hintText: '70.5',
          rangoSugeridoText: 'Registra tu peso corporal en kg',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            LengthLimitingTextInputFormatter(5),
          ],
        );
    }
  }
}

class _MetricaMeta {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final Color accentBorderColor;
  final Color valueTextColor;
  final String questionTitle;
  final String instructionSubtitle;
  final String hintText;
  final String rangoSugeridoText;
  final TextInputType keyboardType;
  final List<TextInputFormatter> inputFormatters;

  const _MetricaMeta({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.accentBorderColor,
    required this.valueTextColor,
    required this.questionTitle,
    required this.instructionSubtitle,
    required this.hintText,
    required this.rangoSugeridoText,
    required this.keyboardType,
    required this.inputFormatters,
  });
}

/// Formateador automático inteligente para presión arterial (ej. "120/80")
class _PresionInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text.replaceAll(RegExp(r'[^0-9/]'), '');

    // Si escribe 3 dígitos seguidos sin barra, agrega automáticamente la barra '/'
    if (text.length == 3 && !text.contains('/') && !oldValue.text.contains('/')) {
      text = '$text/';
    } else if (text.length > 3 && !text.contains('/')) {
      text = '${text.substring(0, 3)}/${text.substring(3)}';
    }

    if (text.length > 7) {
      text = text.substring(0, 7);
    }

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
