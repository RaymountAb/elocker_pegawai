import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';

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
                  size: 200,
                  gapless: true,
                ),
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () {
                    print('Button ditekan ...');
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
}
