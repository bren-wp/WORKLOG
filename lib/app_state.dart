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
  final List<TeamMember> teamMembers = [];

  CompanyProfile companyProfile = const CompanyProfile();
  AppPreferences preferences = const AppPreferences();

  int activeTab = 0;
  bool onboardingComplete = false;
  bool loggedIn = false;
  bool profileReady = false;

  void _seed() {
    final ivica = Client(
      id: 'client-ivica',
      name: "Ivica Horvat",
      type: "Privatna osoba",
      phone: "091 123 4567",
      email: "ivica.horvat@example.com",
      address: "Zagreb, Trešnjevka",
    );
    final marija = Client(
      id: 'client-marija',
      name: "Marija Kovač",
      type: "Privatna osoba",
      phone: "091 987 6543",
      email: "marija.kovac@example.com",
      address: "Zagreb, Maksimir",
    );
    final korzo = Client(
      id: 'client-korzo',
      name: "Restoran Korzo",
      type: "Tvrtka",
      phone: "091 555 1234",
      email: "ured@korzo.example.com",
      address: "Zagreb, Centar",
    );
    final goran = Client(
      id: 'client-goran',
      name: "Goran Babić",
      type: "Privatna osoba",
      phone: "091 222 3344",
      email: "goran.babic@example.com",
      address: "Velika Gorica",
    );
    clients.addAll([ivica, marija, korzo, goran]);

    teamMembers.addAll([
      TeamMember(
        id: 'team-owner',
        name: 'Marko Horvat',
        role: 'Vlasnik / administrator',
        phone: '091 100 2000',
        email: 'marko@worklog.hr',
      ),
      TeamMember(
        id: 'team-tehnicar',
        name: 'Ivan Barić',
        role: 'Terenski tehničar',
        phone: '091 300 4000',
        email: 'ivan@worklog.hr',
      ),
    ]);

    companyProfile = const CompanyProfile(
      name: 'WORKLOG servis',
      activity: 'Instalacije i klimatizacija',
      phone: '091 100 2000',
      email: 'ured@worklog.hr',
      address: 'Zagreb, Hrvatska',
      oib: '',
    );

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
        .map((value) => Client.fromJson(Map<String, dynamic>.from(value)))
        .toList();

    final savedJobs = (data['jobs'] as List? ?? const [])
        .whereType<Map>()
        .map((value) => WorkJob.fromJson(Map<String, dynamic>.from(value)))
        .toList();

    final savedTeam = (data['teamMembers'] as List? ?? const [])
        .whereType<Map>()
        .map((value) => TeamMember.fromJson(Map<String, dynamic>.from(value)))
        .toList();

    final companyRaw = data['companyProfile'];
    if (companyRaw is Map) {
      companyProfile = CompanyProfile.fromJson(
        Map<String, dynamic>.from(companyRaw),
      );
    }

    final preferencesRaw = data['preferences'];
    if (preferencesRaw is Map) {
      preferences = AppPreferences.fromJson(
        Map<String, dynamic>.from(preferencesRaw),
      );
    }

    if (savedClients.isNotEmpty) {
      clients
        ..clear()
        ..addAll(savedClients);
    }

    if (savedJobs.isNotEmpty) {
      for (final job in savedJobs) {
        final canonical = clients.cast<Client?>().firstWhere(
              (client) =>
                  client?.id == job.client.id ||
                  (client?.email.isNotEmpty == true &&
                      client?.email == job.client.email),
              orElse: () => null,
            );
        if (canonical != null) {
          job.client = canonical;
        }
      }
      jobs
        ..clear()
        ..addAll(savedJobs);
    }

    if (savedTeam.isNotEmpty) {
      teamMembers
        ..clear()
        ..addAll(savedTeam);
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

  void addClient(Client client) {
    clients.insert(0, client);
    notifyListeners();
    _schedulePersist();
  }

  void updateClient(Client updated) {
    final index = clients.indexWhere((client) => client.id == updated.id);
    if (index < 0) return;
    clients[index] = updated;
    for (final job in jobs) {
      if (job.client.id == updated.id) {
        job.client = updated;
      }
    }
    notifyListeners();
    _schedulePersist();
  }

  bool removeClient(String clientId) {
    final hasJobs = jobs.any((job) => job.client.id == clientId);
    if (hasJobs) return false;
    clients.removeWhere((client) => client.id == clientId);
    notifyListeners();
    _schedulePersist();
    return true;
  }

  void updateCompanyProfile(CompanyProfile profile) {
    companyProfile = profile;
    profileReady = true;
    notifyListeners();
    _schedulePersist();
  }

  void addTeamMember(TeamMember member) {
    teamMembers.insert(0, member);
    notifyListeners();
    _schedulePersist();
  }

  void updateTeamMember(TeamMember updated) {
    final index = teamMembers.indexWhere((member) => member.id == updated.id);
    if (index < 0) return;
    teamMembers[index] = updated;
    notifyListeners();
    _schedulePersist();
  }

  void removeTeamMember(String memberId) {
    teamMembers.removeWhere((member) => member.id == memberId);
    notifyListeners();
    _schedulePersist();
  }

  void updatePreferences(AppPreferences value) {
    preferences = value;
    notifyListeners();
    _schedulePersist();
  }

  Future<void> persistNow() => _persist();

  void _schedulePersist() {
    if (!preferences.autoSaveEnabled) return;
    unawaited(_persist());
  }

  Future<void> _persist() async {
    final service = storage;
    if (service == null) return;
    try {
      await service.writeState({
        'schemaVersion': 3,
        'onboardingComplete': onboardingComplete,
        'profileReady': profileReady,
        'companyProfile': companyProfile.toJson(),
        'preferences': preferences.toJson(),
        'clients': clients.map((client) => client.toJson()).toList(),
        'teamMembers': teamMembers.map((member) => member.toJson()).toList(),
        'jobs': jobs.map((job) => job.toJson()).toList(),
      });
    } catch (error, stackTrace) {
      debugPrint('WORKLOG pohrana nije uspjela: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}
