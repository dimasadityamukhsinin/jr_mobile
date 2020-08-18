import 'dart:async';
import 'dart:convert';

import 'package:async/async.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sparkline/flutter_sparkline.dart';
import 'package:jasaraharja/ViewStaff/Profil.dart';
import 'package:jasaraharja/ViewStaff/homepage.dart';
import 'package:rich_alert/rich_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jasaraharja/clipper.dart';
import 'package:http/http.dart' as http;

class PageOneStaff extends StatefulWidget {
  final VoidCallback keluar;
  PageOneStaff(this.keluar);

  @override
  _PageOneStaffState createState() => _PageOneStaffState();
}

class _PageOneStaffState extends State<PageOneStaff>
    with AutomaticKeepAliveClientMixin<PageOneStaff> {
  bool get wantKeepAlive => true;
  var data = [0.0, 5.0, 2.0, 4.0, 3.0, 8.0, 10.0];
  int _current = 0;

  String nama, ttd, id;
  int totaldata, belumdiproses, sudahdiproses,  selesai;
  var test;
  bool loading = false;

  final AsyncMemoizer _memoizer = AsyncMemoizer();

  Connectivity connectivity = Connectivity();
  String status;

  keluar() {
    setState(() {
      widget.keluar();
    });
  }

  void checkConnectivity1() async {
    var connectivityResult = await connectivity.checkConnectivity();
    var conn = getConnectionValue(connectivityResult);
    setState(() {
      status = 'Check Connection: ' + conn;
      if (status == "Check Connection: None") {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return RichAlertDialog(
                //uses the custom alert dialog
                alertTitle: richTitle("Gagal!"),
                alertSubtitle: richSubtitle("Jaringan Tidak Ditemukan!"),
                alertType: RichAlertType.WARNING,
                actions: <Widget>[
                  FlatButton(
                    child: Text("Reload"),
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                HomePageStaff(keluar)),
                        ModalRoute.withName('/'),
                      );
                    },
                  )
                ],
              );
            });
      }
    });
  }

// Method to convert the connectivity to a string value
  String getConnectionValue(var connectivityResult) {
    String status = '';
    switch (connectivityResult) {
      case ConnectivityResult.mobile:
        status = 'Mobile';
        break;
      case ConnectivityResult.wifi:
        status = 'Wi-Fi';
        break;
      case ConnectivityResult.none:
        status = 'None';
        break;
      default:
        status = 'None';
        break;
    }
    return status;
  }

  Future getPref() => _memoizer.runOnce(() async {
        SharedPreferences preferences = await SharedPreferences.getInstance();
        id = preferences.getString("id");
        nama = preferences.getString("nama");
        ttd = preferences.getString("ttd");
        final response =
            await http.get("http://dtd.jasaraharjariau.com/api/grafik");

        test = json.decode(response.body);
        totaldata = test['total_data'];
        belumdiproses = test['belum_diproses'];
        sudahdiproses = test['sudah_diproses'];
        selesai = test['selesai'];
      });

  @override
  void initState() {
    super.initState();
    checkConnectivity1();
    getPref();
  }

  Widget headerGreeting() {
    return Container(
      padding: EdgeInsets.fromLTRB(30, 30, 30, 20),
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Hi, $nama!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 8),
                ),
                Text(
                  "Selamat Datang!\nMari lihat perkembangannya",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                ProfilStaff(keluar)),
                        ModalRoute.withName('/'),
                      );            },
            child: Container(
              child: CircleAvatar(
                child: Text('C'),
                backgroundImage: AssetImage('assets/img/logo.png'),
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
              ),
              width: 50.0,
              height: 50.0,
              padding: EdgeInsets.all(2.0), // borde width
              decoration: BoxDecoration(
                color: Color(0xFFFFFFFF), // border color
                shape: BoxShape.circle,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget progressBox(title, progress, iconName, boxColorStart, boxColorEnd) {
    return ClipPath(
      clipper: Clipper(),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(43.5),
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              boxColorStart,
              boxColorEnd,
            ],
          ),
        ),
        height: 200,
        width: 200,
        padding: EdgeInsets.fromLTRB(25, 23, 25, 23),
        child: Stack(
          children: <Widget>[
            Positioned(
              top: 45.0,
              left: 70.0,
              right: 0.0,
              child: Icon(
                iconName,
                size: 55,
                color: Color(0x77FFFFFF),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(color: Colors.white, fontSize: 23),
                ),
                Text(
                  progress.toString(),
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 55,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget summary() {
    return Container(
      width: double.infinity,
      height: 230,
      margin: EdgeInsets.only(top: 15),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          topLeft: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 0, 15),
            child: Text(
              "Data Kendaraan",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 20),
          ),
          Container(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Total data',
                        style: TextStyle(color: Colors.grey[800], fontSize: 16),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 10),
                      ),
                      Row(
                        // mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            totaldata.toString() == null
                                ? 0
                                : totaldata.toString(),
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  Container(
                    height: 45,
                    width: 150,
                    child: Sparkline(
                      data: data,
                      lineWidth: 5.0,
                      lineGradient: new LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [Color(0xFFE5788C), Color(0xFFFFC195)],
                      ),
                      pointsMode: PointsMode.last,
                      pointSize: 10.0,
                      pointColor: Colors.amber,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List headerList = [0, 1, 2];
    return FutureBuilder(
          future: getPref(),
          builder: (context, snapshot) {
            return Scaffold(
                body: snapshot.connectionState == ConnectionState.done
                    ? ListView(
                        children: <Widget>[
                          Container(
                            // padding: EdgeInsets.only(bottom: 30),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color(0xFF0374BB),
                                  Color(0xFF32A8B7),
                                  Colors.teal,
                                ],
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                headerGreeting(),
                                CarouselSlider(
                                    height: 200,
                                    onPageChanged: (index) {
                                      setState(() {
                                        _current = index;
                                      });
                                    },
                                    items: [
                                      progressBox(
                                        'Belum Diproses',
                                        belumdiproses == null ? 0 : belumdiproses,
                                        Icons.report_problem,
                                        Color(0xFFFC888F),
                                        Color(0xFFE059A3),
                                      ),
                                      progressBox(
                                        'On Progress',
                                        sudahdiproses == null ? 0 : sudahdiproses,
                                        Icons.settings,
                                        Color(0xFFFFA464),
                                        Color(0xFFFD7B5B),
                                      ),
                                      progressBox(
                                          'Data Selesai',
                                          selesai == null ? 0 : selesai,
                                          Icons.done_all,
                                          Color(0xFF3DC9D2),
                                          Color(0xFF1CB293))
                                    ]),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: headerList.map(
                                    (index) {
                                      return Container(
                                        width: 8.0,
                                        height: 8.0,
                                        margin: EdgeInsets.symmetric(
                                          vertical: 10.0,
                                          horizontal: 2.0,
                                        ),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: _current == index
                                              ? Color(0xFFCDEBEE)
                                              : Color(0xFF64C7C8),
                                        ),
                                      );
                                    },
                                  ).toList(),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 10),
                                ),
                                summary(),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Center(child: CircularProgressIndicator()));
          });
  }
}
