import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthUser {
  const AuthUser({required this.id, required this.name, required this.email});

  final String id;
  final String name;
  final String email;

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    email: json['email'] as String? ?? '',
  );
}

class AuthException implements Exception {
  const AuthException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class AuthService {
  AuthService({
    String? baseUrl,
    http.Client? client,
    FlutterSecureStorage? secureStorage,
  }) : _baseUrl = _normalizeBaseUrl(
         baseUrl ??
             const String.fromEnvironment(
               'WORKLOG_API_BASE_URL',
               defaultValue: '',
             ),
       ),
       _client = client ?? http.Client(),
       _storage = secureStorage ?? const FlutterSecureStorage();

  final String? _baseUrl;
  final http.Client _client;
  final FlutterSecureStorage _storage;

  static const _accessKey = 'worklog.auth.access';
  static const _refreshKey = 'worklog.auth.refresh';
  static const _userKey = 'worklog.auth.user';

  bool get isConfigured => _baseUrl != null;

  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    _requireConfigured();
    final data = await _post('auth/login', {
      'email': email.trim(),
      'password': password,
    });
    return _persistSession(data);
  }

  Future<AuthUser> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _requireConfigured();
    final data = await _post('auth/register', {
      'name': name.trim(),
      'email': email.trim(),
      'password': password,
    });
    return _persistSession(data);
  }

  Future<AuthUser?> restoreSession() async {
    if (!isConfigured) return null;

    final accessToken = await _storage.read(key: _accessKey);
    if (accessToken == null || accessToken.isEmpty) return null;

    try {
      return await me(accessToken: accessToken);
    } on AuthException catch (error) {
      if (error.statusCode != 401) rethrow;
      final refreshToken = await _storage.read(key: _refreshKey);
      if (refreshToken == null || refreshToken.isEmpty) {
        await clearLocalSession();
        return null;
      }
      try {
        final data = await _post('auth/refresh', {
          'refresh_token': refreshToken,
        });
        return await _persistSession(data);
      } on AuthException {
        await clearLocalSession();
        return null;
      }
    }
  }

  Future<AuthUser> me({String? accessToken}) async {
    _requireConfigured();
    final token = accessToken ?? await _storage.read(key: _accessKey);
    if (token == null || token.isEmpty) {
      throw const AuthException('Nema aktivne sesije.', statusCode: 401);
    }

    final response = await _client.get(
      _uri('auth/me'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );
    final data = _decode(response);
    final user = data['user'];
    if (user is! Map) {
      throw const AuthException('Poslužitelj je vratio neispravan profil.');
    }
    final authUser = AuthUser.fromJson(Map<String, dynamic>.from(user));
    await _storage.write(key: _userKey, value: jsonEncode(user));
    return authUser;
  }

  Future<void> logout() async {
    if (!isConfigured) {
      await clearLocalSession();
      return;
    }

    final accessToken = await _storage.read(key: _accessKey);
    final refreshToken = await _storage.read(key: _refreshKey);

    if (accessToken != null && accessToken.isNotEmpty) {
      try {
        await _client.post(
          _uri('auth/logout'),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
          body: jsonEncode({'refresh_token': refreshToken ?? ''}),
        );
      } catch (_) {
        // Lokalna odjava mora uspjeti i ako je poslužitelj nedostupan.
      }
    }

    await clearLocalSession();
  }

  Future<void> clearLocalSession() async {
    await Future.wait([
      _storage.delete(key: _accessKey),
      _storage.delete(key: _refreshKey),
      _storage.delete(key: _userKey),
    ]);
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await _client.post(
      _uri(path),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
    return _decode(response);
  }

  Map<String, dynamic> _decode(http.Response response) {
    Map<String, dynamic> data = {};
    if (response.body.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map) {
          data = Map<String, dynamic>.from(decoded);
        }
      } catch (_) {
        throw AuthException(
          'Poslužitelj je vratio neispravan odgovor.',
          statusCode: response.statusCode,
        );
      }
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AuthException(
        data['error'] as String? ?? 'Zahtjev nije uspio.',
        statusCode: response.statusCode,
      );
    }
    return data;
  }

  Future<AuthUser> _persistSession(Map<String, dynamic> data) async {
    final user = data['user'];
    final accessToken = data['access_token'];
    final refreshToken = data['refresh_token'];

    if (user is! Map ||
        accessToken is! String ||
        accessToken.isEmpty ||
        refreshToken is! String ||
        refreshToken.isEmpty) {
      throw const AuthException('Poslužitelj je vratio nepotpunu sesiju.');
    }

    final normalizedUser = Map<String, dynamic>.from(user);
    await Future.wait([
      _storage.write(key: _accessKey, value: accessToken),
      _storage.write(key: _refreshKey, value: refreshToken),
      _storage.write(key: _userKey, value: jsonEncode(normalizedUser)),
    ]);
    return AuthUser.fromJson(normalizedUser);
  }

  Uri _uri(String path) => Uri.parse('${_baseUrl!}/$path');

  void _requireConfigured() {
    if (!isConfigured) {
      throw const AuthException(
        'WORKLOG API nije konfiguriran. Postavi WORKLOG_API_BASE_URL pri buildanju aplikacije.',
      );
    }
  }

  static String? _normalizeBaseUrl(String raw) {
    final value = raw.trim().replaceAll(RegExp(r'/+$'), '');
    if (value.isEmpty) return null;
    final uri = Uri.tryParse(value);
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
      return null;
    }
    return value;
  }
}
