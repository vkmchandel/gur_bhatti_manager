import 'package:flutter_test/flutter_test.dart';

import 'package:gur_bhatti_manager/app/gur_bhatti_app.dart';

void main() {
  testWidgets('Dashboard home loads with session context', (WidgetTester tester) async {
    await tester.pumpWidget(const GurBhattiApp());
    await tester.pumpAndSettle();

    expect(find.text('GurBhattiManager'), findsWidgets);
    expect(find.textContaining('Session'), findsWidgets);
  });

  testWidgets('Bottom nav reaches Farmers master list', (WidgetTester tester) async {
    await tester.pumpWidget(const GurBhattiApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Farmers'));
    await tester.pumpAndSettle();

    expect(find.text('Master list'), findsOneWidget);
  });
}
