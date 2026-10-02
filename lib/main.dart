import 'package:flutter/material.dart';
import 'app_state.dart';
import 'screens.dart';
import 'worklog_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WorklogApp());
}

class WorklogApp extends StatefulWidget {
  const WorklogApp({super.key});

  @override
  State<WorklogApp> createState() => _WorklogAppState();
}

class _WorklogAppState extends State<WorklogApp> {
  final AppState state = AppState();

  @override
  void initState() {
    super.initState();
    state.addListener(_refresh);
  }

  @override
  void dispose() {
    state.removeListener(_refresh);
    state.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "WORKLOG",
      debugShowCheckedModeBanner: false,
      theme: buildWorklogTheme(),
      home: !state.onboardingComplete
          ? OnboardingScreen(state: state)
          : !state.loggedIn
              ? LoginScreen(state: state)
              : !state.profileReady
                  ? ProfileSetupScreen(state: state)
                  : HomeShell(state: state),
    );
  }
}
