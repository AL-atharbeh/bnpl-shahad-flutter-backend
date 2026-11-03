import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Same backend as the portal. Override at build time with
/// `--dart-define=API_URL=http://localhost:3000/api/v1`.
const String kApiBaseUrl = String.fromEnvironment(
  'API_URL',
  defaultValue: 'https://api.shahedapp.com/api/v1',
);

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

/// Thin JSON client. Carries the vendor token and reports an expired session
/// once, so the app can return to sign-in the way the portal does on a 401.
class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const _timeout = Duration(seconds: 30);

  String? token;
  VoidCallback? onUnauthorized;

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final params = <String, String>{};
    query?.forEach((key, value) {
      if (value != null) params[key] = value.toString();
    });
    return Uri.parse(
      '$kApiBaseUrl$path',
    ).replace(queryParameters: params.isEmpty ? null : params);
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) =>
      _send(() => _client.get(_uri(path, query), headers: _headers));

  Future<dynamic> post(String path, [Object? body]) => _send(
    () => _client.post(
      _uri(path),
      headers: _headers,
      body: body == null ? null : jsonEncode(body),
    ),
  );

  Future<dynamic> put(String path, Object body) => _send(
    () => _client.put(_uri(path), headers: _headers, body: jsonEncode(body)),
  );

  Future<dynamic> delete(String path) =>
      _send(() => _client.delete(_uri(path), headers: _headers));

  Future<dynamic> upload(
    String path,
    String filePath, {
    String field = 'file',
  }) {
    return _send(() async {
      final request = http.MultipartRequest('POST', _uri(path))
        ..headers.addAll({
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        })
        ..files.add(await http.MultipartFile.fromPath(field, filePath));
      return http.Response.fromStream(await _client.send(request));
    });
  }

  Future<dynamic> _send(Future<http.Response> Function() request) async {
    final http.Response response;
    try {
      response = await request().timeout(_timeout);
    } on SocketException {
      throw ApiException('network');
    } on TimeoutException {
      throw ApiException('network');
    } on http.ClientException {
      throw ApiException('network');
    }

    dynamic body;
    if (response.body.isNotEmpty) {
      try {
        body = jsonDecode(utf8.decode(response.bodyBytes));
      } on FormatException {
        body = response.body;
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) return body;

    if (response.statusCode == 401 && token != null) onUnauthorized?.call();
    throw ApiException(_messageFrom(body), statusCode: response.statusCode);
  }

  static String _messageFrom(dynamic body) {
    if (body is Map) {
      final message = body['message'];
      if (message is List) return message.join(', ');
      if (message is String && message.isNotEmpty) return message;
      final error = body['error'];
      if (error is String && error.isNotEmpty) return error;
    }
    return 'error';
  }
}
