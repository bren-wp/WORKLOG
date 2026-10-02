import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models.dart';
import '../worklog_theme.dart';

class ClientDuplicatesScreen extends StatefulWidget {
  const ClientDuplicatesScreen({super.key, required this.state});

  final AppState state;

  @override
  State<ClientDuplicatesScreen> createState() => _ClientDuplicatesScreenState();
}

class _ClientDuplicatesScreenState extends State<ClientDuplicatesScreen> {
  final Map<String, String> primaryByGroup = {};

  String groupKey(ClientDuplicateGroup group) {
    final ids = group.clients.map((client) => client.id).toList()..sort();
    return ids.join('|');
  }

  int jobCount(String clientId) =>
      widget.state.jobs.where((job) => job.client.id == clientId).length;

  int messageCount(String clientId) => widget.state.messages
      .where((message) => message.clientId == clientId)
      .length;

  Future<void> merge(ClientDuplicateGroup group, Client duplicate) async {
    final key = groupKey(group);
    final keepId = primaryByGroup[key] ?? group.clients.first.id;
    if (duplicate.id == keepId) return;

    Client? primary;
    for (final client in group.clients) {
      if (client.id == keepId) {
        primary = client;
        break;
      }
    }
    if (primary == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Spoji klijente?'),
        content: Text(
          'Poslovi i razgovori klijenta "${duplicate.name}" bit će prevezani na "${primary!.name}". '
          'Prazni kontaktni podaci primarnog klijenta popunit će se podacima duplikata.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Odustani'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Spoji'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final merged = widget.state.mergeClients(
      keepClientId: keepId,
      removeClientId: duplicate.id,
    );
    if (!merged || !mounted) return;

    setState(primaryByGroup.clear);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Klijenti su spojeni, a povezana povijest je sačuvana.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groups = widget.state.findDuplicateClientGroups();

    return Scaffold(
      appBar: AppBar(title: const Text('Mogući duplikati klijenata')),
      body: groups.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Nisu pronađeni mogući duplikati.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: WorklogColors.muted),
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(18),
              itemCount: groups.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final group = groups[index];
                final key = groupKey(group);
                final selectedId =
                    primaryByGroup[key] ?? group.clients.first.id;

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.content_copy_rounded,
                              color: WorklogColors.warning,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                group.reason.isEmpty
                                    ? 'Mogući duplikati'
                                    : group.reason,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        DropdownButtonFormField<String>(
                          initialValue: selectedId,
                          decoration: const InputDecoration(
                            labelText: 'Primarni klijent',
                            helperText: 'Podaci i povijest drugih zapisa spojit će se u ovaj zapis.',
                          ),
                          items: group.clients
                              .map(
                                (client) => DropdownMenuItem(
                                  value: client.id,
                                  child: Text(client.name),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => primaryByGroup[key] = value);
                          },
                        ),
                        const SizedBox(height: 12),
                        ...group.clients.map((client) {
                          final primary = client.id == selectedId;
                          final meta = <String>[
                            if (client.type.isNotEmpty) client.type,
                            if (client.oib.isNotEmpty) 'OIB ${client.oib}',
                            if (client.email.isNotEmpty) client.email,
                            if (client.phone.isNotEmpty) client.phone,
                            '${jobCount(client.id)} poslova',
                            '${messageCount(client.id)} poruka',
                          ];

                          return Card(
                            color: primary
                                ? WorklogColors.surface2
                                : WorklogColors.surface,
                            child: ListTile(
                              leading: Icon(
                                primary
                                    ? Icons.verified_rounded
                                    : Icons.person_outline_rounded,
                                color: primary
                                    ? WorklogColors.success
                                    : WorklogColors.primary,
                              ),
                              title: Text(
                                client.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              subtitle: Text(meta.join(' • ')),
                              trailing: primary
                                  ? const Text(
                                      'Primarni',
                                      style: TextStyle(
                                        color: WorklogColors.success,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    )
                                  : TextButton(
                                      onPressed: () => merge(group, client),
                                      child: const Text('Spoji'),
                                    ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
