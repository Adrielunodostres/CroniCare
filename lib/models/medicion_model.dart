import 'package:intl/intl.dart';
import 'metrica_tipo.dart';

/// Modelo para una medición de salud, correspondiente a la tabla `metricas_pacientes`
/// en la base de datos `pacientescronicos (1).sql`.
class MedicionModel {
  final int? id;
  final int pacienteId;
  final int tipoMetricaId;
  final double valor;
  /// Para presión arterial se suele almacenar la sistólica en [valor]
  /// y la diastólica en [valorSecundario].
  final double? valorSecundario;
  final DateTime fechaRegistro;
  final String? notas;

  const MedicionModel({
    this.id,
    required this.pacienteId,
    required this.tipoMetricaId,
    required this.valor,
    this.valorSecundario,
    required this.fechaRegistro,
    this.notas,
  });

  /// Determina la categoría general según el tipo de métrica
  CategoriaMetrica get categoria {
    switch (tipoMetricaId) {
      case 1:
      case 2:
        return CategoriaMetrica.presion;
      case 3:
        return CategoriaMetrica.glucosa;
      case 4:
        return CategoriaMetrica.peso;
      case 5:
        return CategoriaMetrica.frecuenciaCardiaca;
      default:
        return CategoriaMetrica.glucosa;
    }
  }

  /// Retorna el tipo de métrica
  TipoMetrica get tipoMetrica => TipoMetrica.fromId(tipoMetricaId);

  /// Retorna el valor formateado para la UI (ej. "125/82", "95", "70.5", "72")
  String get valorFormateado {
    if (categoria == CategoriaMetrica.presion) {
      final sis = valor.toInt();
      final dia = (valorSecundario ?? 80).toInt();
      return '$sis/$dia';
    } else if (categoria == CategoriaMetrica.peso) {
      return valor.toStringAsFixed(1);
    } else {
      return valor.toInt().toString();
    }
  }

  /// Unidad de medida según la métrica
  String get unidad {
    return categoria.unidad;
  }

  /// Nombre mostrado en la tarjeta (ej. "Glucosa", "Presión", "Frec. Cardiaca", "Peso")
  String get titulo {
    return categoria.label;
  }

  /// Retorna si el valor está fuera de rango normal según los límites en `metricas`
  bool get esAlerta {
    switch (categoria) {
      case CategoriaMetrica.glucosa:
        return valor < 70 || valor > 100;
      case CategoriaMetrica.presion:
        final sis = valor;
        final dia = valorSecundario ?? 80.0;
        return sis > 120 || dia > 80 || sis < 90 || dia < 60;
      case CategoriaMetrica.frecuenciaCardiaca:
        return valor < 60 || valor > 100;
      case CategoriaMetrica.peso:
        return false;
    }
  }

  static String _formatTime(DateTime dt) {
    try {
      return DateFormat('hh:mm a').format(dt);
    } catch (_) {
      final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
      final minute = dt.minute.toString().padLeft(2, '0');
      final period = dt.hour >= 12 ? 'PM' : 'AM';
      final hourStr = hour.toString().padLeft(2, '0');
      return '$hourStr:$minute $period';
    }
  }

  static String _formatShortDay(DateTime dt) {
    try {
      final dia = DateFormat('EEE', 'es').format(dt);
      return dia.isEmpty ? '' : '${dia[0].toUpperCase()}${dia.substring(1).replaceAll('.', '')}';
    } catch (_) {
      const dias = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
      return dias[dt.weekday - 1];
    }
  }

  /// Formatea la fecha al estilo visual visto en las capturas:
  /// "Hoy, 08:00 AM", "Ayer, 08:00 PM", "Lun, 08:00 AM" o "08:00 AM"
  String get fechaFormateadaRelativa {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(fechaRegistro.year, fechaRegistro.month, fechaRegistro.day);
    final timeStr = _formatTime(fechaRegistro);

    if (dateOnly == today) {
      return 'Hoy, $timeStr';
    } else if (dateOnly == today.subtract(const Duration(days: 1))) {
      return 'Ayer, $timeStr';
    } else {
      final dia = _formatShortDay(fechaRegistro);
      return '$dia, $timeStr';
    }
  }

  /// Formato de hora simple o relativo para las tarjetas compactas del dashboard:
  /// ej. "08:00 AM", "07:30 AM", "Ayer"
  String get tiempoResumenDashboard {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(fechaRegistro.year, fechaRegistro.month, fechaRegistro.day);

    if (dateOnly == today) {
      return _formatTime(fechaRegistro);
    } else if (dateOnly == today.subtract(const Duration(days: 1))) {
      return 'Ayer';
    } else {
      final day = fechaRegistro.day.toString().padLeft(2, '0');
      final month = fechaRegistro.month.toString().padLeft(2, '0');
      return '$day/$month';
    }
  }

  /// Serialización JSON adaptada a la API REST de Laravel (snake_case)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'paciente_id': pacienteId,
      'tipo_metrica_id': tipoMetricaId,
      'valor': valor,
      if (valorSecundario != null) 'valor_secundario': valorSecundario,
      'fecha_registro': fechaRegistro.toIso8601String(),
      if (notas != null) 'notas': notas,
    };
  }

  /// Deserialización desde JSON de Laravel
  factory MedicionModel.fromJson(Map<String, dynamic> json) {
    return MedicionModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? ''),
      pacienteId: json['paciente_id'] is int
          ? json['paciente_id'] as int
          : int.tryParse(json['paciente_id']?.toString() ?? '1') ?? 1,
      tipoMetricaId: json['tipo_metrica_id'] is int
          ? json['tipo_metrica_id'] as int
          : int.tryParse(json['tipo_metrica_id']?.toString() ?? '3') ?? 3,
      valor: (json['valor'] is num)
          ? (json['valor'] as num).toDouble()
          : double.tryParse(json['valor']?.toString() ?? '0.0') ?? 0.0,
      valorSecundario: json['valor_secundario'] != null
          ? ((json['valor_secundario'] is num)
              ? (json['valor_secundario'] as num).toDouble()
              : double.tryParse(json['valor_secundario'].toString()))
          : null,
      fechaRegistro: json['fecha_registro'] != null
          ? DateTime.tryParse(json['fecha_registro'].toString()) ?? DateTime.now()
          : DateTime.now(),
      notas: json['notas'] as String?,
    );
  }

  MedicionModel copyWith({
    int? id,
    int? pacienteId,
    int? tipoMetricaId,
    double? valor,
    double? valorSecundario,
    DateTime? fechaRegistro,
    String? notas,
  }) {
    return MedicionModel(
      id: id ?? this.id,
      pacienteId: pacienteId ?? this.pacienteId,
      tipoMetricaId: tipoMetricaId ?? this.tipoMetricaId,
      valor: valor ?? this.valor,
      valorSecundario: valorSecundario ?? this.valorSecundario,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      notas: notas ?? this.notas,
    );
  }
}
