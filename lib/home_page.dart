import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatelessWidget {
  final String token;
  final String userName;
  final int userId;

  HomePage(this.token, this.userName, this.userId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppBar(
              backgroundColor: Colors.blue,
              automaticallyImplyLeading: false,
              title: Text(
                'Welcome, ${userName}',
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
                            'http://10.78.5.169/admin-elocker/public/api/v1/logout'
                                as Uri);
                        if (response.statusCode == 200) {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.remove('token');
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
                Container(
                  width: double.infinity,
                  height: 130,
                  color: Colors.blueGrey, // Ganti dengan warna yang sesuai
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tambah Loker',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Loker 1',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Tanggal: 01/01/2022',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Jam: 19.00',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 130,
                  color: Colors.blueGrey, // Ganti dengan warna yang sesuai
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Titip Barang',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Loker 1',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Tanggal: 01/01/2022',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Jam: 20.00',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
