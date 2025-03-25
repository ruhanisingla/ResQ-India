import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'location_service.dart'; 

class NeedHelpScreen extends StatefulWidget {
  final String? location;

  const NeedHelpScreen({super.key, this.location});

  @override
  _NeedHelpScreenState createState() => _NeedHelpScreenState();
}

class _NeedHelpScreenState extends State<NeedHelpScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _helpType = '';
  String? _location;
  bool _isFetchingLocation = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _location = widget.location;
    if (_location == null) {
      _fetchLocation();
    } else {
      _isFetchingLocation = false;
    }
  }

  Future<void> _fetchLocation() async {
    String? fetchedLocation = await LocationService.getCurrentLocation();
    setState(() {
      _location = fetchedLocation;
      _isFetchingLocation = false;
    });
  }

  Future<void> _submitHelpRequest() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();
    setState(() => _isSubmitting = true);

    try {
      User? user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance.collection('help_requests').add({
        'userId': user?.uid,
        'name': _name,
        'location': _location ?? 'Location unavailable',
        'helpType': _helpType,
        'status': 'Pending',
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Help request submitted successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting request: $e')),
      );
    }

    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text('Request Help', style: GoogleFonts.poppins()),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ✅ Image (Supports both SVG and JPG)
              SizedBox(
                height: 150,
                child: SvgPicture.asset(
                  'assets/help_illustration.svg', // Ensure the correct file type
                  height: 150,
                  fit: BoxFit.contain,
                  placeholderBuilder: (context) => Image.asset('assets/help_illustration.png', height: 150),
                ),
              ),
              SizedBox(height: 10),

              // ✅ Card for Form
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ✅ Name Field
                        Text('Your Name', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                        TextFormField(
                          validator: (value) => value!.isEmpty ? 'Enter your name' : null,
                          onSaved: (value) => _name = value!,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 10),
                          ),
                        ),
                        SizedBox(height: 12),

                        // ✅ Help Type (Text Input Instead of Dropdown)
                        Text('Type of Help Needed', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                        TextFormField(
                          validator: (value) => value!.isEmpty ? 'Enter the type of help needed' : null,
                          onSaved: (value) => _helpType = value!,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 10),
                          ),
                        ),
                        SizedBox(height: 12),

                        // ✅ Location
                        Text('Location:', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
                          child: _isFetchingLocation
                              ? Center(child: CircularProgressIndicator())
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(child: Text(_location ?? 'Unable to fetch location', style: GoogleFonts.poppins())),
                                    IconButton(
                                      icon: Icon(Icons.map, color: Colors.blue),
                                      onPressed: () {
                                        // TODO: Implement map view feature
                                      },
                                    ),
                                  ],
                                ),
                        ),
                        SizedBox(height: 20),

                        // ✅ Submit & Cancel Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _isSubmitting
                                ? CircularProgressIndicator()
                                : Expanded(
                                    child: ElevatedButton(
                                      onPressed: _submitHelpRequest,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.black,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        padding: EdgeInsets.symmetric(vertical: 15),
                                      ),
                                      child: Text('Submit Request', style: GoogleFonts.poppins()),
                                    ),
                                  ),
                            SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: EdgeInsets.symmetric(vertical: 15),
                                ),
                                child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.black)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}