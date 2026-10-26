// ignore: unused_import
import 'dart:convert';
import 'package:flutter/foundation.dart';
// ignore: unused_import
import 'package:http/http.dart' as http;

// ignore: unused_import
import '../config/api_config.dart';
import '../models/medicion_model.dart';
import '../models/metrica_tipo.dart';
import '../models/paciente_model.dart';
import '../models/recordatorio_model.dart';

/// Servicio gestor de mediciones de salud de CroniCare.
///
/// Implementa patrón `ChangeNotifier` para actualización reactiva de la UI.
/// Actualmente inicializado con datos mock idénticos a las pantallas de diseño
/// y estructurados según `pacientescronicos (1).sql`.
///
/// Deja preparados todos los métodos y hooks para integrar el backend Laravel.
class MetricasService extends ChangeNotifier {
  // Singleton para acceso global sencillo
  static final MetricasService _instance = MetricasService._internal();
  factory MetricasService() => _instance;
  MetricasService._internal() {
    _initMockData();
  }

  // ── Estado ──────────────────────────────────────────────────
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  PacienteModel _paciente = PacienteModel(
    id: 2,
    usuarioId: 4,
    primerNombre: 'María',
    segundoNombre: 'Fernanda',
    apellidoPaterno: 'Ramírez',
    apellidoMaterno: 'Castro',
    email: 'maria.paciente@cronicare.com',
    diagnosticoPrincipal: 'Hipertensión Arterial Primaria',
    nivelRiesgo: 'Medio',
    fechaNacimiento: DateTime(1974, 8, 23),
    telefonoEmergencia: '3128765432',
    sexo: 'Femenino',
    estatura: 1.65,
    medicoId: 1,
    nombreMedico: 'Dr. Carlos Eduardo Hernández Torres',
    especialidadMedico: 'Medicina Interna y Cardiología',
  );
  PacienteModel get paciente => _paciente;
  void actualizarPaciente(PacienteModel nuevoPaciente) {
    _paciente = nuevoPaciente;
    notifyListeners();
  }

  RecordatorioModel? _recordatorio = const RecordatorioModel(
    id: 1,
    mensaje: 'No olvides tomar tu medicamento para la presión a las 2:00 PM.',
    hora: '02:00 PM',
    medicamento: 'Losartán 50mg',
    activo: true,
  );
  RecordatorioModel? get recordatorio => _recordatorio;
  void actualizarRecordatorio(RecordatorioModel? nuevoRecordatorio) {
    _recordatorio = nuevoRecordatorio;
    notifyListeners();
  }

  // Lista de historial de mediciones (orden cronológico descendente)
  final List<MedicionModel> _historial = [];
  List<MedicionModel> get historial => List.unmodifiable(_historial);

  // ── Getters calculados para el Dashboard ─────────────────────
  MedicionModel? get glucosaHoy {
    try {
      return _historial.firstWhere((m) => m.categoria == CategoriaMetrica.glucosa);
    } catch (_) {
      return null;
    }
  }

  MedicionModel? get presionHoy {
    try {
      return _historial.firstWhere((m) => m.categoria == CategoriaMetrica.presion);
    } catch (_) {
      return null;
    }
  }

  MedicionModel? get frecuenciaCardiacaHoy {
    try {
      return _historial.firstWhere((m) => m.categoria == CategoriaMetrica.frecuenciaCardiaca);
    } catch (_) {
      return null;
    }
  }

  MedicionModel? get pesoHoy {
    try {
      return _historial.firstWhere((m) => m.categoria == CategoriaMetrica.peso);
    } catch (_) {
      return null;
    }
  }

  String get estadoGeneralTitulo => 'Estado General: Bueno';
  String get estadoGeneralMensaje => 'Tus métricas de hoy están en orden.';

  // ── Filtrado de historial ────────────────────────────────────
  List<MedicionModel> filtrarHistorial(CategoriaMetrica? filtro) {
    if (filtro == null) return historial;
    return _historial.where((m) => m.categoria == filtro).toList();
  }

  // ── Inicialización con datos mock exactos del diseño ─────────
  void _initMockData() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    // Lunes anterior
    final int daysSinceMonday = (now.weekday - DateTime.monday) % 7;
    final monday = today.subtract(Duration(days: daysSinceMonday == 0 ? 7 : daysSinceMonday));

    _historial.clear();
    _historial.addAll([
      // 1. Glucosa 95 mg/dL - Hoy 08:00 AM
      MedicionModel(
        id: 101,
        pacienteId: _paciente.id,
        tipoMetricaId: TipoMetrica.glucosa.id,
        valor: 95.0,
        fechaRegistro: DateTime(today.year, today.month, today.day, 8, 0),
        notas: 'Medición matutina en ayuno',
      ),
      // 2. Presión 125/82 mmHg - Hoy 07:30 AM
      MedicionModel(
        id: 102,
        pacienteId: _paciente.id,
        tipoMetricaId: TipoMetrica.presionSistolica.id,
        valor: 125.0,
        valorSecundario: 82.0,
        fechaRegistro: DateTime(today.year, today.month, today.day, 7, 30),
        notas: 'Toma matutina en reposo',
      ),
      // 3. Frec. Cardiaca 72 lpm - Ayer 08:00 PM
      MedicionModel(
        id: 103,
        pacienteId: _paciente.id,
        tipoMetricaId: TipoMetrica.frecuenciaCardiaca.id,
        valor: 72.0,
        fechaRegistro: DateTime(yesterday.year, yesterday.month, yesterday.day, 20, 0),
        notas: 'Control nocturno',
      ),
      // 4. Peso 70.5 kg - Ayer 07:00 AM
      MedicionModel(
        id: 104,
        pacienteId: _paciente.id,
        tipoMetricaId: TipoMetrica.peso.id,
        valor: 70.5,
        fechaRegistro: DateTime(yesterday.year, yesterday.month, yesterday.day, 7, 0),
        notas: 'Pesaje semanal',
      ),
      // 5. Glucosa 110 mg/dL - Lun 08:00 AM (alerta / fuera de rango)
      MedicionModel(
        id: 105,
        pacienteId: _paciente.id,
        tipoMetricaId: TipoMetrica.glucosa.id,
        valor: 110.0,
        fechaRegistro: DateTime(monday.year, monday.month, monday.day, 8, 0),
        notas: 'Postdesayuno ligero',
      ),
    ]);
  }

  // ─────────────────────────────────────────────────────────────
  // Métodos de registro preparados para Backend Laravel
  // ─────────────────────────────────────────────────────────────

  /// Registra una nueva medición.
  ///
  /// En el Front-end: actualiza la lista local y notifica a los listeners.
  /// En el Back-end (TODO): realizará una petición `POST ApiConfig.registrarMedicion`.
  Future<bool> registrarNuevaMedicion({
    required int tipoMetricaId,
    required double valor,
    double? valorSecundario,
    DateTime? fechaRegistro,
    String? notas,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final nuevaMedicion = MedicionModel(
        id: DateTime.now().millisecondsSinceEpoch,
        pacienteId: _paciente.id,
        tipoMetricaId: tipoMetricaId,
        valor: valor,
        valorSecundario: valorSecundario,
        fechaRegistro: fechaRegistro ?? DateTime.now(),
        notas: notas?.trim().isEmpty == true ? null : notas?.trim(),
      );

      // =========================================================
      // TODO: BACKEND INTEGRATION
      // Descomentar cuando el endpoint esté listo en Laravel:
      //
      // final response = await http.post(
      //   Uri.parse(ApiConfig.registrarMedicion),
      //   headers: {
      //     'Content-Type': 'application/json',
      //     'Accept': 'application/json',
      //     // 'Authorization': 'Bearer $token',
      //   },
      //   body: jsonEncode(nuevaMedicion.toJson()),
      // );
      //
      // if (response.statusCode != 200 && response.statusCode != 201) {
      //   throw Exception('Error al guardar medición en el servidor');
      // }
      // =========================================================

      // Simulación de retraso breve de guardado front-end
      await Future.delayed(const Duration(milliseconds: 300));

      // Se agrega al inicio de la lista de mediciones
      _historial.insert(0, nuevaMedicion);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error al registrar medición: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Carga el historial de mediciones desde el backend Laravel
  Future<void> cargarHistorialDesdeServidor() async {
    // =========================================================
    // TODO: BACKEND INTEGRATION
    // final url = '${ApiConfig.historialMediciones}?paciente_id=${_paciente.id}';
    // final response = await http.get(Uri.parse(url), headers: {'Accept': 'application/json'});
    // if (response.statusCode == 200) {
    //   final List data = jsonDecode(response.body);
    //   _historial.clear();
    //   _historial.addAll(data.map((item) => MedicionModel.fromJson(item)));
    //   notifyListeners();
    // }
    // =========================================================
  }

  /// Carga los datos del paciente desde el backend Laravel
  Future<void> cargarPerfilPaciente(int pacienteId) async {
    // =========================================================
    // TODO: BACKEND INTEGRATION
    // final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/pacientes/$pacienteId'));
    // if (response.statusCode == 200) {
    //   _paciente = PacienteModel.fromJson(jsonDecode(response.body));
    //   notifyListeners();
    // }
    // =========================================================
  }
}
