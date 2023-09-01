import 'package:flutter/material.dart';
import 'login_page.dart';
import 'profile_page.dart';
import 'home_page.dart';
import 'qrcode_page.dart';

void main() {
  runApp(MaterialApp(
    initialRoute: '/Login',
    routes: {
      'Login': (context) => LoginPage(),
      'Home': (context) => HomePage('Nama Pengguna', {'data': 'pengguna'}),
      'QRCode': (context) => QRCodePage(),
      'Profile': (context) => ProfilePage(),
    },
  ));
}
