import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const KasirTokokuApp());
}

class KasirTokokuApp extends StatelessWidget {
  const KasirTokokuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Kasir Toko',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginScreen(),
    );
  }
}