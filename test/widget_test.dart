import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:cronicare/main.dart';
import 'package:cronicare/screens/register_metric_input_screen.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es');
  });

  testWidgets('CroniCareApp smoke test renders LoginScreen and Logo',
      (WidgetTester tester) async {
    await tester.pumpWidget(const CroniCareApp());
    // Verifica que la pantalla de inicio de sesión y la marca se rendericen.
    expect(find.text('CroniCare'), findsOneWidget);
    expect(find.text('Iniciar Sesión'), findsNWidgets(2));
    expect(find.text('Correo Electrónico'), findsOneWidget);
  });

  testWidgets('RegisterMetricInputScreen renders single input for Glucosa',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: RegisterMetricInputScreen.glucosa(),
      ),
    );
    expect(find.text('Registrar Glucosa'), findsOneWidget);
    expect(find.text('¿Cuál es tu nivel de glucosa?'), findsOneWidget);
    expect(find.text('mg/dL'), findsOneWidget);
    expect(find.text('Guardar Medición'), findsOneWidget);
  });
}
