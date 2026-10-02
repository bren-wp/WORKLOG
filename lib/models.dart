enum JobStatus { planned, active, completed }

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
  });

  final String name;
  final String activity;
  final String phone;
  final String email;
  final String address;
  final String oib;

  CompanyProfile copyWith({
    String? name,
    String? activity,
    String? phone,
    String? email,
    String? address,
    String? oib,
  }) {
    return CompanyProfile(
      name: name ?? this.name,
      activity: activity ?? this.activity,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      oib: oib ?? this.oib,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'activity': activity,
        'phone': phone,
        'email': email,
        'address': address,
        'oib': oib,
      };

  factory CompanyProfile.fromJson(Map<String, dynamic> json) {
    return CompanyProfile(
      name: json['name'] as String? ?? 'WORKLOG servis',
      activity: json['activity'] as String? ?? 'Instalacije i klimatizacija',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      address: json['address'] as String? ?? '',
      oib: json['oib'] as String? ?? '',
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
    this.notificationsEnabled = true,
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
      notificationsEnabled:
          notificationsEnabled ?? this.notificationsEnabled,
      autoSaveEnabled: autoSaveEnabled ?? this.autoSaveEnabled,
      biometricLockEnabled:
          biometricLockEnabled ?? this.biometricLockEnabled,
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
      notificationsEnabled:
          json['notificationsEnabled'] as bool? ?? true,
      autoSaveEnabled: json['autoSaveEnabled'] as bool? ?? true,
      biometricLockEnabled:
          json['biometricLockEnabled'] as bool? ?? false,
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

class WorkJob {
  WorkJob({
    String? id,
    required this.title,
    required this.client,
    required this.location,
    required this.dateLabel,
    required this.timeLabel,
    required this.status,
    this.description = "",
    this.priority = "Srednji",
    this.minutesWorked = 0,
    List<MaterialItem>? materials,
    List<String>? notes,
    List<String>? beforePhotoPaths,
    List<String>? afterPhotoPaths,
    this.signaturePath,
    this.reportPath,
    this.reportSent = false,
  })  : id = id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        materials = materials ?? <MaterialItem>[],
        notes = notes ?? <String>[],
        beforePhotoPaths = beforePhotoPaths ?? <String>[],
        afterPhotoPaths = afterPhotoPaths ?? <String>[];

  final String id;
  final String title;
  Client client;
  final String location;
  final String dateLabel;
  final String timeLabel;
  JobStatus status;
  String description;
  String priority;
  int minutesWorked;
  final List<MaterialItem> materials;
  final List<String> notes;
  final List<String> beforePhotoPaths;
  final List<String> afterPhotoPaths;
  String? signaturePath;
  String? reportPath;
  bool reportSent;

  String get statusLabel => switch (status) {
        JobStatus.planned => "Planirano",
        JobStatus.active => "U tijeku",
        JobStatus.completed => "Završeno",
      };

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'client': client.toJson(),
        'location': location,
        'dateLabel': dateLabel,
        'timeLabel': timeLabel,
        'status': status.name,
        'description': description,
        'priority': priority,
        'minutesWorked': minutesWorked,
        'materials': materials.map((item) => item.toJson()).toList(),
        'notes': notes,
        'beforePhotoPaths': beforePhotoPaths,
        'afterPhotoPaths': afterPhotoPaths,
        'signaturePath': signaturePath,
        'reportPath': reportPath,
        'reportSent': reportSent,
      };

  factory WorkJob.fromJson(Map<String, dynamic> json) {
    final statusName = json['status'] as String? ?? JobStatus.planned.name;
    final resolvedStatus = JobStatus.values.firstWhere(
      (value) => value.name == statusName,
      orElse: () => JobStatus.planned,
    );

    return WorkJob(
      id: json['id'] as String?,
      title: json['title'] as String? ?? 'Posao',
      client: Client.fromJson(
        Map<String, dynamic>.from(json['client'] as Map? ?? const {}),
      ),
      location: json['location'] as String? ?? '',
      dateLabel: json['dateLabel'] as String? ?? '',
      timeLabel: json['timeLabel'] as String? ?? '',
      status: resolvedStatus,
      description: json['description'] as String? ?? '',
      priority: json['priority'] as String? ?? 'Srednji',
      minutesWorked: (json['minutesWorked'] as num?)?.toInt() ?? 0,
      materials: (json['materials'] as List? ?? const [])
          .whereType<Map>()
          .map(
            (item) => MaterialItem.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
      notes: (json['notes'] as List? ?? const []).whereType<String>().toList(),
      beforePhotoPaths: (json['beforePhotoPaths'] as List? ?? const [])
          .whereType<String>()
          .toList(),
      afterPhotoPaths: (json['afterPhotoPaths'] as List? ?? const [])
          .whereType<String>()
          .toList(),
      signaturePath: json['signaturePath'] as String?,
      reportPath: json['reportPath'] as String?,
      reportSent: json['reportSent'] as bool? ?? false,
    );
  }
}
