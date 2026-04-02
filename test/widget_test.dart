import 'package:flutter_test/flutter_test.dart';
import 'package:serviya/main.dart'; // Verifica que este sea el nombre de tu paquete

void main() {
  testWidgets('Prueba de carga inicial de ServiYa - Login', (
    WidgetTester tester,
  ) async {
    // 1. Construimos la app simulando que NO hay sesión iniciada.
    // Pasamos isLoggedIn: false y un rol vacío.
    await tester.pumpWidget(const ServiYaApp(isLoggedIn: false, userRole: ''));

    // 2. Verificamos que aparezca el botón de "INGRESAR" en mayúsculas (como lo pusimos en el código).
    expect(find.text('INGRESAR'), findsOneWidget);

    // 3. Verificamos que aparezca el texto para registrarse.
    // Nota: El texto original es "¿No tienes cuenta? Regístrate aquí"
    expect(find.textContaining('Regístrate aquí'), findsOneWidget);

    // 4. Verificamos que NO estemos en ninguna de las pantallas de Home.
    expect(find.textContaining('Panel de Técnico'), findsNothing);
    expect(find.textContaining('ServiYa Cliente'), findsNothing);
  });
}
