class ApiConfig {
  // Base URL for the API
  static const String baseUrl = 'https://api.lgbtinder.com'; // Change this to your actual API base URL
  
  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String verifyEmail = '/auth/verify-email';
  static const String resendVerification = '/auth/resend-verification';
  static const String refreshToken = '/auth/refresh-token';
  static const String logout = '/auth/logout';
  static const String sendVerification = '/auth/send-verification';
  static const String verifyCode = '/auth/verify-registration-code';
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String checkEmail = '/auth/check-email';
  static const String checkPhone = '/auth/check-phone';
  
  // User endpoints
  static const String profile = '/user/profile';
  static const String updateProfile = '/user/profile/update';
  static const String uploadAvatar = '/user/avatar/upload';
  
  // Match endpoints
  static const String matches = '/matches';
  static const String like = '/matches/like';
  static const String dislike = '/matches/dislike';
  static const String superlike = '/matches/superlike';
  
  // Chat endpoints
  static const String conversations = '/conversations';
  static const String messages = '/conversations/{id}/messages';
  static const String sendMessage = '/conversations/{id}/messages';
  
  // Search endpoints
  static const String search = '/search/users';
  
  // Helper method to get full URL
  static String getUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }
}
