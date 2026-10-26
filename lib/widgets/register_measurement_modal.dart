import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../models/metrica_tipo.dart';
import '../services/metricas_service.dart';

/// Modal Bottom Sheet para ingresar una nueva medición de salud.
///
/// Prepara todos los campos necesarios según la tabla `metricas_pacientes`
/// y guarda en el estado local de [MetricasService] listo para la conexión backend.
class RegisterMeasurementModal extends StatefulWidget {
  final CategoriaMetrica categoria;

  const RegisterMeasurementModal({
    super.key,
    required this.categoria,
  });

  static Future<bool?> show(BuildContext context, CategoriaMetrica categoria) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => RegisterMeasurementModal(categoria: categoria),
    );
  }

  @override
  State<RegisterMeasurementModal> createState() => _RegisterMeasurementModalState();
}

class _RegisterMeasurementModalState extends State<RegisterMeasurementModal> {
  final _formKey = GlobalKey<FormState>();

  final _valorCtrl = TextEditingController();
  final _diastolicaCtrl = TextEditingController();
  final _notasCtrl = TextEditingController();

  DateTime _fecha = DateTime.now();
  TimeOfDay _hora = TimeOfDay.now();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Valores de ejemplo según la categoría
    switch (widget.categoria) {
      case CategoriaMetrica.glucosa:
        _valorCtrl.text = '95';
        break;
      case CategoriaMetrica.presion:
        _valorCtrl.text = '120';
        _diastolicaCtrl.text = '80';
        break;
      case CategoriaMetrica.frecuenciaCardiaca:
        _valorCtrl.text = '72';
        break;
      case CategoriaMetrica.peso:
        _valorCtrl.text = '70.5';
        break;
    }
  }

  @override
  void dispose() {
    _valorCtrl.dispose();
    _diastolicaCtrl.dispose();
    _notasCtrl.dispose();
    super.dispose();
  }

  DateTime get _fechaHoraCompleta {
    return DateTime(
      _fecha.year,
      _fecha.month,
      _fecha.day,
      _hora.hour,
      _hora.minute,
    );
  }

  Future<void> _pickFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );
    if (picked != null) {
      setState(() => _fecha = picked);
    }
  }

  Future<void> _pickHora() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _hora,
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );
    if (picked != null) {
      setState(() => _hora = picked);
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    int tipoMetricaId;
    double? valorSecundario;

    switch (widget.categoria) {
      case CategoriaMetrica.presion:
        tipoMetricaId = TipoMetrica.presionSistolica.id;
        valorSecundario = double.tryParse(_diastolicaCtrl.text.trim());
        break;
      case CategoriaMetrica.glucosa:
        tipoMetricaId = TipoMetrica.glucosa.id;
        break;
      case CategoriaMetrica.frecuenciaCardiaca:
        tipoMetricaId = TipoMetrica.frecuenciaCardiaca.id;
        break;
      case CategoriaMetrica.peso:
        tipoMetricaId = TipoMetrica.peso.id;
        break;
    }

    final double valor = double.tryParse(_valorCtrl.text.trim()) ?? 0.0;

    final success = await MetricasService().registrarNuevaMedicion(
      tipoMetricaId: tipoMetricaId,
      valor: valor,
      valorSecundario: valorSecundario,
      fechaRegistro: _fechaHoraCompleta,
      notas: _notasCtrl.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Medición de ${widget.categoria.label} guardada exitosamente!'),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Error al guardar la medición'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: bottomInset + 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Barra pequeña superior de arrastre
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Encabezado
              Row(
                children: [
                  _buildHeaderIcon(widget.categoria),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Registrar ${widget.categoria.label}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E3A8A),
                          ),
                        ),
                        Text(
                          'Ingresa tu medición en ${widget.categoria.unidad}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Campos según la categoría
              if (widget.categoria == CategoriaMetrica.presion) ...[
                Row(
                  children: [
                    Expanded(
                      child: _buildInputField(
                        label: 'Sistólica (Alta)',
                        controller: _valorCtrl,
                        suffixText: 'mmHg',
                        hintText: '120',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInputField(
                        label: 'Diastólica (Baja)',
                        controller: _diastolicaCtrl,
                        suffixText: 'mmHg',
                        hintText: '80',
                      ),
                    ),
                  ],
                ),
              ] else ...[
                _buildInputField(
                  label: 'Valor (${widget.categoria.unidad})',
                  controller: _valorCtrl,
                  suffixText: widget.categoria.unidad,
                  hintText: '0.0',
                  isDecimal: widget.categoria == CategoriaMetrica.peso,
                ),
              ],

              const SizedBox(height: 16),

              // Selectores de Fecha y Hora
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _pickFecha,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded, size: 18, color: Color(0xFF2563EB)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                DateFormat('dd/MM/yyyy').format(_fecha),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF334155),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: _pickHora,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time_rounded, size: 18, color: Color(0xFF2563EB)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _hora.format(context),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF334155),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Campo de notas (opcional)
              TextFormField(
                controller: _notasCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Notas u observaciones (opcional)',
                  hintText: 'Ej. En ayunas, después de comer, mareo...',
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Botón Guardar Medición
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _isSaving ? null : _guardar,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String suffixText,
    required String hintText,
    bool isDecimal = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: isDecimal),
      inputFormatters: [
        if (!isDecimal)
          FilteringTextInputFormatter.digitsOnly
        else
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      validator: (val) {
        if (val == null || val.trim().isEmpty) return 'Requerido';
        if (double.tryParse(val) == null) return 'Inválido';
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        suffixText: suffixText,
        suffixStyle: const TextStyle(
          color: Color(0xFF64748B),
          fontWeight: FontWeight.w600,
        ),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildHeaderIcon(CategoriaMetrica cat) {
    switch (cat) {
      case CategoriaMetrica.glucosa:
        return Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: Color(0xFFE0F2FE),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.water_drop_outlined, color: Color(0xFF2563EB), size: 24),
        );
      case CategoriaMetrica.presion:
        return Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: Color(0xFFFFECEB),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.show_chart_rounded, color: Color(0xFFEA580C), size: 24),
        );
      case CategoriaMetrica.frecuenciaCardiaca:
        return Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: Color(0xFFFCE7F3),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.favorite_border_rounded, color: Color(0xFFEC4899), size: 24),
        );
      case CategoriaMetrica.peso:
        return Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: Color(0xFFD1FAE5),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.balance_rounded, color: Color(0xFF10B981), size: 24),
        );
    }
  }
}
