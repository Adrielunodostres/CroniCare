/// Modelo que representa la información de perfil del paciente,
/// integrando las tablas `pacientes` y `usuarios` de `pacientescronicos (1).sql`.
class PacienteModel {
  final int id;
  final int usuarioId;
  final String primerNombre;
  final String? segundoNombre;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String email;
  final String diagnosticoPrincipal;
  final String nivelRiesgo; // 'Bajo', 'Medio', 'Alto'
  final DateTime fechaNacimiento;
  final String telefonoEmergencia;
  final String sexo;
  final double estatura;
  final int? medicoId;
  final String? nombreMedico;
  final String? especialidadMedico;

  const PacienteModel({
    required this.id,
    required this.usuarioId,
    required this.primerNombre,
    this.segundoNombre,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.email,
    required this.diagnosticoPrincipal,
    required this.nivelRiesgo,
    required this.fechaNacimiento,
    required this.telefonoEmergencia,
    required this.sexo,
    required this.estatura,
    this.medicoId,
    this.nombreMedico,
    this.especialidadMedico,
  });

  String get nombreCompleto {
    final seg = (segundoNombre != null && segundoNombre!.trim().isNotEmpty)
        ? ' $segundoNombre '
        : ' ';
    return '$primerNombre$seg$apellidoPaterno $apellidoMaterno'.trim();
  }

  int get edad {
    final now = DateTime.now();
    int age = now.year - fechaNacimiento.year;
    if (now.month < fechaNacimiento.month ||
        (now.month == fechaNacimiento.month && now.day < fechaNacimiento.day)) {
      age--;
    }
    return age;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'usuario_id': usuarioId,
        'primer_nombre': primerNombre,
        'segundo_nombre': segundoNombre,
        'apellido_paterno': apellidoPaterno,
        'apellido_materno': apellidoMaterno,
        'email': email,
        'diagnostico_principal': diagnosticoPrincipal,
        'nivel_riesgo': nivelRiesgo,
        'fecha_nacimiento': fechaNacimiento.toIso8601String().substring(0, 10),
        'telefono_emergencia': telefonoEmergencia,
        'sexo': sexo,
        'estatura': estatura,
        'medico_id': medicoId,
        'nombre_medico': nombreMedico,
        'especialidad_medico': especialidadMedico,
      };

  factory PacienteModel.fromJson(Map<String, dynamic> json) {
    return PacienteModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id'].toString()) ?? 1,
      usuarioId: json['usuario_id'] is int
          ? json['usuario_id'] as int
          : int.tryParse(json['usuario_id'].toString()) ?? 1,
      primerNombre: json['primer_nombre'] as String? ?? 'María',
      segundoNombre: json['segundo_nombre'] as String?,
      apellidoPaterno: json['apellido_paterno'] as String? ?? 'Ramírez',
      apellidoMaterno: json['apellido_materno'] as String? ?? 'Castro',
      email: json['email'] as String? ?? 'maria.paciente@cronicare.com',
      diagnosticoPrincipal: json['diagnostico_principal'] as String? ?? 'Hipertensión Arterial Primaria',
      nivelRiesgo: json['nivel_riesgo'] as String? ?? 'Medio',
      fechaNacimiento: json['fecha_nacimiento'] != null
          ? DateTime.tryParse(json['fecha_nacimiento'].toString()) ?? DateTime(1974, 8, 23)
          : DateTime(1974, 8, 23),
      telefonoEmergencia: json['telefono_emergencia'] as String? ?? '3128765432',
      sexo: json['sexo'] as String? ?? 'Femenino',
      estatura: (json['estatura'] is num)
          ? (json['estatura'] as num).toDouble()
          : double.tryParse(json['estatura']?.toString() ?? '1.65') ?? 1.65,
      medicoId: json['medico_id'] is int ? json['medico_id'] as int : int.tryParse(json['medico_id']?.toString() ?? '1'),
      nombreMedico: json['nombre_medico'] as String? ??
          (json['medico'] is Map && (json['medico'] as Map)['usuario'] is Map
              ? 'Dr. ${(json['medico']['usuario']['primer_nombre'] ?? '')} ${(json['medico']['usuario']['apellido_paterno'] ?? '')}'.trim()
              : 'Dr. Carlos Eduardo Hernández Torres'),
      especialidadMedico: json['especialidad_medico'] as String? ??
          (json['medico'] is Map && (json['medico'] as Map)['especialidad'] != null
              ? (json['medico']['especialidad'] as String)
              : 'Medicina Interna y Cardiología'),
    );
  }
}
