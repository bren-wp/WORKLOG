import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models.dart';
import '../worklog_theme.dart';
import 'job_flow.dart';
import 'management.dart';
import 'support.dart';

class GlobalSearchScreen extends StatefulWidget {
  const GlobalSearchScreen({super.key, required this.state});

  final AppState state;

  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> {
  final queryController = TextEditingController();

  @override
  void dispose() {
    queryController.dispose();
    super.dispose();
  }

  bool matches(String query, Iterable<String?> values) {
    if (query.isEmpty) return false;
    return values.any(
      (value) => normalizeSearchValue(value ?? '').contains(query),
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = normalizeSearchValue(queryController.text);
    final jobs = query.isEmpty
        ? <WorkJob>[]
        : widget.state.jobs.where((job) {
            return matches(query, [
              job.id,
              job.title,
              job.location,
              job.client.name,
              job.client.email,
              job.client.phone,
              job.client.oib,
              job.assignedMemberName,
              job.statusLabel,
            ]);
          }).toList();
    final clients = query.isEmpty
        ? <Client>[]
        : widget.state.clients.where((client) {
            return matches(query, [
              client.id,
              client.name,
              client.type,
              client.phone,
              client.email,
              client.address,
              client.oib,
            ]);
          }).toList();
    final members = query.isEmpty
        ? <TeamMember>[]
        : widget.state.teamMembers.where((member) {
            return matches(query, [
              member.id,
              member.name,
              member.role,
              member.phone,
              member.email,
            ]);
          }).toList();
    final resultCount = jobs.length + clients.length + members.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Globalna pretraga')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          TextField(
            controller: queryController,
            autofocus: true,
            textInputAction: TextInputAction.search,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Posao, klijent, adresa, član tima ili broj naloga...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Očisti pretragu',
                      onPressed: () {
                        queryController.clear();
                        setState(() {});
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          if (query.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(18),
                child: Text(
                  'Pretražuj poslove, nazive i kontakte klijenata, OIB, adrese, članove tima i ID naloga.',
                  style: TextStyle(color: WorklogColors.muted),
                ),
              ),
            )
          else if (resultCount == 0)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(18),
                child: Text(
                  'Nema rezultata za zadanu pretragu.',
                  style: TextStyle(color: WorklogColors.muted),
                ),
              ),
            )
          else ...[
            Text(
              '$resultCount rezultata',
              style: const TextStyle(
                color: WorklogColors.muted,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (jobs.isNotEmpty) ...[
              const _SearchSectionTitle('Poslovi'),
              ...jobs.map(
                (job) => Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.work_outline_rounded,
                      color: WorklogColors.primary,
                    ),
                    title: Text(
                      job.title,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(
                      '${job.client.name} • ${job.location}\n${job.statusLabel} • ID ${job.id}',
                    ),
                    isThreeLine: true,
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            JobDetailScreen(state: widget.state, job: job),
                      ),
                    ),
                  ),
                ),
              ),
            ],
            if (clients.isNotEmpty) ...[
              const _SearchSectionTitle('Klijenti'),
              ...clients.map(
                (client) => Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.people_outline_rounded,
                      color: WorklogColors.cyan,
                    ),
                    title: Text(
                      client.name,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(
                      [
                        client.type,
                        if (client.oib.isNotEmpty) 'OIB ${client.oib}',
                        if (client.address.isNotEmpty) client.address,
                      ].join(' • '),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ClientDetailScreen(
                          state: widget.state,
                          client: client,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
            if (members.isNotEmpty) ...[
              const _SearchSectionTitle('Terenski tim'),
              ...members.map(
                (member) => Card(
                  child: ListTile(
                    leading: Icon(
                      member.active
                          ? Icons.engineering_rounded
                          : Icons.person_off_outlined,
                      color: member.active
                          ? WorklogColors.success
                          : WorklogColors.muted,
                    ),
                    title: Text(
                      member.name,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(
                      '${member.role}${member.email.isEmpty ? '' : ' • ${member.email}'}',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => TeamMemberEditorScreen(
                          state: widget.state,
                          member: member,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _SearchSectionTitle extends StatelessWidget {
  const _SearchSectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 8),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: WorklogColors.muted,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
