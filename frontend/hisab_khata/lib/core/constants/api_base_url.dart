class ApiBaseUrl {
  //for creating tunnel with cloudflare
  // cloudflared tunnel --url http://localhost:8000

  // Emulator URL (Android emulator uses 10.0.2.2 to reach host machine)

  //emulator URL
  static const String baseUrl = "https://btwitsabhishek.me/api/";

  // Real device URL (use your machine's local IP address)
  // static const String baseUrl = "http://192.168.1.69:8000/api/";

  // for Cloudflare Tunnel
  // static const String baseUrl =
  // "https://chuck-recommendation-demonstrated-gerald.trycloudflare.com/api/";
}
