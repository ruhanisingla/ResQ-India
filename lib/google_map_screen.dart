import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart'; // ✅ For opening Google Maps

class GoogleMapScreen extends StatefulWidget {
  final String volunteerLocation;
  final String requesterLocation;
  final String requestId; // ✅ Accept request ID

  const GoogleMapScreen({
    required this.volunteerLocation,
    required this.requesterLocation,
    required this.requestId, // ✅ Include in constructor
    super.key,
  });

  @override
  _GoogleMapScreenState createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  GoogleMapController? _mapController;
  late LatLng _volunteerPosition;
  late LatLng _requesterPosition;
  Map<String, dynamic>? requestDetails; // ✅ Store request details

  @override
  void initState() {
    super.initState();
    _volunteerPosition = _parseLatLng(widget.volunteerLocation);
    _requesterPosition = _parseLatLng(widget.requesterLocation);
    _fetchRequestDetails(); // ✅ Fetch request details
  }

  /// ✅ Parse location safely
  LatLng _parseLatLng(String location) {
    try {
      List<String> parts = location.split(',');
      return LatLng(
        double.parse(parts[0].trim()),
        double.parse(parts[1].trim()),
      );
    } catch (e) {
      print("Error parsing location: $e");
      return const LatLng(0, 0); // Default fallback
    }
  }

  /// ✅ Fetch request details from Firestore
  Future<void> _fetchRequestDetails() async {
    try {
      DocumentSnapshot doc =
          await FirebaseFirestore.instance
              .collection('help_requests')
              .doc(widget.requestId)
              .get();

      if (doc.exists && doc.data() != null) {
        // ✅ Check if data exists
        setState(() {
          requestDetails = doc.data() as Map<String, dynamic>;
        });
      } else {
        print("Request details not found.");
      }
    } catch (e) {
      print("Error fetching details: $e");
    }
  }

  /// ✅ Mark request as completed
  Future<void> _markRequestFulfilled() async {
    try {
      await FirebaseFirestore.instance
          .collection('help_requests')
          .doc(widget.requestId)
          .update({'status': 'Completed'});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request marked as fulfilled!')),
      );

      Navigator.pop(context); // ✅ Return to previous screen
    } catch (e) {
      print("Error updating Firestore: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update request. Try again.')),
      );
    }
  }

  /// ✅ Open Google Maps for navigation
  Future<void> _openGoogleMaps() async {
    final String googleMapsUrl =
        "https://www.google.com/maps/dir/?api=1&destination=${_requesterPosition.latitude},${_requesterPosition.longitude}";

    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open Google Maps")),
      );
    }
  }

  /// ✅ Show request details in a bottom sheet
  void _showRequestDetails() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        if (requestDetails == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Requester: ${requestDetails?['name'] ?? 'Unknown'}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Help Type: ${requestDetails?['helpType'] ?? 'N/A'}",
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Text(
                "Status: ${requestDetails?['status'] ?? 'Pending'}",
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Navigation to Requester')),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _volunteerPosition,
              zoom: 14.0,
            ),
            markers: {
              Marker(
                markerId: const MarkerId('volunteer'),
                position: _volunteerPosition,
              ),
              Marker(
                markerId: const MarkerId('requester'),
                position: _requesterPosition,
              ),
            },
            onMapCreated: (controller) {
              setState(() {
                _mapController = controller;
              });
            },
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: _showRequestDetails, // ✅ Show details
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: const Text('Show Details'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _openGoogleMaps, // ✅ Open Google Maps
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: const Text('Get Directions'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed:
                      _markRequestFulfilled, // ✅ Mark request as fulfilled
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('Request Fulfilled'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
