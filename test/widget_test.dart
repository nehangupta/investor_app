import 'package:flutter_test/flutter_test.dart';
import 'package:investor_app/main.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const InvestorApp());
    expect(find.byType(InvestorApp), findsOneWidget);
  });
}