/// Alamat backend Flask, dipusatkan di satu tempat.
/// Di HP fisik pakai IP laptop di jaringan WiFi yang sama (cek: `hostname -I`).
/// IP ini bisa berubah tiap ganti jaringan, jadi cukup ubah di sini.
class ApiConfig {
  ApiConfig._();

  static const String baseUrl = 'http://192.168.100.124:5000';
  static const Duration timeout = Duration(seconds: 10);
}