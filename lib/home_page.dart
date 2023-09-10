import 'package:flutter/material.dart';
//import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  final String token;
  final String userName;
  final int userId;

  HomePage(this.token, this.userName, this.userId);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic> userData = {};

  @override
  void initState() {
    super.initState();
    fetchData(widget.userId); // Memanggil fungsi fetchData saat widget dimuat
  }

  Future<void> fetchData(int userId) async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://10.78.5.169/admin-elocker/public/api/pegawai/home/$userId'),
        headers: {
          'Authorization':
              'Bearer ${widget.token}', // Menggunakan token dari properti widget
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          userData =
              data; // Mengisi userData dengan data yang diterima dari API
        });
        print('Data yang diterima: $data');
      } else {
        // Tangani kesalahan jika diperlukan
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      // Tangani kesalahan lain yang mungkin terjadi
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppBar(
                backgroundColor: Colors.blue,
                automaticallyImplyLeading: false,
                title: Text(
                  'Welcome, ${userData['userName'] ?? widget.userName}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      Icons.exit_to_app_rounded,
                      color: Colors.red,
                      size: 30,
                    ),
                    onPressed: () async {
                      // Tampilkan konfirmasi kepada pengguna
                      bool confirmLogout = await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Konfirmasi Logout'),
                            content: Text('Anda yakin ingin keluar?'),
                            actions: <Widget>[
                              TextButton(
                                child: Text('Batal'),
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(false); // Batalkan logout
                                },
                              ),
                              TextButton(
                                child: Text('Ya, Keluar'),
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(true); // Setujui logout
                                },
                              ),
                            ],
                          );
                        },
                      );
                      if (confirmLogout == true) {
                        try {
                          final response = await http.delete(
                              Uri.parse(
                                  'http://10.78.5.169/admin-elocker/public/api/v1/logout'),
                              headers: {
                                'Authorization':
                                    'Bearer ${widget.token}', // Menggunakan token dari properti widget
                              });
                          if (response.statusCode == 200) {
                            // Hapus token dari SharedPreferences
                            // Gantilah ini sesuai dengan cara Anda menyimpan token pada SharedPreferences
                            // final prefs = await SharedPreferences.getInstance();
                            // await prefs.remove('token');
                            Navigator.pushNamed(context, 'Login');
                          } else {
                            // Tangani kesalahan logout jika diperlukan
                            print('Logout Gagal: ${response.statusCode}');
                          }
                        } catch (e) {
                          // Tangani kesalahan lain yang mungkin terjadi
                          print('Error: $e');
                        }
                      }
                    },
                  )
                ],
                centerTitle: false,
                elevation: 0,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.infinity,
                  height: 225,
                  decoration: BoxDecoration(
                    color: Colors.blueGrey,
                    borderRadius:
                        BorderRadius.circular(15), // Tambah border radius
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, 'QRCode');
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Icon(
                              Icons.qr_code,
                              color: Colors.black,
                              size: 100,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, 'QRCode');
                        },
                        child: Text(
                          'Scan QR Code',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue, // Ganti warna teks
                            decoration:
                                TextDecoration.underline, // Tambah garis bawah
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Loker Akses',
                      style: TextStyle(
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: 70,
                    color: Colors.blueGrey, // Ganti dengan warna yang sesuai
                    padding: EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Loker 1',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'User History',
                      style: TextStyle(
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true, // Untuk menghindari kesalahan tata letak
                    itemCount: userData['histories'].length,
                    itemBuilder: (context, index) {
                      final history = userData['histories'][index];

                      return Container(
                        width: double.infinity,
                        height: 130,
                        color: Colors.blueGrey,
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 4),
                            Text(
                              'Loker ${history['loker']}',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Tanggal: ${history['date']}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Jam: ${history['time']}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
