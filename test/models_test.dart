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
      dateLabel: '2. listopada 2026.',
      timeLabel: '08:00',
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
