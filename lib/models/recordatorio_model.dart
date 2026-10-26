/// Modelo para recordatorios de medicamentos y tomas de salud.
class RecordatorioModel {
  final int id;
  final String mensaje;
  final String hora;
  final String? medicamento;
  final bool activo;

  const RecordatorioModel({
    required this.id,
    required this.mensaje,
    required this.hora,
    this.medicamento,
    this.activo = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'mensaje': mensaje,
        'hora': hora,
        if (medicamento != null) 'medicamento': medicamento,
        'activo': activo,
      };

  factory RecordatorioModel.fromJson(Map<String, dynamic> json) {
    return RecordatorioModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id'].toString()) ?? 0,
      mensaje: json['mensaje'] as String? ?? '',
      hora: json['hora'] as String? ?? '02:00 PM',
      medicamento: json['medicamento'] as String?,
      activo: json['activo'] as bool? ?? true,
    );
  }
}
