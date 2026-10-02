import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worklog/app_state.dart';
import 'package:worklog/main.dart';
import 'package:worklog/screens/job_flow.dart';
import 'package:worklog/screens/onboarding.dart';

void main() {
  testWidgets('WORKLOG prikazuje početno uvođenje', (tester) async {
    await tester.pumpWidget(const WorklogApp());
    expect(find.text('Organiziraj posao na terenu.'), findsOneWidget);
    expect(find.text('Preskoči'), findsOneWidget);
  });

  testWidgets('novi posao bez klijenata prikazuje sigurno prazno stanje', (
    tester,
  ) async {
    final state = AppState();

    await tester.pumpWidget(MaterialApp(home: NewJobScreen(state: state)));
    await tester.pump();

    expect(find.textContaining('Nema spremljenih klijenata'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('lokalni pristup ne prikazuje lažnu serversku prijavu', (
    tester,
  ) async {
    final state = AppState();

    await tester.pumpWidget(MaterialApp(home: LoginScreen(state: state)));
    await tester.pump();

    expect(find.text('Rad na ovom uređaju'), findsOneWidget);
    expect(find.text('Nastavi na ovom uređaju'), findsOneWidget);
    expect(find.text('Zaboravljena lozinka?'), findsNothing);
    expect(find.text('Nastavi s Googleom'), findsNothing);
    expect(find.text('Nastavi s Appleom'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
