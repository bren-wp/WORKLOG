import 'package:flutter/material.dart';
import '../app_state.dart';
import '../brand.dart';
import '../models.dart';
import '../worklog_theme.dart';
import 'job_flow.dart';
import 'management.dart';

class ClientDetailScreen extends StatefulWidget {
  const ClientDetailScreen({
    super.key,
    required this.state,
    required this.client,
  });

  final AppState state;
  final Client client;

  @override
  State<ClientDetailScreen> createState() => _ClientDetailScreenState();
}

class _ClientDetailScreenState extends State<ClientDetailScreen> {
  Client get client => widget.state.clients.firstWhere(
        (item) => item.id == widget.client.id,
        orElse: () => widget.client,
      );

  Future<void> editClient() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ClientEditorScreen(
          state: widget.state,
          client: client,
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  Future<void> removeClient() async {
    final current = client;
    final jobs = widget.state.jobs
        .where((job) => job.client.id == current.id)
        .length;
    if (jobs > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Klijenta nije moguće izbrisati jer je povezan s $jobs posla.',
          ),
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Izbrisati klijenta?'),
        content: Text(
          'Klijent ${current.name} bit će uklonjen s ovog uređaja.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Odustani'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Izbriši'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    if (widget.state.removeClient(current.id)) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = client;
    final jobs = widget.state.jobs
        .where((job) => job.client.id == current.id)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalj klijenta"),
        actions: [
          IconButton(
            onPressed: editClient,
            tooltip: 'Uredi klijenta',
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: WorklogColors.primary,
                child: Text(
                  current.name.isEmpty ? '?' : current.name.substring(0, 1),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      current.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      current.type,
                      style: const TextStyle(color: WorklogColors.muted),
                    ),
                  ],
                ),
              ),
              const Chip(label: Text("Aktivan")),
            ],
          ),
          const SizedBox(height: 20),
          InfoTile(
            icon: Icons.phone_outlined,
            title: current.phone.isEmpty ? 'Nije uneseno' : current.phone,
            subtitle: "Telefon",
          ),
          InfoTile(
            icon: Icons.mail_outline_rounded,
            title: current.email.isEmpty ? 'Nije uneseno' : current.email,
            subtitle: "E-pošta",
          ),
          InfoTile(
            icon: Icons.location_on_outlined,
            title: current.address.isEmpty ? 'Nije uneseno' : current.address,
            subtitle: "Adresa",
          ),
          const SectionTitle("Povijest poslova"),
          if (jobs.isEmpty)
            const Text(
              "Nema evidentiranih poslova.",
              style: TextStyle(color: WorklogColors.muted),
            ),
          ...jobs.map(
            (job) => Card(
              child: ListTile(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => JobDetailScreen(
                      state: widget.state,
                      job: job,
                    ),
                  ),
                ),
                leading: const Icon(
                  Icons.handyman_rounded,
                  color: WorklogColors.cyan,
                ),
                title: Text(
                  job.title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text(job.dateLabel),
                trailing: Text(job.statusLabel),
              ),
            ),
          ),
          const SectionTitle("Komunikacija"),
          FilledButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MessagesScreen(
                  state: widget.state,
                  client: current,
                ),
              ),
            ),
            icon: const Icon(Icons.chat_bubble_outline_rounded),
            label: const Text("Otvori poruke"),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: removeClient,
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: WorklogColors.danger,
            ),
            label: const Text(
              'Izbriši klijenta',
              style: TextStyle(color: WorklogColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({
    super.key,
    required this.state,
    required this.client,
  });

  final AppState state;
  final Client client;

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final controller = TextEditingController();
  final scrollController = ScrollController();

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void sendMine() {
    final text = controller.text.trim();
    if (text.isEmpty) return;

    widget.state.addMessage(
      clientId: widget.client.id,
      text: text,
      mine: true,
    );
    controller.clear();
    _scrollToEnd();
  }

  Future<void> addClientReply() async {
    final reply = TextEditingController();
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Evidentiraj odgovor klijenta'),
        content: TextField(
          controller: reply,
          autofocus: true,
          minLines: 2,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Upiši poruku koju je klijent poslao ili rekao...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Odustani'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, reply.text.trim()),
            child: const Text('Spremi odgovor'),
          ),
        ],
      ),
    );
    reply.dispose();

    if (value == null || value.trim().isEmpty || !mounted) return;
    widget.state.addMessage(
      clientId: widget.client.id,
      text: value,
      mine: false,
    );
    _scrollToEnd();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  String formatTimestamp(DateTime value) {
    final now = DateTime.now();
    final sameDay =
        now.year == value.year &&
        now.month == value.month &&
        now.day == value.day;
    final time =
        '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
    if (sameDay) return 'Danas • $time';
    return '${value.day}. ${value.month}. ${value.year}. • $time';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.client.name),
        actions: [
          IconButton(
            onPressed: addClientReply,
            tooltip: 'Evidentiraj odgovor klijenta',
            icon: const Icon(Icons.mark_chat_unread_outlined),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: widget.state,
        builder: (context, _) {
          final messages =
              widget.state.messagesForClient(widget.client.id);

          return Column(
            children: [
              Expanded(
                child: messages.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(28),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.forum_outlined,
                                size: 52,
                                color: WorklogColors.muted,
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Nema evidentiranih poruka.',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Pošalji internu zabilješku razgovora ili evidentiraj odgovor klijenta.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: WorklogColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.all(18),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          return MessageBubble(
                            text: message.text,
                            mine: message.mine,
                            timestamp: formatTimestamp(message.createdAt),
                          );
                        },
                      ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          minLines: 1,
                          maxLines: 4,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => sendMine(),
                          decoration: const InputDecoration(
                            hintText: 'Napiši poruku ili bilješku...',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        onPressed: sendMine,
                        icon: const Icon(Icons.send_rounded),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.text,
    required this.mine,
    required this.timestamp,
  });

  final String text;
  final bool mine;
  final String timestamp;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 310),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: mine ? WorklogColors.primary : WorklogColors.surface2,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(text),
            const SizedBox(height: 5),
            Text(
              timestamp,
              style: TextStyle(
                fontSize: 10,
                color: mine
                    ? Colors.white.withValues(alpha: .74)
                    : WorklogColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({
    super.key,
    required this.state,
  });

  final AppState state;

  IconData iconFor(String kind) => switch (kind) {
        'job' => Icons.handyman_outlined,
        'client' => Icons.person_outline_rounded,
        'team' => Icons.groups_outlined,
        'report' => Icons.picture_as_pdf_outlined,
        'message' => Icons.chat_bubble_outline_rounded,
        _ => Icons.info_outline_rounded,
      };

  Color colorFor(String kind) => switch (kind) {
        'job' => WorklogColors.primary,
        'client' => WorklogColors.cyan,
        'team' => WorklogColors.violet,
        'report' => WorklogColors.success,
        'message' => WorklogColors.warning,
        _ => WorklogColors.muted,
      };

  String formatTimestamp(DateTime value) {
    final now = DateTime.now();
    final sameDay =
        now.year == value.year &&
        now.month == value.month &&
        now.day == value.day;
    final time =
        '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
    if (sameDay) return 'Danas u $time';
    return '${value.day}. ${value.month}. ${value.year}. u $time';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        final items = state.activityItems;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              state.unreadActivityCount == 0
                  ? 'Obavijesti'
                  : 'Obavijesti (${state.unreadActivityCount})',
            ),
            actions: [
              if (state.unreadActivityCount > 0)
                IconButton(
                  onPressed: state.markAllActivityRead,
                  tooltip: 'Označi sve kao pročitano',
                  icon: const Icon(Icons.done_all_rounded),
                ),
              if (items.any((item) => item.read))
                IconButton(
                  onPressed: state.clearReadActivity,
                  tooltip: 'Ukloni pročitane',
                  icon: const Icon(Icons.delete_sweep_outlined),
                ),
            ],
          ),
          body: items.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.notifications_none_rounded,
                          size: 54,
                          color: WorklogColors.muted,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Nema zabilježenih događaja.',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Novi poslovi, klijenti, članovi tima i važni događaji pojavit će se ovdje.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: WorklogColors.muted),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(18),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final color = colorFor(item.kind);
                    return Card(
                      child: ListTile(
                        onTap: () => state.markActivityRead(item.id),
                        leading: CircleAvatar(
                          backgroundColor: color.withValues(alpha: .16),
                          child: Icon(iconFor(item.kind), color: color),
                        ),
                        title: Text(
                          item.title,
                          style: TextStyle(
                            fontWeight: item.read
                                ? FontWeight.w600
                                : FontWeight.w900,
                          ),
                        ),
                        subtitle: Text(
                          item.subtitle.isEmpty
                              ? formatTimestamp(item.createdAt)
                              : '${item.subtitle}\n${formatTimestamp(item.createdAt)}',
                        ),
                        isThreeLine: item.subtitle.isNotEmpty,
                        trailing: item.read
                            ? null
                            : const Icon(
                                Icons.circle,
                                size: 10,
                                color: WorklogColors.primary,
                              ),
                      ),
                    );
                  },
                ),
        );
      },
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
              subtitle: Text("${job.client.name} • ${job.dateLabel}"),
              trailing: Chip(label: Text(job.status == JobStatus.completed ? "Potpisano" : "Na čekanju")),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SendReportScreen(state: state, job: job),
                ),
              ),
            ),
          ),
        ).toList(),
      ),
    );
  }
}
