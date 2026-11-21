import 'dart:convert';

import 'package:dawak/network/api_endpoints.dart';
import 'package:http/http.dart' as http;

class BaseApi {
  BaseApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  final Uri _baseUri = Uri.parse(ApiEndpoints.baseUrl);

  Future<http.Response> get(
    String endpoint, {
    Object? body,
    Map<String, String>? headers,
  }) async {
    final request = http.Request('GET', _baseUri.resolve(endpoint))
      ..headers.addAll(_mergeHeaders(headers));
    if (body != null) {
      request.body = jsonEncode(body);
    }

    return http.Response.fromStream(await _client.send(request));
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

  Future<http.Response> patch(
    String endpoint, {
    Object? body,
    Map<String, String>? headers,
  }) {
    return _client.patch(
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
