import 'package:flutter/material.dart';
import 'package:frontend/screens/discover_screen.dart';
import 'package:frontend/services/api_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // required before any async in main
  await ApiService.init();   // resolve URL once at startup
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DiscoverScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
