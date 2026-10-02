import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';

import '../app_state.dart';
import '../brand.dart';
import '../models.dart';
import '../worklog_theme.dart';
import '../services/device_services.dart';
import '../services/notification_service.dart';
import '../services/pdf_report_service.dart';

class NewJobScreen extends StatefulWidget {
  const NewJobScreen({super.key, required this.state});

  final AppState state;

  @override
  State<NewJobScreen> createState() => _NewJobScreenState();
}

class _NewJobScreenState extends State<NewJobScreen> {
  final formKey = GlobalKey<FormState>();
  final title = TextEditingController();
  final location = TextEditingController();
  final description = TextEditingController();

  Client? selectedClient;
  String priority = "Srednji";
  String assignedMemberId = "";
  DateTime selectedDate = DateTime.now();
  TimeOfDay startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay endTime = const TimeOfDay(hour: 9, minute: 0);

  @override
  void initState() {
    super.initState();
    selectedClient = widget.state.clients.isEmpty
        ? null
        : widget.state.clients.first;
  }

  @override
  void dispose() {
    title.dispose();
    location.dispose();
    description.dispose();
    super.dispose();
  }

  DateTime get scheduledStart => DateTime(
    selectedDate.year,
    selectedDate.month,
    selectedDate.day,
    startTime.hour,
    startTime.minute,
  );

  DateTime get scheduledEnd => DateTime(
    selectedDate.year,
    selectedDate.month,
    selectedDate.day,
    endTime.hour,
    endTime.minute,
  );

  Future<void> pickDate() async {
    final value = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 3650)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      helpText: 'Odaberi datum posla',
      cancelText: 'Odustani',
      confirmText: 'Odaberi',
    );
    if (value != null && mounted) {
      setState(() => selectedDate = value);
    }
  }

  Future<void> pickStartTime() async {
    final value = await showTimePicker(
      context: context,
      initialTime: startTime,
      helpText: 'Vrijeme početka',
    );
    if (value != null && mounted) {
      setState(() => startTime = value);
    }
  }

  Future<void> pickEndTime() async {
    final value = await showTimePicker(
      context: context,
      initialTime: endTime,
      helpText: 'Vrijeme završetka',
    );
    if (value != null && mounted) {
      setState(() => endTime = value);
    }
  }

  void save() {
    if (!(formKey.currentState?.validate() ?? false)) return;
    final client = selectedClient;
    if (client == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Prvo dodaj i odaberi klijenta za ovaj posao.'),
        ),
      );
      return;
    }
    if (!scheduledEnd.isAfter(scheduledStart)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vrijeme završetka mora biti nakon početka.'),
        ),
      );
      return;
    }

    widget.state.addJob(
      WorkJob(
        title: title.text.trim(),
        client: client,
        location: location.text.trim(),
        scheduledStart: scheduledStart,
        scheduledEnd: scheduledEnd,
        status: JobStatus.planned,
        description: description.text.trim(),
        priority: priority,
        assignedMemberId: assignedMemberId.isEmpty ? null : assignedMemberId,
        assignedMemberName: widget.state.teamMemberById(assignedMemberId)?.name,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Novi posao")),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            TextFormField(
              controller: title,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: "Naziv posla *",
                prefixIcon: Icon(Icons.edit_note_rounded),
              ),
              validator: (value) => value == null || value.trim().length < 2
                  ? 'Unesi naziv posla.'
                  : null,
            ),
            const SizedBox(height: 12),
            if (widget.state.clients.isEmpty) ...[
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.person_add_alt_1_rounded,
                        color: WorklogColors.cyan,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Nema spremljenih klijenata. Prvo dodaj klijenta u kartici Klijenti, a zatim izradi posao.',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            DropdownButtonFormField<Client>(
              initialValue: selectedClient,
              decoration: const InputDecoration(
                labelText: "Klijent *",
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
              items: widget.state.clients
                  .map(
                    (client) => DropdownMenuItem(
                      value: client,
                      child: Text(client.name),
                    ),
                  )
                  .toList(),
              onChanged: (client) => setState(() => selectedClient = client),
              validator: (client) =>
                  client == null ? 'Odaberi klijenta.' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: location,
              decoration: const InputDecoration(
                labelText: "Lokacija *",
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
              validator: (value) => value == null || value.trim().length < 2
                  ? 'Unesi lokaciju posla.'
                  : null,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: pickDate,
              icon: const Icon(Icons.calendar_month_outlined),
              label: Align(
                alignment: Alignment.centerLeft,
                child: Text(formatCroatianDate(selectedDate)),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: pickStartTime,
                    icon: const Icon(Icons.schedule_rounded),
                    label: Text(
                      MaterialLocalizations.of(
                        context,
                      ).formatTimeOfDay(startTime, alwaysUse24HourFormat: true),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: pickEndTime,
                    icon: const Icon(Icons.schedule_send_rounded),
                    label: Text(
                      MaterialLocalizations.of(
                        context,
                      ).formatTimeOfDay(endTime, alwaysUse24HourFormat: true),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: assignedMemberId,
              decoration: const InputDecoration(
                labelText: "Dodijeli članu tima",
                prefixIcon: Icon(Icons.engineering_outlined),
              ),
              items: [
                const DropdownMenuItem(
                  value: "",
                  child: Text("Nije dodijeljeno"),
                ),
                ...widget.state.teamMembers
                    .where((member) => member.active)
                    .map(
                      (member) => DropdownMenuItem(
                        value: member.id,
                        child: Text(member.name),
                      ),
                    ),
              ],
              onChanged: (value) =>
                  setState(() => assignedMemberId = value ?? ""),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: description,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(labelText: "Opis posla"),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: priority,
              decoration: const InputDecoration(labelText: "Prioritet"),
              items: ["Niski", "Srednji", "Visoki"]
                  .map(
                    (value) =>
                        DropdownMenuItem(value: value, child: Text(value)),
                  )
                  .toList(),
              onChanged: (value) =>
                  setState(() => priority = value ?? priority),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: selectedClient == null ? null : save,
                icon: const Icon(Icons.save_outlined),
                label: const Text("Spremi posao"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class JobEditorScreen extends StatefulWidget {
  const JobEditorScreen({super.key, required this.state, required this.job});

  final AppState state;
  final WorkJob job;

  @override
  State<JobEditorScreen> createState() => _JobEditorScreenState();
}

class _JobEditorScreenState extends State<JobEditorScreen> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController title;
  late final TextEditingController location;
  late final TextEditingController description;
  late Client selectedClient;
  late String priority;
  late JobStatus status;
  late String assignedMemberId;
  late DateTime selectedDate;
  late TimeOfDay startTime;
  late TimeOfDay endTime;

  @override
  void initState() {
    super.initState();
    final job = widget.job;
    final start = job.scheduledStart ?? DateTime.now();
    final end = job.scheduledEnd ?? start.add(const Duration(hours: 1));

    title = TextEditingController(text: job.title);
    location = TextEditingController(text: job.location);
    description = TextEditingController(text: job.description);
    selectedClient = job.client;
    priority = job.priority;
    status = job.status;
    assignedMemberId = widget.state.teamMemberById(job.assignedMemberId) == null
        ? ""
        : job.assignedMemberId ?? "";
    selectedDate = DateTime(start.year, start.month, start.day);
    startTime = TimeOfDay.fromDateTime(start);
    endTime = TimeOfDay.fromDateTime(end);
  }

  @override
  void dispose() {
    title.dispose();
    location.dispose();
    description.dispose();
    super.dispose();
  }

  DateTime get scheduledStart => DateTime(
    selectedDate.year,
    selectedDate.month,
    selectedDate.day,
    startTime.hour,
    startTime.minute,
  );

  DateTime get scheduledEnd => DateTime(
    selectedDate.year,
    selectedDate.month,
    selectedDate.day,
    endTime.hour,
    endTime.minute,
  );

  Future<void> pickDate() async {
    final value = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 3650)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      helpText: 'Odaberi datum posla',
    );
    if (value != null && mounted) setState(() => selectedDate = value);
  }

  Future<void> pickTime({required bool start}) async {
    final value = await showTimePicker(
      context: context,
      initialTime: start ? startTime : endTime,
      helpText: start ? 'Vrijeme početka' : 'Vrijeme završetka',
    );
    if (value == null || !mounted) return;
    setState(() {
      if (start) {
        startTime = value;
      } else {
        endTime = value;
      }
    });
  }

  void save() {
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (!scheduledEnd.isAfter(scheduledStart)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vrijeme završetka mora biti nakon početka.'),
        ),
      );
      return;
    }

    final job = widget.job;
    job.title = title.text.trim();
    job.client = selectedClient;
    job.location = location.text.trim();
    job.description = description.text.trim();
    job.priority = priority;
    job.status = status;
    job.assignedMemberId = assignedMemberId.isEmpty ? null : assignedMemberId;
    job.assignedMemberName = widget.state
        .teamMemberById(assignedMemberId)
        ?.name;
    job.setSchedule(scheduledStart, scheduledEnd);

    widget.state.updateJob(
      activityTitle: 'Posao ažuriran',
      activitySubtitle: '${job.title} • ${job.client.name}',
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final activeTeam = widget.state.teamMembers.where(
      (member) => member.active || member.id == assignedMemberId,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Uredi posao')),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            TextFormField(
              controller: title,
              decoration: const InputDecoration(labelText: 'Naziv posla *'),
              validator: (value) => value == null || value.trim().length < 2
                  ? 'Unesi naziv posla.'
                  : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<Client>(
              initialValue: selectedClient,
              decoration: const InputDecoration(labelText: 'Klijent *'),
              items: widget.state.clients
                  .map(
                    (client) => DropdownMenuItem(
                      value: client,
                      child: Text(client.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) =>
                  setState(() => selectedClient = value ?? selectedClient),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: location,
              decoration: const InputDecoration(labelText: 'Lokacija *'),
              validator: (value) => value == null || value.trim().length < 2
                  ? 'Unesi lokaciju posla.'
                  : null,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: pickDate,
              icon: const Icon(Icons.calendar_month_outlined),
              label: Align(
                alignment: Alignment.centerLeft,
                child: Text(formatCroatianDate(selectedDate)),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => pickTime(start: true),
                    icon: const Icon(Icons.schedule_rounded),
                    label: Text(
                      MaterialLocalizations.of(
                        context,
                      ).formatTimeOfDay(startTime, alwaysUse24HourFormat: true),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => pickTime(start: false),
                    icon: const Icon(Icons.schedule_send_rounded),
                    label: Text(
                      MaterialLocalizations.of(
                        context,
                      ).formatTimeOfDay(endTime, alwaysUse24HourFormat: true),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<JobStatus>(
              initialValue: status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: JobStatus.values
                  .map(
                    (value) => DropdownMenuItem(
                      value: value,
                      child: Text(value.label),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => status = value ?? status),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: assignedMemberId,
              decoration: const InputDecoration(labelText: 'Terenski tehničar'),
              items: [
                const DropdownMenuItem(
                  value: '',
                  child: Text('Nije dodijeljeno'),
                ),
                ...activeTeam.map(
                  (member) => DropdownMenuItem(
                    value: member.id,
                    child: Text(member.name),
                  ),
                ),
              ],
              onChanged: (value) =>
                  setState(() => assignedMemberId = value ?? assignedMemberId),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: priority,
              decoration: const InputDecoration(labelText: 'Prioritet'),
              items: ['Niski', 'Srednji', 'Visoki']
                  .map(
                    (value) =>
                        DropdownMenuItem(value: value, child: Text(value)),
                  )
                  .toList(),
              onChanged: (value) =>
                  setState(() => priority = value ?? priority),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: description,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(labelText: 'Opis posla'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: save,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Spremi promjene'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class JobDetailScreen extends StatefulWidget {
  const JobDetailScreen({super.key, required this.state, required this.job});

  final AppState state;
  final WorkJob job;

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  Future<void> editJob() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => JobEditorScreen(state: widget.state, job: widget.job),
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;
    final state = widget.state;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalj posla"),
        actions: [
          IconButton(
            onPressed: editJob,
            tooltip: 'Uredi posao',
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text(
            job.title,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Chip(label: Text(job.statusLabel)),
          ),
          const SizedBox(height: 14),
          InfoTile(
            icon: Icons.person_outline_rounded,
            title: job.client.name,
            subtitle: job.client.phone,
          ),
          InfoTile(
            icon: Icons.engineering_outlined,
            title:
                state.teamMemberById(job.assignedMemberId)?.name ??
                job.assignedMemberName ??
                "Nije dodijeljeno",
            subtitle: "Terenski tehničar",
          ),
          InfoTile(
            icon: Icons.location_on_outlined,
            title: job.location,
            subtitle: "Otvori navigaciju",
          ),
          InfoTile(
            icon: Icons.calendar_month_outlined,
            title: job.dateLabel,
            subtitle: job.timeLabel,
          ),
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
                Center(
                  child: Icon(
                    Icons.map_rounded,
                    size: 74,
                    color: WorklogColors.border,
                  ),
                ),
                Center(
                  child: Icon(
                    Icons.location_pin,
                    size: 44,
                    color: WorklogColors.primary,
                  ),
                ),
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
              ActionButton(
                icon: Icons.phone_rounded,
                label: "Nazovi",
                color: WorklogColors.success,
                onTap: () async {
                  final opened = await const ExternalActionService().call(
                    job.client.phone,
                  );
                  if (!opened && context.mounted) {
                    _toast(
                      context,
                      "Poziv nije moguće otvoriti na ovom uređaju.",
                    );
                  }
                },
              ),
              ActionButton(
                icon: Icons.navigation_rounded,
                label: "Navigacija",
                color: WorklogColors.primary,
                onTap: () async {
                  final opened = await const ExternalActionService()
                      .openNavigation(job.location);
                  if (!opened && context.mounted) {
                    _toast(context, "Navigaciju nije moguće otvoriti.");
                  }
                },
              ),
              ActionButton(
                icon: Icons.timer_outlined,
                label: "Evidencija vremena",
                color: WorklogColors.cyan,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TimeTrackingScreen(state: state, job: job),
                  ),
                ),
              ),
              ActionButton(
                icon: Icons.inventory_2_outlined,
                label: "Materijal",
                color: WorklogColors.violet,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MaterialsScreen(state: state, job: job),
                  ),
                ),
              ),
              ActionButton(
                icon: Icons.note_alt_outlined,
                label: "Bilješke",
                color: WorklogColors.warning,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NotesScreen(state: state, job: job),
                  ),
                ),
              ),
              ActionButton(
                icon: Icons.photo_camera_outlined,
                label: "Fotografije",
                color: WorklogColors.primary,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BeforeAfterScreen(state: state, job: job),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 54,
            child: FilledButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CompletionFlowScreen(state: state, job: job),
                ),
              ),
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
  const InfoTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });
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
  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: color),
      label: Text(label, textAlign: TextAlign.center),
    );
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
  Timer? ticker;

  @override
  void initState() {
    super.initState();
    _syncTicker();
  }

  @override
  void dispose() {
    ticker?.cancel();
    super.dispose();
  }

  void _syncTicker() {
    ticker?.cancel();
    ticker = null;
    if (!widget.job.timerRunning) return;
    ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> toggle() async {
    if (widget.job.timerRunning) {
      widget.state.pauseJobTimer(widget.job);
      _syncTicker();
      if (mounted) setState(() {});
      return;
    }

    final wasPlanned = widget.job.status == JobStatus.planned;
    final started = widget.state.startJobTimer(widget.job);
    if (!started) return;

    _syncTicker();
    if (mounted) setState(() {});

    if (wasPlanned && widget.state.preferences.notificationsEnabled) {
      try {
        await WorklogNotificationService.instance.showJobStarted(
          jobTitle: widget.job.title,
          clientName: widget.job.client.name,
        );
      } catch (_) {
        // Mjerenje mora nastaviti raditi čak i ako OS odbije obavijest.
      }
    }
  }

  void stop() {
    if (!widget.state.stopJobTimer(widget.job)) return;
    _syncTicker();
    if (mounted) setState(() {});
  }

  Future<void> adjustTime() async {
    final minutesController = TextEditingController();
    final reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ručna korekcija vremena'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: minutesController,
              keyboardType: const TextInputType.numberWithOptions(signed: true),
              decoration: const InputDecoration(
                labelText: 'Minute (+ ili -)',
                hintText: 'npr. 15 ili -10',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Razlog korekcije'),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Odustani'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Spremi korekciju'),
          ),
        ],
      ),
    );

    final minutes = int.tryParse(minutesController.text.trim());
    final reason = reasonController.text.trim();
    minutesController.dispose();
    reasonController.dispose();

    if (confirmed != true ||
        minutes == null ||
        minutes == 0 ||
        reason.isEmpty) {
      return;
    }

    final updated = widget.state.adjustJobTime(
      widget.job,
      minutes: minutes,
      reason: reason,
    );
    if (!updated || !mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Korekcija vremena je spremljena.')),
    );
  }

  String get formatted {
    final seconds = widget.job.workedSeconds();
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    return [h, m, s].map((value) => value.toString().padLeft(2, '0')).join(':');
  }

  String _durationForEntry(WorkTimeEntry entry) {
    final seconds = entry.elapsedSeconds();
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainder = seconds % 60;
    if (hours > 0) return '${hours} h ${minutes} min';
    if (minutes > 0) return '${minutes} min ${remainder} s';
    return '${remainder} s';
  }

  @override
  Widget build(BuildContext context) {
    final running = widget.job.timerRunning;
    final entries = widget.job.timeEntries.reversed.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Evidencija vremena')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [
                  Text(
                    widget.job.title,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    formatted,
                    style: const TextStyle(
                      fontSize: 46,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    running
                        ? 'Rad u tijeku'
                        : widget.job.status == JobStatus.paused
                        ? 'Mjerenje je pauzirano'
                        : 'Mjerenje nije aktivno',
                    style: TextStyle(
                      color: running
                          ? WorklogColors.success
                          : WorklogColors.muted,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FloatingActionButton.large(
                        heroTag: 'timer',
                        onPressed: toggle,
                        child: Icon(
                          running
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                        ),
                      ),
                      const SizedBox(width: 18),
                      FloatingActionButton.large(
                        heroTag: 'stop',
                        backgroundColor: WorklogColors.danger,
                        onPressed: running ? stop : null,
                        child: const Icon(Icons.stop_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    onPressed: adjustTime,
                    icon: const Icon(Icons.edit_clock_outlined),
                    label: const Text('Ručna korekcija'),
                  ),
                ],
              ),
            ),
          ),
          const SectionTitle('Intervali rada'),
          if (entries.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Još nema evidentiranih intervala rada.',
                  style: TextStyle(color: WorklogColors.muted),
                ),
              ),
            )
          else
            ...entries.map(
              (entry) => TimelineEntry(
                title: entry.isRunning ? 'Rad u tijeku' : 'Radni interval',
                time:
                    '${formatClock(entry.startedAt)} – ${entry.endedAt == null ? 'u tijeku' : formatClock(entry.endedAt!)}',
                duration: _durationForEntry(entry),
                color: entry.isRunning
                    ? WorklogColors.success
                    : WorklogColors.primary,
              ),
            ),
          if (widget.job.manualAdjustmentMinutes != 0) ...[
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.tune_rounded,
                  color: WorklogColors.cyan,
                ),
                title: Text(
                  'Ručna korekcija: ${widget.job.manualAdjustmentMinutes > 0 ? '+' : ''}${widget.job.manualAdjustmentMinutes} min',
                ),
                subtitle: Text(
                  widget.job.manualAdjustmentReason.isEmpty
                      ? 'Razlog nije naveden'
                      : widget.job.manualAdjustmentReason,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class TimelineEntry extends StatelessWidget {
  const TimelineEntry({
    super.key,
    required this.title,
    required this.time,
    required this.duration,
    required this.color,
  });
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
      trailing: Text(
        duration,
        style: const TextStyle(color: WorklogColors.muted),
      ),
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
    final total = widget.job.materials.fold<double>(
      0,
      (sum, item) => sum + item.price,
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text("Materijal"),
        actions: [
          IconButton(
            onPressed: _add,
            icon: const Icon(Icons.add_circle_outline_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          ...widget.job.materials.map(
            (item) => Card(
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.inventory_2_outlined),
                ),
                title: Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(item.quantity),
                trailing: Text(
                  "${item.price.toStringAsFixed(2).replaceAll(".", ",")} €",
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 50,
            child: FilledButton.icon(
              onPressed: _add,
              icon: const Icon(Icons.add),
              label: const Text("Dodaj stavku"),
            ),
          ),
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  const Text(
                    "Ukupna vrijednost",
                    style: TextStyle(color: WorklogColors.muted),
                  ),
                  const Spacer(),
                  Text(
                    "${total.toStringAsFixed(2).replaceAll(".", ",")} €",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
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
        padding: EdgeInsets.fromLTRB(
          18,
          18,
          18,
          MediaQuery.of(context).viewInsets.bottom + 18,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Nova stavka materijala",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: "Naziv"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: quantity,
              decoration: const InputDecoration(labelText: "Količina"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: price,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Cijena (€)"),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  setState(() {
                    widget.job.materials.add(
                      MaterialItem(
                        name: name.text.trim().isEmpty
                            ? "Materijal"
                            : name.text.trim(),
                        quantity: quantity.text.trim(),
                        price:
                            double.tryParse(price.text.replaceAll(",", ".")) ??
                            0,
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
              Expanded(
                child: TextField(
                  controller: note,
                  decoration: const InputDecoration(
                    hintText: "Dodaj bilješku...",
                  ),
                ),
              ),
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
          if (widget.job.notes.isEmpty)
            const Text(
              "Još nema bilješki.",
              style: TextStyle(color: WorklogColors.muted),
            ),
          ...widget.job.notes.map(
            (item) => Card(
              child: ListTile(
                leading: const Icon(Icons.note_alt_outlined),
                title: Text(item),
              ),
            ),
          ),
          const SectionTitle("Fotografije s terena"),
          const Row(
            children: [
              Expanded(
                child: PhotoPlaceholder(
                  icon: Icons.ac_unit_rounded,
                  label: "Vanjska jedinica",
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: PhotoPlaceholder(
                  icon: Icons.handyman_rounded,
                  label: "Radovi",
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.mic_none_rounded),
            label: const Text("Snimi glasovnu bilješku"),
          ),
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
  const BeforeAfterScreen({super.key, required this.state, required this.job});

  final AppState state;
  final WorkJob job;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Fotografije")),
      body: JobPhotoManager(state: state, job: job),
    );
  }
}

class JobPhotoManager extends StatefulWidget {
  const JobPhotoManager({
    super.key,
    required this.state,
    required this.job,
    this.compact = false,
  });

  final AppState state;
  final WorkJob job;
  final bool compact;

  @override
  State<JobPhotoManager> createState() => _JobPhotoManagerState();
}

class _JobPhotoManagerState extends State<JobPhotoManager> {
  final DeviceMediaService _media = DeviceMediaService();
  bool busy = false;

  @override
  void initState() {
    super.initState();
    unawaited(_recoverLostImages());
  }

  Future<void> _recoverLostImages() async {
    final storage = widget.state.storage;
    if (storage == null) return;
    final paths = await _media.recoverLostImages(
      storage: storage,
      job: widget.job,
    );
    if (paths.isEmpty || !mounted) return;
    setState(() => widget.job.beforePhotoPaths.addAll(paths));
    widget.state.updateJob();
  }

  Future<void> _pick(bool before, ImageSource source) async {
    final storage = widget.state.storage;
    if (storage == null || busy) return;

    setState(() => busy = true);
    try {
      final path = await _media.pickJobPhoto(
        storage: storage,
        job: widget.job,
        before: before,
        source: source,
      );
      if (path == null || !mounted) return;
      setState(() {
        final list = before
            ? widget.job.beforePhotoPaths
            : widget.job.afterPhotoPaths;
        list.add(path);
      });
      widget.state.updateJob();
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _chooseSource(bool before) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text("Kamera"),
                subtitle: const Text("Snimi novu fotografiju na terenu."),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text("Galerija"),
                subtitle: const Text("Odaberi postojeću fotografiju."),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );
    if (source != null && mounted) {
      await _pick(before, source);
    }
  }

  void _remove(bool before, String path) {
    setState(() {
      final list = before
          ? widget.job.beforePhotoPaths
          : widget.job.afterPhotoPaths;
      list.remove(path);
    });
    widget.state.updateJob();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(widget.compact ? 14 : 18),
      shrinkWrap: widget.compact,
      physics: widget.compact
          ? const NeverScrollableScrollPhysics()
          : const AlwaysScrollableScrollPhysics(),
      children: [
        PhotoSection(
          title: "Fotografije prije",
          subtitle: "Dokumentiraj stanje prije početka radova.",
          paths: widget.job.beforePhotoPaths,
          onAdd: () => _chooseSource(true),
          onRemove: (path) => _remove(true, path),
          busy: busy,
        ),
        const SizedBox(height: 18),
        PhotoSection(
          title: "Fotografije poslije",
          subtitle: "Dodaj dokaz završenih radova.",
          paths: widget.job.afterPhotoPaths,
          onAdd: () => _chooseSource(false),
          onRemove: (path) => _remove(false, path),
          busy: busy,
        ),
      ],
    );
  }
}

class PhotoSection extends StatelessWidget {
  const PhotoSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.paths,
    required this.onAdd,
    required this.onRemove,
    required this.busy,
  });

  final String title;
  final String subtitle;
  final List<String> paths;
  final VoidCallback onAdd;
  final ValueChanged<String> onRemove;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(color: WorklogColors.muted)),
        const SizedBox(height: 12),
        if (paths.isEmpty)
          const PhotoPlaceholder(
            icon: Icons.add_a_photo_outlined,
            label: "Još nema fotografija",
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: paths.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.15,
            ),
            itemBuilder: (context, index) {
              final path = paths[index];
              return ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(
                      File(path),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: WorklogColors.surface2,
                        child: const Icon(
                          Icons.broken_image_outlined,
                          color: WorklogColors.muted,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 6,
                      top: 6,
                      child: IconButton.filledTonal(
                        onPressed: () => onRemove(path),
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: busy ? null : onAdd,
            icon: busy
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.add_a_photo_outlined),
            label: Text(busy ? "Spremanje..." : "Dodaj fotografiju"),
          ),
        ),
      ],
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
        gradient: const LinearGradient(
          colors: [Color(0xFF163B5F), Color(0xFF0A192B)],
        ),
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
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CompletionFlowScreen extends StatefulWidget {
  const CompletionFlowScreen({
    super.key,
    required this.state,
    required this.job,
  });

  final AppState state;
  final WorkJob job;

  @override
  State<CompletionFlowScreen> createState() => _CompletionFlowScreenState();
}

class _CompletionFlowScreenState extends State<CompletionFlowScreen> {
  int step = 0;
  bool processing = false;
  final PageController pageController = PageController();
  final GlobalKey<SignatureStepState> signatureKey =
      GlobalKey<SignatureStepState>();

  Future<void> next() async {
    if (processing) return;

    if (step == 1) {
      await signatureKey.currentState?.persistSignature();
    }

    if (step < 3) {
      await pageController.nextPage(
        duration: const Duration(milliseconds: 230),
        curve: Curves.easeOut,
      );
      return;
    }

    final storage = widget.state.storage;
    if (storage == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pohrana uređaja nije dostupna.")),
      );
      return;
    }

    setState(() => processing = true);
    try {
      widget.job.pauseTimer();
      widget.job.status = JobStatus.completed;
      widget.state.updateJob(
        activityTitle: 'Posao završen',
        activitySubtitle: '${widget.job.title} • ${widget.job.client.name}',
      );
      final file = await PdfReportService(storage).generate(widget.job);
      await widget.state.persistNow();

      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => SendReportScreen(
            state: widget.state,
            job: widget.job,
            initialFile: file,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("PDF zapisnik nije moguće izraditi: $error")),
      );
    } finally {
      if (mounted) setState(() => processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final titles = [
      "Dokaz radova",
      "Potpis klijenta",
      "Pregled zapisnika",
      "Dovrši posao",
    ];
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
                JobPhotoManager(state: widget.state, job: widget.job),
                SignatureStep(
                  key: signatureKey,
                  state: widget.state,
                  job: widget.job,
                ),
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
              child: FilledButton(
                onPressed: processing ? null : next,
                child: processing
                    ? const SizedBox.square(
                        dimension: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      )
                    : Text(step == 3 ? "Generiraj PDF zapisnik" : "Dalje"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SignatureStep extends StatefulWidget {
  const SignatureStep({super.key, required this.state, required this.job});

  final AppState state;
  final WorkJob job;

  @override
  State<SignatureStep> createState() => SignatureStepState();
}

class SignatureStepState extends State<SignatureStep> {
  final List<Offset?> points = [];
  final GlobalKey boundaryKey = GlobalKey();
  bool saving = false;

  Future<void> persistSignature() async {
    if (points.whereType<Offset>().length < 2 || saving) return;
    final storage = widget.state.storage;
    if (storage == null) return;

    setState(() => saving = true);
    try {
      await WidgetsBinding.instance.endOfFrame;
      final object = boundaryKey.currentContext?.findRenderObject();
      if (object is! RenderRepaintBoundary) return;

      final image = await object.toImage(pixelRatio: 2);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      if (byteData == null) return;

      final path = await storage.persistBytes(
        bytes: byteData.buffer.asUint8List(),
        directoryName: 'potpisi',
        fileName: 'potpis-${widget.job.id}.png',
      );
      widget.job.signaturePath = path;
      widget.state.updateJob();
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  void clear() {
    setState(points.clear);
    widget.job.signaturePath = null;
    widget.state.updateJob();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text(
          "Potpis klijenta",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        const Text(
          "Klijent potvrđuje da su radovi izvedeni prema dogovoru.",
          style: TextStyle(color: WorklogColors.muted),
        ),
        const SizedBox(height: 18),
        TextField(
          controller: TextEditingController(text: widget.job.client.name),
          readOnly: true,
          decoration: const InputDecoration(
            labelText: "Ime i prezime klijenta",
          ),
        ),
        const SizedBox(height: 12),
        RepaintBoundary(
          key: boundaryKey,
          child: Container(
            height: 240,
            decoration: BoxDecoration(
              color: WorklogColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: WorklogColors.border),
            ),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanStart: (details) {
                setState(() => points.add(details.localPosition));
              },
              onPanUpdate: (details) {
                setState(() => points.add(details.localPosition));
              },
              onPanEnd: (_) {
                setState(() => points.add(null));
              },
              child: CustomPaint(
                painter: SignaturePainter(points),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: saving ? null : clear,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text("Očisti"),
          ),
        ),
        if (widget.job.signaturePath != null)
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color: WorklogColors.success,
                  size: 18,
                ),
                SizedBox(width: 6),
                Text(
                  "Potpis je spremljen.",
                  style: TextStyle(color: WorklogColors.success),
                ),
              ],
            ),
          ),
        CheckboxListTile(
          value: true,
          onChanged: (_) {},
          title: const Text(
            "Potvrđujem da su radovi izvedeni kvalitetno i u skladu s dogovorom.",
          ),
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
    final minutes = job.totalWorkedMinutes;
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text(
          "Pregled zapisnika",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        const Text(
          "Provjeri sve informacije prije generiranja PDF zapisnika.",
          style: TextStyle(color: WorklogColors.muted),
        ),
        const SizedBox(height: 16),
        ReportBlock(
          title: "Sažetak posla",
          rows: [
            ["Vrsta radova", job.title],
            ["Klijent", job.client.name],
            ["Lokacija", job.location],
            ["Datum", job.dateLabel],
          ],
        ),
        ReportBlock(
          title: "Odrađeni sati",
          rows: [
            ["Ukupno", "${minutes ~/ 60} h ${minutes % 60} min"],
          ],
        ),
        ReportBlock(
          title: "Materijal",
          rows: job.materials.isEmpty
              ? [
                  ["Materijal", "Nije evidentiran"],
                ]
              : job.materials
                    .map((item) => [item.name, item.quantity])
                    .toList(),
        ),
        ReportBlock(
          title: "Dokaz rada",
          rows: [
            ["Fotografije prije", job.beforePhotoPaths.length.toString()],
            ["Fotografije poslije", job.afterPhotoPaths.length.toString()],
            [
              "Potpis klijenta",
              job.signaturePath == null ? "Nije spremljen" : "Spremljen",
            ],
          ],
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
                    Expanded(
                      child: Text(
                        row[0],
                        style: const TextStyle(color: WorklogColors.muted),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        row[1],
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
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
            CircleAvatar(
              radius: 46,
              backgroundColor: Color(0x2210B981),
              child: Icon(
                Icons.check_rounded,
                color: WorklogColors.success,
                size: 54,
              ),
            ),
            SizedBox(height: 22),
            Text(
              "Posao je spreman za završetak",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
            ),
            SizedBox(height: 10),
            Text(
              "Fotografije, potpis, materijal i odrađeni sati bit će objedinjeni u stvarnom PDF zapisniku.",
              textAlign: TextAlign.center,
              style: TextStyle(color: WorklogColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class SendReportScreen extends StatefulWidget {
  const SendReportScreen({
    super.key,
    required this.state,
    required this.job,
    this.initialFile,
  });

  final AppState state;
  final WorkJob job;
  final File? initialFile;

  @override
  State<SendReportScreen> createState() => _SendReportScreenState();
}

class _SendReportScreenState extends State<SendReportScreen> {
  File? reportFile;
  bool busy = false;

  bool get sent => widget.job.reportSent;

  @override
  void initState() {
    super.initState();
    reportFile = widget.initialFile;
    final savedPath = widget.job.reportPath;
    if (reportFile == null && savedPath != null && savedPath.isNotEmpty) {
      reportFile = File(savedPath);
    }
  }

  Future<File?> _ensureReport() async {
    final existing = reportFile;
    if (existing != null && await existing.exists()) return existing;

    final storage = widget.state.storage;
    if (storage == null) return null;

    final generated = await PdfReportService(storage).generate(widget.job);
    reportFile = generated;
    await widget.state.persistNow();
    if (mounted) setState(() {});
    return generated;
  }

  Future<void> _share(BuildContext shareContext) async {
    if (busy) return;
    final storage = widget.state.storage;
    if (storage == null) return;

    setState(() => busy = true);
    try {
      final file = await _ensureReport();
      if (file == null || !mounted || !shareContext.mounted) return;

      final result = await PdfReportService(
        storage,
      ).share(shareContext, file, widget.job);

      if (result.status == ShareResultStatus.success) {
        widget.job.reportSent = true;
        widget.state.updateJob(
          activityTitle: 'Zapisnik podijeljen',
          activitySubtitle: '${widget.job.title} • ${widget.job.client.name}',
          kind: 'report',
        );
        await widget.state.persistNow();
        if (mounted) setState(() {});
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Dijeljenje nije uspjelo: $error")),
      );
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _regenerate() async {
    final storage = widget.state.storage;
    if (storage == null || busy) return;
    setState(() => busy = true);
    try {
      final file = await PdfReportService(storage).generate(widget.job);
      reportFile = file;
      await widget.state.persistNow();
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("PDF zapisnik je ponovno generiran.")),
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final path = reportFile?.path ?? widget.job.reportPath;
    return Scaffold(
      appBar: AppBar(title: const Text("Pošalji izvještaj")),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.picture_as_pdf_rounded,
                color: Colors.redAccent,
              ),
              title: const Text(
                "PDF zapisnik",
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text(
                path == null
                    ? "Zapisnik će biti generiran pri dijeljenju."
                    : "PDF je spremljen na uređaju.",
              ),
              trailing: IconButton(
                onPressed: busy ? null : _regenerate,
                tooltip: "Ponovno generiraj",
                icon: const Icon(Icons.refresh_rounded),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Builder(
            builder: (shareContext) => Column(
              children: [
                ShareTile(
                  icon: Icons.ios_share_rounded,
                  title: "Podijeli zapisnik",
                  subtitle:
                      "Otvori sustavni izbornik za e-poštu, WhatsApp i druge aplikacije.",
                  onTap: busy ? () {} : () => _share(shareContext),
                ),
                ShareTile(
                  icon: Icons.mail_outline_rounded,
                  title: "E-pošta",
                  subtitle:
                      "PDF možeš odabrati u sustavnom izborniku dijeljenja.",
                  onTap: busy ? () {} : () => _share(shareContext),
                ),
                ShareTile(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: "WhatsApp",
                  subtitle: "Podijeli PDF kroz instalirane aplikacije.",
                  onTap: busy ? () {} : () => _share(shareContext),
                ),
              ],
            ),
          ),
          if (busy)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: LinearProgressIndicator(),
            ),
          if (sent) ...[
            const SizedBox(height: 18),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: WorklogColors.success,
                      size: 64,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Izvještaj uspješno podijeljen!",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Zapisnik za ${widget.job.client.name} označen je kao podijeljen.",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: WorklogColors.muted),
                    ),
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
  const ShareTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
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
