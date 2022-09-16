// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:absenin/settingloc.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  // final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String latOffice = "",
      longOffice = "",
      curLat = "",
      curLong = "",
      jarak = "0",
      _approved = "";
  bool absenToday = false;

  late SharedPreferences sharedPreferences;

  getPref() async {
    sharedPreferences = await SharedPreferences.getInstance();

    if (sharedPreferences.getString("latSave") == null) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Location'),
            content: Text(
              'Check Location Office!',
              style: TextStyle(fontWeight: FontWeight.w400),
            ),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => settingLocation()));
                  },
                  child: Text('Setting')),
            ],
          );
        },
      );
    } else {
      setState(() {
        latOffice = sharedPreferences.getString("latSave")!;
        longOffice = sharedPreferences.getString("longSave")!;
      });
      print("LatitudeOffice: " + latOffice);
      print("LongitudeOffice: " + longOffice);
    }
  }

  void getCurrentPosition() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      print("Permissions not given");
      // ignore: unused_local_variable
      LocationPermission asked = await Geolocator.requestPermission();
    } else {
      Position currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);

      setState(() {
        curLat = currentPosition.latitude.toString();
        curLong = currentPosition.longitude.toString();
      });

      print("Latitude: " + curLat);
      print("Longitude: " + curLong);

      if (latOffice != "" && longOffice != "") {
        double distanceInMeters = Geolocator.distanceBetween(
            double.parse(latOffice),
            double.parse(longOffice),
            double.parse(curLat),
            double.parse(curLong));

        setState(() {
          jarak = distanceInMeters.toString();
        });

        print(distanceInMeters);
      }
    }
  }

  String formatJam(String tanggal) {
    if (tanggal != "") {
      DateTime dt = DateTime.parse(tanggal);
      String jam = DateFormat('HH:mm').format(dt);

      return '$jam WIB';
    } else {
      return "- : -";
    }
  }

  List _listAttendance = [
    {
      "Nama": "John Sumargo",
      "Tanggal": "14/09/2022",
      "Jam Masuk": "08:53 WIB",
      "Jam Pulang": "17:25 WIB"
    },
    {
      "Nama": "John Sumargo",
      "Tanggal": "15/09/2022",
      "Jam Masuk": "08:59 WIB",
      "Jam Pulang": "17:03 WIB"
    }
  ];

  @override
  void initState() {
    getPref();
    getCurrentPosition();
    super.initState();
    print(_listAttendance);
    print(_listAttendance.length);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("ABSEN-in"),
        actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: InkWell(
              child: Icon(Icons.settings),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => settingLocation())),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome back, John Sumargo!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Image.asset(
                  'assets/img/attendance.png',
                  fit: BoxFit.cover,
                  height: 150,
                ),
              ),
            ),
            _approved == "Rejected"
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Center(
                      child: Text(
                        "Rejected!",
                        style: TextStyle(
                            color: Colors.red,
                            fontSize: 35,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                : _approved == "Approved"
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: Center(
                          child: Text(
                            "Approved!",
                            style: TextStyle(
                                color: Colors.green,
                                fontSize: 35,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      )
                    : Text(""),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              // mainAxisSize: MainAxisSize.,
              children: [
                new Expanded(
                  child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          getCurrentPosition();

                          if (num.parse(jarak) > int.parse('50')) {
                            setState(() {
                              _approved = "Rejected";
                            });

                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text('Status'),
                                  content: Text(
                                    'Attendance rejected!\nyour distance is too far, ' +
                                        double.parse(jarak).round().toString() +
                                        ' m',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w400),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text('Back')),
                                  ],
                                );
                              },
                            );
                          } else {
                            if (absenToday == false) {
                              _listAttendance.add({
                                "Nama": "John Sumargo",
                                "Tanggal": DateFormat("dd/MM/yyyy")
                                    .format(DateTime.now()),
                                "Jam Masuk":
                                    formatJam(DateTime.now().toString()),
                                "Jam Pulang": "--:-- WIB"
                              });

                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text('Status'),
                                    content: Text(
                                      'Your attendance is approved,\nyour distance ' +
                                          double.parse(jarak)
                                              .round()
                                              .toString() +
                                          ' m',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400),
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text('Back')),
                                    ],
                                  );
                                },
                              );
                            } else {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text('Warning'),
                                    content: Text(
                                      'Your attendance today is done!',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400),
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text('Back')),
                                    ],
                                  );
                                },
                              );
                            }

                            setState(() {
                              _approved = "Approved";
                              absenToday = true;
                            });
                          }
                        });
                      },
                      icon: new Icon(Icons.login),
                      label: new Text("Check-in"),
                      style: ElevatedButton.styleFrom(
                          shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(10.0),
                          ),
                          minimumSize: Size(300.0, 60.0))),
                ),
                SizedBox(width: 15),
                new Expanded(
                  child: ElevatedButton.icon(
                      onPressed: () {
                        _listAttendance[2]["Jam Pulang"] =
                            formatJam(DateTime.now().toString());

                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('Status'),
                              content: Text(
                                'Attendance Cleared!',
                                style: TextStyle(fontWeight: FontWeight.w400),
                              ),
                              actions: <Widget>[
                                TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _approved = "";
                                      });
                                      Navigator.pop(context);
                                    },
                                    child: Text('Back')),
                              ],
                            );
                          },
                        );
                      },
                      icon: new Icon(Icons.logout),
                      label: new Text("Check-out"),
                      style: ElevatedButton.styleFrom(
                          shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(10.0),
                          ),
                          minimumSize: Size(300.0, 60.0))),
                ),
              ],
            ),
            SizedBox(height: 30),
            Expanded(
              child: ListView.builder(
                itemCount: _listAttendance.length,
                itemBuilder: (context, i) {
                  final x = _listAttendance[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Container(
                      // margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        // border: Border.all(
                        //     width: 0.5, color: Colors.grey.withOpacity(0.2)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            blurRadius: 5.0,
                            offset: Offset(0.0, 2.0),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(x['Tanggal']),
                                Text(
                                  x['Nama'],
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Masuk   :  ${x['Jam Masuk']}",
                                      style: TextStyle(color: Colors.green),
                                    ),
                                    Text(
                                      "Keluar   :  ${x['Jam Pulang']}",
                                      style: TextStyle(color: Colors.red),
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
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Text(
          "ABSEN-in version 1.0",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[300]),
        ),
      ),
    );
  }
}
