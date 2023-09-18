import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class QRCodePage extends StatefulWidget {
  final Map<String, dynamic> qrCodeData;

  QRCodePage(this.qrCodeData);

  @override
  _QRCodePageState createState() => _QRCodePageState();
}

class _QRCodePageState extends State<QRCodePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildAppBar(context),
            buildQRCode(),
            buildDeleteAccessButton(context),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget buildAppBar(BuildContext context) {
    return Padding(
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
    );
  }

  Widget buildQRCode() {
    String qrcodeValue = widget.qrCodeData['qrcode'][0]['qrcode'];
    return Container(
      alignment: Alignment.center,
      child: QrImageView(
        data: qrcodeValue,
        version: QrVersions.auto,
        size: 350,
        gapless: true,
      ),
    );
  }

  Widget buildDeleteAccessButton(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: ElevatedButton(
        onPressed: () {
          deleteAccess(context);
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
            width: 200,
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
    );
  }

  Future<void> deleteAccess(BuildContext context) async {
    try {
      final int userId = widget.qrCodeData['qrcode'][0]['pegawai'];
      final response = await http.get(
        Uri.parse(
            'http://10.78.12.112/admin-elocker/public/api/end-session/$userId'), // Ganti URL_DELETE_ACCESS_API dengan URL yang sesuai
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        showResponseDialog(context, 'Berhasil Menghapus Akses', jsonResponse);
      } else {
        final jsonResponse = json.decode(response.body);
        showResponseDialog(context, 'Gagal Menghapus Akses', jsonResponse);
      }
    } catch (e) {
      print('Error: $e');
      showResponseDialog(context, 'Error',
          {'message': 'Terjadi kesalahan saat menghapus akses.'});
    }
  }

  void showResponseDialog(
      BuildContext context, String title, Map<String, dynamic> jsonResponse) {
    final message = jsonResponse['message'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content:
              Text(message != null ? message.toString() : 'Tidak ada pesan'),
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
