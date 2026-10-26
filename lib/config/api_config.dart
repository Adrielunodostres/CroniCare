/// Configuración centralizada de la API REST (Laravel).
///
/// Cambia [baseUrl] según el entorno:
///   - Emulador Android: `http://10.0.2.2:8000/api`
///   - Dispositivo físico: `http://<IP_LAN>:8000/api`
class ApiConfig {
  ApiConfig._();

  static const String baseUrl = 'http://127.0.0.1:8000/api';

  // ── Endpoints ──────────────────────────────────────────────
  static const String login = '$baseUrl/login';
  static const String logout = '$baseUrl/logout';
  static const String perfilMe = '$baseUrl/me';
  static const String registroPaciente = '$baseUrl/pacientes/registro';
  static const String metricasCatalogo = '$baseUrl/metricas';
  static const String registrarMedicion = '$baseUrl/metricas-pacientes';
  static const String historialMediciones = '$baseUrl/metricas-pacientes';
  static const String resumenSaludHoy = '$baseUrl/pacientes/resumen-hoy';
  static const String recordatorios = '$baseUrl/recordatorios';
}
