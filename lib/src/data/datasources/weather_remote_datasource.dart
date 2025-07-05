import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherRemoteDatasource {
  Future<List<Map<String, dynamic>>> fetchWeatherList() async {
    final response = await http.get(Uri.parse('https://mocki.io/v1/b9607fd2-bd7a-484e-917f-a5e641ec6cc9'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e)).toList();
    } else {
      throw Exception('Failed to load weather');
    }
  }
} 