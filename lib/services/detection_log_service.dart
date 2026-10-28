import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_config.dart';

class DetectionLogEntry {
  final int id;
  final String predictedWord;
  final double? confidence;
  final DateTime createdAt;

  const DetectionLogEntry({
    required this.id,
    required this.predictedWord,
    required this.createdAt,
    this.confidence,
  });

  factory DetectionLogEntry.fromJson(Map<String, dynamic> json) => DetectionLogEntry(
        id: json['id'] as int,
        predictedWord: json['predicted_word'] as String,
        confidence: (json['confidence'] as num?)?.toDouble(),
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}

/// Error yang pesannya aman ditampilkan langsung ke pengguna.
class DetectionLogException implements Exception {
  final String message;
  const DetectionLogException(this.message);

  @override
  String toString() => message;
}

/// Service untuk menyimpan & mengambil riwayat deteksi dari backend.
/// Endpoint ini global (tidak terikat akun), sesuai desain arsitektur app.
class DetectionLogService {
  DetectionLogService._();
  static final DetectionLogService instance = DetectionLogService._();

  static const _basePath = '/api/detection-logs';

  /// Simpan 1 hasil deteksi. Dipanggil tiap kali TFLite berhasil memprediksi
  /// sebuah kata. Gagal secara diam-diam (tidak melempar) supaya kegagalan
  /// jaringan tidak mengganggu pengalaman deteksi real-time di kamera.
  Future<void> logDetection({required String predictedWord, double? confidence}) async {
    try {
      await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}$_basePath'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'predicted_word': predictedWord,
              if (confidence != null) 'confidence': confidence,
            }),
          )
          .timeout(ApiConfig.timeout);
    } catch (_) {
      // Offline/server mati: riwayat gagal tersimpan, tapi deteksi di layar
      // tetap jalan (inferensi 100% on-device, backend cuma pelengkap).
    }
  }

  /// Ambil daftar riwayat deteksi, terbaru dulu.
  Future<List<DetectionLogEntry>> fetchHistory({int limit = 20, int offset = 0}) async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}$_basePath?limit=$limit&offset=$offset'),
          )
          .timeout(ApiConfig.timeout);

      final decoded = _decode(response.body);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw DetectionLogException(
          decoded['error']?.toString() ?? 'Gagal memuat riwayat (kode ${response.statusCode})',
        );
      }

      final data = decoded['data'];
      if (data is! List) {
        throw const DetectionLogException('Respons server tidak sesuai.');
      }
      return data
          .whereType<Map<String, dynamic>>()
          .map(DetectionLogEntry.fromJson)
          .toList();
    } on TimeoutException {
      throw const DetectionLogException('Server tidak merespons. Pastikan backend berjalan.');
    } on SocketException {
      throw const DetectionLogException('Tidak bisa terhubung ke server.');
    } on http.ClientException {
      throw const DetectionLogException('Tidak bisa terhubung ke server.');
    }
  }

  /// Hapus satu riwayat berdasarkan ID.
  Future<void> deleteOne(int id) async {
    try {
      final response = await http
          .delete(Uri.parse('${ApiConfig.baseUrl}$_basePath/$id'))
          .timeout(ApiConfig.timeout);

      final decoded = _decode(response.body);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw DetectionLogException(
          decoded['error']?.toString() ?? 'Gagal menghapus riwayat (kode ${response.statusCode})',
        );
      }
    } on TimeoutException {
      throw const DetectionLogException('Server tidak merespons. Pastikan backend berjalan.');
    } on SocketException {
      throw const DetectionLogException('Tidak bisa terhubung ke server.');
    } on http.ClientException {
      throw const DetectionLogException('Tidak bisa terhubung ke server.');
    }
  }

  /// Hapus SEMUA riwayat deteksi sekaligus.
  Future<void> deleteAll() async {
    try {
      final response = await http
          .delete(Uri.parse('${ApiConfig.baseUrl}$_basePath'))
          .timeout(ApiConfig.timeout);

      final decoded = _decode(response.body);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw DetectionLogException(
          decoded['error']?.toString() ?? 'Gagal menghapus riwayat (kode ${response.statusCode})',
        );
      }
    } on TimeoutException {
      throw const DetectionLogException('Server tidak merespons. Pastikan backend berjalan.');
    } on SocketException {
      throw const DetectionLogException('Tidak bisa terhubung ke server.');
    } on http.ClientException {
      throw const DetectionLogException('Tidak bisa terhubung ke server.');
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
}