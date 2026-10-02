import 'package:flutter_test/flutter_test.dart';
import 'package:worklog/app_state.dart';
import 'package:worklog/models.dart';

void main() {
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
