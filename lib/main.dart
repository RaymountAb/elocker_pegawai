import 'package:flutter/material.dart';
import 'login_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Locker Pegawai',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: 'Login',
      routes: {
        'Login': (context) => LoginPage(),
      },
    );
  }
}
