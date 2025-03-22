import 'dart:convert';
import 'package:http/http.dart' as http;

class AmbeeService {
  final String apiKey = "ee85c0683ae2b9ca6d87d082af3323d1b8f9c8f2e118f55d3d95cee2e5a9c7cb";  // Replace with your Ambee API Key
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
