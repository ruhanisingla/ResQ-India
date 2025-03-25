import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'location_service.dart';
import 'google_map_screen.dart';
import 'VolunteerSignInScreen.dart';

class GiveHelpScreen extends StatefulWidget {
  const GiveHelpScreen({super.key});

  @override
  _GiveHelpScreenState createState() => _GiveHelpScreenState();
}

class _GiveHelpScreenState extends State<GiveHelpScreen> {
  String? _volunteerLocation;
  bool _isFetchingLocation = false;
  User? _user;
  bool _isCheckingAuth = true;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  void _checkAuthentication() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => VolunteerSignInScreen()),
        );
      } else {
        setState(() {
          _user = user;
          _isCheckingAuth = false;
        });
        _fetchLocation();
      }
    });
  }

  Future<void> _fetchLocation() async {
    if (_isFetchingLocation) return;
    setState(() => _isFetchingLocation = true);

    String? fetchedLocation = await LocationService.getCurrentLocation();
    setState(() {
      _volunteerLocation = fetchedLocation;
      _isFetchingLocation = false;
    });
  }

  Future<void> _acceptRequest(String requestId, String requesterLocation) async {
    if (_user == null) return;

    try {
      await FirebaseFirestore.instance.collection('help_requests').doc(requestId).update({
        'status': 'Assigned',
        'volunteerId': _user!.uid,
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GoogleMapScreen(
            volunteerLocation: _volunteerLocation!,
            requesterLocation: requesterLocation,
            requestId: requestId,
          ),
        ),
      );
    } catch (e) {
      _showErrorSnackbar('Error assigning request: $e');
    }
  }

  Future<void> _markRequestFulfilled(String requestId) async {
    try {
      await FirebaseFirestore.instance.collection('help_requests').doc(requestId).update({
        'status': 'Fulfilled',
      });

      _showSuccessSnackbar('Request marked as fulfilled!');
    } catch (e) {
      _showErrorSnackbar('Error updating request status: $e');
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: GoogleFonts.poppins(color: Colors.white))),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: GoogleFonts.poppins(color: Colors.white))),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingAuth) {
      return const Center(child: CircularProgressIndicator());
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('help_requests')
          .where('status', whereIn: ['Pending', 'Assigned'])
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildNoRequestsMessage();
        }

        var requests = snapshot.data!.docs.where((doc) {
          String status = doc['status'];
          return status == 'Pending' || (status == 'Assigned' && doc['volunteerId'] == _user?.uid);
        }).toList();

        if (requests.isEmpty) {
          return _buildNoRequestsMessage();
        }

        return ListView.builder(
          itemCount: requests.length,
          itemBuilder: (context, index) {
            var request = requests[index];
            String requestId = request.id;
            String requesterLocation = request['location'];
            String helpType = request['helpType'];
            String requesterName = request['name'];
            String status = request['status'];

            return Card(
              margin: const EdgeInsets.all(10),
              child: ListTile(
                title: Text(
                  'Help Type: $helpType',
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Requested by: $requesterName\nLocation: $requesterLocation\nStatus: $status',
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (status == 'Pending')
                      ElevatedButton(
                        onPressed: () => _acceptRequest(requestId, requesterLocation),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: Text('Accept', style: GoogleFonts.poppins()),
                      ),
                    if (status == 'Assigned' && request['volunteerId'] == _user?.uid)
                      ElevatedButton(
                        onPressed: () => _markRequestFulfilled(requestId),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                        child: Text('Mark Fulfilled', style: GoogleFonts.poppins()),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ✅ UI for "No Requests Available"
  Widget _buildNoRequestsMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ✅ Ensure asset exists; otherwise, show an error-safe fallback
          SvgPicture.asset(
            'assets/no_requests.svg',
            height: 180,
            fit: BoxFit.contain,
            semanticsLabel: 'No requests available',
            placeholderBuilder: (context) => const CircularProgressIndicator(),
          ),
          const SizedBox(height: 20),
          Text(
            "No requests available at the moment.",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          Text(
            "Check back later to assist those in need.",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}