import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'need_help_screen.dart';
import 'my_requests_screen.dart';
import 'give_help_screen.dart'; // ✅ Import GiveHelpScreen

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  _HelpScreenState createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ResQ", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          labelStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
          tabs: [
            Tab(text: "Need Help"), // ✅ Left-side tab
            Tab(text: "Give Help"), // ✅ Right-side tab
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNeedHelpTab(), // ✅ Left: Need Help
          GiveHelpScreen(),    // ✅ Right: Give Help
        ],
      ),
    );
  }

  // ✅ "Need Help" Tab Content with Image
  Widget _buildNeedHelpTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/need_help.svg', // ✅ Add this image in assets folder
              height: 200,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => NeedHelpScreen()));
              },
              child: Text("Request Help", style: GoogleFonts.poppins(fontSize: 14)),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => MyRequestsScreen()));
              },
              child: Text("Track My Requests", style: GoogleFonts.poppins(fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }
}
