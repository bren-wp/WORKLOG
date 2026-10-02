import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worklog/app_state.dart';
import 'package:worklog/main.dart';
import 'package:worklog/models.dart';
import 'package:worklog/screens/global_search.dart';
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
  testWidgets('auth ekran nema Google ni Apple prijavu', (tester) async {
    final state = AppState();

    await tester.pumpWidget(MaterialApp(home: LoginScreen(state: state)));
    await tester.pump();

    expect(find.text('Prijava u WORKLOG'), findsOneWidget);
    expect(find.text('Prijava'), findsOneWidget);
    expect(find.text('Registracija'), findsOneWidget);
    expect(find.textContaining('Backend kod je u /web'), findsOneWidget);
    expect(find.text('Nastavi s Googleom'), findsNothing);
    expect(find.text('Nastavi s Appleom'), findsNothing);
    expect(find.text('Nastavi na ovom uređaju'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('globalna pretraga pronalazi klijenta po OIB-u', (tester) async {
    final state = AppState();
    final client = Client(
      id: 'client-oib',
      name: 'Adria Projekt d.o.o.',
      type: 'Tvrtka',
      phone: '091 555 1234',
      email: 'info@adria.hr',
      address: 'Rijeka',
      oib: '69435151530',
    );
    state.clients.add(client);
    state.jobs.add(
      WorkJob(
        id: 'nalog-2026-001',
        title: 'Servis klimatizacije',
        client: client,
        location: 'Korzo 12, Rijeka',
        status: JobStatus.confirmed,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(home: GlobalSearchScreen(state: state)),
    );
    await tester.pump();

    await tester.enterText(find.byType(TextField), '69435151530');
    await tester.pump();

    expect(find.text('Adria Projekt d.o.o.'), findsOneWidget);
    expect(find.textContaining('OIB 69435151530'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('globalna pretraga pronalazi posao po ID-u naloga', (
    tester,
  ) async {
    final state = AppState();
    final client = Client(
      id: 'client-1',
      name: 'Klijent',
      type: 'Privatna osoba',
      phone: '',
      email: '',
      address: 'Rijeka',
    );
    state.clients.add(client);
    state.jobs.add(
      WorkJob(
        id: 'nalog-2026-001',
        title: 'Servis klimatizacije',
        client: client,
        location: 'Rijeka',
        status: JobStatus.planned,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(home: GlobalSearchScreen(state: state)),
    );
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'nalog-2026-001');
    await tester.pump();

    expect(find.text('Servis klimatizacije'), findsOneWidget);
    expect(find.textContaining('ID nalog-2026-001'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
