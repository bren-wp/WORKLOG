import 'package:flutter/material.dart';
import '../app_state.dart';
import '../brand.dart';
import '../models.dart';
import '../worklog_theme.dart';
import 'job_flow.dart';

class ClientDetailScreen extends StatelessWidget {
  const ClientDetailScreen({super.key, required this.state, required this.client});
  final AppState state;
  final Client client;

  @override
  Widget build(BuildContext context) {
    final jobs = state.jobs.where((job) => job.client.name == client.name).toList();
    return Scaffold(
      appBar: AppBar(title: const Text("Detalj klijenta")),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: WorklogColors.primary,
                child: Text(client.name.substring(0, 1), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(client.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                    Text(client.type, style: const TextStyle(color: WorklogColors.muted)),
                  ],
                ),
              ),
              const Chip(label: Text("Aktivan")),
            ],
          ),
          const SizedBox(height: 20),
          InfoTile(icon: Icons.phone_outlined, title: client.phone, subtitle: "Telefon"),
          InfoTile(icon: Icons.mail_outline_rounded, title: client.email, subtitle: "E-pošta"),
          InfoTile(icon: Icons.location_on_outlined, title: client.address, subtitle: "Adresa"),
          const SectionTitle("Povijest poslova"),
          if (jobs.isEmpty) const Text("Nema evidentiranih poslova.", style: TextStyle(color: WorklogColors.muted)),
          ...jobs.map(
            (job) => Card(
              child: ListTile(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => JobDetailScreen(state: state, job: job))),
                leading: const Icon(Icons.handyman_rounded, color: WorklogColors.cyan),
                title: Text(job.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                subtitle: Text(job.dateLabel),
                trailing: Text(job.statusLabel),
              ),
            ),
          ),
          const SectionTitle("Komunikacija"),
          FilledButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MessagesScreen(client: client))),
            icon: const Icon(Icons.chat_bubble_outline_rounded),
            label: const Text("Otvori poruke"),
          ),
        ],
      ),
    );
  }
}

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key, required this.client});
  final Client client;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(client.name)),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: const [
                MessageBubble(text: "Dobar dan, možete li potvrditi dolazak za danas u 09:30?", mine: false),
                MessageBubble(text: "Dobar dan! Dolazim prema planu. Vidimo se u 09:30.", mine: true),
                MessageBubble(text: "Odlično, hvala. Parking je osiguran.", mine: false),
                MessageBubble(text: "Javit ću vam kad budem na lokaciji.", mine: true),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Expanded(child: TextField(decoration: InputDecoration(hintText: "Napiši poruku..."))),
                const SizedBox(width: 8),
                IconButton.filled(onPressed: () {}, icon: const Icon(Icons.send_rounded)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.text, required this.mine});
  final String text;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: mine ? WorklogColors.primary : WorklogColors.surface2,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(text),
      ),
    );
  }
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Obavijesti")),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: const [
          Notice(icon: Icons.directions_car_rounded, title: "Dolazak za 30 minuta", subtitle: "Termin kod Ivica Horvat • Zagreb, Trešnjevka", color: WorklogColors.success),
          Notice(icon: Icons.check_circle_rounded, title: "Klijent je potvrdio termin", subtitle: "Marija Kovač • danas u 09:30", color: WorklogColors.success),
          Notice(icon: Icons.draw_rounded, title: "Zapisnik je potpisan", subtitle: "Servis bojlera • Marija Kovač", color: WorklogColors.violet),
          Notice(icon: Icons.inventory_2_rounded, title: "Materijal pri kraju", subtitle: "PVC cijev Ø32 • preostalo 2 kom", color: WorklogColors.warning),
        ],
      ),
    );
  }
}

class Notice extends StatelessWidget {
  const Notice({super.key, required this.icon, required this.title, required this.subtitle, required this.color});
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color.withValues(alpha: .16), child: Icon(icon, color: color)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(subtitle),
      ),
    );
  }
}

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Izvještaji")),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: state.jobs.map(
          (job) => Card(
            child: ListTile(
              leading: const Icon(Icons.picture_as_pdf_rounded, color: Colors.redAccent),
              title: Text(job.title, style: const TextStyle(fontWeight: FontWeight.w800)),
              subtitle: Text(job.client.name + " • " + job.dateLabel),
              trailing: Chip(label: Text(job.status == JobStatus.completed ? "Potpisano" : "Na čekanju")),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SendReportScreen(job: job))),
            ),
          ),
        ).toList(),
      ),
    );
  }
}

class SimplePage extends StatelessWidget {
  const SimplePage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const WorklogMark(size: 82),
              const SizedBox(height: 20),
              Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              const Text(
                "Modul je uključen u WORKLOG strukturu i spreman za povezivanje s produkcijskim servisima.",
                textAlign: TextAlign.center,
                style: TextStyle(color: WorklogColors.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
