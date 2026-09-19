import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiFailure implements Exception {
  const ApiFailure(this.message, {this.requestId});
  final String message;
  final String? requestId;
}

class ApiClient {
  ApiClient(this.client, this.baseUri);
  final http.Client client;
  final Uri baseUri;
  Future<Map<String, dynamic>> get(String path) async {
    try {
      final response = await client
          .get(baseUri.resolve(path), headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 12));
      if (response.statusCode != 200) {
        throw ApiFailure(
          'The exhibition is temporarily unavailable.',
          requestId: response.headers['x-request-id'],
        );
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic> || decoded['data'] == null) {
        throw const FormatException('Missing response data');
      }
      return decoded;
    } on TimeoutException {
      throw const ApiFailure(
        'The connection is taking longer than expected. Please try again.',
      );
    } on http.ClientException {
      throw const ApiFailure(
        'We could not reach the exhibition. Check your connection.',
      );
    } on FormatException {
      throw const ApiFailure(
        'The exhibition could not be loaded. Please try again.',
      );
    }
  }
}
