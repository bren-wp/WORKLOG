import 'package:flutter/material.dart';

import '../brand.dart';
import '../services/security_service.dart';
import '../worklog_theme.dart';

class AppLockScreen extends StatefulWidget {
  const AppLockScreen({
    super.key,
    required this.security,
    required this.onUnlocked,
  });

  final LocalSecurityService security;
  final VoidCallback onUnlocked;

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> {
  bool authenticating = false;
  String? message;
  bool autoAttempted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (autoAttempted) return;
    autoAttempted = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        authenticate();
      }
    });
  }

  Future<void> authenticate() async {
    if (authenticating) return;
    setState(() {
      authenticating = true;
      message = null;
    });

    final result = await widget.security.authenticate();
    if (!mounted) return;

    setState(() {
      authenticating = false;
      message = result.message;
    });

    if (result.success) {
      widget.onUnlocked();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(28),
            children: [
              const Center(child: WorklogWordmark()),
              const SizedBox(height: 40),
              Center(
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: WorklogColors.surface,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: WorklogColors.border),
                  ),
                  child: const Icon(
                    Icons.lock_rounded,
                    size: 52,
                    color: WorklogColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'WORKLOG je zaključan',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Potvrdi identitet biometrijom ili sigurnosnom šifrom uređaja za pristup poslovnim podacima.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: WorklogColors.muted,
                  height: 1.45,
                ),
              ),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: WorklogColors.warning),
                ),
              ],
              const SizedBox(height: 26),
              SizedBox(
                height: 54,
                child: FilledButton.icon(
                  onPressed: authenticating ? null : authenticate,
                  icon: authenticating
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.fingerprint_rounded),
                  label: Text(
                    authenticating ? 'Provjera...' : 'Otključaj WORKLOG',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
