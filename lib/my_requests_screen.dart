import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class MyRequestsScreen extends StatelessWidget {
  const MyRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('My Help Requests', style: GoogleFonts.poppins(fontSize: 20)),
        backgroundColor: Colors.blueAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('help_requests')
            .where('userId', isEqualTo: user?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No help requests found.',
                style: GoogleFonts.poppins(fontSize: 16),
              ),
            );
          }

          var requests = snapshot.data!.docs;
          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              var request = requests[index];
              String status = request['status'] ?? 'Pending';

              return Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  title: Text(
                    'Help Type: ${request['helpType']}',
                    style: GoogleFonts.poppins(fontSize: 16),
                  ),
                  subtitle: Text(
                    'Location: ${request['location']}\nStatus: $status',
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                  trailing: Icon(
                    status == 'Pending'
                        ? Icons.hourglass_empty
                        : status == 'Assigned'
                            ? Icons.assignment
                            : Icons.check_circle,
                    color: status == 'Fulfilled' ? Colors.green : Colors.orange,
                  ),
                  onTap: () {
                    _showRequestDetails(context, request);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showRequestDetails(BuildContext context, DocumentSnapshot request) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Request Details', style: GoogleFonts.poppins(fontSize: 18)),
          content: Text(
            'Help Type: ${request['helpType']}\n'
            'Location: ${request['location']}\n'
            'Requester: ${request['name']}\n'
            'Status: ${request['status']}',
            style: GoogleFonts.poppins(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close', style: GoogleFonts.poppins()),
            ),
          ],
        );
      },
    );
  }
}
