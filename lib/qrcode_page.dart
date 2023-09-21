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
      child: Column(
        children: [
          QrImageView(
            data: qrcodeValue,
            version: QrVersions.auto,
            size: 350,
            gapless: true,
          ),
          SizedBox(height: 20), // Add some spacing below the QR code
        ],
      ),
    );
  }

  Widget buildDeleteAccessButton(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          deleteAccess(context);
        },
        style: ElevatedButton.styleFrom(
          primary: Color(0xFFFF000E), // Warna latar belakang
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.symmetric(
              vertical: 15, horizontal: 40), // Sesuaikan ukuran tombol
        ),
        child: Text(
          'Hapus Akses',
          style: TextStyle(
            fontFamily: 'Readex Pro',
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Future<void> deleteAccess(BuildContext context) async {
    try {
      final id = widget.qrCodeData['qrcode'][0]['pegawai'];
      final response = await http.get(
        Uri.parse(
            'http://10.78.2.251/admin-elocker/public/api/end-session/$id'),
      );

      final jsonResponse = json.decode(response.body);
      String status = jsonResponse['status'];
      String message = jsonResponse['message'];

      if (response.statusCode == 200) {
        if (status == 'success') {
          showSnackBar(context, 'Berhasil Menghapus Akses: $message');
        } else {
          showSnackBar(context, 'Gagal Menghapus Akses: $message');
        }
      } else {
        showSnackBar(
          context,
          'Gagal Menghapus Akses',
        );
      }
    } catch (e) {
      print('Error: $e');
      showSnackBar(
        context,
        'Gagal Menghapus Akses',
      );
    }
  }

  void showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message.isNotEmpty ? message : 'Tidak ada pesan'),
      action: SnackBarAction(
        label: 'OK',
        onPressed: () {},
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
