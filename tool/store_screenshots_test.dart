import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worklog/app_state.dart';
import 'package:worklog/models.dart';
import 'package:worklog/services/auth_service.dart';
import 'package:worklog/screens/onboarding.dart';
import 'package:worklog/screens/shell.dart';
import 'package:worklog/worklog_theme.dart';

Future<void> captureStoreScreen(
  WidgetTester tester, {
  required Widget child,
  required Size physicalSize,
  required double devicePixelRatio,
  required String filePath,
}) async {
  tester.view.physicalSize = physicalSize;
  tester.view.devicePixelRatio = devicePixelRatio;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final captureKey = GlobalKey();
  await tester.pumpWidget(
    RepaintBoundary(
      key: captureKey,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildWorklogTheme(),
        home: Scaffold(body: SafeArea(child: child)),
      ),
    ),
  );
  await tester.pumpAndSettle();

  final boundary =
      captureKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final logicalWidth = physicalSize.width / devicePixelRatio;
  final captureRatio = physicalSize.width / logicalWidth;

  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: captureRatio);
    try {
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw StateError('Flutter nije mogao generirati PNG screenshot.');
      }

      final file = File(filePath);
      await file.parent.create(recursive: true);
      await file.writeAsBytes(byteData.buffer.asUint8List(), flush: true);

      if (image.width != physicalSize.width.round() ||
          image.height != physicalSize.height.round()) {
        throw StateError(
          'Neispravna screenshot dimenzija: '
          '${image.width}x${image.height}, očekivano '
          '${physicalSize.width.round()}x${physicalSize.height.round()}.',
        );
      }
    } finally {
      image.dispose();
    }
  });
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
      scheduledStart: DateTime(now.year, now.month, now.day, 9),
      scheduledEnd: DateTime(now.year, now.month, now.day, 11, 30),
      status: JobStatus.active,
      priority: 'Visoki',
      assignedMemberId: 'tech-1',
      assignedMemberName: 'Ivan Barić',
      timeEntries: [
        WorkTimeEntry(
          id: 'time-1',
          startedAt: DateTime(now.year, now.month, now.day, 9),
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
      scheduledEnd: DateTime(now.year, now.month, now.day, 15),
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

Future<void> capturePhoneSet(
  WidgetTester tester, {
  required String directory,
  required Size physicalSize,
  required double devicePixelRatio,
}) async {
  final state = populatedState();

  await captureStoreScreen(
    tester,
    child: OnboardingScreen(state: AppState()),
    physicalSize: physicalSize,
    devicePixelRatio: devicePixelRatio,
    filePath: '$directory/worklog-onboarding.png',
  );
  await captureStoreScreen(
    tester,
    child: LoginScreen(
      state: AppState(
        auth: AuthService(baseUrl: 'https://worklog.example/api/v1'),
      ),
    ),
    physicalSize: physicalSize,
    devicePixelRatio: devicePixelRatio,
    filePath: '$directory/worklog-local-access.png',
  );
  await captureStoreScreen(
    tester,
    child: DashboardScreen(state: state),
    physicalSize: physicalSize,
    devicePixelRatio: devicePixelRatio,
    filePath: '$directory/worklog-dashboard.png',
  );
  await captureStoreScreen(
    tester,
    child: JobsScreen(state: state),
    physicalSize: physicalSize,
    devicePixelRatio: devicePixelRatio,
    filePath: '$directory/worklog-jobs.png',
  );
  await captureStoreScreen(
    tester,
    child: ClientsScreen(state: state),
    physicalSize: physicalSize,
    devicePixelRatio: devicePixelRatio,
    filePath: '$directory/worklog-clients.png',
  );
  await captureStoreScreen(
    tester,
    child: CalendarScreen(state: state),
    physicalSize: physicalSize,
    devicePixelRatio: devicePixelRatio,
    filePath: '$directory/worklog-calendar.png',
  );
}

void main() {
  testWidgets('generiraj iPhone 6.9 screenshot set', (tester) async {
    await capturePhoneSet(
      tester,
      directory: 'tool/generated-screenshots/iphone-6.9',
      physicalSize: const Size(1320, 2868),
      devicePixelRatio: 3,
    );
  });

  testWidgets('generiraj Android 9:16 screenshot set', (tester) async {
    await capturePhoneSet(
      tester,
      directory: 'tool/generated-screenshots/android-phone',
      physicalSize: const Size(1080, 1920),
      devicePixelRatio: 3,
    );
  });

  testWidgets('generiraj iPad 13 screenshot set', (tester) async {
    final state = populatedState();
    const size = Size(2064, 2752);
    const ratio = 2.0;

    await captureStoreScreen(
      tester,
      child: DashboardScreen(state: state),
      physicalSize: size,
      devicePixelRatio: ratio,
      filePath: 'tool/generated-screenshots/ipad-13/worklog-dashboard.png',
    );
    await captureStoreScreen(
      tester,
      child: JobsScreen(state: state),
      physicalSize: size,
      devicePixelRatio: ratio,
      filePath: 'tool/generated-screenshots/ipad-13/worklog-jobs.png',
    );
    await captureStoreScreen(
      tester,
      child: CalendarScreen(state: state),
      physicalSize: size,
      devicePixelRatio: ratio,
      filePath: 'tool/generated-screenshots/ipad-13/worklog-calendar.png',
    );
    await captureStoreScreen(
      tester,
      child: ClientsScreen(state: state),
      physicalSize: size,
      devicePixelRatio: ratio,
      filePath: 'tool/generated-screenshots/ipad-13/worklog-clients.png',
    );
  });
}
