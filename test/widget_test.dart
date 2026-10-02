import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worklog/app_state.dart';
import 'package:worklog/main.dart';
import 'package:worklog/screens/job_flow.dart';

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

    await tester.pumpWidget(
      MaterialApp(home: NewJobScreen(state: state)),
    );
    await tester.pump();

    expect(
      find.textContaining('Nema spremljenih klijenata'),
      findsOneWidget,
    );
    final saveButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Spremi posao'),
    );
    expect(saveButton.onPressed, isNull);
    expect(tester.takeException(), isNull);
  });
}
