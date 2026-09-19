import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:collector_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('live seeded API drives entrance and home', (tester) async {
    app.main();
    for (
      var i = 0;
      i < 30 && find.text('Enter Exhibition  →').evaluate().isEmpty;
      i++
    ) {
      await tester.pump(const Duration(seconds: 1));
    }
    expect(find.text('Beyond the horizon'), findsOneWidget);
    await tester.ensureVisible(find.text('Enter Exhibition  →'));
    await tester.tap(find.text('Enter Exhibition  →'));
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('A different way to see.'), findsOneWidget);
    expect(find.text('Curator’s Selection'), findsOneWidget);
  });
}
