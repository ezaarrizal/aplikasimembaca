// lib/config/api_config.dart
class ApiConfig {
  // Railway production URL (akan diupdate setelah deploy)
  static const String _productionUrl = 'https://your-app-name.railway.app/api/v1';
  static const String _developmentUrl = 'http://localhost:8000/api/v1';
  
  // Environment detection
  static bool get isProduction => const bool.fromEnvironment('dart.vm.product');
  
  // Base URL berdasarkan environment
  static String get baseUrl => isProduction ? _productionUrl : _developmentUrl;
  
  // Manual override untuk testing (optional)
  static const bool forceProduction = false; // Set true untuk testing production
  static String get baseUrlManual => forceProduction ? _productionUrl : _developmentUrl;
  
  // Method untuk update production URL setelah Railway deploy
  static void updateProductionUrl(String newUrl) {
    // This will be used when we know the actual Railway URL
    print('Production URL should be updated to: $newUrl');
  }
  
  // Endpoints
  static String get loginEndpoint => '$baseUrl/auth/login';
  static String get userEndpoint => '$baseUrl/auth/user';
  static String get logoutEndpoint => '$baseUrl/auth/logout';
  static String get healthEndpoint => '$baseUrl/health';
  
  // Game endpoints
  static String get gamesEndpoint => '$baseUrl/siswa/games';
  static String get badgesEndpoint => '$baseUrl/siswa/badges';
  
  // Feedback endpoints
  static String get feedbackEndpoint => '$baseUrl/guru/feedback';
  static String get parentFeedbackEndpoint => '$baseUrl/orangtua/feedback';
}