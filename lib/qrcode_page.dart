import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class QRCodePage extends StatelessWidget {
  final Map<String, dynamic> data;

  QRCodePage(this.data);

  @override
  Widget build(BuildContext context) {
    String qrCodeData = jsonEncode(data['qrcode']['qrcode']);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          top: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 24, 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.black,
                        size: 30,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
              Container(
                alignment: Alignment.center,
                child: QrImageView(
                  data: qrCodeData,
                  version: QrVersions.auto,
                  size: 400,
                  gapless: true,
                ),
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      final userId = data['qrcode']['pegawai'];
                      final response = await http.get(
                        Uri.parse(
                            'http://10.78.5.169/admin-elocker/public/api/end-session/$userId'),
                      );

                      if (response.statusCode == 200) {
                        // Berhasil menghapus akses, menampilkan respons JSON jika ada.
                        final jsonResponse = json.decode(response.body);
                        _showResponseDialog(
                            context, 'Berhasil Menghapus Akses', jsonResponse);
                      } else {
                        // Gagal menghapus akses, menampilkan pesan respons JSON jika ada.
                        final jsonResponse = json.decode(response.body);
                        _showResponseDialog(
                            context, 'Gagal Menghapus Akses', jsonResponse);
                      }
                    } catch (e) {
                      // Terjadi kesalahan saat melakukan permintaan HTTP.
                      print('Error: $e');
                      _showResponseDialog(context, 'Error', {
                        'message': 'Terjadi kesalahan saat menghapus akses.'
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFF000E),
                    padding: EdgeInsets.all(0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Container(
                      width: 200, // Sesuaikan lebar sesuai kebutuhan
                      height: 55,
                      alignment: Alignment.center,
                      child: Text(
                        'Hapus Akses',
                        style: TextStyle(
                          fontFamily: 'Readex Pro',
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showResponseDialog(
      BuildContext context, String title, Map<String, dynamic> jsonResponse) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(
              jsonResponse['message']), // Menggunakan pesan dari JSON response
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
