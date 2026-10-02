import 'package:flutter_test/flutter_test.dart';
import 'package:worklog/app_state.dart';
import 'package:worklog/models.dart';

Client testClient({String id = 'client-1'}) => Client(
      id: id,
      name: 'Testni klijent',
      type: 'Tvrtka',
      phone: '091 000 0000',
      email: 'test@example.com',
      address: 'Rijeka',
    );

WorkJob testJob(Client client) => WorkJob(
      id: 'job-1',
      title: 'Servis uređaja',
      client: client,
      location: 'Rijeka',
      scheduledStart: DateTime(2026, 10, 2, 8),
      scheduledEnd: DateTime(2026, 10, 2, 10),
      status: JobStatus.planned,
    );

void main() {
  test('produkcijsko stanje ne sadrži demo klijente ni poslove', () {
    final state = AppState();

    expect(state.clients, isEmpty);
    expect(state.jobs, isEmpty);
    expect(state.teamMembers, isEmpty);
    expect(state.activityItems, isEmpty);
  });

  test('uređivanje klijenta ažurira klijenta na povezanim poslovima', () {
    final state = AppState();
    final original = testClient();
    final job = testJob(original);
    state.clients.add(original);
    state.jobs.add(job);

    final updated = original.copyWith(
      name: 'Ažurirani klijent',
      phone: '091 111 2222',
    );
    state.updateClient(updated);

    expect(state.clients.single.name, 'Ažurirani klijent');
    expect(job.client.name, 'Ažurirani klijent');
    expect(job.client.phone, '091 111 2222');
  });

  test('klijent s povezanim poslom ne može se izbrisati', () {
    final state = AppState();
    final client = testClient();
    state.clients.add(client);
    state.jobs.add(testJob(client));

    expect(state.removeClient(client.id), isFalse);
    expect(state.clients.single.id, client.id);
  });

  test('član s otvorenim dodijeljenim poslom ne može se ukloniti', () {
    final state = AppState();
    final client = testClient();
    final member = TeamMember(
      id: 'member-1',
      name: 'Ivan Horvat',
      role: 'Tehničar',
      phone: '',
      email: 'ivan@example.com',
    );
    final job = testJob(client)
      ..assignedMemberId = member.id
      ..assignedMemberName = member.name
      ..status = JobStatus.confirmed;

    state.clients.add(client);
    state.teamMembers.add(member);
    state.jobs.add(job);

    expect(state.removeTeamMember(member.id), isFalse);
    expect(state.teamMembers.single.id, member.id);
  });

  test('timer čuva više intervala i ručnu korekciju s razlogom', () {
    final state = AppState();
    final client = testClient();
    final job = testJob(client);
    state.clients.add(client);
    state.jobs.add(job);

    final firstStart = DateTime(2026, 10, 2, 8);
    expect(state.startJobTimer(job, at: firstStart), isTrue);
    expect(job.status, JobStatus.active);
    expect(
      state.pauseJobTimer(
        job,
        at: firstStart.add(const Duration(seconds: 90)),
      ),
      isTrue,
    );
    expect(job.status, JobStatus.paused);

    final secondStart = DateTime(2026, 10, 2, 9);
    expect(state.startJobTimer(job, at: secondStart), isTrue);
    expect(
      state.stopJobTimer(
        job,
        at: secondStart.add(const Duration(seconds: 30)),
      ),
      isTrue,
    );

    expect(job.timeEntries, hasLength(2));
    expect(job.workedSeconds(), 120);
    expect(
      state.adjustJobTime(
        job,
        minutes: 15,
        reason: 'Naknadno evidentiran rad',
      ),
      isTrue,
    );
    expect(job.manualAdjustmentMinutes, 15);
    expect(job.manualAdjustmentReason, 'Naknadno evidentiran rad');
    expect(job.totalWorkedMinutes, 17);
  });

  test('odgovor klijenta stvara trajni nepročitani događaj', () {
    final state = AppState();
    final client = testClient();
    state.clients.add(client);

    state.addMessage(
      clientId: client.id,
      text: 'Potvrđujem termin.',
      mine: false,
    );

    expect(state.messagesForClient(client.id), hasLength(1));
    expect(state.unreadActivityCount, 1);
    expect(state.activityItems.first.kind, 'message');
    expect(state.activityItems.first.subtitle, client.name);

    state.markAllActivityRead();
    expect(state.unreadActivityCount, 0);

    final snapshot = state.exportSnapshot();
    expect(snapshot['schemaVersion'], 7);
    expect(snapshot['messages'], isA<List>());
    expect(snapshot['activityItems'], isA<List>());
  });

  test('moja poruka ne stvara lažnu novu obavijest', () {
    final state = AppState();
    final client = testClient();
    state.clients.add(client);

    state.addMessage(
      clientId: client.id,
      text: 'Dolazim prema planu.',
      mine: true,
    );

    expect(state.messagesForClient(client.id), hasLength(1));
    expect(state.activityItems, isEmpty);
  });

  test('klijent bez poslova može se izbrisati', () {
    final state = AppState();
    final client = testClient();
    state.clients.add(client);

    expect(state.removeClient(client.id), isTrue);
    expect(state.clients, isEmpty);
  });
}
