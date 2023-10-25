import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';
import 'package:elocker_pegawai/profile_page.dart';

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
  bool shouldRefresh = false;
  Color primaryColor = Color(0xFF105DFB);
  Color bgColor = Color(0xFF73CEFF);

  TextStyle titleTextStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  TextStyle subTitleTextStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: Color(0xFF14181B),
  );

  TextStyle buttonTextStyle = TextStyle(
    fontWeight: FontWeight.w500,
  );

  Icon personIcon = Icon(
    Icons.person,
    color: Color(0xFF105DFB),
    size: 24,
  );

  Image statusImage = Image.asset(
    'assets/images/Safe.png',
    width: 130,
    height: 130,
    fit: BoxFit.contain,
  );

  Image kosongImage = Image.asset(
    'assets/images/Search Product.png',
    width: 130,
    height: 130,
    fit: BoxFit.contain,
  );

  @override
  void initState() {
    super.initState();
    fetchData(widget.userId);
  }

  Future<void> _refreshPage() async {
    await fetchData(widget.userId);
    setState(() {});
    _showSnackBar('Halaman Diperbarui');
  }

  void _showResponseDialog(
      BuildContext context, String title, Map<String, dynamic> jsonResponse) {
    showDialog(
      context: context,
      builder: (context) {
        if (jsonResponse['status'] == 'success') {
          return AlertDialog(
            title: Text(title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 400, // Atur lebar sesuai kebutuhan
                  height: 400, // Atur tinggi sesuai kebutuhan
                  child: QrImageView(
                    data: jsonResponse['qrcode'], // String QR Code
                    version:
                        QrVersions.auto, // Versi QR Code (bisa disesuaikan)
                    size: 400, // Ukuran gambar QR Code
                  ),
                ),
                SizedBox(height: 5),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    final qrcode = jsonResponse['qrcode'];
                    final response = await http.get(Uri.parse(
                        'https://admin-elocker.adevelop.my.id/api/checkakses/$qrcode'));

                    if (response.statusCode == 200) {
                      final data = json.decode(response.body);
                      String status = data['status'];
                      String message = data['message'];
                      if (status == 'success') {
                        _showSnackBar('$message');
                        // Setelah aksi berhasil, atur shouldRefresh menjadi true
                        setState(() {
                          shouldRefresh = true;
                        });
                      } else {
                        _showSnackBar('$message');
                        setState(() {
                          shouldRefresh = true;
                        });
                      }
                    } else {
                      _showSnackBar('Silahkan ulangi qrcode');
                      setState(() {
                        shouldRefresh = true;
                      });
                    }
                  },
                  child: Text('Tutup'),
                ),
              ],
            ),
          );
        } else {
          // Jika status failed, tampilkan pesan
          return AlertDialog(
            title: Text(title),
            content: Text(jsonResponse['message']),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Tutup'),
              ),
            ],
          );
        }
      },
    );
  }

  void _showSnackBar(String message) {
    final snackBar = SnackBar(
      content: Text(message.isNotEmpty ? message : 'Tidak ada pesan'),
      action: SnackBarAction(
        label: 'OK',
        onPressed: () {},
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> fetchData(int userId) async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://admin-elocker.adevelop.my.id/api/pegawai/home/$userId'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          userData = data;
        });
      } else {
        print('Error: ${response.statusCode}');
        print('Response Body: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarBrightness: Theme.of(context).brightness,
          systemStatusBarContrastEnforced: true,
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        // Handle onTap
      },
      child: Scaffold(
        backgroundColor: Color(0xFFF8F8F8),
        body: SafeArea(
          top: true,
          child: RefreshIndicator(
            onRefresh: _refreshPage,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 4,
                        color: Color(0x33000000),
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      _buildHeader(),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Card(
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          color: bgColor,
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    top: 10), // Menambahkan jarak atas
                                child: Text(
                                  'Status Loker',
                                  style: titleTextStyle,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    top: 10), // Menambahkan jarak atas
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: (userData['locker'] != null)
                                      ? statusImage
                                      : kosongImage,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical:
                                        10), // Menambahkan jarak atas dan bawah
                                child: Text(
                                  (userData['locker'] != null)
                                      ? '${userData['locker']['name_loker']}'
                                      : 'Belum ada akses loker',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              if (userData['history'] != null)
                                _buildHistoryRow(),
                              if (userData['history'] == null)
                                _buildEmptyHistoryRow(),
                            ],
                          ),
                        ),
                      ),
                      _buildButtonRow(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Metode-metode baru
  Widget _buildHeader() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 32),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildPersonIcon(),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: 4),
                        child: Text(
                          'Hello,',
                          style: TextStyle(
                            fontSize: 24,
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '${userData['userName'] ?? widget.userName}',
                        style: subTitleTextStyle.copyWith(
                          color: Colors.grey[700],
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _buildLogoutButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPersonIcon() {
    return InkWell(
      onTap: () async {
        final userId = widget.userId;
        final url = Uri.parse(
            'https://admin-elocker.adevelop.my.id/api/pegawai/profile/$userId');

        final headers = {
          'Authorization': 'Bearer ${widget.token}',
        };

        final response = await http.get(url, headers: headers);

        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          // Pindah ke halaman profil dengan data yang diperlukan
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfilePage(data,
                  widget.token), // Anda dapat menggunakan widget.token langsung
            ),
          );
        } else {
          print('Gagal mengambil data QR Code: ${response.statusCode}');
        }
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Color(0x0057636C),
          shape: BoxShape.circle,
          border: Border.all(
            color: primaryColor,
            width: 2,
          ),
        ),
        child: personIcon,
      ),
    );
  }

  Widget _buildLogoutButton() {
    return IconButton(
      icon: Icon(
        Icons.logout,
        color: Color(0xFFFF0000),
        size: 30,
      ),
      onPressed: () async {
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
                    Navigator.of(context).pop(false);
                  },
                ),
                TextButton(
                  child: Text('Ya, Keluar'),
                  onPressed: () async {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          },
        );
        if (confirmLogout == true) {
          _performLogout();
        }
      },
    );
  }

  void _performLogout() async {
    try {
      final response = await http.post(
        Uri.parse('https://admin-elocker.adevelop.my.id/api/logout'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );
      if (response.statusCode == 200) {
        Navigator.pushNamed(context, 'Login');
      } else {
        print('Logout Gagal: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Widget _buildHistoryRow() {
    if (userData['locker'] != null && userData['history'] != null) {
      return Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: Text('${userData['history']['date']}'),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              '${userData['history']['time']}',
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    } else {
      return SizedBox
          .shrink(); // Widget akan tetap ada, tapi tidak terlihat jika data tidak tersedia
    }
  }

  Widget _buildEmptyHistoryRow() {
    if (userData['locker'] == null || userData['history'] == null) {
      return Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Visibility(
            visible: false,
            child: Container(
              height: 20,
            ),
          ),
          Visibility(
            visible: false,
            child: Container(
              height: 20,
            ),
          ),
        ],
      );
    } else {
      return SizedBox
          .shrink(); // Widget akan tetap ada, tapi tidak terlihat jika data tersedia
    }
  }

  Widget _buildButtonRow() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildCardIcon(Icons.history, 'History'),
        _buildCardIcon(Icons.qr_code, 'Scan QR Code'),
        _buildCardIcon(Icons.work_off_outlined, 'Akhiri Akses'),
      ],
    );
  }

  Widget _buildCardIcon(IconData icon, String label) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: SizedBox(
        height: 100,
        width: 100,
        child: Card(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: EdgeInsets.all(5),
                child: Icon(
                  icon,
                  color: primaryColor,
                  size: 50,
                ),
              ),
              Text(
                label,
                style: buttonTextStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
