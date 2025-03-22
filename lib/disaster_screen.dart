import 'package:flutter/material.dart';
import 'ambee_service.dart';

class DisasterScreen extends StatefulWidget {
  const DisasterScreen({super.key});

  @override
  _DisasterScreenState createState() => _DisasterScreenState();
}

class _DisasterScreenState extends State<DisasterScreen> {
  Map<String, dynamic>? disasterData;
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    try {
      final data = await AmbeeService().fetchDisasterData();
      if (data != null && data.containsKey('result')) {
        setState(() {
          disasterData = data;
          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching data: $e");
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Real-Time Disaster Alerts")),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading indicator
          : hasError
              ? Center(child: Text("Failed to fetch data. Please try again."))
              : (disasterData!['result'].isEmpty)
                  ? Center(child: Text("No disaster data available."))
                  : ListView.builder(
                      itemCount: disasterData!['result'].length,
                      itemBuilder: (context, index) {
                        var event = disasterData!['result'][index];

                        return Card(
                          margin: EdgeInsets.all(10),
                          child: ListTile(
                            title: Text("${event['event_name']} (${event['event_type']})"),
                            subtitle: Text(
                              "Location: ${event['lat'] ?? 'N/A'}, ${event['lng'] ?? 'N/A'}\n"
                              "Date: ${event['date'] ?? 'N/A'}\n"
                              "Magnitude: ${event['details']?['event_magnitude'] ?? 'N/A'}",
                            ),
                            trailing: Icon(Icons.warning, color: Colors.red),
                          ),
                        );
                      },
                    ),
    );
  }
}
