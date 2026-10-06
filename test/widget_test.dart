import 'package:flutter_test/flutter_test.dart';
import 'package:callbridge/main.dart';

void main() {
  testWidgets('CallBridge app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CallBridgeApp());
    await tester.pumpAndSettle();

    // Verify Call Bridge home screen renders
    expect(find.text('CALL BRIDGE'), findsOneWidget);
    expect(find.text('Play vs Bots'), findsOneWidget);
  });
}
