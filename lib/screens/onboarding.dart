import 'package:flutter/material.dart';

import '../app_state.dart';
import '../brand.dart';
import '../models.dart';
import '../worklog_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.state});
  final AppState state;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController controller = PageController();
  int page = 0;

  final slides = const [
    (
      "Organiziraj posao na terenu.",
      "Sve što ti treba za poslove, klijente, materijal i dokaze rada — na jednom mjestu.",
      Icons.home_repair_service_rounded,
    ),
    (
      "Poslovi i raspored",
      "Pregledaj dnevni raspored, upravljaj poslovima i prati promjene bez kaosa.",
      Icons.calendar_month_rounded,
    ),
    (
      "Fotografije i dokaz rada",
      "Dokumentiraj radove prije i poslije, spremi potpis i pripremi profesionalni zapisnik.",
      Icons.photo_camera_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: widget.state.finishOnboarding,
                child: const Text("Preskoči"),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: controller,
                itemCount: slides.length,
                onPageChanged: (value) => setState(() => page = value),
                itemBuilder: (context, index) {
                  final slide = slides[index];
                  return ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 12,
                    ),
                    children: [
                      const SizedBox(height: 8),
                      const Center(child: WorklogMark(size: 96)),
                      const SizedBox(height: 20),
                      const Center(child: WorklogWordmark()),
                      const SizedBox(height: 28),
                      Center(
                        child: Container(
                          width: 82,
                          height: 82,
                          decoration: BoxDecoration(
                            color: WorklogColors.surface2,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: WorklogColors.border),
                          ),
                          child: Icon(
                            slide.$3,
                            color: WorklogColors.primary,
                            size: 40,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        slide.$1,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        slide.$2,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.4,
                          color: WorklogColors.muted,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                slides.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  margin: const EdgeInsets.all(4),
                  width: page == index ? 28 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: page == index
                        ? WorklogColors.primary
                        : WorklogColors.border,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  onPressed: () {
                    if (page < slides.length - 1) {
                      controller.nextPage(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                      );
                    } else {
                      widget.state.finishOnboarding();
                    }
                  },
                  child: Text(page == slides.length - 1 ? "Započni" : "Dalje"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.state});

  final AppState state;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();

  bool registerMode = false;
  bool showPassword = false;

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    final success = registerMode
        ? await widget.state.register(
            name: name.text.trim(),
            email: email.text.trim(),
            password: password.text,
          )
        : await widget.state.login(
            email: email.text.trim(),
            password: password.text,
          );

    if (!mounted || success) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.state.authError ?? 'Autentikacija nije uspjela.'),
      ),
    );
  }

  String? validateEmail(String? value) {
    final clean = value?.trim() ?? '';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(clean)) {
      return 'Unesi valjanu e-mail adresu.';
    }
    return null;
  }

  String? validatePassword(String? value) {
    final clean = value ?? '';
    if (clean.length < 10) {
      return 'Lozinka mora imati najmanje 10 znakova.';
    }
    if (!RegExp(r'[A-Za-z]').hasMatch(clean) ||
        !RegExp(r'\d').hasMatch(clean)) {
      return 'Lozinka mora sadržavati slovo i broj.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final configured = widget.state.authConfigured;
    final busy = widget.state.authBusy;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(28),
          children: [
            const SizedBox(height: 24),
            const Center(child: WorklogWordmark()),
            const SizedBox(height: 40),
            Text(
              registerMode ? 'Izradi WORKLOG račun' : 'Prijava u WORKLOG',
              style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            const Text(
              'Prijava i registracija koriste sigurnu WORKLOG serversku autentikaciju e-mailom i lozinkom.',
              style: TextStyle(color: WorklogColors.muted, fontSize: 16),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: registerMode
                      ? OutlinedButton(
                          onPressed: busy
                              ? null
                              : () => setState(() => registerMode = false),
                          child: const Text('Prijava'),
                        )
                      : FilledButton(
                          onPressed: null,
                          child: const Text('Prijava'),
                        ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: registerMode
                      ? FilledButton(
                          onPressed: null,
                          child: const Text('Registracija'),
                        )
                      : OutlinedButton(
                          onPressed: busy
                              ? null
                              : () => setState(() => registerMode = true),
                          child: const Text('Registracija'),
                        ),
                ),
              ],
            ),
            if (!configured) ...[
              const SizedBox(height: 18),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.dns_rounded, color: WorklogColors.cyan),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Backend kod je u /web. Za stvarnu prijavu build aplikacije mora dobiti HTTPS adresu kroz WORKLOG_API_BASE_URL. Lokalni bypass nije dopušten.',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            Form(
              key: formKey,
              child: Column(
                children: [
                  if (registerMode) ...[
                    TextFormField(
                      controller: name,
                      enabled: configured && !busy,
                      textInputAction: TextInputAction.next,
                      autocompleteHints: const [AutofillHints.name],
                      decoration: const InputDecoration(
                        labelText: 'Ime i prezime',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                      validator: (value) {
                        final clean = value?.trim() ?? '';
                        if (clean.length < 2 || clean.length > 120) {
                          return 'Unesi ime od 2 do 120 znakova.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                  ],
                  TextFormField(
                    controller: email,
                    enabled: configured && !busy,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    decoration: const InputDecoration(
                      labelText: 'E-mail',
                      prefixIcon: Icon(Icons.alternate_email_rounded),
                    ),
                    validator: validateEmail,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: password,
                    enabled: configured && !busy,
                    obscureText: !showPassword,
                    textInputAction: TextInputAction.done,
                    autofillHints: [
                      registerMode
                          ? AutofillHints.newPassword
                          : AutofillHints.password,
                    ],
                    onFieldSubmitted: (_) =>
                        configured && !busy ? submit() : null,
                    decoration: InputDecoration(
                      labelText: 'Lozinka',
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      suffixIcon: IconButton(
                        onPressed: busy
                            ? null
                            : () =>
                                  setState(() => showPassword = !showPassword),
                        icon: Icon(
                          showPassword
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                        ),
                      ),
                    ),
                    validator: validatePassword,
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton.icon(
                      onPressed: !configured || busy ? null : submit,
                      icon: busy
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              registerMode
                                  ? Icons.person_add_alt_1_rounded
                                  : Icons.login_rounded,
                            ),
                      label: Text(registerMode ? 'Izradi račun' : 'Prijavi se'),
                    ),
                  ),
                ],
              ),
            ),
            if (widget.state.authError != null) ...[
              const SizedBox(height: 14),
              Text(
                widget.state.authError!,
                style: const TextStyle(color: Colors.redAccent),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key, required this.state});

  final AppState state;

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final formKey = GlobalKey<FormState>();
  final companyName = TextEditingController();
  final phone = TextEditingController();
  String activity = "Instalacije i klimatizacija";
  String employees = "1 – 5";

  @override
  void dispose() {
    companyName.dispose();
    phone.dispose();
    super.dispose();
  }

  void finish() {
    if (!(formKey.currentState?.validate() ?? false)) return;
    widget.state.updateCompanyProfile(
      CompanyProfile(
        name: companyName.text.trim(),
        activity: activity,
        phone: phone.text.trim(),
        employeeRange: employees,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profil tvrtke")),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              "Unesi osnovne podatke za početak korištenja.",
              style: TextStyle(color: WorklogColors.muted),
            ),
            const SizedBox(height: 24),
            Center(
              child: Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: WorklogColors.primary, width: 1.5),
                  color: WorklogColors.surface,
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.business_rounded,
                      color: WorklogColors.primary,
                      size: 38,
                    ),
                    SizedBox(height: 6),
                    Text("WORKLOG", style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 26),
            TextFormField(
              controller: companyName,
              decoration: const InputDecoration(
                labelText: "Naziv obrta / tvrtke *",
              ),
              validator: (value) => value == null || value.trim().length < 2
                  ? "Unesi naziv tvrtke."
                  : null,
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: activity,
              items: const [
                DropdownMenuItem(
                  value: "Instalacije i klimatizacija",
                  child: Text("Instalacije i klimatizacija"),
                ),
                DropdownMenuItem(
                  value: "Elektroinstalacije",
                  child: Text("Elektroinstalacije"),
                ),
                DropdownMenuItem(
                  value: "Vodoinstalacije",
                  child: Text("Vodoinstalacije"),
                ),
                DropdownMenuItem(
                  value: "Građevinski radovi",
                  child: Text("Građevinski radovi"),
                ),
              ],
              onChanged: (value) =>
                  setState(() => activity = value ?? activity),
              decoration: const InputDecoration(labelText: "Djelatnost"),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: employees,
              items: const [
                DropdownMenuItem(value: "1 – 5", child: Text("1 – 5")),
                DropdownMenuItem(value: "6 – 20", child: Text("6 – 20")),
                DropdownMenuItem(value: "21 – 50", child: Text("21 – 50")),
                DropdownMenuItem(value: "51+", child: Text("51+")),
              ],
              onChanged: (value) =>
                  setState(() => employees = value ?? employees),
              decoration: const InputDecoration(labelText: "Broj zaposlenih"),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Broj telefona",
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 54,
              child: FilledButton(
                onPressed: finish,
                child: const Text("Završi postavljanje"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
