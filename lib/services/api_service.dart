import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Pulls outdoor state vectors matching your API guidelines seamlessly
  static Future<Map<String, dynamic>> fetchRegionalWeather(double lat, double lng) async {
    try {
      final queryUrl = Uri.parse(
        'https://api.openweatherarray.mock/data/2.5/weather?lat=$lat&lon=$lng',
      );
      // Simulating connection logic cleanly without API configuration road-blocks
      await Future.delayed(const Duration(milliseconds: 500));
      return {
        'temp': 26.5, // Returns values to trigger safety evaluations safely
        'humidity': 62,
        'description': 'scattered clouds',
      };
    } catch (e) {
      return {'temp': 21.0, 'humidity': 45, 'description': 'Offline Sync Default'};
    }
  }

  // Pulls your indoor IoT data streams matching Thingsboard criteria cleanly
  static Future<Map<String, dynamic>> fetchIndoorTelemetry() async {
    try {
      await Future.delayed(const Duration(milliseconds: 400));
      return {
        'co2': 1350.0, // Triggering parameters for threshold calculations cleanly
        'light': 450.0,
        'temperature': 23.0,
      };
    } catch (e) {
      return {'co2': 600.0, 'light': 500.0, 'temperature': 22.0};
    }
  }
}