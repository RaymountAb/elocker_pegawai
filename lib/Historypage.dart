import 'package:flutter/material.dart';

class HistoryPage extends StatefulWidget {
  final dynamic data;

  HistoryPage(this.data);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final Color backgroundColor = Color(0xFFF1F4F8);
  final Color appBarColor = Color(0xFFF1F4F8);
  final Color textColor = Color(0xFF14181B);
  final Color secondaryTextColor = Color(0xFF57636C);

  @override
  Widget build(BuildContext context) {
    List<dynamic> histories = widget.data['histories'];
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: textColor,
            size: 30,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Riwayat Penggunaan',
          style: TextStyle(
            fontFamily: 'Readex Pro',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        actions: [],
        centerTitle: false,
        elevation: 0,
      ),
      body: SafeArea(
        top: true,
        child: ListView.separated(
          itemCount: histories.length,
          separatorBuilder: (context, index) => Divider(),
          itemBuilder: (context, index) {
            dynamic history = histories[index];
            int activity =
                history['activity'] as int; // Cast 'activity' ke integer

            return Container(
              height: 89,
              color: Colors.white,
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Loker ${history['loker']}',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              color: textColor,
                              fontSize: 20,
                              fontWeight: FontWeight
                                  .bold, // Menambahkan font weight sebagai bold
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 5.0),
                            child: Text(
                              'Tanggal :${history['date']}',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Text(
                            'Waktu :${history['time']}',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              color: secondaryTextColor,
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            getIconForActivity(activity),
                            color: getColorForActivity(activity),
                          ),
                          SizedBox(height: 8),
                          Text(
                            getActivityText(activity),
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              color: secondaryTextColor,
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ],
                  )),
            );
          },
        ),
      ),
    );
  }

  String getActivityText(int activity) {
    switch (activity) {
      case 1:
        return "Tambah Akses";
      case 2:
        return "Titip Barang";
      case 3:
        return "Akhiri Akses";
      default:
        return "Teks Aktivitas Tidak Ditemukan";
    }
  }

  IconData getIconForActivity(int activity) {
    return activityIcons[activity] ?? Icons.info;
  }

  Color getColorForActivity(int activity) {
    return activityColors[activity] ?? Colors.black;
  }

  final Map<int, IconData> activityIcons = {
    1: Icons.work,
    2: Icons.work_history,
    3: Icons.work_off_outlined,
  };

  final Map<int, Color> activityColors = {
    1: Colors.green,
    2: Colors.yellow,
    3: Colors.red,
  };
}
