import 'package:flutter/material.dart';
import '../app_state.dart';
import '../brand.dart';
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
    ("Organiziraj posao na terenu.", "Sve što ti treba za poslove, klijente, materijal i dokaze rada — na jednom mjestu.", Icons.home_repair_service_rounded),
    ("Poslovi i raspored", "Pregledaj dnevni raspored, upravljaj poslovima i prati promjene bez kaosa.", Icons.calendar_month_rounded),
    ("Fotografije i dokaz rada", "Dokumentiraj radove prije i poslije, spremi potpis i pripremi profesionalni zapisnik.", Icons.photo_camera_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(onPressed: widget.state.finishOnboarding, child: const Text("Preskoči")),
            ),
            Expanded(
              child: PageView.builder(
                controller: controller,
                itemCount: slides.length,
                onPageChanged: (value) => setState(() => page = value),
                itemBuilder: (context, index) {
                  final slide = slides[index];
                  return Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const WorklogMark(size: 108),
                        const SizedBox(height: 24),
                        const WorklogWordmark(),
                        const SizedBox(height: 38),
                        Container(
                          width: 92,
                          height: 92,
                          decoration: BoxDecoration(
                            color: WorklogColors.surface2,
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(color: WorklogColors.border),
                          ),
                          child: Icon(slide.$3, color: WorklogColors.primary, size: 44),
                        ),
                        const SizedBox(height: 28),
                        Text(slide.$1, textAlign: TextAlign.center, style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 14),
                        Text(slide.$2, textAlign: TextAlign.center, style: const TextStyle(fontSize: 17, height: 1.45, color: WorklogColors.muted)),
                      ],
                    ),
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
                    color: page == index ? WorklogColors.primary : WorklogColors.border,
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
                      controller.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
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
  bool hidden = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(28),
          children: [
            const SizedBox(height: 36),
            const Center(child: WorklogWordmark()),
            const SizedBox(height: 52),
            const Text("Prijava", style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            const Text("Prijavi se u svoj WORKLOG račun i nastavi raditi.", style: TextStyle(color: WorklogColors.muted, fontSize: 16)),
            const SizedBox(height: 28),
            const TextField(
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: "E-pošta", prefixIcon: Icon(Icons.mail_outline_rounded)),
            ),
            const SizedBox(height: 14),
            TextField(
              obscureText: hidden,
              decoration: InputDecoration(
                labelText: "Lozinka",
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  onPressed: () => setState(() => hidden = !hidden),
                  icon: Icon(hidden ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Checkbox(value: true, onChanged: (_) {}),
                const Text("Zapamti me"),
                const Spacer(),
                TextButton(onPressed: () {}, child: const Text("Zaboravljena lozinka?")),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(height: 54, child: FilledButton(onPressed: widget.state.login, child: const Text("Prijavi se"))),
            const SizedBox(height: 18),
            const Row(
              children: [
                Expanded(child: Divider()),
                Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text("ili se prijavi putem", style: TextStyle(color: WorklogColors.muted))),
                Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.g_mobiledata_rounded), label: const Text("Nastavi s Googleom")),
            const SizedBox(height: 10),
            OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.apple), label: const Text("Nastavi s Appleom")),
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
  String activity = "Instalacije i klimatizacija";
  String employees = "1 – 5";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profil tvrtke")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text("Unesi osnovne podatke za početak korištenja.", style: TextStyle(color: WorklogColors.muted)),
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
                children: [Icon(Icons.add_a_photo_outlined, color: WorklogColors.primary), SizedBox(height: 6), Text("Dodaj logo", style: TextStyle(fontSize: 12))],
              ),
            ),
          ),
          const SizedBox(height: 26),
          const TextField(decoration: InputDecoration(labelText: "Naziv obrta / tvrtke")),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: activity,
            items: const [
              DropdownMenuItem(value: "Instalacije i klimatizacija", child: Text("Instalacije i klimatizacija")),
              DropdownMenuItem(value: "Elektroinstalacije", child: Text("Elektroinstalacije")),
              DropdownMenuItem(value: "Vodoinstalacije", child: Text("Vodoinstalacije")),
              DropdownMenuItem(value: "Građevinski radovi", child: Text("Građevinski radovi")),
            ],
            onChanged: (value) => setState(() => activity = value ?? activity),
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
            onChanged: (value) => setState(() => employees = value ?? employees),
            decoration: const InputDecoration(labelText: "Broj zaposlenih"),
          ),
          const SizedBox(height: 14),
          const TextField(keyboardType: TextInputType.phone, decoration: InputDecoration(labelText: "Broj telefona", prefixIcon: Icon(Icons.phone_outlined))),
          const SizedBox(height: 28),
          SizedBox(height: 54, child: FilledButton(onPressed: widget.state.setupProfile, child: const Text("Završi postavljanje"))),
        ],
      ),
    );
  }
}
