import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worklog/app_state.dart';
import 'package:worklog/models.dart';
import 'package:worklog/screens/onboarding.dart';
import 'package:worklog/screens/shell.dart';
import 'package:worklog/worklog_theme.dart';

Future<void> pumpStoreScreen(
  WidgetTester tester,
  Widget child,
) async {
  tester.view.physicalSize = const Size(1320, 2868);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildWorklogTheme(),
      home: Scaffold(body: SafeArea(child: child)),
    ),
  );
  await tester.pumpAndSettle();
}

AppState populatedState() {
  final state = AppState();
  state.companyProfile = const CompanyProfile(
    name: 'WORKLOG servis',
    activity: 'Servis i održavanje',
    phone: '051 555 010',
    email: 'teren@worklog.hr',
    address: 'Rijeka',
    oib: '12345678901',
    employeeRange: '6 – 20',
  );

  final clientA = Client(
    id: 'client-a',
    name: 'Adria Projekt d.o.o.',
    type: 'Tvrtka',
    phone: '091 222 3300',
    email: 'operativa@adriaprojekt.hr',
    address: 'Rijeka',
  );
  final clientB = Client(
    id: 'client-b',
    name: 'Marin Kovač',
    type: 'Privatna osoba',
    phone: '098 414 212',
    email: 'marin@example.hr',
    address: 'Opatija',
  );

  final now = DateTime.now();
  state.clients.addAll([clientA, clientB]);
  state.teamMembers.addAll([
    TeamMember(
      id: 'tech-1',
      name: 'Ivan Barić',
      role: 'Tehničar',
      phone: '091 101 2020',
      email: 'ivan@worklog.hr',
    ),
    TeamMember(
      id: 'lead-1',
      name: 'Petra Horvat',
      role: 'Voditelj',
      phone: '091 303 4040',
      email: 'petra@worklog.hr',
    ),
  ]);

  state.jobs.addAll([
    WorkJob(
      id: 'job-active',
      title: 'Servis klimatizacije',
      client: clientA,
      location: 'Korzo 12, Rijeka',
      scheduledStart: DateTime(now.year, now.month, now.day, 9, 0),
      scheduledEnd: DateTime(now.year, now.month, now.day, 11, 30),
      status: JobStatus.active,
      priority: 'Visoki',
      assignedMemberId: 'tech-1',
      assignedMemberName: 'Ivan Barić',
      timeEntries: [
        WorkTimeEntry(
          id: 'time-1',
          startedAt: DateTime(now.year, now.month, now.day, 9, 0),
          endedAt: DateTime(now.year, now.month, now.day, 10, 5),
        ),
      ],
      checklist: [
        ChecklistItem(label: 'Provjeriti stanje uređaja', completed: true),
        ChecklistItem(label: 'Fotografirati završno stanje'),
      ],
    ),
    WorkJob(
      id: 'job-confirmed',
      title: 'Redovni pregled sustava',
      client: clientB,
      location: 'Maršala Tita 84, Opatija',
      scheduledStart: DateTime(now.year, now.month, now.day, 13, 30),
      scheduledEnd: DateTime(now.year, now.month, now.day, 15, 0),
      status: JobStatus.confirmed,
      priority: 'Srednji',
      assignedMemberId: 'lead-1',
      assignedMemberName: 'Petra Horvat',
    ),
    WorkJob(
      id: 'job-finished',
      title: 'Zamjena upravljačke jedinice',
      client: clientA,
      location: 'Industrijska zona, Kukuljanovo',
      scheduledStart: DateTime(now.year, now.month, now.day, 7, 30),
      scheduledEnd: DateTime(now.year, now.month, now.day, 8, 30),
      status: JobStatus.completed,
      priority: 'Srednji',
      minutesWorked: 58,
      reportPath: '/zapisnici/job-finished.pdf',
      assignedMemberId: 'tech-1',
      assignedMemberName: 'Ivan Barić',
    ),
  ]);

  return state;
}

void main() {
  testWidgets('store screenshot onboarding', (tester) async {
    final state = AppState();
    await pumpStoreScreen(tester, OnboardingScreen(state: state));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('generated-screenshots/worklog-onboarding.png'),
    );
  });

  testWidgets('store screenshot lokalni pristup', (tester) async {
    final state = AppState();
    await pumpStoreScreen(tester, LoginScreen(state: state));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('generated-screenshots/worklog-local-access.png'),
    );
  });

  testWidgets('store screenshot dashboard', (tester) async {
    final state = populatedState();
    await pumpStoreScreen(tester, DashboardScreen(state: state));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('generated-screenshots/worklog-dashboard.png'),
    );
  });

  testWidgets('store screenshot poslovi', (tester) async {
    final state = populatedState();
    await pumpStoreScreen(tester, JobsScreen(state: state));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('generated-screenshots/worklog-jobs.png'),
    );
  });

  testWidgets('store screenshot klijenti', (tester) async {
    final state = populatedState();
    await pumpStoreScreen(tester, ClientsScreen(state: state));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('generated-screenshots/worklog-clients.png'),
    );
  });

  testWidgets('store screenshot kalendar', (tester) async {
    final state = populatedState();
    await pumpStoreScreen(tester, CalendarScreen(state: state));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('generated-screenshots/worklog-calendar.png'),
    );
  });
}
