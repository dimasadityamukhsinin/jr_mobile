import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jasaraharja/ViewKasubag/homepage.dart';
import 'package:jasaraharja/ViewKepalacabang/homepage.dart';
import 'package:rich_alert/rich_alert.dart';
import 'package:http/http.dart' as http;
import 'package:jasaraharja/model/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:connectivity/connectivity.dart';

import 'ViewAdmin/homepage.dart';
import 'ViewPetugas/homepage.dart';
import 'ViewStaff/homepage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

enum LoginStatus { tidaklogin, login, loginkasubag, loginpetugas, loginstaff, loginkepalacabang }

class _LoginPageState extends State<LoginPage> {
  LoginStatus loginStatus = LoginStatus.tidaklogin;
  final key = GlobalKey<FormState>();
  String username, password;
  String msg = '';
  bool secureText = true;
  bool loading = false;

  Connectivity connectivity = Connectivity();
  String status;

  checkConnectivity1() async {
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
                      Navigator.pop(context);
                    },
                  )
                ],
              );
            });
      loading = false;
      }else {
          check();
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

  showHide() {
    setState(() {
      secureText = !secureText;
    });
  }

  check() {
    final form = key.currentState;
    if (form.validate()) {
      form.save();
      login();
    }
  }

  login() async {
    final response = await http.post(Config.login, body: {
      "username": username,
      "password": password,
    });

    final data = json.decode(response.body);
    String pesan = data['pesan'];
    int value = data['value'];
    String id = data['id'];
    String kodesamsat = data['kode_samsat'];
    String cabang = data['cabang'];
    String namasamsat = data['nama_samsat'];
    String alamat = data['alamat'];
    String datausername = data['username'];
    String nama = data['nama'];
    String notelpon = data['no_telpon'];
    String jabatan = data['jabatan'];
    String regional = data['regional'];
    String namaregional = data['nama_regional'];
    String level = data['id_level'];
    String ttd = data['ttd'];
    if (value == 1) {
      print(level);
      if(level == "1") {
        setState(() {
          loginStatus = LoginStatus.login;
          savePref(id, value, kodesamsat, cabang, namasamsat, alamat,
              datausername, nama, notelpon, jabatan, regional, namaregional,level, ttd);
        });
      }else if(level == "2") {
        setState(() {
          loginStatus = LoginStatus.loginkasubag;
          savePref(id, value, kodesamsat, cabang, namasamsat, alamat,
              datausername, nama, notelpon, jabatan, regional, namaregional,level, ttd);
        });
      }else if(level == "3") {
        setState(() {
          loginStatus = LoginStatus.loginstaff;
          savePref(id, value, kodesamsat, cabang, namasamsat, alamat,
              datausername, nama, notelpon, jabatan, regional, namaregional,level, ttd);
        });
      }else if(level == "4") {
        setState(() {
          loginStatus = LoginStatus.loginpetugas;
          savePref(id, value, kodesamsat, cabang, namasamsat, alamat,
              datausername, nama, notelpon, jabatan, regional, namaregional,level, ttd);
        });
      }else if(level == "5") {
        setState(() {
          loginStatus = LoginStatus.loginkepalacabang;
          savePref(id, value, kodesamsat, cabang, namasamsat, alamat,
              datausername, nama, notelpon, jabatan, regional, namaregional,level, ttd);
        });
      }
    } else {
      setState(() {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return RichAlertDialog(
                //uses the custom alert dialog
                alertTitle: richTitle("Peringatan!"),
                alertSubtitle: richSubtitle("$pesan"),
                alertType: RichAlertType.WARNING,
              );
            });

        loading = false;
      });
    }
  }

  String regional;

  savePref(
      String id,
      int value,
      String kodesamsat,
      String cabang,
      String namasamsat,
      String alamat,
      String datausername,
      String nama,
      String notelpon,
      String jabatan,
      String regional,
      String namaregional, String level, String ttd) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      preferences.setString("id", id);
      preferences.setInt("value", value);
      preferences.setString("kode_samsat", kodesamsat);
      preferences.setString("cabang", cabang);
      preferences.setString("nama_samsat", namasamsat);
      preferences.setString("alamat", alamat);
      preferences.setString("username", datausername);
      preferences.setString("nama", nama);
      preferences.setString("no_telpon", notelpon);
      preferences.setString("jabatan", jabatan);
      preferences.setString("regional", regional);
      preferences.setString("nama_regional", namaregional);
      preferences.setString("id_level", level);
      preferences.setString("ttd", ttd);
    });
  }

  var value;
  var level;
  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      value = preferences.getInt("value");
      level = preferences.getString("id_level");

      if(value == 1 ) {
        if(level == "1") {
          loginStatus = LoginStatus.login;
        }else if(level == "2") {
          loginStatus = LoginStatus.loginkasubag;
        }else if(level == "3") {
          loginStatus = LoginStatus.loginstaff;
        }else if(level == "4") {
          loginStatus = LoginStatus.loginpetugas;
        }else if(level == "5") {
          loginStatus = LoginStatus.loginkepalacabang;
        }
      }else {
        loginStatus = LoginStatus.tidaklogin;
      }

    });
  }

  keluar() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      value = preferences.setInt("value", null);
      loginStatus = LoginStatus.tidaklogin;
      loading = false;
    });
  }

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIOverlays([]);
    super.initState();
    getPref();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    switch (loginStatus) {
      case LoginStatus.tidaklogin:
        ScreenUtil.instance = ScreenUtil()..init(context);
        ScreenUtil.instance =
            ScreenUtil(width: 750, height: 1334, allowFontScaling: true);
        return new Scaffold(
          backgroundColor: Colors.white,
          resizeToAvoidBottomPadding: true,
          body: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Container(
                      child: Padding(
                    padding: EdgeInsets.only(top: 20.0),
                    child: Image.asset(
                      "assets/img/image_01.png",
                      width: ScreenUtil().setWidth(710),
                      height: ScreenUtil().setHeight(505),
                    ),
                  )),
                  Expanded(
                    child: Container(),
                  ),
                  Image.asset("assets/img/image_02.png")
                ],
              ),
              SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(left: 28.0, right: 28.0, top: 60.0),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Image.asset(
                            "assets/img/logo.png",
                            width: ScreenUtil().setWidth(160),
                            height: ScreenUtil().setHeight(160),
                          ),
                          Text("JASA RAHARJA",
                              style: TextStyle(
                                  fontFamily: "Poppins-Bold",
                                  fontSize: ScreenUtil().setSp(40),
                                  letterSpacing: .6,
                                  fontWeight: FontWeight.bold))
                        ],
                      ),
                      SizedBox(
                        height: ScreenUtil().setHeight(180),
                      ),
                      Container(
                        width: double.infinity,
                        height: ScreenUtil().setHeight(575),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.0),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black12,
                                  offset: Offset(0.0, 15.0),
                                  blurRadius: 15.0),
                              BoxShadow(
                                  color: Colors.black12,
                                  offset: Offset(0.0, -10.0),
                                  blurRadius: 10.0),
                            ]),
                        child: Form(
                          key: key,
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: 16.0, right: 16.0, top: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text("Login",
                                    style: TextStyle(
                                        fontSize:
                                            ScreenUtil().setSp(45),
                                        fontFamily: "Poppins-Bold",
                                        letterSpacing: .6)),
                                SizedBox(
                                  height:
                                      ScreenUtil().setHeight(30),
                                ),
                                Text("Username",
                                    style: TextStyle(
                                        fontFamily: "Poppins-Medium",
                                        fontSize: ScreenUtil()
                                            .setSp(26))),
                                TextFormField(
                                  validator: (e) {
                                    if (e.isEmpty) {
                                      loading = false;
                                      return "Silahkan masukkan Username anda";
                                    }
                                  },
                                  onSaved: (e) => username = e,
                                  decoration: InputDecoration(
                                      hintText: "username",
                                      hintStyle: TextStyle(
                                          color: Colors.grey, fontSize: 12.0)),
                                ),
                                SizedBox(
                                  height:
                                      ScreenUtil().setHeight(30),
                                ),
                                Text("Password",
                                    style: TextStyle(
                                        fontFamily: "Poppins-Medium",
                                        fontSize: ScreenUtil()
                                            .setSp(26))),
                                TextFormField(
                                  validator: (e) {
                                    if (e.isEmpty) {
                                      loading = false;
                                      return "Silahkan masukkan password anda";
                                    }
                                  },
                                  onSaved: (e) => password = e,
                                  obscureText: secureText,
                                  decoration: InputDecoration(
                                      hintText: "Password",
                                      hintStyle: TextStyle(
                                          color: Colors.grey, fontSize: 12.0),
                                      suffixIcon: IconButton(
                                          onPressed: showHide,
                                          icon: Icon(secureText
                                              ? Icons.visibility_off
                                              : Icons.visibility))),
                                ),
                                SizedBox(
                                  height:
                                      ScreenUtil().setHeight(35),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: ScreenUtil().setHeight(40)),
                      loading == true
                          ? CircularProgressIndicator()
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                InkWell(
                                  child: Container(
                                    width:
                                        ScreenUtil().setWidth(330),
                                    height:
                                        ScreenUtil().setHeight(100),
                                    decoration: BoxDecoration(
                                        gradient: LinearGradient(colors: [
                                          Color(0xFF17ead9),
                                          Color(0xFF6078ea)
                                        ]),
                                        borderRadius:
                                            BorderRadius.circular(6.0),
                                        boxShadow: [
                                          BoxShadow(
                                              color: Color(0xFF6078ea)
                                                  .withOpacity(.3),
                                              offset: Offset(0.0, 8.0),
                                              blurRadius: 8.0)
                                        ]),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            loading = true;
                                          });
                                          checkConnectivity1();
                                        },
                                        child: Center(
                                          child: Text("SIGNIN",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily: "Poppins-Bold",
                                                  fontSize: 18,
                                                  letterSpacing: 1.0)),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                    ],
                  ),
                ),
              )
            ],
          ),
        );
        break;
      case LoginStatus.login:
        return HomePageAdmin(keluar);
        break;
      case LoginStatus.loginpetugas:
        return HomePagePetugas(keluar);
        break;
      case LoginStatus.loginstaff:
        return HomePageStaff(keluar);
        break;
      case LoginStatus.loginkasubag:
        return HomePageKasubag(keluar);
        break;
      case LoginStatus.loginkepalacabang:
        return HomePageKepalacabang(keluar);
        break;
    }
  }
}
