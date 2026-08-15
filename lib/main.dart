import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'services/setup_storage.dart';
import 'screens/splash/splash_screen.dart';
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const RapidReachApp());
}

class RapidReachApp extends StatelessWidget {
  const RapidReachApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RAPID REACH',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AppStartupScreen(),
    );
  }
}

class AppStartupScreen extends StatefulWidget {
  const AppStartupScreen({super.key});

  @override
  State<AppStartupScreen> createState() => _AppStartupScreenState();
}

class _AppStartupScreenState extends State<AppStartupScreen> {
  bool _loading = true;
  bool _setupCompleted = false;

  @override
  void initState() {
    super.initState();
    _checkSetup();
  }

  Future<void> _checkSetup() async {
    final completed = await SetupStorage.isSetupCompleted();

    if (!mounted) return;

    setState(() {
      _setupCompleted = completed;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return SplashScreen(
      goToDashboard: _setupCompleted,
    );
  }
}