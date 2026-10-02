import 'package:flutter_test/flutter_test.dart';
import 'package:worklog/models.dart';

void main() {
  test('WorkJob JSON zapis zadržava produkcijske podatke', () {
    final client = Client(
      name: 'Ivica Horvat',
      type: 'Privatna osoba',
      phone: '091 123 4567',
      email: 'ivica@example.com',
      address: 'Zagreb',
    );
    final original = WorkJob(
      id: 'job-1',
      title: 'Servis klime',
      client: client,
      location: 'Zagreb',
      scheduledStart: DateTime(2026, 10, 2, 8),
      scheduledEnd: DateTime(2026, 10, 2, 10, 30),
      status: JobStatus.completed,
      minutesWorked: 95,
      materials: const [
        MaterialItem(name: 'Filter', quantity: '1 kom', price: 18),
      ],
      notes: ['Provjeren tlak.'],
      beforePhotoPaths: ['/tmp/prije.jpg'],
      afterPhotoPaths: ['/tmp/poslije.jpg'],
      signaturePath: '/tmp/potpis.png',
      reportPath: '/tmp/zapisnik.pdf',
      reportSent: true,
      assignedMemberId: 'team-1',
      assignedMemberName: 'Ivan Barić',
    );

    final restored = WorkJob.fromJson(original.toJson());

    expect(restored.id, original.id);
    expect(restored.title, original.title);
    expect(restored.status, JobStatus.completed);
    expect(restored.minutesWorked, 95);
    expect(restored.materials.single.name, 'Filter');
    expect(restored.notes.single, 'Provjeren tlak.');
    expect(restored.beforePhotoPaths.single, '/tmp/prije.jpg');
    expect(restored.afterPhotoPaths.single, '/tmp/poslije.jpg');
    expect(restored.signaturePath, '/tmp/potpis.png');
    expect(restored.reportPath, '/tmp/zapisnik.pdf');
    expect(restored.reportSent, isTrue);
    expect(restored.client.id, client.id);
    expect(restored.assignedMemberId, 'team-1');
    expect(restored.assignedMemberName, 'Ivan Barić');
    expect(restored.scheduledStart, DateTime(2026, 10, 2, 8));
    expect(restored.scheduledEnd, DateTime(2026, 10, 2, 10, 30));
    expect(restored.dateLabel, '2. listopada 2026.');
    expect(restored.timeLabel, '08:00 – 10:30');
  });

  test('stari tekstualni termin migrira se u stvarni DateTime raspored', () {
    final restored = WorkJob.fromJson({
      'id': 'legacy-job',
      'title': 'Stari posao',
      'client': {
        'name': 'Klijent',
        'type': 'Privatna osoba',
        'phone': '',
        'email': '',
        'address': '',
      },
      'location': 'Rijeka',
      'dateLabel': '12. ožujka 2026.',
      'timeLabel': '08:15 – 09:45',
      'status': 'planned',
    });

    expect(restored.scheduledStart, DateTime(2026, 3, 12, 8, 15));
    expect(restored.scheduledEnd, DateTime(2026, 3, 12, 9, 45));
  });

  test('setSchedule usklađuje DateTime i hrvatske oznake termina', () {
    final job = WorkJob(
      title: 'Termin',
      client: Client(
        name: 'Klijent',
        type: 'Tvrtka',
        phone: '',
        email: '',
        address: '',
      ),
      location: 'Rijeka',
      status: JobStatus.planned,
    );

    job.setSchedule(
      DateTime(2026, 11, 4, 14),
      DateTime(2026, 11, 4, 15, 30),
    );

    expect(job.dateLabel, '4. studenoga 2026.');
    expect(job.timeLabel, '14:00 – 15:30');
  });

  test('ConversationMessage JSON zadržava smjer i vrijeme poruke', () {
    final createdAt = DateTime(2026, 10, 2, 12, 45);
    final original = ConversationMessage(
      id: 'message-1',
      clientId: 'client-1',
      text: 'Dolazim u 13:00.',
      mine: true,
      createdAt: createdAt,
    );

    final restored = ConversationMessage.fromJson(original.toJson());

    expect(restored.id, 'message-1');
    expect(restored.clientId, 'client-1');
    expect(restored.text, 'Dolazim u 13:00.');
    expect(restored.mine, isTrue);
    expect(restored.createdAt, createdAt);
  });

  test('ActivityItem JSON zadržava read status', () {
    final original = ActivityItem(
      id: 'activity-1',
      title: 'Posao završen',
      subtitle: 'Servis klime',
      kind: 'job',
      createdAt: DateTime(2026, 10, 2, 14),
      read: true,
    );

    final restored = ActivityItem.fromJson(original.toJson());

    expect(restored.id, 'activity-1');
    expect(restored.kind, 'job');
    expect(restored.read, isTrue);
    expect(restored.createdAt, DateTime(2026, 10, 2, 14));
  });

  test('AppPreferences JSON zapis zadržava sigurnosne postavke', () {
    const preferences = AppPreferences(
      notificationsEnabled: false,
      autoSaveEnabled: true,
      biometricLockEnabled: true,
      compactCards: true,
    );

    final restored = AppPreferences.fromJson(preferences.toJson());

    expect(restored.notificationsEnabled, isFalse);
    expect(restored.autoSaveEnabled, isTrue);
    expect(restored.biometricLockEnabled, isTrue);
    expect(restored.compactCards, isTrue);
  });
}
