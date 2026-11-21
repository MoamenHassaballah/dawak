import 'dart:convert';

import 'package:dawak/network/base_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('GET resolves endpoint against the configured base URL', () async {
    final client = MockClient((request) async {
      expect(
        request.url,
        Uri.parse('http://localhost:3001/auth/patient/signup'),
      );
      expect(request.method, 'GET');
      expect(request.headers['Accept'], 'application/json');
      return http.Response('{}', 200);
    });
    final api = BaseApi(client: client);
    addTearDown(api.close);

    final response = await api.get('/auth/patient/signup');

    expect(response.statusCode, 200);
  });

  test('GET sends a JSON body when supplied', () async {
    final client = MockClient((request) async {
      expect(request.method, 'GET');
      expect(request.headers['Content-Type'], 'application/json');
      expect(jsonDecode(request.body), {'id': 'patient-id'});
      return http.Response('{}', 200);
    });
    final api = BaseApi(client: client);
    addTearDown(api.close);

    final response = await api.get(
      '/patient/profile',
      body: {'id': 'patient-id'},
    );

    expect(response.statusCode, 200);
  });

  test('POST sends JSON and merges custom headers', () async {
    final requestBody = {'name': 'Patient'};
    final client = MockClient((request) async {
      expect(
        request.url,
        Uri.parse('http://localhost:3001/auth/patient/signup'),
      );
      expect(request.method, 'POST');
      expect(request.headers['Content-Type'], 'application/json');
      expect(request.headers['Authorization'], 'Bearer token');
      expect(jsonDecode(request.body), requestBody);
      return http.Response('{}', 201);
    });
    final api = BaseApi(client: client);
    addTearDown(api.close);

    final response = await api.post(
      '/auth/patient/signup',
      body: requestBody,
      headers: {'Authorization': 'Bearer token'},
    );

    expect(response.statusCode, 201);
  });
}
