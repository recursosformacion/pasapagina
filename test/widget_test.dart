import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pasapagina/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('Pasapagina muestra la biblioteca inicial', (tester) async {
    await tester.pumpWidget(const PasapaginaApp());

    // Allow the asynchronous library load to finish without waiting on
    // animations that may remain active in the application.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Pasapagina'), findsWidgets);
  });
}
