// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<dynamic> listData = [];
  List<Marker> myMarker = [];
  String addressAgunan = "", latAgunan = "", longAgunan = "";

  late LatLng currentLatLng = const LatLng(-6.200000, 106.816666);
  final Completer<GoogleMapController> _controller = Completer();

  Future<void> _determinePosition() async {
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      currentLatLng = LatLng(position.latitude, position.longitude);
    });
    return;
  }

  Future<void> _goToCurrentLocation() async {
    await _determinePosition();
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: currentLatLng, zoom: 14.0)));
  }

  Future<void> setLatLong() async {
    listData.add(latAgunan);
    listData.add(longAgunan);
    listData.add(addressAgunan);

    Navigator.pop(context);
    Navigator.pop(context, listData);
  }

  @override
  void initState() {
    super.initState();
    _goToCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: GoogleMap(
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
            initialCameraPosition:
                CameraPosition(target: currentLatLng, zoom: 14),
            markers: Set.from(myMarker),
            onTap: _handleTap,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
        ),
      ),
    );
  }

  _handleTap(LatLng tappedPoint) async {
    print(tappedPoint);
    setState(() {
      myMarker = [];
      myMarker.add(
        Marker(
          markerId: MarkerId(tappedPoint.toString()),
          position: tappedPoint,
        ),
      );
    });

    List<Placemark> newPlace = await placemarkFromCoordinates(
        tappedPoint.latitude, tappedPoint.longitude);
    print(newPlace);

    // this is all you need
    Placemark placeMark = newPlace[0];
    String street = placeMark.street.toString();
    String subLocality = placeMark.subLocality.toString();
    String locality = placeMark.locality.toString();
    String administrativeArea = placeMark.administrativeArea.toString();
    String postalCode = placeMark.postalCode.toString();
    String country = placeMark.country.toString();
    String address =
        "${street}, ${subLocality}, ${locality}, ${administrativeArea} ${postalCode}, ${country}";

    // print(address);

    setState(() {
      addressAgunan = address; // update _address
      latAgunan = tappedPoint.latitude.toString();
      longAgunan = tappedPoint.longitude.toString();
    });

    showModalBottomSheet<void>(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          height: 250,
          // color: Colors.amber,
          child: ListView(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Description",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Latitude :" + latAgunan,
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Longtitude :" + longAgunan,
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
                  ),
                  SizedBox(height: 5),
                  Text(
                    addressAgunan,
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          child: const Text('Get Location Office'),
                          onPressed: () {
                            setLatLong();
                          },
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
