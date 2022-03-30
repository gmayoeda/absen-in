import 'package:absenin/settingloc.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
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

  @override
  void initState() {
    getPref();
    getCurrentPosition();
    super.initState();
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 30.0),
                child: Image.asset(
                  'assets/img/attendance.png',
                  fit: BoxFit.cover,
                  height: 180,
                ),
              ),
            ),
            _approved == "Rejected"
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Text(
                      "Rejected!",
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 35,
                          fontWeight: FontWeight.bold),
                    ),
                  )
                : _approved == "Approved"
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: Text(
                          "Approved!",
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: 35,
                              fontWeight: FontWeight.bold),
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
                                    'Attendance rejected!\nyour distance is too far',
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
                            setState(() {
                              _approved = "Approved";
                            });

                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text('Status'),
                                  content: Text(
                                    'Your attendance is approved',
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
                          }
                        });
                      },
                      icon: new Icon(Icons.login),
                      label: new Text("Check-in"),
                      style: ElevatedButton.styleFrom(
                          shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(10.0),
                          ),
                          minimumSize: Size(300.0, 80.0))),
                ),
                SizedBox(width: 15),
                new Expanded(
                  child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
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
                        });
                      },
                      icon: new Icon(Icons.logout),
                      label: new Text("Check-out"),
                      style: ElevatedButton.styleFrom(
                          shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(10.0),
                          ),
                          minimumSize: Size(300.0, 80.0))),
                ),
              ],
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
