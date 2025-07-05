import 'dart:convert';
import 'package:http/http.dart' as http;

class ImageRemoteDatasource {
  Future<List<String>> fetchImages() async {
    final response = await http.get(Uri.parse('https://mocki.io/v1/a5d4cf16-1f36-4f2b-b5cd-89772a83e999'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.cast<String>();
    } else {
      throw Exception('Failed to load images');
    }
  }
} 