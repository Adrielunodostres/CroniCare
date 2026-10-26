import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../config/api_config.dart';
import 'home_screen.dart';

/// Pantalla de registro de pacientes.
///
/// Envía los datos a `POST /api/pacientes/registro` en el backend Laravel.
/// Todas las claves del JSON siguen la convención **snake_case** de Laravel.
class RegisterPatientScreen extends StatefulWidget {
  const RegisterPatientScreen({super.key});

  @override
  State<RegisterPatientScreen> createState() => _RegisterPatientScreenState();
}

class _RegisterPatientScreenState extends State<RegisterPatientScreen>
    with SingleTickerProviderStateMixin {
  // ── Form key ───────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();

  // ── Controllers ────────────────────────────────────────────
  final _nombreCompletoCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _estaturaCtrl = TextEditingController();

  // ── State ──────────────────────────────────────────────────
  bool _isLoading = false;
  bool _obscurePassword = true;
  DateTime? _fechaNacimiento;
  String _sexo = 'Masculino';
  String _condicionClinica = 'Hipertensión Arterial';

  // ── Animation ──────────────────────────────────────────────
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  // ── Opciones estáticas ─────────────────────────────────────
  static const _condiciones = [
    'Hipertensión Arterial',
    'Diabetes Mellitus Tipo 2',
    'Enfermedad Renal Crónica',
    'Asma Crónica',
    'EPOC',
    'Insuficiencia Cardíaca',
    'Artritis Reumatoide',
    'Epilepsia',
    'Otra',
  ];

  static const _sexos = ['Masculino', 'Femenino', 'Otro'];

  // ── Regex para correo ──────────────────────────────────────
  static final _emailRegex = RegExp(
    r'^[\w\.\-]+@[\w\-]+\.\w{2,}$',
    caseSensitive: false,
  );

  // ───────────────────────────────────────────────────────────
  // Lifecycle
  // ───────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _nombreCompletoCtrl.dispose();
    _correoCtrl.dispose();
    _passwordCtrl.dispose();
    _telefonoCtrl.dispose();
    _estaturaCtrl.dispose();
    super.dispose();
  }

  // ───────────────────────────────────────────────────────────
  // Submit
  // ───────────────────────────────────────────────────────────
  Future<void> _submitRegistration() async {
    // 1. Validar campos obligatorios y fecha
    if (!_formKey.currentState!.validate()) return;
    if (_fechaNacimiento == null) {
      _showSnack('Por favor, selecciona tu fecha de nacimiento');
      return;
    }

    // 2. Activar indicador de carga
    setState(() => _isLoading = true);

    try {
      final url = Uri.parse(ApiConfig.registroPaciente);

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'nombre_completo': _nombreCompletoCtrl.text.trim(),
          'email': _correoCtrl.text.trim(),
          'password': _passwordCtrl.text,
          'fecha_nacimiento': DateFormat('yyyy-MM-dd').format(_fechaNacimiento!),
          'condicion_clinica': _condicionClinica,
          // Campos extra de tu UI que puedes requerir en la BD:
          'telefono': _telefonoCtrl.text.trim(),
          'sexo': _sexo,
          'estatura': double.tryParse(_estaturaCtrl.text.trim()),
        }),
      );

      if (!mounted) return;

      // 3. Manejar respuesta
      if (response.statusCode == 201) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        final errorData = jsonDecode(response.body);
        _showSnack(errorData['message'] ?? 'Error de validación en el servidor');
      }
    } catch (e) {
      if (!mounted) return;
      _showSnack('Error de conexión con el servidor.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────
  // Date picker
  // ───────────────────────────────────────────────────────────
  Future<void> _pickFechaNacimiento() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaNacimiento ?? DateTime(now.year - 30),
      firstDate: DateTime(1920),
      lastDate: now,
      helpText: 'Fecha de nacimiento',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );
    if (picked != null) {
      setState(() => _fechaNacimiento = picked);
    }
  }

  // ───────────────────────────────────────────────────────────
  // Build
  // ───────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnim,
        child: CustomScrollView(
          slivers: [
            // ── Header ──────────────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [cs.primary, cs.tertiary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(32),
                  ),
                ),
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 24,
                  bottom: 32,
                  left: 24,
                  right: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.medical_information_rounded,
                      color: cs.onPrimary,
                      size: 40,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Nuevo Expediente',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: cs.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Completa tu información para que tu médico pueda '
                      'monitorear tu salud.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onPrimary.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Form ────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
              sliver: SliverToBoxAdapter(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // ── Nombre completo ───────────────────
                      _buildTextField(
                        controller: _nombreCompletoCtrl,
                        label: 'Nombre completo',
                        icon: Icons.person_outline_rounded,
                        keyboardType: TextInputType.name,
                        textCapitalization: TextCapitalization.words,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Ingresa tu nombre completo'
                            : null,
                      ),

                      // ── Correo electrónico ────────────────
                      _buildTextField(
                        controller: _correoCtrl,
                        label: 'Correo electrónico',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Ingresa tu correo electrónico';
                          }
                          if (!_emailRegex.hasMatch(v.trim())) {
                            return 'Formato de correo inválido';
                          }
                          return null;
                        },
                      ),

                      // ── Contraseña ────────────────────────
                      _buildTextField(
                        controller: _passwordCtrl,
                        label: 'Contraseña',
                        icon: Icons.lock_outline_rounded,
                        obscure: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Ingresa una contraseña';
                          }
                          if (v.length < 8) {
                            return 'La contraseña debe tener al menos 8 caracteres';
                          }
                          return null;
                        },
                      ),

                      // ── Fecha de nacimiento ───────────────
                      _DatePickerTile(
                        fecha: _fechaNacimiento,
                        onTap: _pickFechaNacimiento,
                      ),
                      const SizedBox(height: 16),

                      // ── Teléfono de emergencia ────────────
                      _buildTextField(
                        controller: _telefonoCtrl,
                        label: 'Teléfono de emergencia',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(15),
                        ],
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Ingresa un teléfono de emergencia'
                            : null,
                      ),

                      // ── Sexo ──────────────────────────────
                      _buildDropdown<String>(
                        label: 'Sexo',
                        icon: Icons.wc_outlined,
                        value: _sexo,
                        items: _sexos,
                        onChanged: (v) => setState(() => _sexo = v!),
                      ),

                      // ── Estatura ──────────────────────────
                      _buildTextField(
                        controller: _estaturaCtrl,
                        label: 'Estatura (cm)',
                        icon: Icons.height_rounded,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d{0,3}\.?\d{0,2}'),
                          ),
                        ],
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Ingresa tu estatura';
                          }
                          final n = double.tryParse(v.trim());
                          if (n == null || n < 30 || n > 250) {
                            return 'Estatura inválida (30 – 250 cm)';
                          }
                          return null;
                        },
                      ),

                      // ── Condición clínica ─────────────────
                      _buildDropdown<String>(
                        label: 'Condición clínica base',
                        icon: Icons.healing_outlined,
                        value: _condicionClinica,
                        items: _condiciones,
                        onChanged: (v) =>
                            setState(() => _condicionClinica = v!),
                      ),

                      const SizedBox(height: 32),

                      // ── Botón principal ───────────────────
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: FilledButton.icon(
                          onPressed: _isLoading ? null : _submitRegistration,
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.assignment_add),
                          label: Text(
                            _isLoading
                                ? 'Registrando...'
                                : 'Crear Expediente',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      TextButton.icon(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const HomeScreen()),
                          );
                        },
                        icon: const Icon(Icons.arrow_forward_rounded),
                        label: const Text('Ir a Pantallas Principales'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────
  // Helpers — reusable form widgets
  // ───────────────────────────────────────────────────────────
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    bool obscure = false,
    Widget? suffixIcon,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        obscureText: obscure,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          filled: true,
          fillColor: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest
              .withValues(alpha: 0.35),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required IconData icon,
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<T>(
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          filled: true,
          fillColor: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest
              .withValues(alpha: 0.35),
        ),
        items: items
            .map(
              (e) => DropdownMenuItem<T>(value: e, child: Text(e.toString())),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Widget privado: selector de fecha
// ─────────────────────────────────────────────────────────────
class _DatePickerTile extends StatelessWidget {
  const _DatePickerTile({required this.fecha, required this.onTap});

  final DateTime? fecha;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final hasDate = fecha != null;

    return Material(
      color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: cs.outline),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_month_outlined, color: cs.onSurfaceVariant),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  hasDate
                      ? DateFormat('dd / MMMM / yyyy', 'es').format(fecha!)
                      : 'Fecha de nacimiento',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: hasDate ? cs.onSurface : cs.onSurfaceVariant,
                  ),
                ),
              ),
              Icon(Icons.arrow_drop_down, color: cs.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
