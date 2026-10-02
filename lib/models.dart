enum JobStatus { planned, active, completed }

class Client {
  const Client({
    required this.name,
    required this.type,
    required this.phone,
    required this.email,
    required this.address,
  });

  final String name;
  final String type;
  final String phone;
  final String email;
  final String address;

  Map<String, dynamic> toJson() => {
        'name': name,
        'type': type,
        'phone': phone,
        'email': email,
        'address': address,
      };

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? 'Privatna osoba',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      address: json['address'] as String? ?? '',
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
  final Client client;
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
