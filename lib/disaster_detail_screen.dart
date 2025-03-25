import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DisasterDetailScreen extends StatefulWidget {
  final String disasterName;

  const DisasterDetailScreen({super.key, required this.disasterName});

  @override
  _DisasterDetailScreenState createState() => _DisasterDetailScreenState();
}

class _DisasterDetailScreenState extends State<DisasterDetailScreen> {
  Map<String, dynamic>? disasterData;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDisasterData());
  }

  Future<void> _loadDisasterData() async {
    try {
      String jsonData = await DefaultAssetBundle.of(context).loadString('assets/disaster_info.json');
      Map<String, dynamic> data = json.decode(jsonData);
      
      setState(() {
        // Ensure key matching
        disasterData = data[widget.disasterName] ?? data[widget.disasterName.toLowerCase()];
      });
    } catch (e) {
      debugPrint("Error loading JSON: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (disasterData == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.disasterName),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.disasterName),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ Check if 'imagePath' exists before using it
              if (disasterData!['imagePath'] != null)
                Image.asset(disasterData!['imagePath'], height: 150, width: double.infinity, fit: BoxFit.contain),

              SizedBox(height: 10),
              Text(disasterData!['description'] ?? "No description available", 
                style: GoogleFonts.poppins(fontSize: 16)),
              
              SizedBox(height: 10),
              if (disasterData!['causes'] != null) ...[
                Text("Causes:", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
                _buildBulletPoints(disasterData!['causes']),
              ],

              SizedBox(height: 10),
              if (disasterData!['precautions'] != null) ...[
                Text("Precautions:", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
                _buildBulletPoints(disasterData!['precautions']),
              ],

              SizedBox(height: 10),
              if (disasterData!['dos_donts'] != null) ...[
                _buildDoDontsSection("Before", disasterData!['dos_donts']['before']),
                _buildDoDontsSection("During", disasterData!['dos_donts']['during']),
                _buildDoDontsSection("After", disasterData!['dos_donts']['after']),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBulletPoints(dynamic items) {
    if (items is List) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items.map((item) => Text("• $item", style: GoogleFonts.poppins(fontSize: 16))).toList(),
      );
    }
    return SizedBox(); // Return empty if no data
  }

  Widget _buildDoDontsSection(String title, dynamic data) {
    if (data == null || data is! Map) return SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$title:", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
        if (data['dos'] != null) _buildBulletPoints(data['dos']),
        if (data['donts'] != null) _buildBulletPoints(data['donts']),
      ],
    );
  }
}
