import 'package:elocker_pegawai/Historypage.dart';
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
  Color primaryColor = Colors.blue;
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
    color: Colors.blue,
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
    setState(() {
      shouldRefresh = true;
    });
  }

  void _showResponseDialog(
      BuildContext context, String title, Map<String, dynamic> jsonResponse) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 400,
                height: 400,
                child: QrImageView(
                  data: jsonResponse['qrcode'],
                  version: QrVersions.auto,
                  size: 400,
                ),
              ),
              SizedBox(height: 5),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    shouldRefresh = true;
                  });
                },
                child: Text('Tutup'),
              ),
            ],
          ),
        );
      },
    );
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
    if (shouldRefresh) {
      fetchData(widget.userId);
      setState(() {
        shouldRefresh = false;
      });
    }
    return GestureDetector(
      onTap: () {},
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
                                padding: EdgeInsets.only(top: 10),
                                child: Text(
                                  'Status Loker',
                                  style: titleTextStyle,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 10),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: (userData['locker'] != null)
                                      ? statusImage
                                      : kosongImage,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal:
                                        20), // Sesuaikan jarak sesuai kebutuhan
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
                              if (userData['histories'] != null)
                                _buildHistoryRow(),
                              if (userData['histories'] == null)
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
                          fontSize: 15,
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfilePage(data, widget.token),
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
    if (userData['locker'] != null && userData['histories'] != null) {
      return Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: Text('${userData['histories'][0]['date']}'),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              'Jam : ${userData['histories'][0]['time']}',
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    } else {
      return SizedBox.shrink();
    }
  }

  Widget _buildEmptyHistoryRow() {
    if (userData['locker'] == null || userData['histories'] == null) {
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
      return SizedBox.shrink();
    }
  }

  Widget _buildButtonRow() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildCardWithAction(Icons.history, 'History', () async {
          try {
            final userId = widget.userId;
            final url = Uri.parse(
                'https://admin-elocker.adevelop.my.id/api/pegawai/history/$userId');

            final headers = {
              'Authorization': 'Bearer ${widget.token}',
            };

            final response = await http.get(url, headers: headers);

            if (response.statusCode == 200) {
              final data = json.decode(response.body);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HistoryPage(data),
                ),
              );
            } else {
              print('Gagal mengambil data History: ${response.statusCode}');
            }
          } catch (e) {
            print('Error: $e');
          }
        }),
        _buildCardWithAction(Icons.qr_code, 'Scan QR Code', () async {
          try {
            final userId = widget.userId;
            final response = await http.get(
              Uri.parse(
                  'https://admin-elocker.adevelop.my.id/api/addAkses/$userId'),
            );

            if (response.statusCode == 200) {
              final jsonResponse = json.decode(response.body);
              _showResponseDialog(
                context,
                'Scan QR Code Akses',
                jsonResponse,
              );
            } else {
              final jsonResponse = json.decode(response.body);
              _showResponseDialog(
                context,
                'Gagal Menambah Akses',
                jsonResponse,
              );
            }
          } catch (e) {
            print('Error: $e');
            _showResponseDialog(context, 'Error', {
              'message': 'Terjadi kesalahan saat menambah akses.',
            });
          }
        }),
        if (userData['locker'] != null)
          _buildCardWithAction(Icons.work_off_outlined, 'Akhiri Akses',
              () async {
            bool confirmEndAccess = await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Konfirmasi Akhiri Akses'),
                  content: Text('Anda yakin ingin mengakhiri akses?'),
                  actions: <Widget>[
                    TextButton(
                      child: Text('Batal'),
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                    ),
                    TextButton(
                      child: Text('Ya, Akhiri Akses'),
                      onPressed: () async {
                        Navigator.of(context).pop(true);
                        try {
                          final id = widget.userId;
                          final response = await http.get(
                            Uri.parse(
                                'https://admin-elocker.adevelop.my.id/api/end-session/$id'),
                          );

                          final jsonResponse = json.decode(response.body);
                          String status = jsonResponse['status'];
                          String message = jsonResponse['message'];

                          if (response.statusCode == 200) {
                            if (status == 'success') {
                              _showSuccessDialog(message);
                            } else {
                              _showErrorDialog(message);
                            }
                          } else {
                            _showErrorDialog('Gagal Menghapus Akses');
                          }
                        } catch (e) {
                          print('Error: $e');
                          _showErrorDialog('Gagal Menghapus Akses');
                        }
                      },
                    ),
                  ],
                );
              },
            );
            if (confirmEndAccess == true) {
              // Perform your action here when the user confirms the end of access
            }
          }),
      ],
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Berhasil Mengakhiri Akses'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('Tutup'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  shouldRefresh = true;
                });
              },
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('Tutup'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildCardWithAction(IconData icon, String label, VoidCallback onTap) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          height: 105,
          width: 105,
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
      ),
    );
  }
}
