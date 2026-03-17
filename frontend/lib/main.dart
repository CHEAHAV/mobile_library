import 'package:flutter/material.dart';
import 'package:frontend/authentication/login.dart';
import 'package:frontend/authentication/register.dart';
import 'package:frontend/screens/onboard.dart';
import 'package:frontend/services/api_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // ✅ AuthGate handles login ↔ register navigation
      home: const OnBoard(),
      routes: {
        '/login':    (context) => const AuthGate(),
        '/register': (context) => const AuthGate(startOnRegister: true),
      },
    );
  }
}

// ── AuthGate — owns login ↔ register toggle ───────────────────────────────────
class AuthGate extends StatefulWidget {
  final bool startOnRegister;
  const AuthGate({super.key, this.startOnRegister = false});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late bool _showLogin;

  @override
  void initState() {
    super.initState();
    _showLogin = !widget.startOnRegister;
  }

  void _goToRegister() => setState(() => _showLogin = false);
  void _goToLogin()    => setState(() => _showLogin = true);

  @override
  Widget build(BuildContext context) {
    // ✅ onTap is ALWAYS passed — never null
    return _showLogin
        ? LoginPage(onTap: _goToRegister)
        : RegisterPage(onTap: _goToLogin);
  }
}