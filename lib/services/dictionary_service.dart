import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/dictionary_entry.dart';

class DictionaryService {
  // GANTI base URL ini sesuai kondisi kamu:
  // - Emulator Android  -> 'http://10.0.2.2:5000/api'
  // - HP fisik (WiFi sama dengan laptop) -> 'http://IP_LAPTOP_KAMU:5000/api'
  //   contoh: 'http://192.168.1.10:5000/api'
  static const String baseUrl = 'http://10.0.2.2:5000/api';

  Future<List<DictionaryEntry>> fetchDictionary({String? search}) async {
    final uri = Uri.parse('$baseUrl/dictionary').replace(
      queryParameters: search != null && search.isNotEmpty
          ? {'search': search}
          : null,
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => DictionaryEntry.fromJson(e)).toList();
    } else {
      throw Exception('Gagal mengambil data kamus (${response.statusCode})');
    }
  }

  Future<DictionaryEntry> submitWord(DictionaryEntry entry) async {
    final response = await http.post(
      Uri.parse('$baseUrl/dictionary'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(entry.toJson()),
    );

    if (response.statusCode == 201) {
      return DictionaryEntry.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal menambahkan kosakata (${response.statusCode})');
    }
  }
}
