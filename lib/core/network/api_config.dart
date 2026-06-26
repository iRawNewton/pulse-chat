class ApiConfig {
  ApiConfig._();

  /// Local development base URL
  static const String localBaseUrl = 'http://10.0.2.2:8000';

  /// Production environment base URL
  static const String productionBaseUrl = 'https://api.pulse-chat.com';

  /// Environment toggle flag. Set [isProduction] to true when releasing.
  static const bool isProduction = false;

  /// Returns the active base URL for HTTP REST requests.
  static String get baseUrl => isProduction ? productionBaseUrl : localBaseUrl;

  /// Dynamically constructs the WebSocket URL based on the active base HTTP URL.
  /// If the baseUrl starts with 'https', it uses 'wss', otherwise it uses 'ws'.
  static String get wsUrl {
    final cleanUrl = baseUrl.replaceFirst('http://', '').replaceFirst('https://', '');
    final scheme = baseUrl.startsWith('https') ? 'wss' : 'ws';
    return '$scheme://$cleanUrl/ws';
  }
}
