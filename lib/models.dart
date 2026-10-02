enum JobStatus {
  planned,
  confirmed,
  enRoute,
  active,
  paused,
  completed,
  cancelled,
}

extension JobStatusPresentation on JobStatus {
  String get label => switch (this) {
    JobStatus.planned => 'Planirano',
    JobStatus.confirmed => 'Potvrđeno',
    JobStatus.enRoute => 'Na putu',
    JobStatus.active => 'U tijeku',
    JobStatus.paused => 'Pauzirano',
    JobStatus.completed => 'Završeno',
    JobStatus.cancelled => 'Otkazano',
  };

  bool get isClosed =>
      this == JobStatus.completed || this == JobStatus.cancelled;
}

class Client {
  Client({
    String? id,
    required this.name,
    required this.type,
    required this.phone,
    required this.email,
    required this.address,
  }) : id = id ?? DateTime.now().microsecondsSinceEpoch.toString();

  final String id;
  final String name;
  final String type;
  final String phone;
  final String email;
  final String address;

  Client copyWith({
    String? name,
    String? type,
    String? phone,
    String? email,
    String? address,
  }) {
    return Client(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type,
    'phone': phone,
    'email': email,
    'address': address,
  };

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'] as String?,
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? 'Privatna osoba',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      address: json['address'] as String? ?? '',
    );
  }
}

class CompanyProfile {
  const CompanyProfile({
    this.name = 'WORKLOG servis',
    this.activity = 'Instalacije i klimatizacija',
    this.phone = '',
    this.email = '',
    this.address = '',
    this.oib = '',
    this.employeeRange = '1 – 5',
  });

  final String name;
  final String activity;
  final String phone;
  final String email;
  final String address;
  final String oib;
  final String employeeRange;

  CompanyProfile copyWith({
    String? name,
    String? activity,
    String? phone,
    String? email,
    String? address,
    String? oib,
    String? employeeRange,
  }) {
    return CompanyProfile(
      name: name ?? this.name,
      activity: activity ?? this.activity,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      oib: oib ?? this.oib,
      employeeRange: employeeRange ?? this.employeeRange,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'activity': activity,
    'phone': phone,
    'email': email,
    'address': address,
    'oib': oib,
    'employeeRange': employeeRange,
  };

  factory CompanyProfile.fromJson(Map<String, dynamic> json) {
    return CompanyProfile(
      name: json['name'] as String? ?? 'WORKLOG servis',
      activity: json['activity'] as String? ?? 'Instalacije i klimatizacija',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      address: json['address'] as String? ?? '',
      oib: json['oib'] as String? ?? '',
      employeeRange: json['employeeRange'] as String? ?? '1 – 5',
    );
  }
}

class TeamMember {
  TeamMember({
    String? id,
    required this.name,
    required this.role,
    required this.phone,
    required this.email,
    this.active = true,
  }) : id = id ?? DateTime.now().microsecondsSinceEpoch.toString();

  final String id;
  final String name;
  final String role;
  final String phone;
  final String email;
  final bool active;

  TeamMember copyWith({
    String? name,
    String? role,
    String? phone,
    String? email,
    bool? active,
  }) {
    return TeamMember(
      id: id,
      name: name ?? this.name,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      active: active ?? this.active,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'role': role,
    'phone': phone,
    'email': email,
    'active': active,
  };

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    return TeamMember(
      id: json['id'] as String?,
      name: json['name'] as String? ?? '',
      role: json['role'] as String? ?? 'Tehničar',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      active: json['active'] as bool? ?? true,
    );
  }
}

class AppPreferences {
  const AppPreferences({
    this.notificationsEnabled = false,
    this.autoSaveEnabled = true,
    this.biometricLockEnabled = false,
    this.compactCards = false,
  });

  final bool notificationsEnabled;
  final bool autoSaveEnabled;
  final bool biometricLockEnabled;
  final bool compactCards;

  AppPreferences copyWith({
    bool? notificationsEnabled,
    bool? autoSaveEnabled,
    bool? biometricLockEnabled,
    bool? compactCards,
  }) {
    return AppPreferences(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      autoSaveEnabled: autoSaveEnabled ?? this.autoSaveEnabled,
      biometricLockEnabled: biometricLockEnabled ?? this.biometricLockEnabled,
      compactCards: compactCards ?? this.compactCards,
    );
  }

  Map<String, dynamic> toJson() => {
    'notificationsEnabled': notificationsEnabled,
    'autoSaveEnabled': autoSaveEnabled,
    'biometricLockEnabled': biometricLockEnabled,
    'compactCards': compactCards,
  };

  factory AppPreferences.fromJson(Map<String, dynamic> json) {
    return AppPreferences(
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? false,
      autoSaveEnabled: json['autoSaveEnabled'] as bool? ?? true,
      biometricLockEnabled: json['biometricLockEnabled'] as bool? ?? false,
      compactCards: json['compactCards'] as bool? ?? false,
    );
  }
}

class MaterialItem {
  const MaterialItem({
    required this.name,
    required this.quantity,
    required this.price,
  });

  final String name;
  final String quantity;
  final double price;

  Map<String, dynamic> toJson() => {
    'name': name,
    'quantity': quantity,
    'price': price,
  };

  factory MaterialItem.fromJson(Map<String, dynamic> json) {
    return MaterialItem(
      name: json['name'] as String? ?? '',
      quantity: json['quantity'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
    );
  }
}

class ConversationMessage {
  ConversationMessage({
    String? id,
    required this.clientId,
    required this.text,
    required this.mine,
    DateTime? createdAt,
  }) : id = id ?? DateTime.now().microsecondsSinceEpoch.toString(),
       createdAt = createdAt ?? DateTime.now();

  final String id;
  final String clientId;
  final String text;
  final bool mine;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'clientId': clientId,
    'text': text,
    'mine': mine,
    'createdAt': createdAt.toIso8601String(),
  };

  factory ConversationMessage.fromJson(Map<String, dynamic> json) {
    return ConversationMessage(
      id: json['id'] as String?,
      clientId: json['clientId'] as String? ?? '',
      text: json['text'] as String? ?? '',
      mine: json['mine'] as bool? ?? true,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
    );
  }
}

class ActivityItem {
  ActivityItem({
    String? id,
    required this.title,
    required this.subtitle,
    required this.kind,
    DateTime? createdAt,
    this.read = false,
  }) : id = id ?? DateTime.now().microsecondsSinceEpoch.toString(),
       createdAt = createdAt ?? DateTime.now();

  final String id;
  final String title;
  final String subtitle;
  final String kind;
  final DateTime createdAt;
  bool read;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'subtitle': subtitle,
    'kind': kind,
    'createdAt': createdAt.toIso8601String(),
    'read': read,
  };

  factory ActivityItem.fromJson(Map<String, dynamic> json) {
    return ActivityItem(
      id: json['id'] as String?,
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      kind: json['kind'] as String? ?? 'system',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
      read: json['read'] as bool? ?? false,
    );
  }
}

const _croatianMonths = <String>[
  'siječnja',
  'veljače',
  'ožujka',
  'travnja',
  'svibnja',
  'lipnja',
  'srpnja',
  'kolovoza',
  'rujna',
  'listopada',
  'studenoga',
  'prosinca',
];

const _croatianMonthLookup = <String, int>{
  'siječnja': 1,
  'veljače': 2,
  'ožujka': 3,
  'travnja': 4,
  'svibnja': 5,
  'lipnja': 6,
  'srpnja': 7,
  'kolovoza': 8,
  'rujna': 9,
  'listopada': 10,
  'studenoga': 11,
  'prosinca': 12,
};

String formatCroatianDate(DateTime value) =>
    '${value.day}. ${_croatianMonths[value.month - 1]} ${value.year}.';

String formatClock(DateTime value) =>
    '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';

String formatTimeRange(DateTime start, DateTime? end) {
  if (end == null) return formatClock(start);
  return '${formatClock(start)} – ${formatClock(end)}';
}

DateTime? parseCroatianScheduleStart(String dateLabel, String timeLabel) {
  final date = RegExp(
    r'^(\d{1,2})\.\s+([^\s]+)\s+(\d{4})\.?$',
  ).firstMatch(dateLabel.trim());
  final time = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(timeLabel);
  if (date == null || time == null) return null;

  final day = int.tryParse(date.group(1) ?? '');
  final month = _croatianMonthLookup[date.group(2)];
  final year = int.tryParse(date.group(3) ?? '');
  final hour = int.tryParse(time.group(1) ?? '');
  final minute = int.tryParse(time.group(2) ?? '');
  if (day == null ||
      month == null ||
      year == null ||
      hour == null ||
      minute == null) {
    return null;
  }

  try {
    return DateTime(year, month, day, hour, minute);
  } on ArgumentError {
    return null;
  }
}

DateTime? parseCroatianScheduleEnd(
  String dateLabel,
  String timeLabel,
  DateTime? start,
) {
  final times = RegExp(r'(\d{1,2}):(\d{2})').allMatches(timeLabel).toList();
  if (times.length < 2 || start == null) return null;

  final hour = int.tryParse(times[1].group(1) ?? '');
  final minute = int.tryParse(times[1].group(2) ?? '');
  if (hour == null || minute == null) return null;

  var end = DateTime(start.year, start.month, start.day, hour, minute);
  if (!end.isAfter(start)) {
    end = end.add(const Duration(days: 1));
  }
  return end;
}

class WorkTimeEntry {
  WorkTimeEntry({String? id, required this.startedAt, this.endedAt})
    : id = id ?? DateTime.now().microsecondsSinceEpoch.toString();

  final String id;
  final DateTime startedAt;
  DateTime? endedAt;

  bool get isRunning => endedAt == null;

  int elapsedSeconds({DateTime? now}) {
    final finish = endedAt ?? now ?? DateTime.now();
    if (!finish.isAfter(startedAt)) return 0;
    return finish.difference(startedAt).inSeconds;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'startedAt': startedAt.toIso8601String(),
    'endedAt': endedAt?.toIso8601String(),
  };

  factory WorkTimeEntry.fromJson(Map<String, dynamic> json) {
    return WorkTimeEntry(
      id: json['id'] as String?,
      startedAt:
          DateTime.tryParse(json['startedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      endedAt: DateTime.tryParse(json['endedAt'] as String? ?? ''),
    );
  }
}

class ChecklistItem {
  ChecklistItem({
    String? id,
    required this.label,
    this.completed = false,
  }) : id = id ?? DateTime.now().microsecondsSinceEpoch.toString();

  final String id;
  String label;
  bool completed;

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'completed': completed,
      };

  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      id: json['id'] as String?,
      label: json['label'] as String? ?? '',
      completed: json['completed'] as bool? ?? false,
    );
  }
}

class WorkJob {
  WorkJob({
    String? id,
    required this.title,
    required this.client,
    required this.location,
    String? dateLabel,
    String? timeLabel,
    required this.status,
    this.description = "",
    this.priority = "Srednji",
    this.minutesWorked = 0,
    List<WorkTimeEntry>? timeEntries,
    this.manualAdjustmentMinutes = 0,
    this.manualAdjustmentReason = '',
    List<MaterialItem>? materials,
    List<String>? notes,
    List<ChecklistItem>? checklist,
    List<String>? beforePhotoPaths,
    List<String>? afterPhotoPaths,
    this.signaturePath,
    this.reportPath,
    this.reportSent = false,
    this.assignedMemberId,
    this.assignedMemberName,
    this.scheduledStart,
    this.scheduledEnd,
  }) : id = id ?? DateTime.now().microsecondsSinceEpoch.toString(),
       dateLabel =
           dateLabel ??
           (scheduledStart == null ? '' : formatCroatianDate(scheduledStart)),
       timeLabel =
           timeLabel ??
           (scheduledStart == null
               ? ''
               : formatTimeRange(scheduledStart, scheduledEnd)),
       timeEntries = timeEntries ?? <WorkTimeEntry>[],
       materials = materials ?? <MaterialItem>[],
       notes = notes ?? <String>[],
       checklist = checklist ?? <ChecklistItem>[],
       beforePhotoPaths = beforePhotoPaths ?? <String>[],
       afterPhotoPaths = afterPhotoPaths ?? <String>[];

  final String id;
  String title;
  Client client;
  String location;
  String dateLabel;
  String timeLabel;
  JobStatus status;
  String description;
  String priority;
  int minutesWorked;
  final List<WorkTimeEntry> timeEntries;
  int manualAdjustmentMinutes;
  String manualAdjustmentReason;
  final List<MaterialItem> materials;
  final List<String> notes;
  final List<ChecklistItem> checklist;
  final List<String> beforePhotoPaths;
  final List<String> afterPhotoPaths;
  String? signaturePath;
  String? reportPath;
  bool reportSent;
  String? assignedMemberId;
  String? assignedMemberName;
  DateTime? scheduledStart;
  DateTime? scheduledEnd;

  String get statusLabel => status.label;

  WorkTimeEntry? get activeTimeEntry {
    for (final entry in timeEntries.reversed) {
      if (entry.isRunning) return entry;
    }
    return null;
  }

  bool get timerRunning => activeTimeEntry != null;

  int workedSeconds({DateTime? now}) {
    var total = minutesWorked * 60 + manualAdjustmentMinutes * 60;
    for (final entry in timeEntries) {
      total += entry.elapsedSeconds(now: now);
    }
    return total < 0 ? 0 : total;
  }

  int get totalWorkedMinutes => (workedSeconds() + 59) ~/ 60;

  bool startTimer({DateTime? at}) {
    if (timerRunning) return false;
    timeEntries.add(WorkTimeEntry(startedAt: at ?? DateTime.now()));
    return true;
  }

  bool pauseTimer({DateTime? at}) {
    final entry = activeTimeEntry;
    if (entry == null) return false;
    final endedAt = at ?? DateTime.now();
    entry.endedAt = endedAt.isBefore(entry.startedAt)
        ? entry.startedAt
        : endedAt;
    return true;
  }

  void addManualTimeAdjustment({required int minutes, required String reason}) {
    if (minutes == 0) return;
    manualAdjustmentMinutes += minutes;
    manualAdjustmentReason = reason.trim();
  }

  void setSchedule(DateTime start, DateTime end) {
    scheduledStart = start;
    scheduledEnd = end;
    dateLabel = formatCroatianDate(start);
    timeLabel = formatTimeRange(start, end);
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'client': client.toJson(),
    'location': location,
    'dateLabel': dateLabel,
    'timeLabel': timeLabel,
    'scheduledStart': scheduledStart?.toIso8601String(),
    'scheduledEnd': scheduledEnd?.toIso8601String(),
    'status': status.name,
    'description': description,
    'priority': priority,
    'minutesWorked': minutesWorked,
    'timeEntries': timeEntries.map((entry) => entry.toJson()).toList(),
    'manualAdjustmentMinutes': manualAdjustmentMinutes,
    'manualAdjustmentReason': manualAdjustmentReason,
    'materials': materials.map((item) => item.toJson()).toList(),
    'notes': notes,
    'checklist': checklist.map((item) => item.toJson()).toList(),
    'beforePhotoPaths': beforePhotoPaths,
    'afterPhotoPaths': afterPhotoPaths,
    'signaturePath': signaturePath,
    'reportPath': reportPath,
    'reportSent': reportSent,
    'assignedMemberId': assignedMemberId,
    'assignedMemberName': assignedMemberName,
  };

  factory WorkJob.fromJson(Map<String, dynamic> json) {
    final statusName = json['status'] as String? ?? JobStatus.planned.name;
    final resolvedStatus = JobStatus.values.firstWhere(
      (value) => value.name == statusName,
      orElse: () => JobStatus.planned,
    );

    final dateLabel = json['dateLabel'] as String? ?? '';
    final timeLabel = json['timeLabel'] as String? ?? '';
    final savedStart = DateTime.tryParse(
      json['scheduledStart'] as String? ?? '',
    );
    final resolvedStart =
        savedStart ?? parseCroatianScheduleStart(dateLabel, timeLabel);
    final savedEnd = DateTime.tryParse(json['scheduledEnd'] as String? ?? '');
    final resolvedEnd =
        savedEnd ??
        parseCroatianScheduleEnd(dateLabel, timeLabel, resolvedStart);

    return WorkJob(
      id: json['id'] as String?,
      title: json['title'] as String? ?? 'Posao',
      client: Client.fromJson(
        Map<String, dynamic>.from(json['client'] as Map? ?? const {}),
      ),
      location: json['location'] as String? ?? '',
      dateLabel: dateLabel,
      timeLabel: timeLabel,
      scheduledStart: resolvedStart,
      scheduledEnd: resolvedEnd,
      status: resolvedStatus,
      description: json['description'] as String? ?? '',
      priority: json['priority'] as String? ?? 'Srednji',
      minutesWorked: (json['minutesWorked'] as num?)?.toInt() ?? 0,
      timeEntries: (json['timeEntries'] as List? ?? const [])
          .whereType<Map>()
          .map(
            (item) => WorkTimeEntry.fromJson(Map<String, dynamic>.from(item)),
          )
          .where((entry) => entry.startedAt.millisecondsSinceEpoch > 0)
          .toList(),
      manualAdjustmentMinutes:
          (json['manualAdjustmentMinutes'] as num?)?.toInt() ?? 0,
      manualAdjustmentReason: json['manualAdjustmentReason'] as String? ?? '',
      materials: (json['materials'] as List? ?? const [])
          .whereType<Map>()
          .map((item) => MaterialItem.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
      notes: (json['notes'] as List? ?? const []).whereType<String>().toList(),
      checklist: (json['checklist'] as List? ?? const [])
          .whereType<Map>()
          .map((item) => ChecklistItem.fromJson(Map<String, dynamic>.from(item)))
          .where((item) => item.label.trim().isNotEmpty)
          .toList(),
      beforePhotoPaths: (json['beforePhotoPaths'] as List? ?? const [])
          .whereType<String>()
          .toList(),
      afterPhotoPaths: (json['afterPhotoPaths'] as List? ?? const [])
          .whereType<String>()
          .toList(),
      signaturePath: json['signaturePath'] as String?,
      reportPath: json['reportPath'] as String?,
      reportSent: json['reportSent'] as bool? ?? false,
      assignedMemberId: json['assignedMemberId'] as String?,
      assignedMemberName: json['assignedMemberName'] as String?,
    );
  }
}
