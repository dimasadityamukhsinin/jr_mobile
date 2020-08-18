import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:connectivity/connectivity.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoder/geocoder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:mime/mime.dart';
import 'package:rich_alert/rich_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:http_parser/http_parser.dart';
import 'package:jasaraharja/Tandatangan.dart';
import 'homepage.dart';
import 'package:flutter/services.dart';

class PageTwoStaff extends StatefulWidget {
  final VoidCallback keluar;
  PageTwoStaff(this.keluar);

  @override
  _PageTwoStaffState createState() => _PageTwoStaffState();
}

enum SingingCharacter { lafayette, jefferson }

class _PageTwoStaffState extends State<PageTwoStaff> {
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

  String _currentAddress;
  var currentLocation;

  getUserLocation() async {//call this async method from whereever you need

    LocationData myLocation;
    String error;
    Location location = new Location();
    try {
      myLocation = await location.getLocation();
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        error = 'please grant permission';
        print(error);
      }
      if (e.code == 'PERMISSION_DENIED_NEVER_ASK') {
        error = 'permission denied- please enable it from app settings';
        print(error);
      }
      myLocation = null;
    }
    currentLocation = myLocation;
    print(currentLocation);
    final coordinates = new Coordinates(
        myLocation.latitude, myLocation.longitude);
    var addresses = await Geocoder.local.findAddressesFromCoordinates(
        coordinates);
    var first = addresses.first;
    _currentAddress = "${first.locality}, ${first.adminArea},${first.subLocality}, ${first.subAdminArea},${first.addressLine}, ${first.featureName},${first.thoroughfare}, ${first.subThoroughfare}";
    print(' ${first.locality}, ${first.adminArea},${first.subLocality}, ${first.subAdminArea},${first.addressLine}, ${first.featureName},${first.thoroughfare}, ${first.subThoroughfare}');
    return first;
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

  cekttd() async {
    print(ttd);
    if (ttd == null) {
      setState(() {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return RichAlertDialog(
                //uses the custom alert dialog
                alertTitle: richTitle("Peringatan!"),
                alertSubtitle: richSubtitle(
                    "Tanda tangan tidak ditemukan,\n mohon segera dilengkapi!"),
                alertType: RichAlertType.WARNING,
                actions: <Widget>[
                  FlatButton(
                    child: Text("OK"),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )
                ],
              );
            });
      });
    }
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

  dataoutstanding(String tarifs, var masaakhir) async {
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

    var numBulan = 1 + (date1 - dateTime2) * 12;
    // menghitung selisih bulan
    numBulan += date3 - dateTime4;
    var tarif = int.parse(tarifs);
    var data = tarif * numBulan;
    final formatter = NumberFormat("#,###");
    outstanding = formatter.format(data);
  }

  @override
  void initState() {
    super.initState();
    checkConnectivity1();
    getUserLocation();
    getUserDetails();
    getPref();
    Future.delayed(Duration.zero, () {
      this.cekttd();
    });
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
                        dataoutstanding(
                            _searchResult[i].tarif, _searchResult[i].masaakhir);
                        return GestureDetector(
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (_) => EditData(
                                    _searchResult[i], keluar, _currentAddress));
                          },
                          child: Card(
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
                          ),
                        );
                      },
                    )
                  : new ListView.builder(
                      itemCount: _userDetails.length,
                      itemBuilder: (context, index) {
                        dataoutstanding(_userDetails[index].tarif,
                            _userDetails[index].masaakhir);
                        return GestureDetector(
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (_) => EditData(_userDetails[index],
                                    keluar, _currentAddress));
                          },
                          child: Card(
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
                          ),
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

class EditData extends StatefulWidget {
  final VoidCallback keluar;
  var dataalamat;
  var data;
  EditData(this.data, this.keluar, this.dataalamat);

  @override
  _EditDataState createState() => _EditDataState(this.data, this.dataalamat);
}

class _EditDataState extends State<EditData> {
  final key = GlobalKey<FormState>();
  String pemilik, nopol, alamat, notelpon, kondisi, tarif;
  var janjibayar, tanggalpelaksanaan, masaawal, masaakhir;
  final format = DateFormat("yyyy-MM-dd");
  String datakondisi;
  var data, dataalamat;
  bool loading = false;
  String pekanbaru = "pekanbaru";
  String dumai = "dumai";
  String siak = "siak";
  String rohul = "rohul";
  String rohil = "rohil";
  String pelalawan = "pelalawan";
  String kuansing = "kuansing";
  String kampar = "kampar";
  String inhu = "inhu";
  String inhil = "inhil";
  String bengkalis = "bengkalis";
  _EditDataState(this.data, this.dataalamat);

  Connectivity connectivity = Connectivity();
  String statuskonek;

  keluar() {
    setState(() {
      widget.keluar();
    });
  }

  void checkConnectivity1(var id, var dataregional, var ttd, var datakondisi) async {
    var connectivityResult = await connectivity.checkConnectivity();
    var conn = getConnectionValue(connectivityResult);
    setState(() {
      statuskonek = 'Check Connection: ' + conn;
      if (statuskonek == "Check Connection: None") {
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
                      Navigator.pop(context);
                    },
                  )
                ],
              );
            });
        loading = false;
      } else {
        updatedata(id, dataregional, ttd, datakondisi);
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

  updatedata(var id, var dataregional, var ttd, var datakondisi) async {
    if (janjibayar.toString() != null && datakondisi == "Beroperasi" ||
        datakondisi == "Rusak Selamanya" && tanggalpelaksanaan.toString() != null) {
      final response =
          await http.get("http://dtd.jasaraharjariau.com/api/gambar/$id");
      var tes = json.decode(response.body);
      var gambar = tes['gambar'];
      if (ttd == null && gambar.toString() == "[]") {
        if (_imageFile != null &&
            _imageFilegambar1 != null &&
            _imageFilegambar2 != null) {
          var status = "Sudah Diproses";
          responsegambar =
              await _uploadImage(_imageFile, id, status, dataregional, datakondisi);
          print(responsegambar);
          responsegambar1 = await _uploadImagegambar1(_imageFilegambar1, id);
          print(responsegambar1);
          responsegambar2 = await _uploadImagegambar2(_imageFilegambar2, id);
          print(responsegambar2);
          setState(() {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return RichAlertDialog(
                    //uses the custom alert dialog
                    alertTitle: richTitle("Sukses!"),
                    alertSubtitle: richSubtitle("Data berhasil di update!"),
                    alertType: RichAlertType.SUCCESS,
                    actions: <Widget>[
                      FlatButton(
                        child: Text("OK"),
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
            loading = false;
          });
        } else {
          setState(() {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return RichAlertDialog(
                    //uses the custom alert dialog
                    alertTitle: richTitle("Gagal!"),
                    alertSubtitle:
                        richSubtitle("Gambar Error Atau Tidak Diiisi!"),
                    alertType: RichAlertType.WARNING,
                    actions: <Widget>[
                      FlatButton(
                        child: Text("OK"),
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
            loading = false;
          });
        }
      } else {
        SharedPreferences preferences = await SharedPreferences.getInstance();
        String iduser = preferences.getString("id");
        var status = "Sudah Diproses";

        final response = await http
            .put('http://dtd.jasaraharjariau.com/api/data/$id', body: {
          "id_user": iduser,
          "nopol": nopol,
          "pemilik": pemilik,
          "alamat": alamat,
          "no_telpon": notelpon,
          "kondisi": datakondisi,
          "status": status,
          "regional": dataregional,
          "janji_bayar": janjibayar.toString(),
          "status": status,
          "masa_awal": masaawal.toString(),
          "masa_akhir": masaakhir.toString(),
          "tarif": tarif,
          "tanggal_pelaksanaan": tanggalpelaksanaan.toString(),
        });
        json.decode(response.body);
        setState(() {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return RichAlertDialog(
                  //uses the custom alert dialog
                  alertTitle: richTitle("Sukses!"),
                  alertSubtitle: richSubtitle("Data berhasil di update!"),
                  alertType: RichAlertType.SUCCESS,
                  actions: <Widget>[
                    FlatButton(
                      child: Text("OK"),
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
        });
      }
    }
    else if (datakondisi == "Beroperasi" ||
        datakondisi == "Rusak Selamanya" ||
        datakondisi == "Dijual" ||
        datakondisi == "Ganti Nopol" ||
        datakondisi == "Pindah PO" && tanggalpelaksanaan.toString() != null) {
      final response =
          await http.get("http://dtd.jasaraharjariau.com/api/gambar/$id");
      var tes = json.decode(response.body);
      var gambar = tes['gambar'];
      if (ttd == null && gambar.toString() == "[]") {
        if (_imageFile != null &&
            _imageFilegambar1 != null &&
            _imageFilegambar2 != null) {
          var status = "Selesai";
          responsegambar =
              await _uploadImage(_imageFile, id, status, dataregional, datakondisi);
          print(responsegambar);
          responsegambar1 = await _uploadImagegambar1(_imageFilegambar1, id);
          print(responsegambar1);
          responsegambar2 = await _uploadImagegambar2(_imageFilegambar2, id);
          print(responsegambar2);
          setState(() {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return RichAlertDialog(
                    //uses the custom alert dialog
                    alertTitle: richTitle("Sukses!"),
                    alertSubtitle: richSubtitle("Data berhasil di update!"),
                    alertType: RichAlertType.SUCCESS,
                    actions: <Widget>[
                      FlatButton(
                        child: Text("OK"),
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
            loading = false;
          });
        } else {
          setState(() {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return RichAlertDialog(
                    //uses the custom alert dialog
                    alertTitle: richTitle("Gagal!"),
                    alertSubtitle:
                        richSubtitle("Gambar Error Atau Tidak Diiisi!"),
                    alertType: RichAlertType.WARNING,
                    actions: <Widget>[
                      FlatButton(
                        child: Text("OK"),
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
            loading = false;
          });
        }
      } else {
        SharedPreferences preferences = await SharedPreferences.getInstance();
        String iduser = preferences.getString("id");
        var status = "Selesai";

        final response = await http
            .put('http://dtd.jasaraharjariau.com/api/data/$id', body: {
          "id_user": iduser,
          "nopol": nopol,
          "pemilik": pemilik,
          "alamat": alamat,
          "no_telpon": notelpon,
          "kondisi": datakondisi,
          "status": status,
          "regional": dataregional,
          "janji_bayar": janjibayar.toString(),
          "status": status,
          "masa_awal": masaawal.toString(),
          "masa_akhir": masaakhir.toString(),
          "tarif": tarif,
          "tanggal_pelaksanaan": tanggalpelaksanaan.toString(),
        });
        json.decode(response.body);
        setState(() {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return RichAlertDialog(
                  //uses the custom alert dialog
                  alertTitle: richTitle("Sukses!"),
                  alertSubtitle: richSubtitle("Data berhasil di update!"),
                  alertType: RichAlertType.SUCCESS,
                  actions: <Widget>[
                    FlatButton(
                      child: Text("OK"),
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
        });
      }
    } else {
      var status = "Belum Diproses";
      final response =
          await http.put('http://dtd.jasaraharjariau.com/api/data/$id', body: {
        "nopol": nopol,
        "pemilik": pemilik,
        "alamat": alamat,
        "no_telpon": notelpon,
        "status": status,
        "masa_awal": masaawal.toString(),
        "masa_akhir": masaakhir.toString(),
        "tarif": tarif,
        "regional": dataregional
      });
      json.decode(response.body);
      setState(() {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return RichAlertDialog(
                //uses the custom alert dialog
                alertTitle: richTitle("Sukses!"),
                alertSubtitle: richSubtitle("Data berhasil di update!"),
                alertType: RichAlertType.SUCCESS,
                actions: <Widget>[
                  FlatButton(
                    child: Text("OK"),
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
      });
    }
  }

  status() {
    String sstatus = data.status;
    return sstatus;
  }

  bayar(var data) {
    DateFormat dateFormat = DateFormat("yyyy-MM-dd");
    DateTime dateTime = dateFormat.parse("$data");
    return dateTime;
  }

  fmasaawal(var data) {
    DateFormat dateFormat = DateFormat("yyyy-MM-dd");
    DateTime dateTime = dateFormat.parse("$data");
    return dateTime;
  }

  fjanjibayar(var data) {
    DateFormat dateFormat = DateFormat("yyyy-MM-dd");
    DateTime dateTime = dateFormat.parse("$data");
    return dateTime;
  }

  ftanggalpelaksanaan(var data) {
    DateFormat dateFormat = DateFormat("yyyy-MM-dd");
    DateTime dateTime = dateFormat.parse("$data");
    return dateTime;
  }

  fmasaakhir(var data) {
    DateFormat dateFormat = DateFormat("yyyy-MM-dd");
    DateTime dateTime = dateFormat.parse("$data");
    return dateTime;
  }

  feditmasaawal() {
    DateFormat dateFormat = DateFormat("yyyy-MM-dd");
    DateTime dateTime = dateFormat.parse("000-00-00");
    return dateTime;
  }

  feditjanjibayar() {
    DateFormat dateFormat = DateFormat("yyyy-MM-dd");
    DateTime dateTime = dateFormat.parse("000-00-00");
    return dateTime;
  }

  fedittanggalpelaksanaan() {
    DateFormat dateFormat = DateFormat("yyyy-MM-dd");
    DateTime dateTime = dateFormat.parse("000-00-00");
    return dateTime;
  }

  feditmasaakhir() {
    DateFormat dateFormat = DateFormat("yyyy-MM-dd");
    DateTime dateTime = dateFormat.parse("000-00-00");
    return dateTime;
  }

  // To store the file provided by the image_picker
  File _imageFile;
  File _imageFilegambar1;
  File _imageFilegambar2;

  // To track the file uploading state
  bool _isUploading = false;
  bool _isUploadinggambar2 = false;
  bool _isUploadinggambar1 = false;

  void _getImage(BuildContext context, ImageSource source) async {
    File image = await ImagePicker.pickImage(source: source);

    setState(() {
      _imageFile = image;
    });

    // Closes the bottom sheet
    Navigator.pop(context);
  }

  void _getImagegambar1(BuildContext context, ImageSource source) async {
    File image = await ImagePicker.pickImage(source: source, maxWidth: 500, maxHeight: 500);

    setState(() {
      _imageFilegambar1 = image;
    });

    // Closes the bottom sheet
    Navigator.pop(context);
  }

  void _getImagegambar2(BuildContext context, ImageSource source) async {
    File image = await ImagePicker.pickImage(source: source, maxWidth: 500, maxHeight: 500);

    setState(() {
      _imageFilegambar2 = image;
    });

    // Closes the bottom sheet
    Navigator.pop(context);
  }

  Future<Map<String, dynamic>> _uploadImage(
      File image, var id, var status, var regional, var datakondisi) async {
    setState(() {
      _isUploading = true;
    });

    String baseUrl = 'http://dtd.jasaraharjariau.com/androids/test.php';

    // Find the mime type of the selected file by looking at the header bytes of the file
    final mimeTypeData =
        lookupMimeType(image.path, headerBytes: [0xFF, 0xD8]).split('/');

    DateFormat dateFormat = DateFormat("yyyy-MM-dd");
    String pelaksanaan = dateFormat.format(DateTime.now());
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String iduser = preferences.getString("id");

    // Intilize the multipart request
    final imageUploadRequest =
        http.MultipartRequest('POST', Uri.parse(baseUrl));
    imageUploadRequest.fields['id'] = id;
    imageUploadRequest.fields['id_user'] = iduser;
    imageUploadRequest.fields['nopol'] = nopol;
    imageUploadRequest.fields['pemilik'] = pemilik;
    imageUploadRequest.fields['alamat'] = alamat;
    imageUploadRequest.fields['no_telpon'] = notelpon;
    imageUploadRequest.fields['kondisi'] = datakondisi;
    imageUploadRequest.fields['regional'] = regional;
    imageUploadRequest.fields['janji_bayar'] = janjibayar.toString();
    imageUploadRequest.fields['status'] = status;
    imageUploadRequest.fields['masa_awal'] = masaawal.toString();
    imageUploadRequest.fields['masa_akhir'] = masaakhir.toString();
    imageUploadRequest.fields['tarif'] = tarif;
    imageUploadRequest.fields['tanggal_pelaksanaan'] =
        tanggalpelaksanaan.toString();

    // Attach the file in the request
    final file = await http.MultipartFile.fromPath('image', image.path,
        contentType: MediaType(mimeTypeData[0], mimeTypeData[1]));

    // Explicitly pass the extension of the image with request body
    // Since image_picker has some bugs due which it mixes up
    // image extension with file name like this filenamejpge
    // Which creates some problem at the server side to manage
    // or verify the file extension
    imageUploadRequest.fields['ext'] = mimeTypeData[1];

    imageUploadRequest.files.add(file);

    try {
      final streamedResponse = await imageUploadRequest.send();

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        return null;
      }

      final Map<String, dynamic> responseData = json.decode(response.body);

      _resetState();

      return responseData;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<Map<String, dynamic>> _uploadImagegambar1(File image, var id) async {
    setState(() {
      _isUploadinggambar1 = true;
    });

    String baseUrl = 'http://dtd.jasaraharjariau.com/androids/gambar1.php';

    // Find the mime type of the selected file by looking at the header bytes of the file
    final mimeTypeData =
        lookupMimeType(image.path, headerBytes: [0xFF, 0xD8]).split('/');

    // Intilize the multipart request
    final imageUploadRequest =
        http.MultipartRequest('POST', Uri.parse(baseUrl));
    imageUploadRequest.fields['id_data'] = id;

    // Attach the file in the request
    final file = await http.MultipartFile.fromPath('image', image.path,
        contentType: MediaType(mimeTypeData[0], mimeTypeData[1]));

    // Explicitly pass the extension of the image with request body
    // Since image_picker has some bugs due which it mixes up
    // image extension with file name like this filenamejpge
    // Which creates some problem at the server side to manage
    // or verify the file extension
    imageUploadRequest.fields['ext'] = mimeTypeData[1];

    imageUploadRequest.files.add(file);

    try {
      final streamedResponse = await imageUploadRequest.send();

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        return null;
      }

      final Map<String, dynamic> responseData = json.decode(response.body);

      _resetStategambar1();

      return responseData;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<Map<String, dynamic>> _uploadImagegambar2(File image, var id) async {
    setState(() {
      _isUploadinggambar2 = true;
    });

    String baseUrl = 'http://dtd.jasaraharjariau.com/androids/gambar2.php';

    // Find the mime type of the selected file by looking at the header bytes of the file
    final mimeTypeData =
        lookupMimeType(image.path, headerBytes: [0xFF, 0xD8]).split('/');

    // Intilize the multipart request
    final imageUploadRequest =
        http.MultipartRequest('POST', Uri.parse(baseUrl));
    imageUploadRequest.fields['id_data'] = id;

    // Attach the file in the request
    final file = await http.MultipartFile.fromPath('image', image.path,
        contentType: MediaType(mimeTypeData[0], mimeTypeData[1]));

    // Explicitly pass the extension of the image with request body
    // Since image_picker has some bugs due which it mixes up
    // image extension with file name like this filenamejpge
    // Which creates some problem at the server side to manage
    // or verify the file extension
    imageUploadRequest.fields['ext'] = mimeTypeData[1];

    imageUploadRequest.files.add(file);

    try {
      final streamedResponse = await imageUploadRequest.send();

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        return null;
      }

      final Map<String, dynamic> responseData = json.decode(response.body);

      _resetStategambar2();

      return responseData;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Map<String, dynamic> responsegambar;
  Map<String, dynamic> responsegambar1;
  Map<String, dynamic> responsegambar2;

  void _resetState() {
    setState(() {
      _imageFile = null;
    });
  }

  void _resetStategambar1() {
    setState(() {
      _imageFilegambar1 = null;
    });
  }

  void _resetStategambar2() {
    setState(() {
      _imageFilegambar2 = null;
    });
  }

  void _openImagePickerModal(BuildContext context) {
    final flatButtonColor = Theme.of(context).primaryColor;
    print('Image Picker Modal Called');
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 100.0,
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                Text(
                  'Pick an image',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                FlatButton(
                  textColor: flatButtonColor,
                  child: Text('Use Gallery'),
                  onPressed: () {
                    _getImage(context, ImageSource.gallery);
                  },
                ),
              ],
            ),
          );
        });
  }

  void _openImagePickerModalgambar1(BuildContext context) {
    final flatButtonColor = Theme.of(context).primaryColor;
    print('Image Picker Modal Called');
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 150.0,
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                Text(
                  'Pick an image',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                FlatButton(
                  textColor: flatButtonColor,
                  child: Text('Use Gallery'),
                  onPressed: () {
                    _getImagegambar1(context, ImageSource.gallery);
                  },
                ),
              ],
            ),
          );
        });
  }

  void _openImagePickerModalgambar2(BuildContext context) {
    final flatButtonColor = Theme.of(context).primaryColor;
    print('Image Picker Modal Called');
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 150.0,
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                Text(
                  'Pick an image',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                FlatButton(
                  textColor: flatButtonColor,
                  child: Text('Use Gallery'),
                  onPressed: () {
                    _getImagegambar2(context, ImageSource.gallery);
                  },
                ),
              ],
            ),
          );
        });
  }

  Map<String, dynamic> dataregional;
  String _dataregionalterkini;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    datakondisi = data.kondisi == null ? "Beroperasi" : data.kondisi;
    dataregional = {
      "Kota Pekanbaru": pekanbaru,
      "Kota Dumai": dumai,
      "Kabupaten Siak": siak,
      "Kabupaten Rokan Hulu": rohul,
      "Kabupaten Rokan Hilir": rohil,
      "Kabupaten Pelalawan": pelalawan,
      "Kabupaten Kuantan Singingi": kuansing,
      "Kabupaten Kampar": kampar,
      "Kabupaten Indragiri Hulu": inhu,
      "Kabupaten Indragiri Hilir": inhil,
      "Kabupaten Bengkalis": bengkalis
    };
    _dataregionalterkini = data.regional;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(32.0))),
      title: Text("Edit Data"),
      content: Container(
        height: 500.00,
        width: 300.00,
        child: SingleChildScrollView(
          child: Form(
            key: key,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: ScreenUtil().setHeight(30),
                ),
                Text("Nopol",
                    style: TextStyle(
                        fontFamily: "Poppins-Medium",
                        fontSize: ScreenUtil().setSp(26))),
                TextFormField(
                  initialValue: data.nopol,
                  validator: (e) {
                    if (e.isEmpty) {
                      loading = false;
                      return "Silahkan masukkan Nopol anda";
                    }
                  },
                  onSaved: (e) => nopol = e,
                  decoration: InputDecoration(
                      hintText: "Nopol",
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 12.0)),
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(30),
                ),
                Text("Pemilik",
                    style: TextStyle(
                        fontFamily: "Poppins-Medium",
                        fontSize: ScreenUtil().setSp(26))),
                TextFormField(
                  initialValue: data.pemilik,
                  validator: (e) {
                    if (e.isEmpty) {
                      loading = false;
                      return "Silahkan masukkan nama pemilik anda";
                    }
                  },
                  onSaved: (e) => pemilik = e,
                  decoration: InputDecoration(
                      hintText: "Pemilik",
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 12.0)),
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(30),
                ),
                Text("Alamat",
                    style: TextStyle(
                        fontFamily: "Poppins-Medium",
                        fontSize: ScreenUtil().setSp(26))),
                TextFormField(
                  maxLines: 4,
                  initialValue: data.alamat == null || data.alamat == "" ? dataalamat : data.alamat,
                  validator: (e) {
                    if (e.isEmpty) {
                      loading = false;
                      return "Silahkan masukkan alamat anda";
                    }
                  },
                  onSaved: (e) => alamat = e,
                  decoration: InputDecoration(
                      hintText: "Alamat",
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 12.0)),
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(30),
                ),
                Text("No Telpon",
                    style: TextStyle(
                        fontFamily: "Poppins-Medium",
                        fontSize: ScreenUtil().setSp(26))),
                TextFormField(
                  keyboardType: TextInputType.number,
                  initialValue: data.notelpon,
                  validator: (e) {
                    if (e.isEmpty) {
                      loading = false;
                      return "Silahkan masukkan no telpon anda";
                    }
                  },
                  onSaved: (e) => notelpon = e,
                  decoration: InputDecoration(
                      hintText: "No Telpon",
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 12.0)),
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(30),
                ),
                Text("Kondisi",
                    style: TextStyle(
                        fontFamily: "Poppins-Medium",
                        fontSize: ScreenUtil().setSp(26))),
                RadioListTile<String>(
                  title: const Text('Beroperasi'),
                  value: 'Beroperasi',
                  groupValue: datakondisi,
                  onChanged: (value) {
                    setState(() {
                      datakondisi = value;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Rusak Selamanya'),
                  value: 'Rusak Selamanya',
                  groupValue: datakondisi,
                  onChanged: (value) {
                    setState(() {
                      datakondisi = value;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Dijual'),
                  value: 'Dijual',
                  groupValue: datakondisi,
                  onChanged: (value) {
                    setState(() {
                      datakondisi = value;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Ganti nopol'),
                  value: 'Ganti nopol',
                  groupValue: datakondisi,
                  onChanged: (value) {
                    setState(() {
                      datakondisi = value;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Pindah PO'),
                  value: 'Pindah PO',
                  groupValue: datakondisi,
                  onChanged: (value) {
                    setState(() {
                      datakondisi = value;
                    });
                  },
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(30),
                ),
                Text("Masa Awal",
                    style: TextStyle(
                        fontFamily: "Poppins-Medium",
                        fontSize: ScreenUtil().setSp(26))),
                DateTimeField(
                  onSaved: (e) => masaawal = e,
                  initialValue: fmasaawal(data.masaawal) == feditmasaawal()
                      ? null
                      : fmasaawal(data.masaawal),
                  validator: (e) {
                    if (e == null) {
                      loading = false;
                      return "Silahkan masukkan masa awal anda";
                    }
                  },
                  format: format,
                  onShowPicker: (context, currentValue) {
                    return showDatePicker(
                        context: context,
                        firstDate: DateTime(1900),
                        initialDate: currentValue ?? DateTime.now(),
                        lastDate: DateTime(2100));
                  },
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(30),
                ),
                Text("Masa Akhir",
                    style: TextStyle(
                        fontFamily: "Poppins-Medium",
                        fontSize: ScreenUtil().setSp(26))),
                DateTimeField(
                  onSaved: (e) => masaakhir = e,
                  initialValue: fmasaakhir(data.masaakhir) == feditmasaakhir()
                      ? null
                      : fmasaakhir(data.masaakhir),
                  validator: (e) {
                    if (e == null) {
                      loading = false;
                      return "Silahkan masukkan masa akhir anda";
                    }
                  },
                  format: format,
                  onShowPicker: (context, currentValue) {
                    return showDatePicker(
                        context: context,
                        firstDate: DateTime(1900),
                        initialDate: currentValue ?? DateTime.now(),
                        lastDate: DateTime(2100));
                  },
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(30),
                ),
                Text("Tarif",
                    style: TextStyle(
                        fontFamily: "Poppins-Medium",
                        fontSize: ScreenUtil().setSp(26))),
                TextFormField(
                  keyboardType: TextInputType.number,
                  initialValue: data.tarif,
                  validator: (e) {
                    if (e.isEmpty) {
                      loading = false;
                      return "Silahkan masukkan tarif anda";
                    }
                  },
                  onSaved: (e) => tarif = e,
                  decoration: InputDecoration(
                      hintText: "Tarif",
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 12.0)),
                ),
                data.ttd == null
                    ? SizedBox(
                        height: ScreenUtil().setHeight(30),
                      )
                    : SizedBox(
                        height: ScreenUtil().setHeight(10),
                      ),
                data.ttd == null
                    ? Text("Tambah Tanda Tangan",
                        style: TextStyle(
                            fontFamily: "Poppins-Medium",
                            fontSize: ScreenUtil().setSp(26)))
                    : SizedBox(
                        height: ScreenUtil().setHeight(10),
                      ),
                data.ttd == null
                    ? _imageFile == null
                        ? Padding(
                            padding: const EdgeInsets.only(
                                top: 40.0, left: 10.0, right: 10.0),
                            child: OutlineButton(
                              onPressed: () => _openImagePickerModal(context),
                              borderSide: BorderSide(
                                  color: Theme.of(context).accentColor,
                                  width: 1.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  SizedBox(
                                    width: 5.0,
                                  ),
                                  Text('Tambah'),
                                ],
                              ),
                            ),
                          )
                        : Image.file(
                            _imageFile,
                            fit: BoxFit.cover,
                            height: 300.0,
                            alignment: Alignment.topCenter,
                            width: MediaQuery.of(context).size.width,
                          )
                    : SizedBox(
                        height: ScreenUtil().setHeight(10),
                      ),
                SizedBox(
                  height: ScreenUtil().setHeight(30),
                ),
                Text("Regional",
                    style: TextStyle(
                        fontFamily: "Poppins-Medium",
                        fontSize: ScreenUtil().setSp(26))),
                DropdownButton<String>(
                  items: dataregional
                      .map((description, value) {
                        return MapEntry(
                            description,
                            DropdownMenuItem<String>(
                              value: value,
                              child: Text(description,
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 15)),
                            ));
                      })
                      .values
                      .toList(),
                  value: _dataregionalterkini,
                  onChanged: (newValue) {
                    setState(() {
                      _dataregionalterkini = newValue;
                    });
                  },
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(30),
                ),
                Text("Janji Bayar",
                    style: TextStyle(
                        fontFamily: "Poppins-Medium",
                        fontSize: ScreenUtil().setSp(26))),
                DateTimeField(
                  onSaved: (e) => janjibayar = e,
                  initialValue:
                      fjanjibayar(data.janjibayar) == feditjanjibayar()
                          ? null
                          : fjanjibayar(data.janjibayar),
                  validator: (e) {
                    if (e == null) {
                      loading = false;
                      return "Silahkan masukkan janji bayar anda";
                    }
                  },
                  format: format,
                  onShowPicker: (context, currentValue) {
                    return showDatePicker(
                        context: context,
                        firstDate: DateTime(1900),
                        initialDate: currentValue ?? DateTime.now(),
                        lastDate: DateTime(2100));
                  },
                ),
                data.ttd == null
                    ? SizedBox(
                        height: ScreenUtil().setHeight(30),
                      )
                    : SizedBox(
                        height: ScreenUtil().setHeight(10),
                      ),
                data.ttd == null
                    ? Text("Tambah Gambar",
                        style: TextStyle(
                            fontFamily: "Poppins-Medium",
                            fontSize: ScreenUtil().setSp(26)))
                    : SizedBox(
                        height: ScreenUtil().setHeight(10),
                      ),
                data.ttd == null
                    ? Row(
                        children: <Widget>[
                          Expanded(
                            child: _imageFilegambar1 == null
                                ? Card(
                                    child: IconButton(
                                      icon: Icon(Icons.add),
                                      onPressed: () {
                                        _openImagePickerModalgambar1(context);
                                      },
                                    ),
                                  )
                                : Image.file(
                                    _imageFilegambar1,
                                    height: 80,
                                  ),
                          ),
                          Expanded(
                            child: _imageFilegambar2 == null
                                ? Card(
                                    child: IconButton(
                                      icon: Icon(Icons.add),
                                      onPressed: () {
                                        _openImagePickerModalgambar2(context);
                                      },
                                    ),
                                  )
                                : Image.file(
                                    _imageFilegambar2,
                                    height: 80,
                                  ),
                          ),
                        ],
                      )
                    : SizedBox(
                        height: ScreenUtil().setHeight(10),
                      ),
                SizedBox(
                  height: ScreenUtil().setHeight(30),
                ),
                Text("Tanggal Pelaksanaan",
                    style: TextStyle(
                        fontFamily: "Poppins-Medium",
                        fontSize: ScreenUtil().setSp(26))),
                DateTimeField(
                  onSaved: (e) => tanggalpelaksanaan = e,
                  initialValue: ftanggalpelaksanaan(data.tanggalpelaksanaan) ==
                          fedittanggalpelaksanaan()
                      ? null
                      : ftanggalpelaksanaan(data.tanggalpelaksanaan),
                  validator: (e) {
                    if (e == null) {
                      loading = false;
                      return "Silahkan masukkan Nopol anda";
                    }
                  },
                  format: format,
                  onShowPicker: (context, currentValue) {
                    return showDatePicker(
                        context: context,
                        firstDate: DateTime(1900),
                        initialDate: currentValue ?? DateTime.now(),
                        lastDate: DateTime(2100));
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: <Widget>[
        FlatButton(
                child: Text("+"),
                onPressed: () {
                  setState(() {
                    showDialog(context: context, builder: (_) => TambahLanjutan(data, keluar, dataalamat));
                  });
                },
              ),
        data.ttd == null
            ? FlatButton(
                child: Text("TTD"),
                onPressed: () {
                  setState(() {
                    showDialog(context: context, builder: (_) => Tandatangan(data.nopol));
                  });
                },
              )
            : null,
        loading == true
            ? CircularProgressIndicator()
            : FlatButton(
                child: Text("EDIT"),
                onPressed: () {
                  setState(() {
                    loading = true;
                    final form = key.currentState;
                    if (form.validate()) {
                      form.save();
                      checkConnectivity1(
                          data.id, _dataregionalterkini, data.ttd, datakondisi);
                    }
                  });
                },
              )
      ],
    );
  }
}

class TambahLanjutan extends StatefulWidget {
  final VoidCallback keluar;
  var dataalamat;
  var data;
  TambahLanjutan(this.data, this.keluar, this.dataalamat);

  @override
  _TambahLanjutanState createState() => _TambahLanjutanState(this.data, this.dataalamat);
}

class _TambahLanjutanState extends State<TambahLanjutan> {
  final key = GlobalKey<FormState>();
  String pemilik, nopol, alamat, notelpon, kondisi, tarif;
  String _maritalStatus = 'Belum Diproses';
  var masaawal, masaakhir, dataalamat, data;
  _TambahLanjutanState(this.data, this.dataalamat);
  final format = DateFormat("yyyy-MM-dd");
  String pekanbaru = "pekanbaru";
  String dumai = "dumai";
  String siak = "siak";
  String rohul = "rohul";
  String rohil = "rohil";
  String pelalawan = "pelalawan";
  String kuansing = "kuansing";
  String kampar = "kampar";
  String inhu = "inhu";
  String inhil = "inhil";
  String bengkalis = "bengkalis";

  Map<String, dynamic> dataregional;
  String _dataregionalterkini = "pekanbaru";
  bool loading = false;

  Connectivity connectivity = Connectivity();
  String statuskonek;

  keluar() {
    setState(() {
      widget.keluar();
    });
  }

  void checkConnectivity1(var regional, var status) async {
    var connectivityResult = await connectivity.checkConnectivity();
    var conn = getConnectionValue(connectivityResult);
    setState(() {
      statuskonek = 'Check Connection: ' + conn;
      if (statuskonek == "Check Connection: None") {
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
                      Navigator.pop(context);
                    },
                  )
                ],
              );
            });
        loading = false;
      } else {
        tambahdata(regional, status);
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dataregional = {
      "Kota Pekanbaru": pekanbaru,
      "Kota Dumai": dumai,
      "Kabupaten Siak": siak,
      "Kabupaten Rokan Hulu": rohul,
      "Kabupaten Rokan Hilir": rohil,
      "Kabupaten Pelalawan": pelalawan,
      "Kabupaten Kuantan Singingi": kuansing,
      "Kabupaten Kampar": kampar,
      "Kabupaten Indragiri Hulu": inhu,
      "Kabupaten Indragiri Hilir": inhil,
      "Kabupaten Bengkalis": bengkalis
    };
  }

  tambahdata(var regional, var status) async {
    final response =
        await http.post('http://dtd.jasaraharjariau.com/api/data', body: {
      "nopol": nopol,
      "pemilik": pemilik,
      "alamat": alamat,
      "no_telpon": notelpon,
      "status": status,
      "masa_awal": masaawal.toString(),
      "masa_akhir": masaakhir.toString(),
      "tarif": tarif,
      "regional": regional,
    });
    json.decode(response.body);

    setState(() {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return RichAlertDialog(
              //uses the custom alert dialog
              alertTitle: richTitle("Sukses!"),
              alertSubtitle: richSubtitle("Data berhasil di ditambah!"),
              alertType: RichAlertType.SUCCESS,
              actions: <Widget>[
                FlatButton(
                  child: Text("OK"),
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
    });
  }

  bayar(var data) {
    DateFormat dateFormat = DateFormat("yyyy-MM-dd");
    DateTime dateTime = dateFormat.parse("$data");
    return dateTime;
  }

  fmasaawal(var data) {
    DateFormat dateFormat = DateFormat("yyyy-MM-dd");
    DateTime dateTime = dateFormat.parse("$data");
    return dateTime;
  }

  editbayar() {
    DateFormat dateFormat = DateFormat("yyyy-MM-dd");
    DateTime dateTime = dateFormat.parse("000-00-00");
    return dateTime;
  }

  feditmasaawal() {
    DateFormat dateFormat = DateFormat("yyyy-MM-dd");
    DateTime dateTime = dateFormat.parse("000-00-00");
    return dateTime;
  }

  fmasaakhir(var data) {
    DateFormat dateFormat = DateFormat("yyyy-MM-dd");
    DateTime dateTime = dateFormat.parse("$data");
    return dateTime;
  }

  feditmasaakhir() {
    DateFormat dateFormat = DateFormat("yyyy-MM-dd");
    DateTime dateTime = dateFormat.parse("000-00-00");
    return dateTime;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(32.0))),
      title: Text("Tambah " + data.nopol),
      content: Container(
        height: 400.00,
        width: 300.00,
        child: SingleChildScrollView(
          child: Form(
            key: key,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: ScreenUtil().setHeight(30),
                ),
                Text("Nopol",
                    style: TextStyle(
                        fontFamily: "Poppins-Medium",
                        fontSize: ScreenUtil().setSp(26))),
                TextFormField(
                  initialValue: data.nopol,
                  enabled: false,
                  onSaved: (e) => nopol = e,
                  decoration: InputDecoration(
                      hintText: "Nopol",
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 12.0)),
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(30),
                ),
                Text("Pemilik",
                    style: TextStyle(
                        fontFamily: "Poppins-Medium",
                        fontSize: ScreenUtil().setSp(26))),
                TextFormField(
                  initialValue: data.pemilik,
                  enabled: false,
                  onSaved: (e) => pemilik = e,
                  decoration: InputDecoration(
                      hintText: "Pemilik",
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 12.0)),
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(30),
                ),
                Text("Alamat",
                    style: TextStyle(
                        fontFamily: "Poppins-Medium",
                        fontSize: ScreenUtil().setSp(26))),
                TextFormField(
                  maxLines: 4,
                  initialValue: dataalamat,
                  validator: (e) {
                    if (e.isEmpty) {
                      loading = false;
                      return "Silahkan masukkan Alamat anda";
                    }
                  },
                  onSaved: (e) => alamat = e,
                  decoration: InputDecoration(
                    hintText: "Alamat",
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 12.0),
                  ),
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(30),
                ),
                Text("No Telpon",
                    style: TextStyle(
                        fontFamily: "Poppins-Medium",
                        fontSize: ScreenUtil().setSp(26))),
                TextFormField(
                  keyboardType: TextInputType.number,
                  initialValue: data.notelpon,
                  validator: (e) {
                    if (e.isEmpty) {
                      loading = false;
                      return "Silahkan masukkan no telpon anda";
                    }
                  },
                  onSaved: (e) => notelpon = e,
                  decoration: InputDecoration(
                      hintText: "No Telpon",
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 12.0)),
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(30),
                ),
                Text("Status",
                    style: TextStyle(
                        fontFamily: "Poppins-Medium",
                        fontSize: ScreenUtil().setSp(26))),
                RadioListTile<String>(
                  title: const Text('Belum Diproses'),
                  value: 'Belum Diproses',
                  groupValue: _maritalStatus,
                  onChanged: (value) {
                    setState(() {
                      _maritalStatus = value;
                    });
                  },
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(30),
                ),
                Text("Masa awal",
                    style: TextStyle(
                        fontFamily: "Poppins-Medium",
                        fontSize: ScreenUtil().setSp(26))),
                DateTimeField(
                  initialValue: fmasaawal(data.masaawal) == feditmasaawal()
                      ? null
                      : fmasaawal(data.masaawal),
                  onSaved: (e) => masaawal = e,
                  enabled: false,
                  format: format,
                  onShowPicker: (context, currentValue) {
                    return showDatePicker(
                        context: context,
                        firstDate: DateTime(1900),
                        initialDate: currentValue ?? DateTime.now(),
                        lastDate: DateTime(2100));
                  },
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(30),
                ),
                Text("Masa akhir",
                    style: TextStyle(
                        fontFamily: "Poppins-Medium",
                        fontSize: ScreenUtil().setSp(26))),
                DateTimeField(
                  enabled: false,
                  onSaved: (e) => masaakhir = e,
                  initialValue: fmasaakhir(data.masaakhir) == feditmasaakhir()
                      ? null
                      : fmasaakhir(data.masaakhir),
                  format: format,
                  onShowPicker: (context, currentValue) {
                    return showDatePicker(
                        context: context,
                        firstDate: DateTime(1900),
                        initialDate: currentValue ?? DateTime.now(),
                        lastDate: DateTime(2100));
                  },
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(30),
                ),
                Text("Tarif",
                    style: TextStyle(
                        fontFamily: "Poppins-Medium",
                        fontSize: ScreenUtil().setSp(26))),
                TextFormField(
                  enabled: false,
                  initialValue: data.tarif,
                  keyboardType: TextInputType.number,
                  onSaved: (e) => tarif = e,
                  decoration: InputDecoration(
                      hintText: "Tarif",
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 12.0)),
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(30),
                ),
                Text("Regional",
                    style: TextStyle(
                        fontFamily: "Poppins-Medium",
                        fontSize: ScreenUtil().setSp(26))),
                DropdownButton<String>(
                  items: dataregional
                      .map((description, value) {
                        return MapEntry(
                            description,
                            DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  description,
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 15),
                                )));
                      })
                      .values
                      .toList(),
                  value: _dataregionalterkini,
                  onChanged: (newValue) {
                    setState(() {
                      _dataregionalterkini = newValue;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: <Widget>[
        loading == true
            ? CircularProgressIndicator()
            : FlatButton(
                child: Text("TAMBAH"),
                onPressed: () {
                  setState(() {
                    loading = true;
                    final form = key.currentState;
                    if (form.validate()) {
                      form.save();
                      checkConnectivity1(_dataregionalterkini, _maritalStatus);
                    }
                  });
                },
              )
      ],
    );
  }
}