import 'package:flutter_test/flutter_test.dart';
import 'package:worklog/app_state.dart';
import 'package:worklog/models.dart';

void main() {
  test('početni poslovi imaju stvarni raspored', () {
    final state = AppState();

    expect(state.jobs, isNotEmpty);
    expect(state.jobs.every((job) => job.scheduledStart != null), isTrue);
    expect(
      state.jobs.every(
        (job) =>
            job.scheduledEnd == null ||
            job.scheduledEnd!.isAfter(job.scheduledStart!),
      ),
      isTrue,
    );
  });

  test('uređivanje klijenta ažurira klijenta na povezanim poslovima', () {
    final state = AppState();
    final original = state.clients.first;
    final linkedJobs = state.jobs
        .where((job) => job.client.id == original.id)
        .toList();

    final updated = original.copyWith(
      name: 'Ažurirani klijent',
      phone: '091 000 0000',
    );
    state.updateClient(updated);

    expect(state.clients.firstWhere((c) => c.id == original.id).name,
        'Ažurirani klijent');
    for (final job in linkedJobs) {
      expect(job.client.name, 'Ažurirani klijent');
      expect(job.client.phone, '091 000 0000');
    }
  });

  test('klijent s povezanim poslom ne može se izbrisati', () {
    final state = AppState();
    final client = state.jobs.first.client;

    expect(state.removeClient(client.id), isFalse);
    expect(state.clients.any((item) => item.id == client.id), isTrue);
  });

  test('član s aktivnim dodijeljenim poslom ne može se ukloniti', () {
    final state = AppState();
    final member = state.teamMembers.firstWhere(
      (item) => state.jobs.any(
        (job) =>
            job.assignedMemberId == item.id &&
            job.status != JobStatus.completed,
      ),
    );

    expect(state.removeTeamMember(member.id), isFalse);
    expect(state.teamMembers.any((item) => item.id == member.id), isTrue);
  });

  test('odgovor klijenta stvara trajni nepročitani događaj', () {
    final state = AppState();
    final client = state.clients.first;

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
    expect(snapshot['messages'], isA<List>());
    expect(snapshot['activityItems'], isA<List>());
  });

  test('moja poruka ne stvara lažnu novu obavijest', () {
    final state = AppState();
    final client = state.clients.first;

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
    final client = Client(
      name: 'Testni klijent',
      type: 'Privatna osoba',
      phone: '',
      email: '',
      address: '',
    );
    state.addClient(client);

    expect(state.removeClient(client.id), isTrue);
    expect(state.clients.any((item) => item.id == client.id), isFalse);
  });
}
