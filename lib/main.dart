import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:projesof/screens/homepage_screen.dart';
import 'firebase_options.dart';
// import 'screens/name_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CircleUP',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.deepPurple),
      home: const HomepageScreen(),
    );
  }
}