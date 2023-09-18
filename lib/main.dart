import 'package:flutter/material.dart';
import 'login_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Locker Pegawai', // Ganti dengan nama aplikasi Anda
      theme: ThemeData(
        primarySwatch: Colors.blue, // Ganti dengan warna tema Anda
      ),
      home: LoginPage(),
    );
  }
}
