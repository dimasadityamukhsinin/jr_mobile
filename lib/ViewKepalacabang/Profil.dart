import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jasaraharja/Tandatangan.dart';
import 'package:jasaraharja/ViewKepalacabang/homepage.dart';
import 'package:mime/mime.dart';
import 'package:rich_alert/rich_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:http_parser/http_parser.dart';

class ProfilKepalacabang extends StatefulWidget {
  final VoidCallback keluar;
  ProfilKepalacabang(this.keluar);

  @override
  _ProfilKepalacabangState createState() => _ProfilKepalacabangState();
}

class _ProfilKepalacabangState extends State<ProfilKepalacabang> {
  String nama,
      id,
      kodesamsat,
      cabang,
      alamat,
      username,
      notelpon,
      jabatan,
      ttd;

  keluar() {
    setState(() {
      widget.keluar();
    });
  }

  final AsyncMemoizer _memoizer = AsyncMemoizer();
  Future getPref() => _memoizer.runOnce(() async {
        SharedPreferences preferences = await SharedPreferences.getInstance();
        nama = preferences.getString("nama");
        id = preferences.getString("id");
        kodesamsat = preferences.getString("kode_samsat");
        cabang = preferences.getString("cabang");
        alamat = preferences.getString("alamat");
        username = preferences.getString("username");
        notelpon = preferences.getString("no_telpon");
        jabatan = preferences.getString("jabatan");
        ttd = preferences.getString("ttd");
      });

  Connectivity connectivity = Connectivity();
  String status;

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
    super.initState();
    checkConnectivity1();
    getPref();
  }

  Widget task(name) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      padding: EdgeInsets.fromLTRB(12, 8, 12, 8),
      margin: EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                name,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget alamatprofil(name) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      padding: EdgeInsets.fromLTRB(12, 8, 12, 8),
      margin: EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 276,
                child: Text(
                  name,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    kodesamsat == null ? kodesamsat = "" : kodesamsat;
    cabang == null ? cabang = "" : cabang;
    alamat == null ? alamat = "" : alamat;
    notelpon == null ? notelpon = "" : notelpon;
    jabatan == null ? jabatan = "" : jabatan;
    // double height = MediaQuery.of(context).size.height;
    return FutureBuilder(
        future: getPref(),
        builder: (context, snapshot) {
          return Scaffold(
            backgroundColor: Color(0xFF0374BB),
            body: ListView(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 30),
                  padding: EdgeInsets.fromLTRB(10, 20, 10, 10),
                  // height: height,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    color: Colors.white,
                  ),
                  width: double.infinity,
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  Icons.chevron_left,
                                  size: 35,
                                  color: Colors.grey[700],
                                ),
                                Text(
                                  'Kembali',
                                  style: TextStyle(
                                      color: Colors.grey[700], fontSize: 16),
                                )
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              keluar();
                            },
                            child: Row(
                              children: <Widget>[
                                Text(
                                  'Keluar',
                                  style: TextStyle(
                                      color: Colors.grey[700], fontSize: 16),
                                ),
                                Icon(
                                  Icons.exit_to_app,
                                  size: 35,
                                  color: Colors.grey[700],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      CircleAvatar(
                        backgroundImage: AssetImage('assets/img/logo.png'),
                        radius: 25,
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 10),
                      ),
                      Text(
                        '$nama',
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 10),
                      ),
                      Divider(height: 2),
                      Container(
                        padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  'Profil',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                FlatButton(
                                  child: Text(
                                    "Edit Profil",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.blue[500],
                                    ),
                                  ),
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (_) => EditData(
                                            id,
                                            nama,
                                            kodesamsat,
                                            cabang,
                                            alamat,
                                            username,
                                            notelpon,
                                            jabatan,
                                            ttd,
                                            keluar));
                                  },
                                )
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 20),
                            ),
                            task('Kode Samsat : $kodesamsat'),
                            task('Cabang : $cabang'),
                            alamatprofil('Alamat : $alamat'),
                            task('Username : $username'),
                            task('Nama : $nama'),
                            task('No Telpon : $notelpon'),
                            task('Jabatan : $jabatan'),
                            Padding(
                              padding: EdgeInsets.only(top: 35),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }
}

class EditData extends StatefulWidget {
  final VoidCallback keluar;
  String id,
      nama,
      kodesamsat,
      cabang,
      alamat,
      username,
      notelpon,
      jabatan,
      ttd;
  EditData(
      this.id,
      this.nama,
      this.kodesamsat,
      this.cabang,
      this.alamat,
      this.username,
      this.notelpon,
      this.jabatan,
      this.ttd,
      this.keluar);

  @override
  _EditDataState createState() => _EditDataState(
      this.id,
      this.nama,
      this.kodesamsat,
      this.cabang,
      this.alamat,
      this.username,
      this.notelpon,
      this.jabatan,
      this.ttd);
}

class _EditDataState extends State<EditData> {
  final key = GlobalKey<FormState>();
  String id,
      nama,
      kodesamsat,
      cabang,
      alamat,
      username,
      notelpon,
      jabatan,
      ttd;
  String dataid,
      datanama,
      datakodesamsat,
      datacabang,
      dataalamat,
      datanotelpon,
      datajabatan;
  bool loading = false;
  _EditDataState(
      this.id,
      this.nama,
      this.kodesamsat,
      this.cabang,
      this.alamat,
      this.username,
      this.notelpon,
      this.jabatan,
      this.ttd);

  Connectivity connectivity = Connectivity();
  String statuskonek;

  keluar() {
    setState(() {
      widget.keluar();
    });
  }

  void checkConnectivity2() async {
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
        updateprofil();
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

  updateprofil() async {
    if (ttd == null) {
      responsegambar = await _uploadImage(_imageFile);
      if (responsegambar != null || responsegambar.containsKey("response")) {
        setState(() {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return RichAlertDialog(
                  //uses the custom alert dialog
                  alertTitle: richTitle("Sukses!"),
                  alertSubtitle: richSubtitle(
                      "Data berhasil di update, Silahkan login kembali!"),
                  alertType: RichAlertType.SUCCESS,
                  actions: <Widget>[
                    FlatButton(
                      child: Text("OK"),
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
                                  HomePageKepalacabang(keluar)),
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
      final response = await http
          .put('http://dtd.jasaraharjariau.com/api/profil/$id', body: {
        "kode_samsat": datakodesamsat,
        "cabang": datacabang,
        "alamat": dataalamat,
        "nama": datanama,
        "no_telpon": datanotelpon,
        "jabatan": datajabatan
      });
      json.decode(response.body);
      setState(() {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return RichAlertDialog(
                //uses the custom alert dialog
                alertTitle: richTitle("Sukses!"),
                alertSubtitle: richSubtitle(
                    "Data berhasil di update, Silahkan login kembali!"),
                alertType: RichAlertType.SUCCESS,
                actions: <Widget>[
                  FlatButton(
                    child: Text("OK"),
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
        loading = false;
      });
    }
  }

  // To store the file provided by the image_picker
  File _imageFile;

  // To track the file uploading state
  bool _isUploading = false;

  void _getImage(BuildContext context, ImageSource source) async {
    File image = await ImagePicker.pickImage(source: source);

    setState(() {
      _imageFile = image;
    });

    // Closes the bottom sheet
    Navigator.pop(context);
  }

  Future<Map<String, dynamic>> _uploadImage(File image) async {
    setState(() {
      _isUploading = true;
    });

    String baseUrl = 'http://dtd.jasaraharjariau.com/androids/profilttd.php';

    // Find the mime type of the selected file by looking at the header bytes of the file
    final mimeTypeData =
        lookupMimeType(image.path, headerBytes: [0xFF, 0xD8]).split('/');

    // Intilize the multipart request
    final imageUploadRequest =
        http.MultipartRequest('POST', Uri.parse(baseUrl));
    imageUploadRequest.fields['id'] = id;
    imageUploadRequest.fields['kode_samsat'] = datakodesamsat;
    imageUploadRequest.fields['cabang'] = datacabang;
    imageUploadRequest.fields['alamat'] = dataalamat;
    imageUploadRequest.fields['nama'] = datanama;
    imageUploadRequest.fields['no_telpon'] = datanotelpon;
    imageUploadRequest.fields['jabatan'] = datajabatan;

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

  Map<String, dynamic> responsegambar;

  void _resetState() {
    setState(() {
      _imageFile = null;
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(32.0))),
      title: Text("Edit Profil"),
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
                Text("Kode Samsat",
                    style: TextStyle(
                        fontFamily: "Poppins-Medium",
                        fontSize: ScreenUtil().setSp(26))),
                TextFormField(
                  initialValue: kodesamsat,
                  onSaved: (e) => datakodesamsat = e,
                  decoration: InputDecoration(
                      hintText: "Kode Samsat",
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 12.0)),
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(30),
                ),
                Text("Cabang",
                    style: TextStyle(
                        fontFamily: "Poppins-Medium",
                        fontSize: ScreenUtil().setSp(26))),
                TextFormField(
                  initialValue: cabang,
                  onSaved: (e) => datacabang = e,
                  decoration: InputDecoration(
                      hintText: "Kode Samsat",
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
                  initialValue: alamat,
                  onSaved: (e) => dataalamat = e,
                  decoration: InputDecoration(
                      hintText: "Alamat",
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 12.0),
                      suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              var datas = alamat;
                              final url =
                                  "https://www.google.com/maps/search/$datas";
                              if (canLaunch(url) != null) {
                                launch(url);
                              } else {
                                throw "Could not launch $url";
                              }
                            });
                          },
                          icon: Icon(Icons.map))),
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(30),
                ),
                Text("Nama",
                    style: TextStyle(
                        fontFamily: "Poppins-Medium",
                        fontSize: ScreenUtil().setSp(26))),
                TextFormField(
                  initialValue: nama,
                  validator: (e) {
                    if (e.isEmpty) {
                      return "Silahkan masukkan nama anda";
                    }
                  },
                  onSaved: (e) => datanama = e,
                  decoration: InputDecoration(
                      hintText: "Nama",
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
                  initialValue: notelpon,
                  onSaved: (e) => datanotelpon = e,
                  decoration: InputDecoration(
                      hintText: "No Telpon",
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 12.0)),
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(30),
                ),
                Text("Jabatan",
                    style: TextStyle(
                        fontFamily: "Poppins-Medium",
                        fontSize: ScreenUtil().setSp(26))),
                TextFormField(
                  initialValue: jabatan,
                  onSaved: (e) => datajabatan = e,
                  decoration: InputDecoration(
                      hintText: "Jabatan",
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 12.0)),
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(30),
                ),
                ttd == null
                    ? Text("Tanda Tangan",
                        style: TextStyle(
                            fontFamily: "Poppins-Medium",
                            fontSize: ScreenUtil().setSp(26)))
                    : SizedBox(
                        height: ScreenUtil().setHeight(15),
                      ),
                ttd == null
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
                        height: ScreenUtil().setHeight(15),
                      ),
              ],
            ),
          ),
        ),
      ),
      actions: <Widget>[
        ttd == null
            ? FlatButton(
                child: Text("TTD"),
                onPressed: () {
                  setState(() {
                    showDialog(
                        context: context, builder: (_) => Tandatangan(nama));
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
                      checkConnectivity2();
                    }
                  });
                },
              )
      ],
    );
  }
}
