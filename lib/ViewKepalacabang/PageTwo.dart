import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:connectivity/connectivity.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:rich_alert/rich_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:http_parser/http_parser.dart';
import 'homepage.dart';

class PageTwoKepalacabang extends StatefulWidget {
  final VoidCallback keluar;
  PageTwoKepalacabang(this.keluar);

  @override
  _PageTwoKepalacabangState createState() => _PageTwoKepalacabangState();
}

enum SingingCharacter { lafayette, jefferson }

class _PageTwoKepalacabangState extends State<PageTwoKepalacabang> {
  String pemilik, nopol, alamat, notelpon, kondisi;
  TextEditingController controller = new TextEditingController();
  final format = DateFormat("yyyy-MM-dd");
  bool loading = false;
  final key = GlobalKey<FormState>();

  Connectivity connectivity = Connectivity();
  String status;
  String id, nama, ttd;

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
                                HomePageKepalacabang(keluar)),
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

  final AsyncMemoizer _memoizer = AsyncMemoizer();

  Future getPref() => _memoizer.runOnce(() async {
        SharedPreferences preferences = await SharedPreferences.getInstance();
        id = preferences.getString("id");
        nama = preferences.getString("nama");
        ttd = preferences.getString("ttd");
      });

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

  // Get json result and convert it to model. Then add
  Future<Null> getUserDetails() async {
    _userDetails.clear();
    final response = await http.get(url);
    final responseJson = json.decode(response.body);

    setState(() {
      for (Map user in responseJson) {
        _userDetails.add(UserDetails.fromJson(user));
      }
    });
  }

  bayar(var data) {
    DateFormat dateFormat = DateFormat("yyyy-MM-dd");
    DateTime dateTime = dateFormat.parse("$data");
    return dateTime;
  }

  var outstanding;

  dataoutstanding(String tarifs, var masaakhir) async{
    DateFormat dateFormat = DateFormat("yyyy-MM-dd");
    var jamsekarang = DateTime.now();
    DateTime dateTime = dateFormat.parse("$masaakhir");

    String date = DateFormat('yyy').format(jamsekarang);
    String dateTime1 = DateFormat('yyy').format(dateTime);
    var date1 = int.parse(date);
    var dateTime2 = int.parse(dateTime1);

    String date2 = DateFormat('MM').format(jamsekarang);
    String dateTime3 = DateFormat('MM').format(dateTime);
    var date3 = int.parse(date2);
    var dateTime4 = int.parse(dateTime3);

    var numBulan = 1 + (date1 - dateTime2)*12;
    // menghitung selisih bulan
    numBulan += date3 - dateTime4;
    var tarif = int.parse(tarifs);
    var data =  tarif * numBulan;
    final formatter = NumberFormat("#,###");
    outstanding = formatter.format(data);
  }

  @override
  void initState() {
    super.initState();
    checkConnectivity1();
    getUserDetails();
    getPref();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue[400],
      padding: EdgeInsets.only(top: 15),
      child: new Scaffold(
        appBar: new AppBar(
          title: new Text('Cari Data'),
          backgroundColor: Colors.blue[400],
          elevation: 0.0,
        ),
        body: new Column(
          children: <Widget>[
            new Container(
              color: Colors.blue[400],
              child: new Padding(
                padding: const EdgeInsets.all(8.0),
                child: new Card(
                  child: new ListTile(
                    leading: new Icon(Icons.search),
                    title: new TextField(
                      controller: controller,
                      decoration: new InputDecoration(
                          hintText: 'Search', border: InputBorder.none),
                      onChanged: onSearchTextChanged,
                    ),
                    trailing: new IconButton(
                      icon: new Icon(Icons.cancel),
                      onPressed: () {
                        controller.clear();
                        onSearchTextChanged('');
                      },
                    ),
                  ),
                ),
              ),
            ),
            new Expanded(
              child: _searchResult.length != 0 || controller.text.isNotEmpty
                  ? new ListView.builder(
                      itemCount: _searchResult.length,
                      itemBuilder: (context, i) {
                        dataoutstanding(_searchResult[i].tarif, _searchResult[i].masaakhir);
                        return Card(
                            elevation: 1.5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Container(
                                width: MediaQuery.of(context).size.width,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10.0, vertical: 10.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        SizedBox(width: 5),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(_searchResult[i].nopol,
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Text(
                                                "Nama : " +
                                                    _searchResult[i].pemilik,
                                                style: TextStyle(
                                                    color: Colors.grey)),
                                            Text(
                                                "Status : " +
                                                    _searchResult[i].status,
                                                style: TextStyle(
                                                    color: Colors.grey)),
                                            Text(
                                                "Outstanding : " +
                                                    "Rp." + outstanding.toString(),
                                                style: TextStyle(
                                                    color: Colors.grey))
                                          ],
                                        )
                                      ],
                                    ),
                                  ],
                                )),
                          );
                      },
                    )
                  : new ListView.builder(
                      itemCount: _userDetails.length,
                      itemBuilder: (context, index) {
                        dataoutstanding(_userDetails[index].tarif, _userDetails[index].masaakhir);
                        return Card(
                            elevation: 1.5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Container(
                                width: MediaQuery.of(context).size.width,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10.0, vertical: 10.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        SizedBox(width: 5),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(_userDetails[index].nopol,
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Text(
                                                "Nama : " +
                                                    _userDetails[index].pemilik,
                                                style: TextStyle(
                                                    color: Colors.grey)),
                                            Text(
                                                "Status : " +
                                                    _userDetails[index].status,
                                                style: TextStyle(
                                                    color: Colors.grey)),
                                            Text(
                                                "Outstanding : " +
                                                    "Rp." + outstanding.toString(),
                                                style: TextStyle(
                                                    color: Colors.grey))
                                          ],
                                        )
                                      ],
                                    ),
                                  ],
                                )),
                          );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  onSearchTextChanged(String text) async {
    _searchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    _userDetails.forEach((userDetail) {
      if (userDetail.nopol.contains(text) ||
          userDetail.pemilik.contains(text) ||
          userDetail.status.contains(text) ||
          userDetail.tarif.contains(text) ||
          userDetail.tanggalpelaksanaan.contains(text) || userDetail.regional.contains(text))
        _searchResult.add(userDetail);
    });

    setState(() {});
  }
}

List<UserDetails> _searchResult = [];

List<UserDetails> _userDetails = [];

final String url = 'http://dtd.jasaraharjariau.com/api/data';

class UserDetails {
  final String id,
      nopol,
      pemilik,
      alamat,
      notelpon,
      kondisi,
      status,
      masaawal,
      masaakhir,
      tarif,
      regional,
      janjibayar,
      ttd,
      tanggalpelaksanaan;

  UserDetails(
      {this.id,
      this.nopol,
      this.pemilik,
      this.alamat,
      this.kondisi,
      this.status,
      this.masaawal,
      this.masaakhir,
      this.tarif,
      this.notelpon,
      this.regional,
      this.janjibayar,
      this.ttd,
      this.tanggalpelaksanaan});

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return new UserDetails(
        id: json['id'],
        nopol: json['nopol'],
        pemilik: json['pemilik'],
        alamat: json['alamat'],
        notelpon: json['no_telpon'],
        kondisi: json['kondisi'],
        status: json['status'],
        masaawal: json['masa_awal'],
        masaakhir: json['masa_akhir'],
        tarif: json['tarif'],
        regional: json['regional'],
        janjibayar: json['janji_bayar'],
        ttd: json['ttd'],
        tanggalpelaksanaan: json['tanggal_pelaksanaan']);
  }
}
