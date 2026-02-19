import 'package:flutter/material.dart'; 
import 'package:flutter_test/flutter_test.dart';
import 'package:toquiqtt/main.dart';
import 'package:toquiqtt/data/repositories/broker_repository.dart';

void main() {
  testWidgets('ToquiQTT smoke test', (WidgetTester tester) async {
    // 1. Instanciamos el repositorio requerido
    final brokerRepository = BrokerRepository();

    // 2. Construimos la app pasando el parámetro obligatorio
    await tester.pumpWidget(MyApp(brokerRepository: brokerRepository));

    // 3. Verificamos que el título de la App aparezca en la pantalla
    expect(find.text('ToquiQTT Brokers'), findsOneWidget);

    // 4. Verificamos que el botón de agregar (+) esté presente
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}
