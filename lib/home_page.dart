import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:qr_flutter/qr_flutter.dart';
import 'profile_page.dart';
import 'qrcode_page.dart';

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
  @override
  void initState() {
    super.initState();
    fetchData(widget.userId);
  }

  String getActivityDescription(int activityCode) {
    switch (activityCode) {
      case 1:
        return 'Tambah Akses';
      case 2:
        return 'Titip Barang';
      case 3:
        return 'Akhiri Akses';
      default:
        return 'Aktivitas Tidak Dikenal';
    }
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
          'https://admin-elocker.adevelop.my.id/api/pegawai/home/$userId',
        ),
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
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (shouldRefresh) {
      // Jika shouldRefresh adalah true, panggil fetchData untuk merefresh data
      fetchData(widget.userId);
      // Set shouldRefresh kembali menjadi false agar tidak terus merefresh
      setState(() {
        shouldRefresh = false;
      });
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await fetchData(widget.userId);
          },
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildAppBar(),
                buildQRCodeSection(),
                buildUserHistorySection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget untuk AppBar
  Widget buildAppBar() {
    return AppBar(
      backgroundColor: Colors.blue,
      automaticallyImplyLeading: false,
      title: GestureDetector(
        onTap: () async {
          final userId = widget.userId;
          final url = Uri.parse(
              'https://admin-elocker.adevelop.my.id/api/pegawai/profile/$userId');

          final headers = {
            'Authorization':
                'Bearer ${widget.token}', // Gantilah $yourToken dengan token yang valid
          };

          final response = await http.get(url, headers: headers);

          if (response.statusCode == 200) {
            final token = widget.token;
            final data = json.decode(response.body);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfilePage(data, token),
              ),
            );
          } else {
            // Tangani kesalahan jika permintaan ke server gagal
            print('Gagal mengambil data QR Code: ${response.statusCode}');
          }
        },
        child: Text(
          'Welcome, ${userData['userName'] ?? widget.userName}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
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
              try {
                final response = await http.post(
                  Uri.parse(
                      'https://admin-elocker.adevelop.my.id/api/logout'), // Ganti URL_LOGOUT_API dengan URL yang sesuai
                  headers: {
                    'Authorization': 'Bearer ${widget.token}',
                  },
                );
                if (response.statusCode == 200) {
                  // Logout berhasil, arahkan ke halaman login
                  Navigator.pushNamed(context, 'Login');
                } else {
                  // Logout gagal, cetak kode status
                  print('Logout Gagal: ${response.statusCode}');
                }
              } catch (e) {
                // Tangani kesalahan jaringan
                print('Error: $e');
              }
            }
          },
        )
      ],
      centerTitle: false,
      elevation: 0,
    );
  }

  // Widget untuk bagian QR Code
  Widget buildQRCodeSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        height: 225,
        decoration: BoxDecoration(
          color: Colors.blueGrey,
          borderRadius: BorderRadius.circular(15), // Tambah border radius
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () async {
                if (userData['locker'] != null) {
                  final userId = widget.userId;
                  final url = Uri.parse(
                      'https://admin-elocker.adevelop.my.id/api/pegawai/qrcode/$userId');

                  final headers = {
                    'Authorization':
                        'Bearer ${widget.token}', // Gantilah $yourToken dengan token yang valid
                  };

                  final response = await http.get(url, headers: headers);

                  if (response.statusCode == 200) {
                    final data = json.decode(response.body);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QRCodePage(data),
                      ),
                    );
                  } else {
                    // Tangani kesalahan jika permintaan ke server gagal
                    print(
                        'Gagal mengambil data QR Code: ${response.statusCode}');
                  }
                } else {
                  // Tampilkan dialog bahwa pengguna tidak memiliki akses loker
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Tidak Ada Akses Loker'),
                        content: Text('Silahkan Akses loker terlebih dahulu.'),
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Tutup'),
                          ),
                        ],
                      );
                    },
                  );
                }
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
              onTap: () async {
                if (userData['locker'] != null) {
                  final userId = widget.userId;
                  final url = Uri.parse(
                      'https://admin-elocker.adevelop.my.id/api/pegawai/qrcode/$userId');

                  final headers = {
                    'Authorization':
                        'Bearer ${widget.token}', // Gantilah $yourToken dengan token yang valid
                  };

                  final response = await http.get(url, headers: headers);

                  if (response.statusCode == 200) {
                    final data = json.decode(response.body);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QRCodePage(data),
                      ),
                    );
                  } else {
                    // Tangani kesalahan jika permintaan ke server gagal
                    print(
                        'Gagal mengambil data QR Code: ${response.statusCode}');
                  }
                } else {
                  // Tampilkan dialog bahwa pengguna tidak memiliki akses loker
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Tidak Ada Akses Loker'),
                        content: Text('Silahkan Akses loker terlebih dahulu'),
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Tutup'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: Text(
                'Scan QR Code',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk bagian User History
  Widget buildUserHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
        Center(
          // Tambahkan Center widget di sini
          child: userData['locker'] != null
              ? Container(
                  width: double.infinity,
                  height: 70,
                  color: Colors.blueGrey,
                  padding: EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          '${userData['locker']['name_loker']}',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : ElevatedButton(
                  onPressed: () async {
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
                          'Scan QR Code untuk Gunakan',
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
                  },
                  child: Text('Akses Loker'),
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
        if (userData['histories'] != null)
          Column(
            children: userData['histories']
                .map<Widget>((history) => buildHistoryItem(history))
                .toList(),
          ),
      ],
    );
  }

  Widget buildHistoryItem(Map<String, dynamic> history) {
    final activityDescription = getActivityDescription(history['activity']);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.blueGrey,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.center, // Mengubah alignment ke tengah
          children: [
            Text(
              activityDescription,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Loker ${history['loker']}',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            Text(
              'Tanggal: ${history['date']}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            Text(
              'Jam: ${history['time']}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
