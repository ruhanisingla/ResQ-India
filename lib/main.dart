import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'auth_screen.dart';
import 'disaster_screen.dart';
import 'help_screen.dart';
import 'resources_screen.dart';
import 'disaster_map_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'location_service.dart'; // ✅ Import LocationService
import 'chatbot_screen.dart';
import 'disaster_detail_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ResQ India',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            return MyHomePage();
          }
          return AuthScreen();
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? userLocation = "Fetching location..."; // ✅ Default message
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    setState(() => isLoading = true);

    try {
      String location = await LocationService.getCurrentLocation();
      setState(() {
        userLocation = location;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        userLocation = "Error: ${e.toString()}";
        isLoading = false;
      });
    }
  }

  // ✅ Added missing _buildNavButton function
  Widget _buildNavButton(String title, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFFAF0E6), // Pale Beige
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      ),
      child: Text(
        title,
        style: GoogleFonts.poppins(fontSize: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ResQ India',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AuthScreen()),
              );
            },
            icon: Icon(Icons.logout, color: Colors.black),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DisasterScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                ),
                child: Text(
                  'View Disaster Alerts',
                  style: GoogleFonts.poppins(fontSize: 18),
                ),
              ),
            ),

            // 📍 Location Display
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "📍 Your Location: ${isLoading ? "Fetching location..." : userLocation}",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 180,
                      child: Image.asset(
                        'assets/family_safe.jpg',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    flex: 1,
                    child: Text(
                      '"Preparedness today ensures safety tomorrow."',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 15),

            // 🗺️ View Nearby Disasters Button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DisasterMapScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
              ),
              child: Text(
                'View Nearby Disasters',
                style: GoogleFonts.poppins(fontSize: 16),
              ),
            ),
            SizedBox(height: 20),

            // Help & Resources
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _buildNavButton('Help', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HelpScreen()),
                    );
                  }),
                  _buildNavButton('Emergency Contacts', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ResourcesScreen(),
                      ),
                    );
                  }),
                ],
              ),
            ),
            SizedBox(height: 20),

            // 🌪️ Disaster Guide Section (Added Below Help & Resources)
            Padding(
  padding: const EdgeInsets.all(16.0),
  child: Column(
    children: [
      Text(
        'Disaster Preparedness Guide',
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: 10),
      GridView.count(
        shrinkWrap: true,
        crossAxisCount: 3,
        physics: NeverScrollableScrollPhysics(),
        children: [
          _buildDisasterIcon('earthquake.png', 'Earthquake'),
          _buildDisasterIcon('flood.png', 'Flood'),
          _buildDisasterIcon('tsunami.png', 'Tsunami'),
          _buildDisasterIcon('cyclone.png', 'Cyclone'),
          _buildDisasterIcon('heatwave.png', 'Heat Wave'),
          _buildDisasterIcon('landslide.png', 'Landslide'),
        ],
      ),
    ],
  ),
),

            SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChatBotScreen()),
          );
        },
        backgroundColor: Colors.black,
        child: Icon(Icons.chat, color: Colors.white),
      ),
    );
  }

 Widget _buildDisasterIcon(String imageName, String label) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DisasterDetailScreen(disasterName: label), // ✅ Removed imagePath
        ),
      );
    },
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/$imageName',
          width: 50,
          height: 50,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Icon(Icons.error, size: 50, color: Colors.red), // ✅ Handles missing image
        ),
        SizedBox(height: 5),
        Text(label, style: GoogleFonts.poppins(fontSize: 14)),
      ],
    ),
  );
}



}
