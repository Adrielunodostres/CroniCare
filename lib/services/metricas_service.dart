import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/medicion_model.dart';
import '../models/metrica_tipo.dart';
import '../models/paciente_model.dart';
import '../models/recordatorio_model.dart';
import 'auth_service.dart';

/// Servicio gestor de mediciones de salud de CroniCare.
///
/// Implementa patrón `ChangeNotifier` para actualización reactiva de la UI.
/// Integra con la API REST de Laravel usando Bearer Token de Sanctum.
/// Cuando el backend no está disponible, opera con datos mock locales.
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

  /// Indica si los datos actuales provienen del servidor o son mock locales
  bool _isOnline = false;
  bool get isOnline => _isOnline;

  /// Mensaje de error del último intento de comunicación con el servidor
  String? _lastError;
  String? get lastError => _lastError;

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

  // ── Headers comunes para todas las peticiones ────────────────
  Map<String, String> get _authHeaders {
    final token = AuthService().token;
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

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

  /// Estado general dinámico basado en las métricas actuales
  String get estadoGeneralTitulo {
    final alertas = _historial.where((m) => m.esAlerta).length;
    if (alertas == 0) return 'Estado General: Bueno';
    if (alertas == 1) return 'Estado General: Atención';
    return 'Estado General: Alerta';
  }

  String get estadoGeneralMensaje {
    final alertas = _historial.where((m) => m.esAlerta).length;
    if (alertas == 0) return 'Tus métricas de hoy están en orden.';
    if (alertas == 1) return 'Tienes 1 métrica fuera del rango normal.';
    return 'Tienes $alertas métricas fuera del rango normal.';
  }

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
  // Integración con Backend Laravel
  // ─────────────────────────────────────────────────────────────

  /// Registra una nueva medición.
  ///
  /// Intenta enviar al servidor via POST. Si falla, almacena localmente.
  Future<bool> registrarNuevaMedicion({
    required int tipoMetricaId,
    required double valor,
    double? valorSecundario,
    DateTime? fechaRegistro,
    String? notas,
  }) async {
    _isLoading = true;
    notifyListeners();

    final nuevaMedicion = MedicionModel(
      id: DateTime.now().millisecondsSinceEpoch,
      pacienteId: _paciente.id,
      tipoMetricaId: tipoMetricaId,
      valor: valor,
      valorSecundario: valorSecundario,
      fechaRegistro: fechaRegistro ?? DateTime.now(),
      notas: notas?.trim().isEmpty == true ? null : notas?.trim(),
    );

    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.registrarMedicion),
            headers: _authHeaders,
            body: jsonEncode(nuevaMedicion.toJson()),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Parsear la respuesta del servidor para obtener el id real
        final data = jsonDecode(response.body);
        MedicionModel medicionGuardada;

        if (data is Map<String, dynamic>) {
          // Si el server devuelve el objeto creado directamente
          final medicionData = data['data'] ?? data['medicion'] ?? data;
          if (medicionData is Map<String, dynamic>) {
            medicionGuardada = MedicionModel.fromJson(medicionData);
          } else {
            medicionGuardada = nuevaMedicion;
          }
        } else {
          medicionGuardada = nuevaMedicion;
        }

        _historial.insert(0, medicionGuardada);
        _isOnline = true;
        _lastError = null;
        _isLoading = false;
        notifyListeners();
        debugPrint('✅ Medición registrada en servidor (id: ${medicionGuardada.id})');
        return true;
      } else {
        // Respuesta de error del servidor, guardar localmente
        debugPrint('⚠️ Servidor respondió ${response.statusCode}: ${response.body}');
        return _guardarMedicionLocal(nuevaMedicion, 'Servidor respondió con error ${response.statusCode}');
      }
    } on SocketException catch (e) {
      debugPrint('📴 Sin conexión al servidor: $e');
      return _guardarMedicionLocal(nuevaMedicion, 'Sin conexión al servidor');
    } on http.ClientException catch (e) {
      debugPrint('📴 Error de conexión: $e');
      return _guardarMedicionLocal(nuevaMedicion, 'Error de conexión');
    } catch (e) {
      if (e.toString().contains('TimeoutException') ||
          e.toString().contains('Failed host lookup') ||
          e.toString().contains('Connection refused')) {
        debugPrint('📴 Timeout al conectar: $e');
        return _guardarMedicionLocal(nuevaMedicion, 'Servidor no disponible');
      }
      debugPrint('❌ Error inesperado al registrar medición: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Almacena la medición localmente cuando el servidor no está disponible
  bool _guardarMedicionLocal(MedicionModel medicion, String razon) {
    _historial.insert(0, medicion);
    _isOnline = false;
    _lastError = razon;
    _isLoading = false;
    notifyListeners();
    debugPrint('💾 Medición guardada localmente ($razon)');
    return true;
  }

  /// Carga el historial de mediciones desde el backend Laravel.
  ///
  /// GET /api/metricas-pacientes?paciente_id={id}
  /// Si falla, mantiene los datos mock/locales actuales.
  Future<void> cargarHistorialDesdeServidor() async {
    _isLoading = true;
    notifyListeners();

    try {
      final url = '${ApiConfig.historialMediciones}?paciente_id=${_paciente.id}';
      final response = await http
          .get(Uri.parse(url), headers: _authHeaders)
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        List<dynamic> dataList;

        // Soportar respuestas paginadas de Laravel {"data": [...]} o listas planas [...]
        if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
          dataList = decoded['data'] as List<dynamic>;
        } else if (decoded is List) {
          dataList = decoded;
        } else {
          debugPrint('⚠️ Formato de respuesta inesperado del historial');
          _isLoading = false;
          notifyListeners();
          return;
        }

        _historial.clear();
        _historial.addAll(
          dataList
              .map((item) => MedicionModel.fromJson(item as Map<String, dynamic>))
              .toList(),
        );

        // Ordenar por fecha descendente
        _historial.sort((a, b) => b.fechaRegistro.compareTo(a.fechaRegistro));

        _isOnline = true;
        _lastError = null;
        debugPrint('✅ Historial cargado desde servidor: ${_historial.length} mediciones');
      } else {
        debugPrint('⚠️ Error al cargar historial: ${response.statusCode}');
        _lastError = 'Error del servidor (${response.statusCode})';
      }
    } on SocketException catch (_) {
      debugPrint('📴 Sin conexión — usando datos locales para historial');
      _isOnline = false;
      _lastError = 'Sin conexión al servidor';
    } on http.ClientException catch (_) {
      debugPrint('📴 Error de conexión — usando datos locales para historial');
      _isOnline = false;
      _lastError = 'Error de conexión';
    } catch (e) {
      if (e.toString().contains('TimeoutException') ||
          e.toString().contains('Failed host lookup') ||
          e.toString().contains('Connection refused')) {
        debugPrint('📴 Timeout — usando datos locales para historial');
        _isOnline = false;
        _lastError = 'Servidor no disponible';
      } else {
        debugPrint('❌ Error inesperado al cargar historial: $e');
        _lastError = 'Error: $e';
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Carga el resumen del dashboard desde el backend Laravel.
  ///
  /// GET /api/pacientes/resumen-hoy
  /// Parsea las métricas más recientes y el recordatorio activo.
  Future<void> cargarResumenHoy() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http
          .get(Uri.parse(ApiConfig.resumenSaludHoy), headers: _authHeaders)
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Actualizar métricas del resumen si vienen en la respuesta
        if (data is Map<String, dynamic>) {
          final resData = (data['data'] is Map<String, dynamic>)
              ? data['data'] as Map<String, dynamic>
              : data;

          // 1. Caso: metricas_resumen de MetricaApiController@resumenDashboard
          if (resData.containsKey('metricas_resumen') && resData['metricas_resumen'] is List) {
            final List<MedicionModel> parsedList = [];
            for (final item in resData['metricas_resumen'] as List) {
              if (item is Map<String, dynamic> &&
                  item['ultima_medicion'] != null &&
                  item['ultima_medicion'] is Map) {
                final u = item['ultima_medicion'] as Map<String, dynamic>;
                final tipoId = item['tipo_metrica_id'] is int
                    ? item['tipo_metrica_id'] as int
                    : int.tryParse(item['tipo_metrica_id']?.toString() ?? '1') ?? 1;

                parsedList.add(MedicionModel(
                  id: u['id'] is int ? u['id'] as int : int.tryParse(u['id']?.toString() ?? ''),
                  pacienteId: _paciente.id,
                  tipoMetricaId: tipoId,
                  valor: (u['valor'] is num)
                      ? (u['valor'] as num).toDouble()
                      : double.tryParse(u['valor']?.toString() ?? '0.0') ?? 0.0,
                  valorSecundario: u['valor_secundario'] != null
                      ? ((u['valor_secundario'] is num)
                          ? (u['valor_secundario'] as num).toDouble()
                          : double.tryParse(u['valor_secundario'].toString()))
                      : (tipoId == 1 ? 80.0 : null),
                  fechaRegistro: u['fecha_registro'] != null
                      ? DateTime.tryParse(u['fecha_registro'].toString()) ?? DateTime.now()
                      : DateTime.now(),
                  notas: u['notas'] as String?,
                ));
              }
            }

            if (parsedList.isNotEmpty) {
              _historial.clear();
              _historial.addAll(parsedList);
              _historial.sort((a, b) => b.fechaRegistro.compareTo(a.fechaRegistro));
            }
          }
          // 2. Caso: lista de mediciones planas
          else if (resData.containsKey('mediciones') && resData['mediciones'] is List) {
            final mediciones = (resData['mediciones'] as List)
                .map((item) => MedicionModel.fromJson(item as Map<String, dynamic>))
                .toList();
            if (mediciones.isNotEmpty) {
              _historial.clear();
              _historial.addAll(mediciones);
              _historial.sort((a, b) => b.fechaRegistro.compareTo(a.fechaRegistro));
            }
          }

          // Parsear recordatorio activo si existe
          final recMap = resData['recordatorio'] ?? data['recordatorio'];
          if (recMap is Map<String, dynamic>) {
            _recordatorio = RecordatorioModel(
              id: recMap['id'] ?? 1,
              mensaje: recMap['mensaje'] ?? '',
              hora: recMap['hora'] ?? '',
              medicamento: recMap['medicamento'],
              activo: recMap['activo'] == true || recMap['activo'] == 1,
            );
          }

          // Parsear datos del paciente
          final pacMap = resData['paciente'] ?? data['paciente'];
          if (pacMap is Map<String, dynamic>) {
            _paciente = PacienteModel.fromJson(pacMap);
          }
        }

        _isOnline = true;
        _lastError = null;
        debugPrint('✅ Resumen del día cargado desde servidor');
      } else {
        debugPrint('⚠️ Error al cargar resumen: ${response.statusCode}');
        _lastError = 'Error del servidor (${response.statusCode})';
      }
    } on SocketException catch (_) {
      debugPrint('📴 Sin conexión — usando datos locales para resumen');
      _isOnline = false;
      _lastError = 'Sin conexión al servidor';
    } on http.ClientException catch (_) {
      debugPrint('📴 Error de conexión — usando datos locales para resumen');
      _isOnline = false;
      _lastError = 'Error de conexión';
    } catch (e) {
      if (e.toString().contains('TimeoutException') ||
          e.toString().contains('Failed host lookup') ||
          e.toString().contains('Connection refused')) {
        debugPrint('📴 Timeout — usando datos locales para resumen');
        _isOnline = false;
        _lastError = 'Servidor no disponible';
      } else {
        debugPrint('❌ Error inesperado al cargar resumen: $e');
        _lastError = 'Error: $e';
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Carga los datos del paciente desde el backend Laravel.
  ///
  /// GET /api/me (perfil del usuario autenticado) o GET /api/pacientes/{id}
  Future<void> cargarPerfilPaciente(int pacienteId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Primero intentar con el endpoint /me que trae datos del usuario autenticado
      final response = await http
          .get(Uri.parse(ApiConfig.perfilMe), headers: _authHeaders)
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is Map<String, dynamic>) {
          // El endpoint /me devuelve { success: true, data: { usuario: {...}, perfil: {...} } } o { usuario: { paciente: ... } }
          final payload = data['data'] is Map<String, dynamic>
              ? data['data'] as Map<String, dynamic>
              : data;
          final usuarioMap = (payload['usuario'] is Map<String, dynamic>)
              ? payload['usuario'] as Map<String, dynamic>
              : payload;
          final perfilMap = (payload['perfil'] ?? payload['paciente'] ?? usuarioMap['paciente'])
              as Map<String, dynamic>?;

          if (perfilMap != null) {
            _paciente = PacienteModel.fromJson({
              ...perfilMap,
              'primer_nombre': usuarioMap['primer_nombre'] ?? perfilMap['primer_nombre'],
              'segundo_nombre': usuarioMap['segundo_nombre'] ?? perfilMap['segundo_nombre'],
              'apellido_paterno': usuarioMap['apellido_paterno'] ?? perfilMap['apellido_paterno'],
              'apellido_materno': usuarioMap['apellido_materno'] ?? perfilMap['apellido_materno'],
              'email': usuarioMap['email'] ?? perfilMap['email'],
            });
          } else {
            // Si no hay perfil anidado, intentar cargar directamente
            await _cargarPerfilPacienteDirecto(pacienteId);
            return;
          }
        }

        _isOnline = true;
        _lastError = null;
        debugPrint('✅ Perfil del paciente cargado desde /me');
      } else if (response.statusCode == 401) {
        debugPrint('🔒 Token expirado o no autorizado al cargar perfil');
        _lastError = 'Sesión expirada. Inicia sesión nuevamente.';
      } else {
        debugPrint('⚠️ Error al cargar perfil desde /me: ${response.statusCode}');
        // Fallback: intentar endpoint directo de paciente
        await _cargarPerfilPacienteDirecto(pacienteId);
        return;
      }
    } on SocketException catch (_) {
      debugPrint('📴 Sin conexión — usando perfil local');
      _isOnline = false;
      _lastError = 'Sin conexión al servidor';
    } on http.ClientException catch (_) {
      debugPrint('📴 Error de conexión — usando perfil local');
      _isOnline = false;
      _lastError = 'Error de conexión';
    } catch (e) {
      if (e.toString().contains('TimeoutException') ||
          e.toString().contains('Failed host lookup') ||
          e.toString().contains('Connection refused')) {
        debugPrint('📴 Timeout — usando perfil local');
        _isOnline = false;
        _lastError = 'Servidor no disponible';
      } else {
        debugPrint('❌ Error inesperado al cargar perfil: $e');
        _lastError = 'Error: $e';
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Carga el paciente directamente desde GET /api/pacientes/{id}
  Future<void> _cargarPerfilPacienteDirecto(int pacienteId) async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/pacientes/$pacienteId'),
            headers: _authHeaders,
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final pacienteData = data is Map<String, dynamic>
            ? (data['data'] ?? data['paciente'] ?? data) as Map<String, dynamic>
            : null;

        if (pacienteData != null) {
          _paciente = PacienteModel.fromJson(pacienteData);
          _isOnline = true;
          _lastError = null;
          debugPrint('✅ Perfil del paciente cargado desde /pacientes/$pacienteId');
        }
      } else {
        debugPrint('⚠️ Error al cargar perfil directo: ${response.statusCode}');
        _lastError = 'Error del servidor (${response.statusCode})';
      }
    } catch (e) {
      debugPrint('📴 Error al cargar perfil directo: $e');
      _isOnline = false;
      _lastError = 'Sin conexión al servidor';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Carga los recordatorios activos del paciente.
  ///
  /// GET /api/recordatorios?paciente_id={id}
  Future<void> cargarRecordatorios() async {
    try {
      final url = '${ApiConfig.recordatorios}?paciente_id=${_paciente.id}';
      final response = await http
          .get(Uri.parse(url), headers: _authHeaders)
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        List<dynamic> dataList;

        if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
          dataList = decoded['data'] as List<dynamic>;
        } else if (decoded is List) {
          dataList = decoded;
        } else {
          return;
        }

        if (dataList.isNotEmpty) {
          // Tomar el recordatorio activo más reciente
          final rec = dataList.first as Map<String, dynamic>;
          _recordatorio = RecordatorioModel(
            id: rec['id'] ?? 1,
            mensaje: rec['mensaje'] ?? '',
            hora: rec['hora'] ?? '',
            medicamento: rec['medicamento'],
            activo: rec['activo'] == true || rec['activo'] == 1,
          );
          notifyListeners();
          debugPrint('✅ Recordatorios cargados desde servidor');
        }
      }
    } catch (e) {
      debugPrint('📴 Error al cargar recordatorios: $e (usando datos locales)');
    }
  }

  /// Sincroniza todos los datos necesarios al iniciar sesión.
  /// Llama a cargarHistorial, cargarResumen, cargarPerfil y cargarRecordatorios.
  Future<void> sincronizarTodo() async {
    await Future.wait([
      cargarHistorialDesdeServidor(),
      cargarPerfilPaciente(_paciente.id),
      cargarRecordatorios(),
    ]);
  }

  /// Elimina una medición por su id.
  ///
  /// DELETE /api/metricas-pacientes/{id}
  Future<bool> eliminarMedicion(int medicionId) async {
    try {
      final response = await http
          .delete(
            Uri.parse('${ApiConfig.historialMediciones}/$medicionId'),
            headers: _authHeaders,
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200 || response.statusCode == 204) {
        _historial.removeWhere((m) => m.id == medicionId);
        notifyListeners();
        debugPrint('✅ Medición eliminada del servidor (id: $medicionId)');
        return true;
      }
    } on SocketException catch (_) {
      // Eliminar solo localmente
    } on http.ClientException catch (_) {
      // Eliminar solo localmente
    } catch (e) {
      if (e.toString().contains('TimeoutException') ||
          e.toString().contains('Connection refused')) {
        // Eliminar solo localmente
      } else {
        debugPrint('❌ Error al eliminar medición: $e');
        return false;
      }
    }

    // Fallback: eliminar localmente
    _historial.removeWhere((m) => m.id == medicionId);
    notifyListeners();
    debugPrint('💾 Medición eliminada localmente (id: $medicionId)');
    return true;
  }
}
