import 'package:flutter/material.dart';
import 'package:sharent/splash.dart';
import 'package:sharent/Login_SignUp/login_page.dart';
import 'package:sharent/my_home_page.dart';

void main() {
  runApp(const MyApp());
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
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const Splash(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => const MyHomePage(),
      },
    );
  }
}
