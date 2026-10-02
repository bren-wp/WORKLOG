import 'package:flutter/material.dart';

import 'app_state.dart';
import 'screens.dart';
import 'services/local_storage_service.dart';
import 'services/notification_service.dart';
import 'services/security_service.dart';
import 'worklog_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final state = AppState(storage: const LocalStorageService());
  await state.load();

  try {
    await WorklogNotificationService.instance.initialize();
  } catch (error) {
    debugPrint('WORKLOG obavijesti nisu inicijalizirane: $error');
  }

  runApp(WorklogApp(state: state));
}

class WorklogApp extends StatefulWidget {
  const WorklogApp({super.key, this.state, this.security});

  final AppState? state;
  final LocalSecurityService? security;

  @override
  State<WorklogApp> createState() => _WorklogAppState();
}

class _WorklogAppState extends State<WorklogApp>
    with WidgetsBindingObserver {
  late final AppState state = widget.state ?? AppState();
  late final LocalSecurityService security =
      widget.security ?? LocalSecurityService();

  bool locked = false;
  late bool wasLoggedIn = state.loggedIn;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    state.addListener(_refresh);

    if (state.loggedIn && state.preferences.biometricLockEnabled) {
      locked = true;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    state.removeListener(_refresh);
    state.dispose();
    super.dispose();
  }

  void _refresh() {
    final loggedInNow = state.loggedIn;
    final lockEnabled = state.preferences.biometricLockEnabled;
    final loginJustCompleted = loggedInNow && !wasLoggedIn;

    wasLoggedIn = loggedInNow;

    if (!loggedInNow || !lockEnabled) {
      locked = false;
    } else if (loginJustCompleted) {
      locked = true;
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    if (lifecycleState != AppLifecycleState.paused) return;
    if (!state.loggedIn || !state.preferences.biometricLockEnabled) return;
    if (locked || !mounted) return;

    setState(() => locked = true);
  }

  void unlock() {
    if (!mounted) return;
    setState(() => locked = false);
  }

  @override
  Widget build(BuildContext context) {
    Widget home;

    if (!state.onboardingComplete) {
      home = OnboardingScreen(state: state);
    } else if (!state.loggedIn) {
      home = LoginScreen(state: state);
    } else if (!state.profileReady) {
      home = ProfileSetupScreen(state: state);
    } else if (state.preferences.biometricLockEnabled && locked) {
      home = AppLockScreen(
        security: security,
        onUnlocked: unlock,
      );
    } else {
      home = HomeShell(state: state);
    }

    return MaterialApp(
      title: 'WORKLOG',
      debugShowCheckedModeBanner: false,
      theme: buildWorklogTheme(),
      home: home,
    );
  }
}
