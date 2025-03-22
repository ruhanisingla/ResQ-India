import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class MapsScreen extends StatefulWidget {
  const MapsScreen({super.key});

  @override
  _MapsScreenState createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  late GoogleMapController mapController;
  LatLng? _currentPosition;
  final Set<Marker> _markers = {};
  final String _apiKey = 'AIzaSyAMhk7_UnEk4BboQY85p2-tICqP67plkgA'; // Replace with your API Key
  List<Map<String, String>> _hospitalList = [];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("Location services are disabled.");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("Location permission denied.");
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      print("Location permission permanently denied.");
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
      );

      if (mounted) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
          _markers.add(
            Marker(
              markerId: MarkerId("current_location"),
              position: _currentPosition!,
              infoWindow: InfoWindow(title: "Your Location"),
            ),
          );
        });

        mapController.animateCamera(
          CameraUpdate.newLatLngZoom(_currentPosition!, 14),
        );

        _fetchNearbyHospitals();
      }
    } catch (e) {
      print("Error fetching location: $e");
    }
  }

  Future<void> _fetchNearbyHospitals() async {
    if (_currentPosition == null) {
      print("Current position is null.");
      return;
    }

    final String url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${_currentPosition!.latitude},${_currentPosition!.longitude}&radius=5000&type=hospital&key=$_apiKey';

    print("Fetching hospitals from: $url");

    try {
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);
      print("Google Places API Response: $data");

      if (data['status'] == 'OK') {
        List results = data['results'];
        Set<Marker> hospitalMarkers = results.map((place) {
          return Marker(
            markerId: MarkerId(place['place_id']),
            position: LatLng(
              place['geometry']['location']['lat'],
              place['geometry']['location']['lng'],
            ),
            infoWindow: InfoWindow(
              title: place['name'],
              snippet: place['vicinity'],
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          );
        }).toSet();

        List<Map<String, String>> hospitals = results.map<Map<String, String>>((place) {
          return {
            "name": place['name'] ?? "Unknown",
            "address": place['vicinity'] ?? "Address not available",
            "rating": place.containsKey('rating') ? place['rating'].toString() : 'N/A'
          };
        }).toList();

        if (mounted) {
          setState(() {
            _markers.addAll(hospitalMarkers);
            _hospitalList = hospitals;
          });

          _showHospitalsDialog(context);
        }
      } else {
        print("Google Places API Error: ${data['status']} - ${data['error_message'] ?? 'No error message'}");
      }
    } catch (e) {
      print("Error fetching hospitals: $e");
    }
  }

  void _showHospitalsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Nearby Hospitals"),
          content: SizedBox(
            width: double.maxFinite,
            child: _hospitalList.isEmpty
                ? Text("No hospitals found nearby.")
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _hospitalList.length,
                    itemBuilder: (context, index) {
                      final hospital = _hospitalList[index];
                      return ListTile(
                        leading: Icon(Icons.local_hospital, color: Colors.red),
                        title: Text(hospital['name']!),
                        subtitle: Text("${hospital['address']} • Rating: ${hospital['rating']}"),
                        onTap: () {
                          Navigator.pop(context);
                          _openGoogleMaps(hospital['address']!);
                        },
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }

  void _openGoogleMaps(String address) async {
    String googleMapsUrl = "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}";
    await launchUrl(Uri.parse(googleMapsUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Nearby Hospitals')),
      body: Stack(
        children: [
          _currentPosition == null
              ? Center(child: CircularProgressIndicator())
              : GoogleMap(
                  onMapCreated: (controller) => mapController = controller,
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition!,
                    zoom: 14.0,
                  ),
                  markers: _markers,
                  myLocationEnabled: true,
                ),
          Positioned(
            bottom: 80,
            right: 20,
            child: FloatingActionButton(
              onPressed: () {
                if (_hospitalList.isEmpty) {
                  print("No hospitals found.");
                } else {
                  _showHospitalsDialog(context);
                }
              },
              backgroundColor: Colors.blue,
              child: Icon(Icons.list),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: () {
                _fetchNearbyHospitals();
              },
              backgroundColor: Colors.green,
              child: Icon(Icons.refresh),
            ),
          ),
        ],
      ),
    );
  }
}
