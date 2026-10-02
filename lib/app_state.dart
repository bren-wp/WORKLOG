import 'dart:async';

import 'package:flutter/foundation.dart';

import 'models.dart';
import 'services/local_storage_service.dart';

class AppState extends ChangeNotifier {
  AppState({this.storage});

  final LocalStorageService? storage;
  final List<Client> clients = [];
  final List<WorkJob> jobs = [];
  final List<TeamMember> teamMembers = [];
  final List<ConversationMessage> messages = [];
  final List<ActivityItem> activityItems = [];

  CompanyProfile companyProfile = const CompanyProfile();
  AppPreferences preferences = const AppPreferences();

  int activeTab = 0;
  bool onboardingComplete = false;
  bool loggedIn = false;
  bool profileReady = false;

  Future<void> load() async {
    final service = storage;
    if (service == null) return;

    final data = await service.readState();
    if (data == null) {
      await _persist();
      return;
    }

    final schemaVersion = (data['schemaVersion'] as num?)?.toInt() ?? 1;

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

    final savedMessages = (data['messages'] as List? ?? const [])
        .whereType<Map>()
        .map(
          (value) =>
              ConversationMessage.fromJson(Map<String, dynamic>.from(value)),
        )
        .toList();

    final savedActivity = (data['activityItems'] as List? ?? const [])
        .whereType<Map>()
        .map((value) => ActivityItem.fromJson(Map<String, dynamic>.from(value)))
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

    if (schemaVersion < 4) {
      preferences = preferences.copyWith(
        notificationsEnabled: false,
        biometricLockEnabled: false,
      );
    }

    if (savedClients.isNotEmpty) {
      clients
        ..clear()
        ..addAll(savedClients);
    }

    if (savedJobs.isNotEmpty) {
      for (final job in savedJobs) {
        Client? canonical;
        for (final client in clients) {
          if (client.id == job.client.id ||
              (client.email.isNotEmpty && client.email == job.client.email) ||
              (client.name == job.client.name &&
                  client.phone == job.client.phone)) {
            canonical = client;
            break;
          }
        }
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

    messages
      ..clear()
      ..addAll(savedMessages);

    activityItems
      ..clear()
      ..addAll(savedActivity)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
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
    _recordActivity(
      title: 'Novi posao',
      subtitle: '${job.title} • ${job.client.name}',
      kind: 'job',
    );
    notifyListeners();
    _schedulePersist();
  }

  bool startJobTimer(WorkJob job, {DateTime? at}) {
    if (!job.startTimer(at: at)) return false;
    job.status = JobStatus.active;
    _recordActivity(
      title: 'Mjerenje vremena pokrenuto',
      subtitle: '${job.title} • ${job.client.name}',
      kind: 'timer',
    );
    notifyListeners();
    _schedulePersist();
    return true;
  }

  bool pauseJobTimer(WorkJob job, {DateTime? at}) {
    if (!job.pauseTimer(at: at)) return false;
    if (!job.status.isClosed) {
      job.status = JobStatus.paused;
    }
    _recordActivity(
      title: 'Mjerenje vremena pauzirano',
      subtitle: '${job.title} • ${job.client.name}',
      kind: 'timer',
    );
    notifyListeners();
    _schedulePersist();
    return true;
  }

  bool stopJobTimer(WorkJob job, {DateTime? at}) {
    if (!job.pauseTimer(at: at)) return false;
    if (!job.status.isClosed) {
      job.status = JobStatus.active;
    }
    _recordActivity(
      title: 'Mjerenje vremena završeno',
      subtitle: '${job.title} • ${job.client.name}',
      kind: 'timer',
    );
    notifyListeners();
    _schedulePersist();
    return true;
  }

  bool adjustJobTime(
    WorkJob job, {
    required int minutes,
    required String reason,
  }) {
    final cleanReason = reason.trim();
    if (minutes == 0 || cleanReason.isEmpty) return false;
    job.addManualTimeAdjustment(minutes: minutes, reason: cleanReason);
    final sign = minutes > 0 ? '+' : '';
    _recordActivity(
      title: 'Ručna korekcija vremena',
      subtitle: '${job.title} • $sign$minutes min • $cleanReason',
      kind: 'timer',
    );
    notifyListeners();
    _schedulePersist();
    return true;
  }

  void updateJob({
    String? activityTitle,
    String? activitySubtitle,
    String kind = 'job',
  }) {
    if (activityTitle != null && activityTitle.trim().isNotEmpty) {
      _recordActivity(
        title: activityTitle.trim(),
        subtitle: activitySubtitle?.trim() ?? '',
        kind: kind,
      );
    }
    notifyListeners();
    _schedulePersist();
  }

  void addClient(Client client) {
    clients.insert(0, client);
    _recordActivity(
      title: 'Novi klijent',
      subtitle: client.name,
      kind: 'client',
    );
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

    String? clientName;
    for (final client in clients) {
      if (client.id == clientId) {
        clientName = client.name;
        break;
      }
    }

    clients.removeWhere((client) => client.id == clientId);
    messages.removeWhere((message) => message.clientId == clientId);
    if (clientName != null) {
      _recordActivity(
        title: 'Klijent uklonjen',
        subtitle: clientName,
        kind: 'client',
      );
    }
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
    _recordActivity(
      title: 'Novi član tima',
      subtitle: '${member.name} • ${member.role}',
      kind: 'team',
    );
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

  bool removeTeamMember(String memberId) {
    final hasOpenJobs = jobs.any(
      (job) => job.assignedMemberId == memberId && !job.status.isClosed,
    );
    if (hasOpenJobs) return false;

    final member = teamMemberById(memberId);
    teamMembers.removeWhere((item) => item.id == memberId);
    if (member != null) {
      _recordActivity(
        title: 'Član tima uklonjen',
        subtitle: member.name,
        kind: 'team',
      );
    }
    notifyListeners();
    _schedulePersist();
    return true;
  }

  List<ConversationMessage> messagesForClient(String clientId) {
    final result =
        messages.where((message) => message.clientId == clientId).toList()
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return result;
  }

  void addMessage({
    required String clientId,
    required String text,
    required bool mine,
  }) {
    final clean = text.trim();
    if (clean.isEmpty) return;

    messages.add(
      ConversationMessage(clientId: clientId, text: clean, mine: mine),
    );

    if (!mine) {
      String clientName = 'Klijent';
      for (final client in clients) {
        if (client.id == clientId) {
          clientName = client.name;
          break;
        }
      }
      _recordActivity(
        title: 'Novi odgovor klijenta',
        subtitle: clientName,
        kind: 'message',
      );
    }

    notifyListeners();
    _schedulePersist();
  }

  int get unreadActivityCount =>
      activityItems.where((item) => !item.read).length;

  void markActivityRead(String id) {
    for (final item in activityItems) {
      if (item.id == id) {
        item.read = true;
        break;
      }
    }
    notifyListeners();
    _schedulePersist();
  }

  void markAllActivityRead() {
    var changed = false;
    for (final item in activityItems) {
      if (!item.read) {
        item.read = true;
        changed = true;
      }
    }
    if (!changed) return;
    notifyListeners();
    _schedulePersist();
  }

  void clearReadActivity() {
    activityItems.removeWhere((item) => item.read);
    notifyListeners();
    _schedulePersist();
  }

  void recordActivity({
    required String title,
    required String subtitle,
    required String kind,
  }) {
    _recordActivity(title: title, subtitle: subtitle, kind: kind);
    notifyListeners();
    _schedulePersist();
  }

  void _recordActivity({
    required String title,
    required String subtitle,
    required String kind,
  }) {
    activityItems.insert(
      0,
      ActivityItem(title: title, subtitle: subtitle, kind: kind),
    );
    if (activityItems.length > 200) {
      activityItems.removeRange(200, activityItems.length);
    }
  }

  TeamMember? teamMemberById(String? memberId) {
    if (memberId == null || memberId.isEmpty) return null;
    for (final member in teamMembers) {
      if (member.id == memberId) return member;
    }
    return null;
  }

  void updatePreferences(AppPreferences value) {
    preferences = value;
    notifyListeners();
    unawaited(_persist());
  }

  Map<String, dynamic> exportSnapshot() => {
    'schemaVersion': 8,
    'companyProfile': companyProfile.toJson(),
    'preferences': preferences.toJson(),
    'clients': clients.map((client) => client.toJson()).toList(),
    'teamMembers': teamMembers.map((member) => member.toJson()).toList(),
    'messages': messages.map((message) => message.toJson()).toList(),
    'activityItems': activityItems.map((item) => item.toJson()).toList(),
    'jobs': jobs.map((job) => job.toJson()).toList(),
  };

  Future<void> resetLocalData() async {
    final service = storage;
    clients.clear();
    jobs.clear();
    teamMembers.clear();
    messages.clear();
    activityItems.clear();
    companyProfile = const CompanyProfile();
    preferences = const AppPreferences();
    onboardingComplete = false;
    loggedIn = false;
    profileReady = false;
    activeTab = 0;
    if (service != null) {
      await service.clearAll();
      await _persist();
    }
    notifyListeners();
  }

  void logout() {
    loggedIn = false;
    activeTab = 0;
    notifyListeners();
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
        'schemaVersion': 8,
        'onboardingComplete': onboardingComplete,
        'profileReady': profileReady,
        'companyProfile': companyProfile.toJson(),
        'preferences': preferences.toJson(),
        'clients': clients.map((client) => client.toJson()).toList(),
        'teamMembers': teamMembers.map((member) => member.toJson()).toList(),
        'messages': messages.map((message) => message.toJson()).toList(),
        'activityItems': activityItems.map((item) => item.toJson()).toList(),
        'jobs': jobs.map((job) => job.toJson()).toList(),
      });
    } catch (error, stackTrace) {
      debugPrint('WORKLOG pohrana nije uspjela: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}
