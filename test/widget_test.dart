import 'package:flutter_test/flutter_test.dart';
import 'package:worklog/main.dart';

void main() {
  testWidgets('WORKLOG prikazuje početno uvođenje', (tester) async {
    await tester.pumpWidget(const WorklogApp());
    expect(find.text('Organiziraj posao na terenu.'), findsOneWidget);
    expect(find.text('Preskoči'), findsOneWidget);
  });
}
