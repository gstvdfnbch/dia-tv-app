import 'package:flutter_test/flutter_test.dart';

import 'package:dia_tv_app/main.dart';

void main() {
  testWidgets('App inicia e mostra a tab bar', (WidgetTester tester) async {
    await tester.pumpWidget(const DiaTvApp());
    await tester.pump();
    expect(find.byType(DiaTvApp), findsOneWidget);
  });
}
