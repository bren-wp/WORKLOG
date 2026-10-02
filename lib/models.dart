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
}

class WorkJob {
  WorkJob({
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
  })  : materials = materials ?? <MaterialItem>[],
        notes = notes ?? <String>[];

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

  String get statusLabel => switch (status) {
        JobStatus.planned => "Planirano",
        JobStatus.active => "U tijeku",
        JobStatus.completed => "Završeno",
      };
}
