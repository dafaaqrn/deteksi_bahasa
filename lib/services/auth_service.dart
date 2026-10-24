import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import 'api_config.dart';

class AuthUser {
  final int id;
  final String email;
  final String username;
  final String? photoUrl;
  final bool hasPassword;
  final bool hasGoogle;

  const AuthUser({
    required this.id,
    required this.email,
    required this.username,
    this.photoUrl,
    this.hasPassword = false,
    this.hasGoogle = false,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        id: json['id'] as int,
        email: json['email'] as String,
        username: json['username'] as String,
        photoUrl: json['photoUrl'] as String?,
        hasPassword: json['has_password'] as bool? ?? false,
        hasGoogle: json['has_google'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'username': username,
        'photoUrl': photoUrl,
        'has_password': hasPassword,
        'has_google': hasGoogle,
      };
}

/// Error yang pesannya aman ditampilkan langsung ke pengguna.
class AuthException implements Exception {
  final String message;
  final bool isCancelled;
  const AuthException(this.message, {this.isCancelled = false});

  @override
  String toString() => message;
}

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthService extends ChangeNotifier {
  AuthService._();
  static final AuthService instance = AuthService._();

  static const _tokenKey = 'access_token';
  static const _userKey = 'user_json';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AuthStatus _status = AuthStatus.unknown;
  AuthUser? _user;
  String? _token;
  bool _googleReady = false;

  AuthStatus get status => _status;
  AuthUser? get user => _user;
  String? get token => _token;

  /// Header siap pakai untuk endpoint yang butuh login.
  Map<String, String> get authHeaders => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  /// Dipanggil sekali saat app dibuka: baca sesi tersimpan.
  /// Kalau ada sesi, langsung dianggap login (app tetap bisa dipakai OFFLINE),
  /// lalu token dicek ke server di latar belakang.
  Future<void> init() async {
    try {
      _token = await _storage.read(key: _tokenKey);
      final userJson = await _storage.read(key: _userKey);
      if (_token != null && userJson != null) {
        _user = AuthUser.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
        _status = AuthStatus.authenticated;
        notifyListeners();
        unawaited(_verifyTokenInBackground());
        return;
      }
    } catch (_) {
      // data tersimpan rusak / tidak terbaca: anggap belum login
      await _clearLocal();
    }
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> register({
    required String email,
    required String username,
    required String password,
  }) async {
    final body = await _post('/api/auth/register', {
      'email': email,
      'username': username,
      'password': password,
    });
    await _saveSession(body);
  }

  Future<void> login({required String username, required String password}) async {
    final body = await _post('/api/auth/login', {
      'username': username,
      'password': password,
    });
    await _saveSession(body);
  }

  /// Login/daftar pakai Google. Dialog pilih akun ditangani package
  /// google_sign_in; id_token hasilnya dikirim ke backend untuk diverifikasi.
  Future<void> loginWithGoogle() async {
    if (ApiConfig.googleWebClientId.isEmpty) {
      throw const AuthException('Login Google belum dikonfigurasi di aplikasi.');
    }

    try {
      if (!_googleReady) {
        await GoogleSignIn.instance.initialize(
          serverClientId: ApiConfig.googleWebClientId,
        );
        _googleReady = true;
      }

      final account = await GoogleSignIn.instance.authenticate();
      // Sinkron di v7 google_sign_in, BUKAN Future — jangan ditambah 'await'.
      final idToken = account.authentication.idToken;
      if (idToken == null) {
        throw const AuthException('Google tidak mengembalikan token. Coba lagi.');
      }

      final body = await _post('/api/auth/google', {'id_token': idToken});
      await _saveSession(body);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw const AuthException('Login dibatalkan', isCancelled: true);
      }
      throw AuthException('Gagal login Google: ${e.description ?? e.code}');
    }
  }

  /// Logout selalu berhasil di HP, walau server tidak terjangkau.
  Future<void> logout() async {
    final currentToken = _token;
    await _clearLocal();
    _status = AuthStatus.unauthenticated;
    notifyListeners();

    if (currentToken != null) {
      try {
        await http
            .post(
              Uri.parse('${ApiConfig.baseUrl}/api/auth/logout'),
              headers: {'Authorization': 'Bearer $currentToken'},
            )
            .timeout(ApiConfig.timeout);
      } catch (_) {
        // Offline: token terhapus dari HP, tapi di server baru nonaktif saat kedaluwarsa (7 hari).
      }
    }

    if (_googleReady) {
      try {
        await GoogleSignIn.instance.signOut();
      } catch (_) {
        // tidak kritis, abaikan
      }
    }
  }

  /// Upload/ganti foto profil. Melempar AuthException kalau gagal.
  Future<void> uploadProfilePhoto(File imageFile) async {
    if (_token == null) {
      throw const AuthException('Belum login.');
    }

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/api/auth/me/photo'),
      );
      request.headers['Authorization'] = 'Bearer $_token';
      request.files.add(await http.MultipartFile.fromPath('photo', imageFile.path));

      final streamedResponse = await request.send().timeout(ApiConfig.timeout);
      final response = await http.Response.fromStream(streamedResponse);
      final decoded = _decode(response.body);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw AuthException(
          decoded['error']?.toString() ?? 'Gagal mengunggah foto (kode ${response.statusCode})',
        );
      }

      final userJson = decoded['user'];
      if (userJson is! Map<String, dynamic>) {
        throw const AuthException('Respons server tidak sesuai.');
      }

      _user = AuthUser.fromJson(userJson);
      try {
        await _storage.write(key: _userKey, value: jsonEncode(_user!.toJson()));
      } catch (_) {}
      notifyListeners();
    } on TimeoutException {
      throw const AuthException('Server tidak merespons. Pastikan backend berjalan.');
    } on SocketException {
      throw const AuthException(
        'Tidak bisa terhubung ke server. Pastikan HP dan laptop di WiFi yang sama.',
      );
    }
  }

  /// Ganti username. Melempar AuthException kalau gagal (format salah, sudah dipakai, dll).
  Future<void> updateUsername(String newUsername) async {
    if (_token == null) {
      throw const AuthException('Belum login.');
    }

    try {
      final response = await http
          .patch(
            Uri.parse('${ApiConfig.baseUrl}/api/auth/me/username'),
            headers: authHeaders,
            body: jsonEncode({'username': newUsername}),
          )
          .timeout(ApiConfig.timeout);

      final decoded = _decode(response.body);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw AuthException(
          decoded['error']?.toString() ?? 'Gagal mengubah username (kode ${response.statusCode})',
        );
      }

      final userJson = decoded['user'];
      if (userJson is! Map<String, dynamic>) {
        throw const AuthException('Respons server tidak sesuai.');
      }

      _user = AuthUser.fromJson(userJson);
      try {
        await _storage.write(key: _userKey, value: jsonEncode(_user!.toJson()));
      } catch (_) {}
      notifyListeners();
    } on TimeoutException {
      throw const AuthException('Server tidak merespons. Pastikan backend berjalan.');
    } on SocketException {
      throw const AuthException(
        'Tidak bisa terhubung ke server. Pastikan HP dan laptop di WiFi yang sama.',
      );
    } on http.ClientException {
      throw const AuthException(
        'Tidak bisa terhubung ke server. Pastikan HP dan laptop di WiFi yang sama.',
      );
    }
  }

  /// Ganti password (akun yang sudah punya password) atau tambahkan password
  /// pertama (akun yang daftar murni lewat Google). [currentPassword] boleh
  /// null kalau akun belum pernah punya password.
  Future<void> updatePassword({
    String? currentPassword,
    required String newPassword,
  }) async {
    if (_token == null) {
      throw const AuthException('Belum login.');
    }

    try {
      final response = await http
          .patch(
            Uri.parse('${ApiConfig.baseUrl}/api/auth/me/password'),
            headers: authHeaders,
            body: jsonEncode({
              if (currentPassword != null) 'current_password': currentPassword,
              'new_password': newPassword,
            }),
          )
          .timeout(ApiConfig.timeout);

      final decoded = _decode(response.body);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw AuthException(
          decoded['error']?.toString() ?? 'Gagal mengubah password (kode ${response.statusCode})',
        );
      }

      final userJson = decoded['user'];
      if (userJson is Map<String, dynamic>) {
        _user = AuthUser.fromJson(userJson);
        try {
          await _storage.write(key: _userKey, value: jsonEncode(_user!.toJson()));
        } catch (_) {}
        notifyListeners();
      }
    } on TimeoutException {
      throw const AuthException('Server tidak merespons. Pastikan backend berjalan.');
    } on SocketException {
      throw const AuthException(
        'Tidak bisa terhubung ke server. Pastikan HP dan laptop di WiFi yang sama.',
      );
    } on http.ClientException {
      throw const AuthException(
        'Tidak bisa terhubung ke server. Pastikan HP dan laptop di WiFi yang sama.',
      );
    }
  }

  /// Hapus akun secara permanen. Setelah berhasil, sesi lokal langsung
  /// dihapus dan status berubah jadi unauthenticated.
  Future<void> deleteAccount() async {
    if (_token == null) {
      throw const AuthException('Belum login.');
    }

    try {
      final response = await http
          .delete(
            Uri.parse('${ApiConfig.baseUrl}/api/auth/me'),
            headers: authHeaders,
          )
          .timeout(ApiConfig.timeout);

      final decoded = _decode(response.body);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw AuthException(
          decoded['error']?.toString() ?? 'Gagal menghapus akun (kode ${response.statusCode})',
        );
      }

      await _clearLocal();
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    } on TimeoutException {
      throw const AuthException('Server tidak merespons. Pastikan backend berjalan.');
    } on SocketException {
      throw const AuthException(
        'Tidak bisa terhubung ke server. Pastikan HP dan laptop di WiFi yang sama.',
      );
    } on http.ClientException {
      throw const AuthException(
        'Tidak bisa terhubung ke server. Pastikan HP dan laptop di WiFi yang sama.',
      );
    }
  }

  // ---------- internal ----------

  Future<void> _verifyTokenInBackground() async {
    try {
      final response = await http
          .get(Uri.parse('${ApiConfig.baseUrl}/api/auth/me'), headers: authHeaders)
          .timeout(ApiConfig.timeout);
      if (response.statusCode == 401) {
        // token kedaluwarsa / sudah di-logout dari tempat lain
        await _clearLocal();
        _status = AuthStatus.unauthenticated;
        notifyListeners();
      }
    } catch (_) {
      // offline atau server mati: biarkan tetap login
    }
  }

  Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> payload) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}$path'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(ApiConfig.timeout);

      final decoded = _decode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return decoded;
      }
      throw AuthException(
        decoded['error']?.toString() ?? 'Terjadi kesalahan (kode ${response.statusCode})',
      );
    } on TimeoutException {
      throw const AuthException('Server tidak merespons. Pastikan backend berjalan.');
    } on SocketException {
      throw const AuthException(
        'Tidak bisa terhubung ke server. Pastikan HP dan laptop di WiFi yang sama.',
      );
    } on http.ClientException {
      throw const AuthException(
        'Tidak bisa terhubung ke server. Pastikan HP dan laptop di WiFi yang sama.',
      );
    }
  }

  Map<String, dynamic> _decode(String body) {
    try {
      final decoded = jsonDecode(body);
      return decoded is Map<String, dynamic> ? decoded : {};
    } catch (_) {
      return {};
    }
  }

  Future<void> _saveSession(Map<String, dynamic> body) async {
    final token = body['access_token'];
    final userJson = body['user'];
    if (token is! String || userJson is! Map<String, dynamic>) {
      throw const AuthException('Respons server tidak sesuai.');
    }

    _token = token;
    _user = AuthUser.fromJson(userJson);
    try {
      await _storage.write(key: _tokenKey, value: token);
      await _storage.write(key: _userKey, value: jsonEncode(_user!.toJson()));
    } catch (_) {
      // gagal menyimpan: tetap login untuk sesi ini, hanya tidak bertahan setelah app ditutup
    }

    _status = AuthStatus.authenticated;
    notifyListeners();
  }

  Future<void> _clearLocal() async {
    _token = null;
    _user = null;
    try {
      await _storage.delete(key: _tokenKey);
      await _storage.delete(key: _userKey);
    } catch (_) {}
  }
}