import 'package:flutter_test/flutter_test.dart';
import 'package:dr_haripada_appointment/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const DrHaripadaApp());
    expect(find.text('ডা. হরিপদ'), findsWidgets);
  });
}
