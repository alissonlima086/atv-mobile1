import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warframe_codex/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('WarframeApp inicializa e renderiza estrutura basica', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const WarframeApp());

    expect(find.text('Warframe Codex'), findsOneWidget);
  });
}
