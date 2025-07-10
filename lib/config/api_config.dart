// lib/config/api_config.dart - DEBUG VERSION
class ApiConfig {
  // PRODUCTION URL - Railway
  static const String baseUrl = 'https://echo-web-production-5353.up.railway.app/api/v1';
  
  // Debug method untuk verify URL
  static void debugCurrentUrl() {
    print('🔍 DEBUG: ApiConfig.baseUrl = $baseUrl');
    print('🔍 DEBUG: Should be Railway URL, NOT localhost');
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
  
  // User management endpoints
  static String get usersEndpoint => '$baseUrl/guru/users';
  static String get siswaListEndpoint => '$baseUrl/guru/siswa-list';
}