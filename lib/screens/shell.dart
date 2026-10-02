import 'package:flutter/material.dart';
import '../app_state.dart';
import '../brand.dart';
import '../models.dart';
import '../worklog_theme.dart';
import 'job_flow.dart';
import 'support.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardScreen(state: state),
      JobsScreen(state: state),
      CalendarScreen(state: state),
      ClientsScreen(state: state),
      MoreScreen(state: state),
    ];
    return Scaffold(
      body: SafeArea(child: IndexedStack(index: state.activeTab, children: screens)),
      bottomNavigationBar: NavigationBar(
        selectedIndex: state.activeTab,
        onDestinationSelected: state.setTab,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: "Početna"),
          NavigationDestination(icon: Icon(Icons.work_outline_rounded), selectedIcon: Icon(Icons.work_rounded), label: "Poslovi"),
          NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month_rounded), label: "Kalendar"),
          NavigationDestination(icon: Icon(Icons.people_outline_rounded), selectedIcon: Icon(Icons.people_rounded), label: "Klijenti"),
          NavigationDestination(icon: Icon(Icons.more_horiz_rounded), label: "Više"),
        ],
      ),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final active = state.jobs.where((job) => job.status != JobStatus.completed).toList();
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Row(
          children: [
            const WorklogWordmark(compact: true),
            const Spacer(),
            IconButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => NotificationsScreen(state: state))),
              icon: const Icon(Icons.notifications_none_rounded),
            ),
          ],
        ),
        const SizedBox(height: 22),
        const Text("Dobar dan!", style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
        const Text("Vrijeme je za nove poslove.", style: TextStyle(color: WorklogColors.muted)),
        const SizedBox(height: 18),
        const _DateBanner(),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.5,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          children: [
            _Metric(icon: Icons.work_rounded, value: active.length.toString(), label: "AKTIVNI POSLOVI", color: WorklogColors.primary),
            _Metric(icon: Icons.people_alt_rounded, value: state.clients.length.toString(), label: "AKTIVNI KLIJENTI", color: WorklogColors.success),
            const _Metric(icon: Icons.schedule_rounded, value: "4:30", label: "DANAŠNJI SATI", color: WorklogColors.cyan),
            const _Metric(icon: Icons.description_rounded, value: "2", label: "ZAPISNIKA", color: WorklogColors.violet),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 52,
          child: FilledButton.icon(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => NewJobScreen(state: state))),
            icon: const Icon(Icons.add),
            label: const Text("Novi posao"),
          ),
        ),
        SectionTitle(
          "Aktivni poslovi",
          action: TextButton(onPressed: () => state.setTab(1), child: const Text("Prikaži sve")),
        ),
        ...active.take(4).map(
          (job) => JobCard(
            job: job,
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => JobDetailScreen(state: state, job: job))),
          ),
        ),
      ],
    );
  }
}

class _DateBanner extends StatelessWidget {
  const _DateBanner();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: WorklogColors.primary.withValues(alpha: .16),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.calendar_today_rounded, color: WorklogColors.primary),
            ),
            const SizedBox(width: 14),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Danas", style: TextStyle(color: WorklogColors.muted)),
                Text("2. listopada 2026.", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.icon, required this.value, required this.label, required this.color});
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900)),
                  Text(label, style: const TextStyle(fontSize: 9, color: WorklogColors.muted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class JobCard extends StatelessWidget {
  const JobCard({super.key, required this.job, required this.onTap});
  final WorkJob job;
  final VoidCallback onTap;

  Color get statusColor => switch (job.status) {
        JobStatus.planned => WorklogColors.primary,
        JobStatus.active => WorklogColors.success,
        JobStatus.completed => WorklogColors.success,
      };

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: WorklogColors.surface2, borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.handyman_rounded, color: WorklogColors.cyan),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(job.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 3),
                    Text(job.client.name, style: const TextStyle(color: WorklogColors.muted, fontSize: 12)),
                    Text(job.location, style: const TextStyle(color: WorklogColors.muted, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(color: statusColor.withValues(alpha: .16), borderRadius: BorderRadius.circular(99)),
                child: Text(job.statusLabel, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key, required this.state});
  final AppState state;

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  String filter = "Svi";

  @override
  Widget build(BuildContext context) {
    final jobs = widget.state.jobs.where((job) {
      if (filter == "Planirano") return job.status == JobStatus.planned;
      if (filter == "U tijeku") return job.status == JobStatus.active;
      if (filter == "Završeno") return job.status == JobStatus.completed;
      return true;
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Row(
          children: [
            const Text("Poslovi", style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
            const Spacer(),
            IconButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => NewJobScreen(state: widget.state))),
              icon: const Icon(Icons.add_circle_rounded, color: WorklogColors.primary),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          children: ["Svi", "Planirano", "U tijeku", "Završeno"]
              .map((label) => ChoiceChip(label: Text(label), selected: filter == label, onSelected: (_) => setState(() => filter = label)))
              .toList(),
        ),
        const SizedBox(height: 16),
        ...jobs.map(
          (job) => JobCard(
            job: job,
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => JobDetailScreen(state: widget.state, job: job))),
          ),
        ),
      ],
    );
  }
}

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text("Kalendar", style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
        const SizedBox(height: 14),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: "Dan", label: Text("Dan")),
            ButtonSegment(value: "Tjedan", label: Text("Tjedan")),
            ButtonSegment(value: "Mjesec", label: Text("Mjesec")),
          ],
          selected: const {"Tjedan"},
          onSelectionChanged: (_) {},
        ),
        const SizedBox(height: 16),
        const Text("28. rujna – 4. listopada 2026.", style: TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 14),
        ...state.jobs.asMap().entries.map(
          (entry) => Card(
            child: ListTile(
              leading: Text(["Pon", "Uto", "Sri", "Čet"][entry.key % 4], style: const TextStyle(color: WorklogColors.primary, fontWeight: FontWeight.w900)),
              title: Text(entry.value.title, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(entry.value.timeLabel + " • " + entry.value.client.name),
              trailing: Text(entry.value.statusLabel, style: const TextStyle(fontSize: 11)),
            ),
          ),
        ),
      ],
    );
  }
}

class ClientsScreen extends StatelessWidget {
  const ClientsScreen({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Row(
          children: [
            const Text("Klijenti", style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
            const Spacer(),
            IconButton(onPressed: () {}, icon: const Icon(Icons.person_add_alt_1_rounded, color: WorklogColors.primary)),
          ],
        ),
        const SizedBox(height: 12),
        const TextField(decoration: InputDecoration(hintText: "Pretraži klijente...", prefixIcon: Icon(Icons.search_rounded))),
        const SizedBox(height: 14),
        ...state.clients.map(
          (client) => Card(
            child: ListTile(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ClientDetailScreen(state: state, client: client))),
              leading: CircleAvatar(child: Text(client.name.split(" ").map((part) => part[0]).take(2).join())),
              title: Text(client.name, style: const TextStyle(fontWeight: FontWeight.w800)),
              subtitle: Text(client.type),
              trailing: const Icon(Icons.chevron_right_rounded),
            ),
          ),
        ),
      ],
    );
  }
}

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text("Više", style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
        const SizedBox(height: 16),
        _MoreTile(icon: Icons.picture_as_pdf_rounded, label: "Izvještaji", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ReportsScreen(state: state)))),
        _MoreTile(icon: Icons.notifications_none_rounded, label: "Obavijesti", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NotificationsScreen(state: state)))),
        _MoreTile(icon: Icons.business_rounded, label: "Profil tvrtke", onTap: () => _simple(context, "Profil tvrtke")),
        _MoreTile(icon: Icons.group_work_outlined, label: "Terenski tim", onTap: () => _simple(context, "Terenski tim")),
        _MoreTile(icon: Icons.settings_outlined, label: "Postavke", onTap: () => _simple(context, "Postavke")),
        _MoreTile(icon: Icons.shield_outlined, label: "Privatnost i sigurnost", onTap: () => _simple(context, "Privatnost i sigurnost")),
      ],
    );
  }

  static void _simple(BuildContext context, String title) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => SimplePage(title: title)));
  }
}

class _MoreTile extends StatelessWidget {
  const _MoreTile({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: WorklogColors.primary),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
