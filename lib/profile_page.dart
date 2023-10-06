import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProfilePage extends StatelessWidget {
  final Map<String, dynamic> userData; // Data pengguna
  final String token;

  ProfilePage(this.userData, this.token);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
            size: 30,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [],
        centerTitle: false,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Text(
              '${userData['pegawai'][0]['nama']}',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${userData['pegawai'][0]['nip']}',
              style: TextStyle(
                fontFamily: 'Readex Pro',
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProfileDetailItem(
                      icon: Icons.people_outline_sharp,
                      label: 'Jenis Kelamin',
                      value: '${userData['pegawaidetail'][0]['jenis_kelamin']}',
                    ),
                    ProfileDetailItem(
                      icon: Icons.contact_phone_outlined,
                      label: 'Nomor Handphone',
                      value: '${userData['pegawaidetail'][0]['no_hp']}',
                    ),
                    ProfileDetailItem(
                      icon: Icons.place,
                      label: 'Alamat',
                      value: '${userData['pegawaidetail'][0]['alamat']}',
                    ),
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: () async {
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
                                  'http://10.78.7.61/admin-elocker/public/api/logout'), // Ganti URL_LOGOUT_API dengan URL yang sesuai
                              headers: {
                                'Authorization': 'Bearer $token',
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
                      child: Align(
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.login_rounded,
                          color: Color(0x81FF000E),
                          size: 40,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileDetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const ProfileDetailItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  // Buat metode untuk mengonversi nilai jenis kelamin
  String convertValue(String label, String value) {
    if (label == 'Jenis Kelamin') {
      if (value == "1") {
        return "Laki-laki";
      } else if (value == "0") {
        return "Perempuan";
      } else {
        return "Tidak Diketahui";
      }
    } else {
      return value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.grey,
            size: 24,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  // Gunakan metode convertValue untuk mengonversi nilai
                  convertValue(label, value),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
