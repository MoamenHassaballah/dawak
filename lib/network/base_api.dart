import 'dart:convert';

import 'package:dawak/network/api_endpoints.dart';
import 'package:http/http.dart' as http;

class BaseApi {
  BaseApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  final Uri _baseUri = Uri.parse(ApiEndpoints.baseUrl);

  Future<http.Response> get(String endpoint, {Map<String, String>? headers}) {
    return _client.get(
      _baseUri.resolve(endpoint),
      headers: _mergeHeaders(headers),
    );
  }

  Future<http.Response> post(
    String endpoint, {
    Object? body,
    Map<String, String>? headers,
  }) {
    return _client.post(
      _baseUri.resolve(endpoint),
      headers: _mergeHeaders(headers),
      body: body == null ? null : jsonEncode(body),
    );
  }

  Map<String, String> _mergeHeaders(Map<String, String>? headers) {
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      ...?headers,
    };
  }

  void close() {
    _client.close();
  }
}
