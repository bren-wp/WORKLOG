import 'dart:async';

import 'package:flutter/foundation.dart';

import 'models.dart';
import 'services/local_storage_service.dart';

class AppState extends ChangeNotifier {
  AppState({this.storage}) {
    _seed();
  }

  final LocalStorageService? storage;
  final List<Client> clients = [];
  final List<WorkJob> jobs = [];

  int activeTab = 0;
  bool onboardingComplete = false;
  bool loggedIn = false;
  bool profileReady = false;

  void _seed() {
    final ivica = const Client(
      name: "Ivica Horvat",
      type: "Privatna osoba",
      phone: "091 123 4567",
      email: "ivica.horvat@example.com",
      address: "Zagreb, Trešnjevka",
    );
    final marija = const Client(
      name: "Marija Kovač",
      type: "Privatna osoba",
      phone: "091 987 6543",
      email: "marija.kovac@example.com",
      address: "Zagreb, Maksimir",
    );
    final korzo = const Client(
      name: "Restoran Korzo",
      type: "Tvrtka",
      phone: "091 555 1234",
      email: "ured@korzo.example.com",
      address: "Zagreb, Centar",
    );
    final goran = const Client(
      name: "Goran Babić",
      type: "Privatna osoba",
      phone: "091 222 3344",
      email: "goran.babic@example.com",
      address: "Velika Gorica",
    );
    clients.addAll([ivica, marija, korzo, goran]);

    jobs.addAll([
      WorkJob(
        id: 'demo-klima',
        title: "Servis klima uređaja",
        client: ivica,
        location: "Zagreb, Trešnjevka",
        dateLabel: "12. ožujka 2026.",
        timeLabel: "08:00 – 12:00",
        status: JobStatus.active,
        description: "Redovni servis, čišćenje filtera i provjera rada.",
        minutesWorked: 135,
        materials: const [
          MaterialItem(
            name: "Sredstvo za čišćenje",
            quantity: "1 kom",
            price: 12.50,
          ),
          MaterialItem(name: "Filter klime", quantity: "1 kom", price: 18),
          MaterialItem(name: "Plin R32", quantity: "0,5 kg", price: 35),
        ],
      ),
      WorkJob(
        id: 'demo-bojler',
        title: "Servis bojlera",
        client: marija,
        location: "Zagreb, Maksimir",
        dateLabel: "12. ožujka 2026.",
        timeLabel: "11:30 – 13:00",
        status: JobStatus.planned,
      ),
      WorkJob(
        id: 'demo-rasvjeta',
        title: "Ugradnja rasvjete",
        client: korzo,
        location: "Zagreb, Centar",
        dateLabel: "13. ožujka 2026.",
        timeLabel: "09:00 – 12:00",
        status: JobStatus.planned,
      ),
      WorkJob(
        id: 'demo-instalacije',
        title: "Sanacija instalacija",
        client: goran,
        location: "Velika Gorica",
        dateLabel: "10. ožujka 2026.",
        timeLabel: "14:30 – 16:00",
        status: JobStatus.completed,
      ),
    ]);
  }

  Future<void> load() async {
    final service = storage;
    if (service == null) return;

    final data = await service.readState();
    if (data == null) {
      await _persist();
      return;
    }

    onboardingComplete = data['onboardingComplete'] as bool? ?? false;
    profileReady = data['profileReady'] as bool? ?? false;

    final savedClients = (data['clients'] as List? ?? const [])
        .whereType<Map>()
        .map(
          (value) => Client.fromJson(Map<String, dynamic>.from(value)),
        )
        .toList();

    final savedJobs = (data['jobs'] as List? ?? const [])
        .whereType<Map>()
        .map(
          (value) => WorkJob.fromJson(Map<String, dynamic>.from(value)),
        )
        .toList();

    if (savedClients.isNotEmpty) {
      clients
        ..clear()
        ..addAll(savedClients);
    }

    if (savedJobs.isNotEmpty) {
      jobs
        ..clear()
        ..addAll(savedJobs);
    }
  }

  void setTab(int value) {
    activeTab = value;
    notifyListeners();
  }

  void finishOnboarding() {
    onboardingComplete = true;
    notifyListeners();
    _schedulePersist();
  }

  void login() {
    loggedIn = true;
    notifyListeners();
  }

  void setupProfile() {
    profileReady = true;
    notifyListeners();
    _schedulePersist();
  }

  void addJob(WorkJob job) {
    jobs.insert(0, job);
    notifyListeners();
    _schedulePersist();
  }

  void updateJob() {
    notifyListeners();
    _schedulePersist();
  }

  Future<void> persistNow() => _persist();

  void _schedulePersist() {
    unawaited(_persist());
  }

  Future<void> _persist() async {
    final service = storage;
    if (service == null) return;
    try {
      await service.writeState({
        'schemaVersion': 2,
        'onboardingComplete': onboardingComplete,
        'profileReady': profileReady,
        'clients': clients.map((client) => client.toJson()).toList(),
        'jobs': jobs.map((job) => job.toJson()).toList(),
      });
    } catch (error, stackTrace) {
      debugPrint('WORKLOG pohrana nije uspjela: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}
