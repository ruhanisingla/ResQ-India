import 'dart:convert';
import 'package:http/http.dart' as http;

class AmbeeService {
  final String apiKey = "";  // Replace with your Ambee API Key
  final String baseUrl = "https://api.ambeedata.com/disasters/latest/by-country-code?countryCode=IND&limit=50&page=1";

  Future<Map<String, dynamic>?> fetchDisasterData() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          "x-api-key": apiKey,
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        print("API Response: $jsonResponse");  // Debugging step
        return jsonResponse;
      } else {
        print("Failed to fetch disaster data: ${response.statusCode}, Response: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error fetching disaster data: $e");
      return null;
    }
  }
}
