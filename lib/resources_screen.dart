import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class ResourcesScreen extends StatelessWidget {
  const ResourcesScreen({super.key});

  // Function to open the phone dialer
  void _callNumber(String number) async {
    final Uri phoneUri = Uri(scheme: "tel", path: number);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Could not launch $number");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Emergency Contacts',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "📞 Emergency Contact Numbers",
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // List of Emergency Contacts
            Expanded(
              child: ListView(
                children: [
                  _buildContactTile("🚔 Police", "100"),
                  _buildContactTile("🚒 Fire Brigade", "101"),
                  _buildContactTile("🚑 Ambulance", "102"),
                  _buildContactTile("🚨 Disaster Management", "108"),
                  _buildContactTile("👩‍⚕️ Medical Helpline", "104"),
                  _buildContactTile("🌍 National Disaster Response Force (NDRF)", "011-24363260"),
                  _buildContactTile("📞 Disaster Relief NGO", "1800-111-555"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to create emergency contact tiles
  Widget _buildContactTile(String title, String phoneNumber) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.phone, color: Colors.green),
        title: Text(title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
        subtitle: Text(phoneNumber, style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54)),
        trailing: const Icon(Icons.call, color: Colors.green),
        onTap: () => _callNumber(phoneNumber),
      ),
    );
  }
}
