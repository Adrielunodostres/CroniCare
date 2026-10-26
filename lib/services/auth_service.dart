import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/paciente_model.dart';
import 'metricas_service.dart';

/// Resultado de una operación de autenticación
class AuthResult {
  final bool success;
  final String message;
  final bool isOffline;

  const AuthResult({
    required this.success,
    required this.message,
    this.isOffline = false,
  });

  factory AuthResult.success({String message = 'Bienvenido a CroniCare', bool isOffline = false}) {
    return AuthResult(success: true, message: message, isOffline: isOffline);
  }

  factory AuthResult.error(String message) {
    return AuthResult(success: false, message: message);
  }
}

/// Servicio de Autenticación de CroniCare.
///
/// Se comunica con la API de Laravel (endpoints `/api/login`, `/api/logout`, `/api/me`)
/// y gestiona el token de acceso seguro de Laravel Sanctum.
class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // ── Estado ──────────────────────────────────────────────────
  String? _token;
  String? get token => _token;
  bool get isAuthenticated => _token != null;

  Map<String, dynamic>? _usuarioActual;
  Map<String, dynamic>? get usuarioActual => _usuarioActual;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // ── Login ───────────────────────────────────────────────────
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    final cleanEmail = email.trim().toLowerCase();

    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.login),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'email': cleanEmail,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 5));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        _token = data['token'] as String?;
        _usuarioActual = data['usuario'] as Map<String, dynamic>?;

        // Si el usuario es un paciente, sincronizar perfil en MetricasService
        if (_usuarioActual != null) {
          _sincronizarPacienteDesdeUsuario(_usuarioActual!);
        }

        _isLoading = false;
        notifyListeners();
        return AuthResult.success(
          message: data['message'] ?? 'Inicio de sesión exitoso',
        );
      } else {
        _isLoading = false;
        notifyListeners();
        return AuthResult.error(
          data['message'] ?? 'Credenciales inválidas. Verifica tus datos.',
        );
      }
    } on SocketException catch (_) {
      // Servidor no alcanzable -> Probar autenticación con cuentas demo locales de la BD
      return _loginDemoFallback(cleanEmail, password);
    } on http.ClientException catch (_) {
      return _loginDemoFallback(cleanEmail, password);
    } catch (e) {
      if (e.toString().contains('TimeoutException') ||
          e.toString().contains('Failed host lookup') ||
          e.toString().contains('Connection refused')) {
        return _loginDemoFallback(cleanEmail, password);
      }
      _isLoading = false;
      notifyListeners();
      return AuthResult.error('Error al conectar con el servidor: $e');
    }
  }

  /// Autenticación de respaldo si el backend Laravel está apagado durante pruebas
  AuthResult _loginDemoFallback(String email, String password) {
    _isLoading = false;

    // Cuentas existentes en pacientescronicos (1).sql
    if (email == 'maria.paciente@cronicare.com' ||
        email == 'maria@cronicare.com' ||
        email == 'paciente@cronicare.com') {
      _token = 'demo_sanctum_token_maria_paciente';
      _usuarioActual = {
        'id': 4,
        'primer_nombre': 'María',
        'segundo_nombre': 'Fernanda',
        'apellido_paterno': 'Ramírez',
        'apellido_materno': 'Castro',
        'email': 'maria.paciente@cronicare.com',
        'rol_id': 3,
        'estado': 'Activo',
      };
      notifyListeners();
      return AuthResult.success(
        message: '¡Bienvenida, María! (Modo demostración local)',
        isOffline: true,
      );
    } else if (email == 'medico@cronicare.com' || email == 'doctor@cronico.com') {
      _token = 'demo_sanctum_token_medico';
      _usuarioActual = {
        'id': 2,
        'primer_nombre': 'Carlos',
        'segundo_nombre': 'Eduardo',
        'apellido_paterno': 'Hernández',
        'apellido_materno': 'Torres',
        'email': email,
        'rol_id': 2,
        'estado': 'Activo',
      };
      notifyListeners();
      return AuthResult.success(
        message: '¡Bienvenido, Dr. Hernández! (Modo demostración local)',
        isOffline: true,
      );
    } else if (email == 'admin@cronicare.com') {
      _token = 'demo_sanctum_token_admin';
      _usuarioActual = {
        'id': 1,
        'primer_nombre': 'Administrador',
        'apellido_paterno': 'General',
        'apellido_materno': 'CróniCare',
        'email': email,
        'rol_id': 1,
        'estado': 'Activo',
      };
      notifyListeners();
      return AuthResult.success(
        message: 'Sesión iniciada como Administrador (Modo local)',
        isOffline: true,
      );
    }

    notifyListeners();
    return AuthResult.error(
      'No se pudo conectar a la API de Laravel (http://127.0.0.1:8000). '
      'Verifica que "php artisan serve" esté activo o usa una cuenta demo.',
    );
  }

  void _sincronizarPacienteDesdeUsuario(Map<String, dynamic> u) {
    try {
      final p = u['paciente'] as Map<String, dynamic>?;
      if (p != null) {
        final nuevoPaciente = PacienteModel(
          id: p['id'] is int ? p['id'] : int.tryParse(p['id'].toString()) ?? 1,
          usuarioId: u['id'] is int ? u['id'] : int.tryParse(u['id'].toString()) ?? 1,
          primerNombre: u['primer_nombre'] ?? 'María',
          segundoNombre: u['segundo_nombre'],
          apellidoPaterno: u['apellido_paterno'] ?? 'Ramírez',
          apellidoMaterno: u['apellido_materno'] ?? 'Castro',
          email: u['email'] ?? 'maria.paciente@cronicare.com',
          diagnosticoPrincipal: p['diagnostico_principal'] ?? 'Hipertensión Arterial Primaria',
          nivelRiesgo: p['nivel_riesgo'] ?? 'Medio',
          fechaNacimiento: p['fecha_nacimiento'] != null
              ? DateTime.tryParse(p['fecha_nacimiento'].toString()) ?? DateTime(1974, 8, 23)
              : DateTime(1974, 8, 23),
          telefonoEmergencia: p['telefono_emergencia'] ?? '3128765432',
          sexo: p['sexo'] ?? 'Femenino',
          estatura: (p['estatura'] is num)
              ? (p['estatura'] as num).toDouble()
              : double.tryParse(p['estatura']?.toString() ?? '1.65') ?? 1.65,
          medicoId: p['medico_id'] is int ? p['medico_id'] : int.tryParse(p['medico_id']?.toString() ?? '1'),
          nombreMedico: p['medico'] != null && p['medico']['usuario'] != null
              ? 'Dr. ${(p['medico']['usuario']['primer_nombre'] ?? '')} ${(p['medico']['usuario']['apellido_paterno'] ?? '')}'.trim()
              : 'Dr. Carlos Eduardo Hernández Torres',
          especialidadMedico: p['medico'] != null && p['medico']['especialidad'] != null
              ? (p['medico']['especialidad'] as String)
              : 'Medicina Interna y Cardiología',
        );
        MetricasService().actualizarPaciente(nuevoPaciente);
      }
    } catch (e) {
      debugPrint('Error sincronizando paciente: $e');
    }
  }

  // ── Logout ──────────────────────────────────────────────────
  Future<void> logout() async {
    if (_token != null) {
      try {
        await http.post(
          Uri.parse(ApiConfig.logout),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $_token',
          },
        ).timeout(const Duration(seconds: 3));
      } catch (_) {
        // En caso de desconexión, simplemente se limpia localmente
      }
    }
    _token = null;
    _usuarioActual = null;
    notifyListeners();
  }
}
