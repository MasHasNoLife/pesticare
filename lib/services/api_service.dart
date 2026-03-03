import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ApiService {
  // Uses a dart define for easily running phone from university (e.g. --dart-define=BACKEND_URL=https://my-ngrok.app)
  // Fallback to 10.0.2.2 which is localhost for Android emulator. Change to actual IP for physical device on LAN.
  final String baseUrl;

  ApiService({this.baseUrl = const String.fromEnvironment('BACKEND_URL', defaultValue: 'http://10.0.2.2:8000')});

  Future<Map<String, dynamic>> predictDisease({
    required File imageFile,
  }) async {
    final String normalizedBaseUrl = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final uri = Uri.parse('$normalizedBaseUrl/analyze');
    final request = http.MultipartRequest('POST', uri);
    
    // Determine mime type basic logic
    final ext = imageFile.path.split('.').last.toLowerCase();
    final mediaType = (ext == 'png') ? MediaType('image', 'png') : MediaType('image', 'jpeg');
    
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        contentType: mediaType,
      ),
    );

    try {
      final response = await request.send().timeout(const Duration(seconds: 30));
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return json.decode(responseBody) as Map<String, dynamic>;
      } else {
        throw Exception('Server error: ${response.statusCode} - $responseBody');
      }
    } catch (e) {
      throw Exception('Network request failed: $e. Check your Ngrok URL and ensure the server is running.');
    }
  }
}

