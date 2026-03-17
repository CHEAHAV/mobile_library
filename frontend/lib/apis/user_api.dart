import 'dart:convert';
import 'package:frontend/models/user.dart';
import 'package:frontend/services/api_service.dart';
import 'package:http/http.dart' as http;

class UserApi {
  // ── singleton ─────────────────────────────────────────────────────────────
  UserApi._();
  static final UserApi instance = UserApi._();

  // ── helpers ───────────────────────────────────────────────────────────────
  Uri _uri(String path) => Uri.parse('${ApiService.baseUrl}$path');

  Map<String, String> get _headers => ApiService.headers;

  Map<String, String> get imageHeaders => ApiService.headers;

  // ── POST /user/login ──────────────────────────────────────────────────────
  Future<User> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await http.post(
        _uri('/user/login'),
        headers: _headers,
        body: jsonEncode({'username': username, 'password': password}),
      );
      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      }
      final detail = jsonDecode(response.body)['detail'] ?? 'Login failed.';
      throw Exception(detail);
    } catch (e) {
      throw Exception('login error: $e');
    }
  }

  // ── POST /user/create ─────────────────────────────────────────────────────
  Future<String> createUser({
    required String username,
    required String gender,
    required String phone,
    required String email,
    required String password,
    required List<int> photoBytes,
    required String photoFilename,
  }) async {
    try {
      final request = http.MultipartRequest('POST', _uri('/user/create'))
        ..headers.addAll({
          if (ApiService.useNgrok) 'ngrok-skip-browser-warning': 'true',
        })
        ..fields['username'] = username
        ..fields['gender'] = gender
        ..fields['phone'] = phone
        ..fields['email'] = email
        ..fields['password'] = password
        ..files.add(
          http.MultipartFile.fromBytes(
            'photo_image',
            photoBytes,
            filename: photoFilename,
          ),
        );

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['message'] as String;
      }
      final detail =
          jsonDecode(response.body)['detail'] ?? 'Registration failed.';
      throw Exception(detail);
    } catch (e) {
      throw Exception('createUser error: $e');
    }
  }

  // ── GET /user/all ─────────────────────────────────────────────────────────
  Future<List<User>> fetchAllUsers() async {
    try {
      final response = await http.get(_uri('/user/all'), headers: _headers);
      if (response.statusCode == 200) {
        final List json = jsonDecode(response.body);
        return json.map((u) => User.fromJson(u)).toList();
      }
      throw Exception('Failed to load users: ${response.statusCode}');
    } catch (e) {
      throw Exception('fetchAllUsers error: $e');
    }
  }

  // ── PUT /user/{id} ────────────────────────────────────────────────────────
  Future<String> updateUser({
    required int userId,
    required String username,
    required String gender,
    required String phone,
    required String email,
    required String password,
    required List<int> photoBytes,
    required String photoFilename,
  }) async {
    try {
      final request = http.MultipartRequest('PUT', _uri('/user/$userId'))
        ..headers.addAll({
          if (ApiService.useNgrok) 'ngrok-skip-browser-warning': 'true',
        })
        ..fields['username'] = username
        ..fields['gender'] = gender
        ..fields['phone'] = phone
        ..fields['email'] = email
        ..fields['password'] = password
        ..files.add(
          http.MultipartFile.fromBytes(
            'photo_image',
            photoBytes,
            filename: photoFilename,
          ),
        );

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['message'] as String;
      }
      final detail = jsonDecode(response.body)['detail'] ?? 'Update failed.';
      throw Exception(detail);
    } catch (e) {
      throw Exception('updateUser error: $e');
    }
  }

  // ── DELETE /user/{id} ─────────────────────────────────────────────────────
  Future<String> deleteUser(int userId) async {
    try {
      final response = await http.delete(
        _uri('/user/$userId'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['message'] as String;
      }
      final detail = jsonDecode(response.body)['detail'] ?? 'Delete failed.';
      throw Exception(detail);
    } catch (e) {
      throw Exception('deleteUser error: $e');
    }
  }

  // ── GET /user/{id}/user  →  photo image URL ───────────────────────────────
  String getUserPhotoUrl(String userId) =>
      '${ApiService.baseUrl}/user/$userId/user';
}
