/// Define los tipos de métricas de salud según la tabla `metricas`
/// de la base de datos `pacientescronicos (1).sql`.
enum TipoMetrica {
  presionSistolica(
    id: 1,
    nombre: 'Presión Arterial Sistólica',
    nombreCorto: 'Presión Sistólica',
    unidad: 'mmHg',
    rangoMinNormal: 90.0,
    rangoMaxNormal: 120.0,
  ),
  presionDiastolica(
    id: 2,
    nombre: 'Presión Arterial Diastólica',
    nombreCorto: 'Presión Diastólica',
    unidad: 'mmHg',
    rangoMinNormal: 60.0,
    rangoMaxNormal: 80.0,
  ),
  glucosa(
    id: 3,
    nombre: 'Glucosa en Sangre',
    nombreCorto: 'Glucosa',
    unidad: 'mg/dL',
    rangoMinNormal: 70.0,
    rangoMaxNormal: 100.0,
  ),
  peso(
    id: 4,
    nombre: 'Peso Corporal',
    nombreCorto: 'Peso',
    unidad: 'kg',
    rangoMinNormal: null,
    rangoMaxNormal: null,
  ),
  frecuenciaCardiaca(
    id: 5,
    nombre: 'Frecuencia Cardíaca',
    nombreCorto: 'Frec. Cardiaca',
    unidad: 'lpm',
    rangoMinNormal: 60.0,
    rangoMaxNormal: 100.0,
  );

  final int id;
  final String nombre;
  final String nombreCorto;
  final String unidad;
  final double? rangoMinNormal;
  final double? rangoMaxNormal;

  const TipoMetrica({
    required this.id,
    required this.nombre,
    required this.nombreCorto,
    required this.unidad,
    this.rangoMinNormal,
    this.rangoMaxNormal,
  });

  static TipoMetrica fromId(int id) {
    return TipoMetrica.values.firstWhere(
      (m) => m.id == id,
      orElse: () => TipoMetrica.glucosa,
    );
  }

  static TipoMetrica? tryFromId(int id) {
    try {
      return TipoMetrica.values.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }
}

/// Categorías agrupadas para la UI (Glucosa, Presión, Frec. Cardiaca, Peso)
enum CategoriaMetrica {
  glucosa('Glucosa', 'mg/dL'),
  presion('Presión', 'mmHg'),
  frecuenciaCardiaca('Frec. Cardiaca', 'lpm'),
  peso('Peso', 'kg');

  final String label;
  final String unidad;

  const CategoriaMetrica(this.label, this.unidad);
}
