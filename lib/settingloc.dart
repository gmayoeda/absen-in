// ignore_for_file: unused_import

import 'package:absenin/home.dart';
import 'package:absenin/maps.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class settingLocation extends StatefulWidget {
  settingLocation({Key? key}) : super(key: key);

  @override
  State<settingLocation> createState() => _settingLocationState();
}

class _settingLocationState extends State<settingLocation> {
  final _key = new GlobalKey<FormState>();

  late SharedPreferences sharedPreferences;

  TextEditingController lat = TextEditingController();
  TextEditingController long = TextEditingController();
  TextEditingController alamat = TextEditingController();

  // void getCurrentPosition() async {
  //   LocationPermission permission = await Geolocator.checkPermission();

  //   if (permission == LocationPermission.denied ||
  //       permission == LocationPermission.deniedForever) {
  //     print("Permissions not given");
  //     // ignore: unused_local_variable
  //     LocationPermission asked = await Geolocator.requestPermission();
  //   } else {
  //     Position currentPosition = await Geolocator.getCurrentPosition(
  //         desiredAccuracy: LocationAccuracy.best);

  //     setState(() {
  //       lat = TextEditingController(text: currentPosition.latitude.toString());
  //       long =
  //           TextEditingController(text: currentPosition.longitude.toString());
  //     });
  //   }
  // }

  Future<void> _navigateAndDisplaySelection(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MapScreen()),
    );
    if (!mounted) return;
    print("====================================================");
    print(result);

    if (result != null) {
      setState(() {
        lat = TextEditingController(text: result[0]);
        long = TextEditingController(text: result[1]);
        alamat = TextEditingController(text: result[2]);
      });
    }
  }

  void savePref() async {
    if (lat.text == "" || long.text == "") {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Alert'),
            content: Text(
              'add Latitude & Longitude Office!',
              style: TextStyle(fontWeight: FontWeight.w400),
            ),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Close')),
            ],
          );
        },
      );
    } else {
      sharedPreferences = await SharedPreferences.getInstance();
      sharedPreferences.setString("latSave", lat.text);
      sharedPreferences.setString("longSave", long.text);
      sharedPreferences.setString("alamat", alamat.text);
    }
  }

  getPref() async {
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      lat = TextEditingController(text: sharedPreferences.getString("latSave"));
      long =
          TextEditingController(text: sharedPreferences.getString("longSave"));
      alamat =
          TextEditingController(text: sharedPreferences.getString("alamat"));
    });
  }

  clear() {
    lat.clear();
    long.clear();
    sharedPreferences.clear();
  }

  init() async {
    await getPref();
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text("Setting Location"),
        leading: InkWell(
          child: Icon(Icons.arrow_back_ios),
          onTap: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => MyHomePage(),
              ),
              (route) => false,
            );
          },
        ),
      ),
      body: Form(
        key: _key,
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: Colors.white,
                    ),
                    padding: EdgeInsets.only(left: 10),
                    child: TextFormField(
                      // enabled: false,
                      controller: lat,
                      validator: (e) {
                        if (e!.isEmpty) {
                          return "Null Latitude";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.location_on),
                        hintText: 'latitude',
                        contentPadding:
                            EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 0.0),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: Colors.white,
                    ),
                    padding: EdgeInsets.only(left: 10),
                    child: TextFormField(
                      // enabled: false,
                      controller: long,
                      validator: (e) {
                        if (e!.isEmpty) {
                          return "Null Longitude";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.location_on),
                        hintText: 'longitude',
                        contentPadding:
                            EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 0.0),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: Colors.white,
                    ),
                    padding: EdgeInsets.only(left: 10),
                    child: TextFormField(
                      // enabled: false,
                      maxLines: null,
                      controller: alamat,
                      validator: (e) {
                        if (e!.isEmpty) {
                          return "Null Alamat";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.house_rounded),
                        hintText: 'Alamat',
                        contentPadding:
                            EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  InkWell(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_searching,
                          color: Colors.blue,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Set Location",
                          style: TextStyle(
                              color: Colors.blue, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    onTap: () {
                      // getCurrentPosition();
                      _navigateAndDisplaySelection(context);
                    },
                  ),
                  SizedBox(height: 40),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    // mainAxisSize: MainAxisSize.,
                    children: [
                      new Expanded(
                        child: ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                savePref();
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        MyHomePage(),
                                  ),
                                  (route) => false,
                                );
                              });
                            },
                            icon: new Icon(Icons.check_box),
                            label: new Text("Save Location"),
                            style: ElevatedButton.styleFrom(
                                shape: new RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(10.0),
                                ),
                                minimumSize: Size(300.0, 45.0))),
                      ),
                      SizedBox(width: 15),
                      new Expanded(
                        child: ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                clear();
                              });
                            },
                            icon: new Icon(Icons.clear),
                            label: new Text("Clear Location"),
                            style: ElevatedButton.styleFrom(
                                shape: new RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(10.0),
                                ),
                                minimumSize: Size(300.0, 45.0))),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
