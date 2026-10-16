import 'package:flutter_test/flutter_test.dart';
import 'package:pasapagina/main.dart';

void main() {
  testWidgets('Pasapagina muestra la biblioteca inicial', (tester) async {
    await tester.pumpWidget(const PasapaginaApp());

    expect(find.text('Pasapagina'), findsWidgets);
  });
}
