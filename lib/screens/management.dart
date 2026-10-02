import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../app_state.dart';
import '../models.dart';
import '../services/device_services.dart';
import '../worklog_theme.dart';

class ClientEditorScreen extends StatefulWidget {
  const ClientEditorScreen({super.key, required this.state, this.client});
  final AppState state;
  final Client? client;

  @override
  State<ClientEditorScreen> createState() => _ClientEditorScreenState();
}

class _ClientEditorScreenState extends State<ClientEditorScreen> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController name;
  late final TextEditingController phone;
  late final TextEditingController email;
  late final TextEditingController address;
  late String type;

  bool get editing => widget.client != null;

  @override
  void initState() {
    super.initState();
    final client = widget.client;
    name = TextEditingController(text: client?.name ?? '');
    phone = TextEditingController(text: client?.phone ?? '');
    email = TextEditingController(text: client?.email ?? '');
    address = TextEditingController(text: client?.address ?? '');
    type = client?.type ?? 'Privatna osoba';
  }

  @override
  void dispose() {
    name.dispose();
    phone.dispose();
    email.dispose();
    address.dispose();
    super.dispose();
  }

  void save() {
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (editing) {
      widget.state.updateClient(
        widget.client!.copyWith(
          name: name.text.trim(),
          type: type,
          phone: phone.text.trim(),
          email: email.text.trim(),
          address: address.text.trim(),
        ),
      );
    } else {
      widget.state.addClient(
        Client(
          name: name.text.trim(),
          type: type,
          phone: phone.text.trim(),
          email: email.text.trim(),
          address: address.text.trim(),
        ),
      );
    }
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(editing ? 'Uredi klijenta' : 'Novi klijent')),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            TextFormField(
              controller: name,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Naziv / ime i prezime *',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
              validator: (value) => value == null || value.trim().length < 2
                  ? 'Unesi naziv klijenta.'
                  : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: type,
              decoration: const InputDecoration(
                labelText: 'Vrsta klijenta',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
              items: const [
                DropdownMenuItem(value: 'Privatna osoba', child: Text('Privatna osoba')),
                DropdownMenuItem(value: 'Tvrtka', child: Text('Tvrtka')),
                DropdownMenuItem(value: 'Obrt', child: Text('Obrt')),
                DropdownMenuItem(value: 'Udruga', child: Text('Udruga')),
              ],
              onChanged: (value) => setState(() => type = value ?? type),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Telefon',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'E-pošta',
                prefixIcon: Icon(Icons.mail_outline_rounded),
              ),
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) return null;
                if (!text.contains('@') || !text.contains('.')) {
                  return 'Unesi ispravnu adresu e-pošte.';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: address,
              decoration: const InputDecoration(
                labelText: 'Adresa',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
              minLines: 2,
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: save,
                icon: const Icon(Icons.save_outlined),
                label: Text(editing ? 'Spremi promjene' : 'Dodaj klijenta'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CompanyProfileScreen extends StatefulWidget {
  const CompanyProfileScreen({super.key, required this.state});
  final AppState state;

  @override
  State<CompanyProfileScreen> createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends State<CompanyProfileScreen> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController name;
  late final TextEditingController activity;
  late final TextEditingController phone;
  late final TextEditingController email;
  late final TextEditingController address;
  late final TextEditingController oib;

  @override
  void initState() {
    super.initState();
    final profile = widget.state.companyProfile;
    name = TextEditingController(text: profile.name);
    activity = TextEditingController(text: profile.activity);
    phone = TextEditingController(text: profile.phone);
    email = TextEditingController(text: profile.email);
    address = TextEditingController(text: profile.address);
    oib = TextEditingController(text: profile.oib);
  }

  @override
  void dispose() {
    name.dispose();
    activity.dispose();
    phone.dispose();
    email.dispose();
    address.dispose();
    oib.dispose();
    super.dispose();
  }

  void save() {
    if (!(formKey.currentState?.validate() ?? false)) return;
    widget.state.updateCompanyProfile(
      CompanyProfile(
        name: name.text.trim(),
        activity: activity.text.trim(),
        phone: phone.text.trim(),
        email: email.text.trim(),
        address: address.text.trim(),
        oib: oib.text.trim(),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profil tvrtke je spremljen.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil tvrtke')),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Center(
              child: Container(
                width: 104,
                height: 104,
                decoration: BoxDecoration(
                  color: WorklogColors.surface2,
                  shape: BoxShape.circle,
                  border: Border.all(color: WorklogColors.primary),
                ),
                child: const Icon(
                  Icons.business_rounded,
                  size: 46,
                  color: WorklogColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 22),
            TextFormField(
              controller: name,
              decoration: const InputDecoration(labelText: 'Naziv tvrtke *'),
              validator: (value) => value == null || value.trim().length < 2
                  ? 'Unesi naziv tvrtke.'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: activity,
              decoration: const InputDecoration(labelText: 'Djelatnost'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Telefon'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'E-pošta'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: address,
              decoration: const InputDecoration(labelText: 'Adresa'),
              minLines: 2,
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: oib,
              keyboardType: TextInputType.number,
              maxLength: 11,
              decoration: const InputDecoration(labelText: 'OIB', counterText: ''),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: save,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Spremi profil'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TeamScreen extends StatelessWidget {
  const TeamScreen({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terenski tim'),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TeamMemberEditorScreen(state: state),
              ),
            ),
            icon: const Icon(Icons.person_add_alt_1_rounded),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: state,
        builder: (context, _) {
          if (state.teamMembers.isEmpty) {
            return const Center(
              child: Text(
                'Još nema članova tima.',
                style: TextStyle(color: WorklogColors.muted),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(18),
            itemCount: state.teamMembers.length,
            itemBuilder: (context, index) {
              final member = state.teamMembers[index];
              return Card(
                child: ListTile(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TeamMemberEditorScreen(
                        state: state,
                        member: member,
                      ),
                    ),
                  ),
                  leading: CircleAvatar(
                    backgroundColor: member.active
                        ? WorklogColors.primary
                        : WorklogColors.border,
                    child: Text(
                      member.name.isEmpty ? '?' : member.name.substring(0, 1),
                    ),
                  ),
                  title: Text(
                    member.name,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(member.role),
                  trailing: Icon(
                    member.active
                        ? Icons.check_circle_rounded
                        : Icons.pause_circle_outline_rounded,
                    color: member.active
                        ? WorklogColors.success
                        : WorklogColors.muted,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class TeamMemberEditorScreen extends StatefulWidget {
  const TeamMemberEditorScreen({
    super.key,
    required this.state,
    this.member,
  });

  final AppState state;
  final TeamMember? member;

  @override
  State<TeamMemberEditorScreen> createState() => _TeamMemberEditorScreenState();
}

class _TeamMemberEditorScreenState extends State<TeamMemberEditorScreen> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController name;
  late final TextEditingController role;
  late final TextEditingController phone;
  late final TextEditingController email;
  late bool active;

  bool get editing => widget.member != null;

  @override
  void initState() {
    super.initState();
    final member = widget.member;
    name = TextEditingController(text: member?.name ?? '');
    role = TextEditingController(text: member?.role ?? 'Terenski tehničar');
    phone = TextEditingController(text: member?.phone ?? '');
    email = TextEditingController(text: member?.email ?? '');
    active = member?.active ?? true;
  }

  @override
  void dispose() {
    name.dispose();
    role.dispose();
    phone.dispose();
    email.dispose();
    super.dispose();
  }

  void save() {
    if (!(formKey.currentState?.validate() ?? false)) return;
    final current = widget.member;
    if (current == null) {
      widget.state.addTeamMember(
        TeamMember(
          name: name.text.trim(),
          role: role.text.trim(),
          phone: phone.text.trim(),
          email: email.text.trim(),
          active: active,
        ),
      );
    } else {
      widget.state.updateTeamMember(
        current.copyWith(
          name: name.text.trim(),
          role: role.text.trim(),
          phone: phone.text.trim(),
          email: email.text.trim(),
          active: active,
        ),
      );
    }
    Navigator.pop(context);
  }

  Future<void> remove() async {
    final current = widget.member;
    if (current == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ukloniti člana?'),
        content: Text(
          'Član ${current.name} bit će uklonjen s ovog uređaja.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Odustani'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ukloni'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    widget.state.removeTeamMember(current.id);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(editing ? 'Uredi člana' : 'Novi član tima')),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            TextFormField(
              controller: name,
              decoration: const InputDecoration(labelText: 'Ime i prezime *'),
              validator: (value) => value == null || value.trim().length < 2
                  ? 'Unesi ime člana tima.'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: role,
              decoration: const InputDecoration(labelText: 'Uloga'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Telefon'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'E-pošta'),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              value: active,
              onChanged: (value) => setState(() => active = value),
              title: const Text('Aktivan član'),
              subtitle: const Text('Aktivni član može primati terenske zadatke.'),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: save,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Spremi člana'),
              ),
            ),
            if (editing) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: remove,
                icon: const Icon(Icons.delete_outline_rounded),
                label: const Text('Ukloni člana'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Postavke')),
      body: AnimatedBuilder(
        animation: state,
        builder: (context, _) {
          final prefs = state.preferences;
          return ListView(
            padding: const EdgeInsets.all(18),
            children: [
              const Text(
                'Rad aplikacije',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      value: prefs.notificationsEnabled,
                      onChanged: (value) => state.updatePreferences(
                        prefs.copyWith(notificationsEnabled: value),
                      ),
                      title: const Text('Obavijesti'),
                      subtitle: const Text(
                        'Prikazuj WORKLOG podsjetnike i obavijesti.',
                      ),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      value: prefs.autoSaveEnabled,
                      onChanged: (value) {
                        state.updatePreferences(
                          prefs.copyWith(autoSaveEnabled: value),
                        );
                        if (value) {
                          state.persistNow();
                        }
                      },
                      title: const Text('Automatsko spremanje'),
                      subtitle: const Text(
                        'Promjene automatski spremaj u privatnu pohranu.',
                      ),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      value: prefs.compactCards,
                      onChanged: (value) => state.updatePreferences(
                        prefs.copyWith(compactCards: value),
                      ),
                      title: const Text('Kompaktne kartice'),
                      subtitle: const Text(
                        'Prikaži više sadržaja na manjim zaslonima.',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Sigurnost',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              Card(
                child: SwitchListTile(
                  value: prefs.biometricLockEnabled,
                  onChanged: (value) => state.updatePreferences(
                    prefs.copyWith(biometricLockEnabled: value),
                  ),
                  title: const Text('Zaključavanje aplikacije'),
                  subtitle: const Text(
                    'Postavka je spremljena; biometrijska provjera bit će povezana s platformskim identitetom.',
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

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key, required this.state});
  final AppState state;

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  bool busy = false;

  Future<void> exportData(BuildContext shareContext) async {
    final storage = widget.state.storage;
    if (storage == null || busy) return;
    setState(() => busy = true);
    try {
      final bytes = utf8.encode(
        const JsonEncoder.withIndent('  ').convert(
          widget.state.exportSnapshot(),
        ),
      );
      final path = await storage.persistBytes(
        bytes: bytes,
        directoryName: 'izvoz',
        fileName: 'worklog-podaci.json',
      );
      if (!mounted || !shareContext.mounted) return;
      await SharePlus.instance.share(
        ShareParams(
          title: 'WORKLOG izvoz podataka',
          subject: 'WORKLOG podaci',
          text: 'Izvoz lokalnih WORKLOG podataka.',
          files: [XFile(path)],
          sharePositionOrigin: ExternalActionService.shareOrigin(shareContext),
        ),
      );
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> resetData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Izbrisati lokalne podatke?'),
        content: const Text(
          'Bit će uklonjeni lokalno spremljeni poslovi, fotografije, potpisi, zapisnici, klijenti i postavke. Ova radnja se ne može poništiti.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Odustani'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Izbriši podatke'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => busy = true);
    await widget.state.resetLocalData();
    if (!mounted) return;
    setState(() => busy = false);
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privatnost i sigurnost')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Card(
            child: const ListTile(
              leading: Icon(
                Icons.lock_outline_rounded,
                color: WorklogColors.success,
              ),
              title: Text(
                'Privatna pohrana uređaja',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text(
                'Operativni podaci, fotografije, potpisi i PDF zapisnici ostaju u privatnom prostoru WORKLOG aplikacije na uređaju.',
              ),
            ),
          ),
          const SizedBox(height: 12),
          Builder(
            builder: (shareContext) => Card(
              child: ListTile(
                onTap: busy ? null : () => exportData(shareContext),
                leading: const Icon(
                  Icons.download_outlined,
                  color: WorklogColors.primary,
                ),
                title: const Text(
                  'Izvezi podatke',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: const Text(
                  'Izradi JSON kopiju klijenata, poslova, tima i postavki.',
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
              ),
            ),
          ),
          Card(
            child: ListTile(
              onTap: () {
                widget.state.logout();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              leading: const Icon(Icons.logout_rounded),
              title: const Text(
                'Odjava',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: const Text('Vrati se na zaslon za prijavu.'),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Opasna zona',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: WorklogColors.danger,
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: ListTile(
              onTap: busy ? null : resetData,
              leading: const Icon(
                Icons.delete_forever_outlined,
                color: WorklogColors.danger,
              ),
              title: const Text(
                'Izbriši lokalne podatke',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: WorklogColors.danger,
                ),
              ),
              subtitle: const Text(
                'Uklanja lokalne WORKLOG podatke i vraća početno stanje aplikacije.',
              ),
            ),
          ),
          if (busy)
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: LinearProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
