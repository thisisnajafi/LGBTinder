import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../utils/api_error_handler.dart';

class SocialLoginService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  /// Sign in with Google
  static Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        return null; // User cancelled
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      final Map<String, dynamic> userData = {
        'provider': 'google',
        'provider_id': googleUser.id,
        'email': googleUser.email,
        'name': googleUser.displayName,
        'photo_url': googleUser.photoUrl,
        'access_token': googleAuth.accessToken,
        'id_token': googleAuth.idToken,
      };

      // Send to backend for verification and account creation
      final result = await _verifySocialLogin(userData);
      return result;
    } catch (e) {
      debugPrint('Google sign in error: $e');
      throw SocialLoginException('Google sign in failed: $e');
    }
  }

  /// Sign in with Apple
  static Future<Map<String, dynamic>?> signInWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final Map<String, dynamic> userData = {
        'provider': 'apple',
        'provider_id': credential.userIdentifier,
        'email': credential.email,
        'name': '${credential.givenName ?? ''} ${credential.familyName ?? ''}'.trim(),
        'photo_url': null, // Apple doesn't provide profile photos
        'access_token': credential.authorizationCode,
        'id_token': credential.identityToken,
      };

      // Send to backend for verification and account creation
      final result = await _verifySocialLogin(userData);
      return result;
    } catch (e) {
      debugPrint('Apple sign in error: $e');
      throw SocialLoginException('Apple sign in failed: $e');
    }
  }

  /// Sign in with Facebook
  static Future<Map<String, dynamic>?> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      
      if (result.status != LoginStatus.success) {
        return null; // User cancelled or error
      }

      final userData = await FacebookAuth.instance.getUserData();
      
      final Map<String, dynamic> socialData = {
        'provider': 'facebook',
        'provider_id': userData['id'],
        'email': userData['email'],
        'name': userData['name'],
        'photo_url': userData['picture']['data']['url'],
        'access_token': result.accessToken?.tokenString,
        'id_token': null, // Facebook doesn't use ID tokens
      };

      // Send to backend for verification and account creation
      final response = await _verifySocialLogin(socialData);
      return response;
    } catch (e) {
      debugPrint('Facebook sign in error: $e');
      throw SocialLoginException('Facebook sign in failed: $e');
    }
  }

  /// Verify social login with backend
  static Future<Map<String, dynamic>> _verifySocialLogin(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.socialLogin)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(userData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 400) {
        final errorData = jsonDecode(response.body);
        throw ValidationException(errorData['message'] ?? 'Invalid social login data');
      } else if (response.statusCode == 401) {
        throw AuthException('Social login verification failed');
      } else {
        throw ApiException('Social login failed: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ValidationException || e is AuthException || e is ApiException) {
        rethrow;
      }
      throw NetworkException('Network error during social login: $e');
    }
  }

  /// Link social account to existing account
  static Future<bool> linkSocialAccount({
    required String provider,
    required String accessToken,
    required String userToken,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.linkSocialAccount)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
        body: jsonEncode({
          'provider': provider,
          'access_token': accessToken,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 400) {
        final errorData = jsonDecode(response.body);
        throw ValidationException(errorData['message'] ?? 'Invalid social account data');
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else {
        throw ApiException('Failed to link social account: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ValidationException || e is AuthException || e is ApiException) {
        rethrow;
      }
      throw NetworkException('Network error while linking social account: $e');
    }
  }

  /// Unlink social account
  static Future<bool> unlinkSocialAccount({
    required String provider,
    required String userToken,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.getUrl(ApiConfig.unlinkSocialAccount)}/$provider'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else {
        throw ApiException('Failed to unlink social account: ${response.statusCode}');
      }
    } catch (e) {
      if (e is AuthException || e is ApiException) {
        rethrow;
      }
      throw NetworkException('Network error while unlinking social account: $e');
    }
  }

  /// Get linked social accounts
  static Future<List<Map<String, dynamic>>> getLinkedAccounts({
    required String userToken,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.linkedAccounts)),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> accounts = data['data'] ?? data;
        return accounts.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else {
        throw ApiException('Failed to get linked accounts: ${response.statusCode}');
      }
    } catch (e) {
      if (e is AuthException || e is ApiException) {
        rethrow;
      }
      throw NetworkException('Network error while getting linked accounts: $e');
    }
  }

  /// Sign out from all social providers
  static Future<void> signOutFromAll() async {
    try {
      // Sign out from Google
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      // Sign out from Facebook
      await FacebookAuth.instance.logout();

      // Apple doesn't require explicit sign out
    } catch (e) {
      debugPrint('Error signing out from social providers: $e');
    }
  }

  /// Check if user is signed in to any social provider
  static Future<bool> isSignedInToAny() async {
    try {
      final googleSignedIn = await _googleSignIn.isSignedIn();
      final facebookSignedIn = await FacebookAuth.instance.accessToken != null;
      
      return googleSignedIn || facebookSignedIn;
    } catch (e) {
      debugPrint('Error checking social sign in status: $e');
      return false;
    }
  }
}

class SocialLoginException implements Exception {
  final String message;
  SocialLoginException(this.message);
  
  @override
  String toString() => 'SocialLoginException: $message';
}

class SocialAccount {
  final String provider;
  final String providerId;
  final String email;
  final String name;
  final String? photoUrl;
  final bool isLinked;
  final DateTime linkedAt;

  SocialAccount({
    required this.provider,
    required this.providerId,
    required this.email,
    required this.name,
    this.photoUrl,
    required this.isLinked,
    required this.linkedAt,
  });

  factory SocialAccount.fromJson(Map<String, dynamic> json) {
    return SocialAccount(
      provider: json['provider'] ?? '',
      providerId: json['provider_id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      photoUrl: json['photo_url'],
      isLinked: json['is_linked'] ?? false,
      linkedAt: DateTime.parse(json['linked_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'provider': provider,
      'provider_id': providerId,
      'email': email,
      'name': name,
      'photo_url': photoUrl,
      'is_linked': isLinked,
      'linked_at': linkedAt.toIso8601String(),
    };
  }

  String get providerDisplayName {
    switch (provider.toLowerCase()) {
      case 'google':
        return 'Google';
      case 'facebook':
        return 'Facebook';
      case 'apple':
        return 'Apple';
      default:
        return provider;
    }
  }

  String get providerIcon {
    switch (provider.toLowerCase()) {
      case 'google':
        return 'assets/icons/google.png';
      case 'facebook':
        return 'assets/icons/facebook.png';
      case 'apple':
        return 'assets/icons/apple.png';
      default:
        return 'assets/icons/social.png';
    }
  }
}
