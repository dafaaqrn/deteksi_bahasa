/// Alamat backend Flask, dipusatkan di satu tempat.
/// Di HP fisik pakai IP laptop di jaringan WiFi yang sama (cek: `hostname -I`).
/// IP ini bisa berubah tiap ganti jaringan, jadi cukup ubah di sini.
class ApiConfig {
  ApiConfig._();

  static const String baseUrl = 'https://mayflower-graceful-wipe.ngrok-free.dev';
  static const Duration timeout = Duration(seconds: 10);

  /// Web Client ID dari Google Cloud Console (bukan Android Client ID).
  /// Harus SAMA PERSIS dengan GOOGLE_CLIENT_ID di .env backend.
  static const String googleWebClientId =
      '991130986638-vvha1ja6asp5mao3c6g7pt7jq82ckar6.apps.googleusercontent.com';
}