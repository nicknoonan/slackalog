import 'dart:convert';
import 'package:http/http.dart' as http;

abstract class IAPIClient {
  Future<Map<String, dynamic>> get(String path);
  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> data);
  // Add other HTTP methods as needed (put, delete, etc.)
}

class APIClient implements IAPIClient {
  final String baseUrl;
  final Map<String, String> defaultHeaders;
  final http.Client _client = http.Client(); // Use a persistent client

  APIClient({
    required this.baseUrl,
    this.defaultHeaders = const {'Content-Type': 'application/json'},
  });

  Uri _getUrl(String path, [Map<String, dynamic>? queryParameters]) {
    return Uri.parse('$baseUrl$path').replace(
        queryParameters: queryParameters);
  }

  Future<Map<String, dynamic>> get(String path) async {
    final response = await _client.get(
      _getUrl(path),
      headers: defaultHeaders,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> data) async {
    final response = await _client.post(
      _getUrl(path),
      headers: defaultHeaders,
      body: jsonEncode(data), // Encode data to JSON string
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to post data: ${response.statusCode}');
    }
  }

  // Add put, delete, etc. methods...
}
