import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:url_launcher/url_launcher.dart';

import 'api/http_service.dart';
import 'list/store_addess_list.dart';
import 'model/store_address.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<LocationScreen> {
  static const double _latitude = 6.4403574;
  static const double _longitude = 3.4554387;
  static const CameraPosition _defaultLocation =
      CameraPosition(target: LatLng(_latitude, _longitude), zoom: 15);
  MapType _currentMapType = MapType.normal;
  final Set<Marker> _markers = {};
  late final GoogleMapController _googleMapController;
  String markerTitle = "KFC Lekki Phase 1";
  String markerSubtitle = "KFC, Admiralty Way, Lekki Phase I, Lagos";

  double selectedLatitude = 6.4403574;
  double selectedLongitude = 3.4554387;

  void _changeMapType() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  void _addMarker() {
    setState(() {
      _markers.add(
        Marker(
            markerId: const MarkerId("defaultLocation"),
            position: _defaultLocation.target,
            icon: BitmapDescriptor.defaultMarker,
            infoWindow:
                InfoWindow(title: markerTitle, snippet: markerSubtitle)),
      );
    });
  }

  Future<void> _moveToNewLocation(String branchName, String address,
      double latitude, double longitude) async {
    LatLng newPosition = LatLng(latitude, longitude);
    _googleMapController
        .animateCamera(CameraUpdate.newLatLngZoom(newPosition, 15));

    setState(() {
      Marker marker = Marker(
          markerId: MarkerId(branchName),
          position: newPosition,
          icon: BitmapDescriptor.defaultMarker,
          infoWindow: InfoWindow(title: branchName, snippet: address));

      _markers
        ..clear()
        ..add(marker);
    });
  }

  late Future<List<StoreAddress>> storeAddressList;
  HttpService httpService = HttpService();

  Future<void> _getLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied) {
      // Handle denied permission
      return;
    }

    if (permission == LocationPermission.deniedForever) {
      // Handle denied forever permission
      return;
    }

    // Permission is granted or allowed while using the app
    try {
      _addMarker();
    } catch (e) {
      setState(() {
        //locationInfo = 'Error getting address: $e';
        //timeInfo = 'Error getting time';
      });
    }
  }

  @override
  void initState() {
    super.initState();

    _getLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 200),
                //google map
                child: GoogleMap(
                  onMapCreated: (controller) {
                    _googleMapController = controller;
                  },
                  initialCameraPosition: _defaultLocation,
                  mapType: _currentMapType,
                  markers: _markers,
                ),
              ),
              SlidingUpPanel(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  color: Colors.white70,
                  minHeight: 300,
                  maxHeight: 500,
                  panel: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 5,
                      ),
                      Container(
                        width: 100,
                        height: 2,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        "Store Addresses",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      FutureBuilder<List<StoreAddress>>(
                        future: httpService.getStoreAddresses(),
                        builder: (BuildContext context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.connectionState ==
                              ConnectionState.none) {
                            return const Center(
                              child: Text('An error occurred!'),
                            );
                          } else if (snapshot.connectionState ==
                              ConnectionState.done) {
                            if (snapshot.hasData) {
                              if (snapshot.error != null) {
                                // ...
                                // Do error handling stuff
                                return const Center(
                                  child: Text('An error occurred!'),
                                );
                              } else {
                                List<StoreAddress> storeAddressList =
                                    snapshot.data!;

                                return Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 50),
                                    child: ListView.builder(
                                      padding: const EdgeInsets.all(4.0),
                                      itemCount: storeAddressList.length,
                                      shrinkWrap: true,
                                      itemBuilder: (context, index) {
                                        var storeAddress =
                                            storeAddressList[index];
                                        return GestureDetector(
                                            onTap: () {
                                              _moveToNewLocation(
                                                  storeAddress.name!,
                                                  storeAddress.address!,
                                                  double.parse(
                                                      storeAddress.latitude!),
                                                  double.parse(
                                                      storeAddress.longitude!));

                                              setState(() {
                                                selectedLatitude = double.parse(
                                                    storeAddress.latitude!);
                                                selectedLongitude =
                                                    double.parse(storeAddress
                                                        .longitude!);
                                              });
                                            },
                                            child: StoreAddressListItem(
                                                storeAddress: storeAddress));
                                      },
                                    ),
                                  ),
                                );
                              }
                            } else {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                          }
                          return const Text("");
                        },
                      )
                    ],
                  )),
              Positioned(
                top: 10,
                right: 10,
                child: FloatingActionButton(
                  onPressed: () {
                    Navigator.pop(context);
                    launchMaps(selectedLatitude, selectedLongitude);
                  },
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: const Icon(
                    Icons.directions_car,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }

  void launchMaps(double latitude, double longitude) async {
    String url =
        'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude';
    Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }
}
