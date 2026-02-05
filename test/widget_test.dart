import 'package:flutter_test/flutter_test.dart';

import 'package:lifevault/main.dart';

void main() {
  testWidgets('App renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const LifeVaultApp());

    expect(find.text('LifeVault'), findsOneWidget);
  });
}
