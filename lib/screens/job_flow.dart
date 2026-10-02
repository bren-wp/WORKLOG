import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../app_state.dart';
import '../brand.dart';
import '../models.dart';
import '../worklog_theme.dart';

class NewJobScreen extends StatefulWidget {
  const NewJobScreen({super.key, required this.state});
  final AppState state;

  @override
  State<NewJobScreen> createState() => _NewJobScreenState();
}

class _NewJobScreenState extends State<NewJobScreen> {
  final title = TextEditingController(text: "Servis klima uređaja");
  final location = TextEditingController(text: "Zagreb, Maksimirska 12");
  final description = TextEditingController(text: "Redovni servis i provjera rada.");
  late Client selectedClient;
  String priority = "Srednji";

  @override
  void initState() {
    super.initState();
    selectedClient = widget.state.clients.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Novi posao")),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          TextField(controller: title, decoration: const InputDecoration(labelText: "Naziv posla *", prefixIcon: Icon(Icons.edit_note_rounded))),
          const SizedBox(height: 12),
          DropdownButtonFormField<Client>(
            initialValue: selectedClient,
            decoration: const InputDecoration(labelText: "Klijent *", prefixIcon: Icon(Icons.person_outline_rounded)),
            items: widget.state.clients.map((client) => DropdownMenuItem(value: client, child: Text(client.name))).toList(),
            onChanged: (client) => setState(() => selectedClient = client ?? selectedClient),
          ),
          const SizedBox(height: 12),
          TextField(controller: location, decoration: const InputDecoration(labelText: "Lokacija *", prefixIcon: Icon(Icons.location_on_outlined))),
          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(child: TextField(decoration: InputDecoration(labelText: "Datum *", hintText: "2. listopada 2026."))),
              SizedBox(width: 10),
              Expanded(child: TextField(decoration: InputDecoration(labelText: "Vrijeme *", hintText: "08:00"))),
            ],
          ),
          const SizedBox(height: 12),
          TextField(controller: description, minLines: 3, maxLines: 5, decoration: const InputDecoration(labelText: "Opis posla")),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: priority,
            decoration: const InputDecoration(labelText: "Prioritet"),
            items: ["Niski", "Srednji", "Visoki"].map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
            onChanged: (value) => setState(() => priority = value ?? priority),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: () {
                widget.state.addJob(
                  WorkJob(
                    title: title.text.trim().isEmpty ? "Novi posao" : title.text.trim(),
                    client: selectedClient,
                    location: location.text.trim(),
                    dateLabel: "2. listopada 2026.",
                    timeLabel: "08:00",
                    status: JobStatus.planned,
                    description: description.text.trim(),
                    priority: priority,
                  ),
                );
                Navigator.pop(context);
              },
              child: const Text("Spremi posao"),
            ),
          ),
        ],
      ),
    );
  }
}

class JobDetailScreen extends StatelessWidget {
  const JobDetailScreen({super.key, required this.state, required this.job});
  final AppState state;
  final WorkJob job;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detalj posla")),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text(job.title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Align(alignment: Alignment.centerLeft, child: Chip(label: Text(job.statusLabel))),
          const SizedBox(height: 14),
          InfoTile(icon: Icons.person_outline_rounded, title: job.client.name, subtitle: job.client.phone),
          InfoTile(icon: Icons.location_on_outlined, title: job.location, subtitle: "Otvori navigaciju"),
          InfoTile(icon: Icons.calendar_month_outlined, title: job.dateLabel, subtitle: job.timeLabel),
          const SizedBox(height: 12),
          Container(
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: WorklogColors.surface2,
              border: Border.all(color: WorklogColors.border),
            ),
            child: const Stack(
              children: [
                Center(child: Icon(Icons.map_rounded, size: 74, color: WorklogColors.border)),
                Center(child: Icon(Icons.location_pin, size: 44, color: WorklogColors.primary)),
              ],
            ),
          ),
          const SectionTitle("Brze radnje"),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.1,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: [
              ActionButton(icon: Icons.phone_rounded, label: "Nazovi", color: WorklogColors.success, onTap: () => _toast(context, "Pozivanje klijenta")),
              ActionButton(icon: Icons.navigation_rounded, label: "Navigacija", color: WorklogColors.primary, onTap: () => _toast(context, "Otvaranje navigacije")),
              ActionButton(icon: Icons.timer_outlined, label: "Evidencija vremena", color: WorklogColors.cyan, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TimeTrackingScreen(state: state, job: job)))),
              ActionButton(icon: Icons.inventory_2_outlined, label: "Materijal", color: WorklogColors.violet, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MaterialsScreen(state: state, job: job)))),
              ActionButton(icon: Icons.note_alt_outlined, label: "Bilješke", color: WorklogColors.warning, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NotesScreen(state: state, job: job)))),
              ActionButton(icon: Icons.photo_camera_outlined, label: "Fotografije", color: WorklogColors.primary, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BeforeAfterScreen(job: job)))),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 54,
            child: FilledButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CompletionFlowScreen(state: state, job: job))),
              icon: const Icon(Icons.check_circle_outline_rounded),
              label: const Text("Dovrši posao i izradi zapisnik"),
            ),
          ),
        ],
      ),
    );
  }

  static void _toast(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}

class InfoTile extends StatelessWidget {
  const InfoTile({super.key, required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 9),
      child: ListTile(
        leading: Icon(icon, color: WorklogColors.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  const ActionButton({super.key, required this.icon, required this.label, required this.color, required this.onTap});
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(onPressed: onTap, icon: Icon(icon, color: color), label: Text(label, textAlign: TextAlign.center));
  }
}

class TimeTrackingScreen extends StatefulWidget {
  const TimeTrackingScreen({super.key, required this.state, required this.job});
  final AppState state;
  final WorkJob job;

  @override
  State<TimeTrackingScreen> createState() => _TimeTrackingScreenState();
}

class _TimeTrackingScreenState extends State<TimeTrackingScreen> {
  Timer? timer;
  int seconds = 0;
  bool running = false;

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void toggle() {
    if (running) {
      timer?.cancel();
      setState(() => running = false);
    } else {
      timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() => seconds++));
      setState(() => running = true);
    }
  }

  String get formatted {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    return [h, m, s].map((value) => value.toString().padLeft(2, "0")).join(":");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Evidencija vremena")),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [
                  Text(widget.job.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 18),
                  Text(formatted, style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, letterSpacing: 1)),
                  Text(running ? "Rad u tijeku" : "Nije pokrenuto", style: TextStyle(color: running ? WorklogColors.success : WorklogColors.muted)),
                  const SizedBox(height: 22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FloatingActionButton.large(heroTag: "timer", onPressed: toggle, child: Icon(running ? Icons.pause_rounded : Icons.play_arrow_rounded)),
                      const SizedBox(width: 18),
                      FloatingActionButton.large(
                        heroTag: "stop",
                        backgroundColor: WorklogColors.danger,
                        onPressed: () {
                          timer?.cancel();
                          setState(() => running = false);
                          widget.job.minutesWorked += (seconds / 60).ceil();
                          widget.job.status = JobStatus.active;
                          widget.state.updateJob();
                        },
                        child: const Icon(Icons.stop_rounded),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SectionTitle("Danas"),
          const TimelineEntry(title: "Dolazak na lokaciju", time: "08:00 – 08:15", duration: "15 min", color: WorklogColors.success),
          const TimelineEntry(title: "Rad na uređaju", time: "08:15 – 10:30", duration: "2 h 15 min", color: WorklogColors.primary),
          const TimelineEntry(title: "Pauza", time: "10:30 – 10:45", duration: "15 min", color: WorklogColors.muted),
          const TimelineEntry(title: "Nastavak rada", time: "10:45 – 11:50", duration: "1 h 5 min", color: WorklogColors.success),
        ],
      ),
    );
  }
}

class TimelineEntry extends StatelessWidget {
  const TimelineEntry({super.key, required this.title, required this.time, required this.duration, required this.color});
  final String title;
  final String time;
  final String duration;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.circle, color: color, size: 13),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(time),
      trailing: Text(duration, style: const TextStyle(color: WorklogColors.muted)),
    );
  }
}

class MaterialsScreen extends StatefulWidget {
  const MaterialsScreen({super.key, required this.state, required this.job});
  final AppState state;
  final WorkJob job;

  @override
  State<MaterialsScreen> createState() => _MaterialsScreenState();
}

class _MaterialsScreenState extends State<MaterialsScreen> {
  @override
  Widget build(BuildContext context) {
    final total = widget.job.materials.fold<double>(0, (sum, item) => sum + item.price);
    return Scaffold(
      appBar: AppBar(title: const Text("Materijal"), actions: [IconButton(onPressed: _add, icon: const Icon(Icons.add_circle_outline_rounded))]),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          ...widget.job.materials.map(
            (item) => Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.inventory_2_outlined)),
                title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text(item.quantity),
                trailing: Text(item.price.toStringAsFixed(2).replaceAll(".", ",") + " €"),
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(height: 50, child: FilledButton.icon(onPressed: _add, icon: const Icon(Icons.add), label: const Text("Dodaj stavku"))),
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  const Text("Ukupna vrijednost", style: TextStyle(color: WorklogColors.muted)),
                  const Spacer(),
                  Text(total.toStringAsFixed(2).replaceAll(".", ",") + " €", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _add() {
    final name = TextEditingController();
    final quantity = TextEditingController(text: "1 kom");
    final price = TextEditingController(text: "0");
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(18, 18, 18, MediaQuery.of(context).viewInsets.bottom + 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Nova stavka materijala", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            TextField(controller: name, decoration: const InputDecoration(labelText: "Naziv")),
            const SizedBox(height: 10),
            TextField(controller: quantity, decoration: const InputDecoration(labelText: "Količina")),
            const SizedBox(height: 10),
            TextField(controller: price, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Cijena (€)")),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  setState(() {
                    widget.job.materials.add(
                      MaterialItem(
                        name: name.text.trim().isEmpty ? "Materijal" : name.text.trim(),
                        quantity: quantity.text.trim(),
                        price: double.tryParse(price.text.replaceAll(",", ".")) ?? 0,
                      ),
                    );
                  });
                  widget.state.updateJob();
                  Navigator.pop(context);
                },
                child: const Text("Dodaj"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key, required this.state, required this.job});
  final AppState state;
  final WorkJob job;

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final note = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bilješke")),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Row(
            children: [
              Expanded(child: TextField(controller: note, decoration: const InputDecoration(hintText: "Dodaj bilješku..."))),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: () {
                  if (note.text.trim().isEmpty) return;
                  setState(() => widget.job.notes.add(note.text.trim()));
                  note.clear();
                  widget.state.updateJob();
                },
                icon: const Icon(Icons.send_rounded),
              ),
            ],
          ),
          const SectionTitle("Kontrolna lista"),
          const CheckRow("Očistiti filtere", true),
          const CheckRow("Provjeriti tlak plina", true),
          const CheckRow("Očistiti vanjsku jedinicu", true),
          const CheckRow("Provjeriti električne spojeve", false),
          const CheckRow("Testirati rad uređaja", false),
          const SectionTitle("Bilješke"),
          if (widget.job.notes.isEmpty) const Text("Još nema bilješki.", style: TextStyle(color: WorklogColors.muted)),
          ...widget.job.notes.map((item) => Card(child: ListTile(leading: const Icon(Icons.note_alt_outlined), title: Text(item)))),
          const SectionTitle("Fotografije s terena"),
          const Row(
            children: [
              Expanded(child: PhotoPlaceholder(icon: Icons.ac_unit_rounded, label: "Vanjska jedinica")),
              SizedBox(width: 10),
              Expanded(child: PhotoPlaceholder(icon: Icons.handyman_rounded, label: "Radovi")),
            ],
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.mic_none_rounded), label: const Text("Snimi glasovnu bilješku")),
        ],
      ),
    );
  }
}

class CheckRow extends StatefulWidget {
  const CheckRow(this.label, this.initial, {super.key});
  final String label;
  final bool initial;

  @override
  State<CheckRow> createState() => _CheckRowState();
}

class _CheckRowState extends State<CheckRow> {
  late bool value = widget.initial;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: value,
      onChanged: (next) => setState(() => value = next ?? value),
      title: Text(widget.label),
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}

class BeforeAfterScreen extends StatelessWidget {
  const BeforeAfterScreen({super.key, required this.job});
  final WorkJob job;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Fotografije")),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const SectionTitle("Fotografije prije"),
          const Row(
            children: [
              Expanded(child: PhotoPlaceholder(icon: Icons.plumbing_rounded, label: "Prije")),
              SizedBox(width: 10),
              Expanded(child: PhotoPlaceholder(icon: Icons.construction_rounded, label: "Prije")),
            ],
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.add_a_photo_outlined), label: const Text("Dodaj fotografiju")),
          const SectionTitle("Fotografije poslije"),
          const Row(
            children: [
              Expanded(child: PhotoPlaceholder(icon: Icons.bathroom_rounded, label: "Poslije")),
              SizedBox(width: 10),
              Expanded(child: PhotoPlaceholder(icon: Icons.check_circle_rounded, label: "Poslije")),
            ],
          ),
        ],
      ),
    );
  }
}

class PhotoPlaceholder extends StatelessWidget {
  const PhotoPlaceholder({super.key, required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF163B5F), Color(0xFF0A192B)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: WorklogColors.border),
      ),
      child: Stack(
        children: [
          Center(child: Icon(icon, size: 46, color: WorklogColors.muted)),
          Positioned(
            left: 8,
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
              child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

class CompletionFlowScreen extends StatefulWidget {
  const CompletionFlowScreen({super.key, required this.state, required this.job});
  final AppState state;
  final WorkJob job;

  @override
  State<CompletionFlowScreen> createState() => _CompletionFlowScreenState();
}

class _CompletionFlowScreenState extends State<CompletionFlowScreen> {
  int step = 0;
  final PageController pageController = PageController();

  void next() {
    if (step < 3) {
      pageController.nextPage(duration: const Duration(milliseconds: 230), curve: Curves.easeOut);
    } else {
      widget.job.status = JobStatus.completed;
      widget.state.updateJob();
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => SendReportScreen(job: widget.job)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final titles = ["Dokaz radova", "Potpis klijenta", "Pregled zapisnika", "Dovrši posao"];
    return Scaffold(
      appBar: AppBar(title: Text(titles[step])),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            child: LinearProgressIndicator(value: (step + 1) / 4),
          ),
          Expanded(
            child: PageView(
              controller: pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (value) => setState(() => step = value),
              children: [
                BeforeAfterStep(job: widget.job),
                const SignatureStep(),
                ReportPreviewStep(job: widget.job),
                const CompleteStep(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(onPressed: next, child: Text(step == 3 ? "Generiraj PDF zapisnik" : "Dalje")),
            ),
          ),
        ],
      ),
    );
  }
}

class BeforeAfterStep extends StatelessWidget {
  const BeforeAfterStep({super.key, required this.job});
  final WorkJob job;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: const [
        Text("Fotografije prije i poslije", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
        SizedBox(height: 8),
        Text("Dodaj dokaz trenutačnog stanja i završenih radova.", style: TextStyle(color: WorklogColors.muted)),
        SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: PhotoPlaceholder(icon: Icons.plumbing_rounded, label: "Prije")),
            SizedBox(width: 10),
            Expanded(child: PhotoPlaceholder(icon: Icons.bathroom_rounded, label: "Poslije")),
          ],
        ),
      ],
    );
  }
}

class SignatureStep extends StatefulWidget {
  const SignatureStep({super.key});

  @override
  State<SignatureStep> createState() => _SignatureStepState();
}

class _SignatureStepState extends State<SignatureStep> {
  final List<Offset?> points = [];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text("Potpis klijenta", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        const Text("Klijent potvrđuje da su radovi izvedeni prema dogovoru.", style: TextStyle(color: WorklogColors.muted)),
        const SizedBox(height: 18),
        const TextField(decoration: InputDecoration(labelText: "Ime i prezime klijenta")),
        const SizedBox(height: 12),
        Container(
          height: 240,
          decoration: BoxDecoration(
            color: WorklogColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: WorklogColors.border),
          ),
          child: GestureDetector(
            onPanStart: (details) => setState(() => points.add(details.localPosition)),
            onPanUpdate: (details) => setState(() => points.add(details.localPosition)),
            onPanEnd: (_) => setState(() => points.add(null)),
            child: CustomPaint(painter: SignaturePainter(points), child: const SizedBox.expand()),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(onPressed: () => setState(points.clear), icon: const Icon(Icons.refresh_rounded), label: const Text("Očisti")),
        ),
        CheckboxListTile(
          value: true,
          onChanged: (_) {},
          title: const Text("Potvrđujem da su radovi izvedeni kvalitetno i u skladu s dogovorom."),
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }
}

class SignaturePainter extends CustomPainter {
  SignaturePainter(this.points);
  final List<Offset?> points;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = WorklogColors.text
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    for (var index = 0; index < points.length - 1; index++) {
      final a = points[index];
      final b = points[index + 1];
      if (a != null && b != null) canvas.drawLine(a, b, paint);
    }
  }

  @override
  bool shouldRepaint(covariant SignaturePainter oldDelegate) => true;
}

class ReportPreviewStep extends StatelessWidget {
  const ReportPreviewStep({super.key, required this.job});
  final WorkJob job;

  @override
  Widget build(BuildContext context) {
    final minutes = math.max(job.minutesWorked, 270);
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text("Pregled zapisnika", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        const Text("Provjeri sve informacije prije generiranja PDF zapisnika.", style: TextStyle(color: WorklogColors.muted)),
        const SizedBox(height: 16),
        ReportBlock(title: "Sažetak posla", rows: [
          ["Vrsta radova", job.title],
          ["Klijent", job.client.name],
          ["Lokacija", job.location],
          ["Datum", job.dateLabel],
        ]),
        ReportBlock(title: "Odrađeni sati", rows: [
          ["Ukupno", (minutes ~/ 60).toString() + " h " + (minutes % 60).toString() + " min"],
        ]),
        ReportBlock(
          title: "Materijal",
          rows: job.materials.isEmpty ? [["Materijal", "Nije evidentiran"]] : job.materials.map((item) => [item.name, item.quantity]).toList(),
        ),
      ],
    );
  }
}

class ReportBlock extends StatelessWidget {
  const ReportBlock({super.key, required this.title, required this.rows});
  final String title;
  final List<List<String>> rows;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
            const Divider(height: 24),
            ...rows.map(
              (row) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Text(row[0], style: const TextStyle(color: WorklogColors.muted))),
                    Expanded(child: Text(row[1], textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w600))),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CompleteStep extends StatelessWidget {
  const CompleteStep({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(radius: 46, backgroundColor: Color(0x2210B981), child: Icon(Icons.check_rounded, color: WorklogColors.success, size: 54)),
            SizedBox(height: 22),
            Text("Posao je spreman za završetak", textAlign: TextAlign.center, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
            SizedBox(height: 10),
            Text("Fotografije, potpis, materijal i odrađeni sati bit će objedinjeni u zapisniku.", textAlign: TextAlign.center, style: TextStyle(color: WorklogColors.muted)),
          ],
        ),
      ),
    );
  }
}

class SendReportScreen extends StatefulWidget {
  const SendReportScreen({super.key, required this.job});
  final WorkJob job;

  @override
  State<SendReportScreen> createState() => _SendReportScreenState();
}

class _SendReportScreenState extends State<SendReportScreen> {
  bool sent = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pošalji izvještaj")),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Card(
            child: ListTile(
              leading: Icon(Icons.picture_as_pdf_rounded, color: Colors.redAccent),
              title: Text("PDF zapisnik", style: TextStyle(fontWeight: FontWeight.w800)),
              subtitle: Text("Spreman za slanje • 2,4 MB"),
            ),
          ),
          const SizedBox(height: 12),
          ShareTile(icon: Icons.mail_outline_rounded, title: "E-pošta", subtitle: "Pošalji klijentu e-poštom", onTap: () => setState(() => sent = true)),
          ShareTile(icon: Icons.chat_bubble_outline_rounded, title: "WhatsApp", subtitle: "Podijeli putem WhatsAppa", onTap: () => setState(() => sent = true)),
          ShareTile(icon: Icons.link_rounded, title: "Poveznica", subtitle: "Kreiraj poveznicu za dijeljenje", onTap: () => setState(() => sent = true)),
          if (sent) ...[
            const SizedBox(height: 18),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: WorklogColors.success, size: 64),
                    const SizedBox(height: 12),
                    const Text("Izvještaj uspješno poslan!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 6),
                    Text("Zapisnik za " + widget.job.client.name + " označen je kao poslan.", textAlign: TextAlign.center, style: const TextStyle(color: WorklogColors.muted)),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class ShareTile extends StatelessWidget {
  const ShareTile({super.key, required this.icon, required this.title, required this.subtitle, required this.onTap});
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: WorklogColors.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
