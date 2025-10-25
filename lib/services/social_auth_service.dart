import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:crypto/crypto.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/auth_responses.dart';
import '../utils/error_handler.dart';

class SocialAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  /// Sign in with Google
  static Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      debugPrint('🔵 Starting Google Sign-In...');
      
      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        debugPrint('❌ Google Sign-In cancelled by user');
        return null;
      }

      debugPrint('✅ Google Sign-In successful: ${googleUser.email}');

      // Get authentication details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Send to backend
      return await _sendSocialAuthToBackend(
        provider: 'google',
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
        email: googleUser.email,
        name: googleUser.displayName,
        photoUrl: googleUser.photoUrl,
      );
    } catch (e) {
      debugPrint('💥 Google Sign-In error: $e');
      throw AppException('Google Sign-In failed: ${e.toString()}');
    }
  }

  /// Sign in with Apple
  static Future<Map<String, dynamic>?> signInWithApple() async {
    try {
      // Only available on iOS 13.0+ and macOS 10.15+
      if (!Platform.isIOS && !Platform.isMacOS) {
        throw AppException('Apple Sign-In is only available on iOS and macOS');
      }

      debugPrint('🍎 Starting Apple Sign-In...');

      // Generate nonce for security
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      // Trigger the Apple Sign-In flow
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      debugPrint('✅ Apple Sign-In successful: ${credential.email ?? "no email"}');

      // Combine first and last name
      String? fullName;
      if (credential.givenName != null || credential.familyName != null) {
        fullName = '${credential.givenName ?? ''} ${credential.familyName ?? ''}'.trim();
      }

      // Send to backend
      return await _sendSocialAuthToBackend(
        provider: 'apple',
        idToken: credential.identityToken,
        email: credential.email,
        name: fullName,
        userId: credential.userIdentifier,
      );
    } catch (e) {
      debugPrint('💥 Apple Sign-In error: $e');
      
      // Handle user cancellation
      if (e.toString().contains('CANCELED') || e.toString().contains('cancelled')) {
        return null;
      }
      
      throw AppException('Apple Sign-In failed: ${e.toString()}');
    }
  }

  /// Sign in with Facebook
  static Future<Map<String, dynamic>?> signInWithFacebook() async {
    try {
      debugPrint('🔵 Starting Facebook Sign-In...');

      // Trigger the Facebook Sign-In flow
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status == LoginStatus.cancelled) {
        debugPrint('❌ Facebook Sign-In cancelled by user');
        return null;
      }

      if (result.status != LoginStatus.success) {
        throw AppException('Facebook Sign-In failed: ${result.message}');
      }

      // Get user data
      final userData = await FacebookAuth.instance.getUserData(
        fields: 'email,name,picture.width(200)',
      );

      debugPrint('✅ Facebook Sign-In successful: ${userData['email']}');

      // Send to backend
      return await _sendSocialAuthToBackend(
        provider: 'facebook',
        accessToken: result.accessToken!.tokenString,
        email: userData['email'],
        name: userData['name'],
        photoUrl: userData['picture']?['data']?['url'],
        userId: userData['id'],
      );
    } catch (e) {
      debugPrint('💥 Facebook Sign-In error: $e');
      throw AppException('Facebook Sign-In failed: ${e.toString()}');
    }
  }

  /// Send social auth data to backend
  static Future<Map<String, dynamic>> _sendSocialAuthToBackend({
    required String provider,
    String? accessToken,
    String? idToken,
    String? email,
    String? name,
    String? photoUrl,
    String? userId,
  }) async {
    try {
      debugPrint('📡 Sending $provider auth to backend...');

      final response = await http.post(
        Uri.parse(ApiConfig.getUrl('/auth/social-login')),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'provider': provider,
          'access_token': accessToken,
          'id_token': idToken,
          'email': email,
          'name': name,
          'photo_url': photoUrl,
          'provider_user_id': userId,
        }),
      );

      debugPrint('📡 Backend response status: ${response.statusCode}');
      debugPrint('📡 Backend response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        
        // Check if the response has a success status
        if (data['status'] == true || data['success'] == true) {
          return {
            'success': true,
            'token': data['token'] ?? data['access_token'] ?? data['data']?['token'],
            'refresh_token': data['refresh_token'] ?? data['data']?['refresh_token'],
            'user': data['user'] ?? data['data']?['user'],
            'expires_in': data['expires_in'] ?? data['data']?['expires_in'] ?? 3600,
            'needs_profile_completion': data['needs_profile_completion'] ?? data['data']?['needs_profile_completion'] ?? false,
          };
        } else {
          throw AppException(data['message'] ?? 'Social authentication failed');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw AppException(errorData['message'] ?? 'Social authentication failed');
      }
    } catch (e) {
      debugPrint('💥 Backend communication error: $e');
      rethrow;
    }
  }

  /// Sign out from all social providers
  static Future<void> signOutAll() async {
    try {
      // Sign out from Google
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      // Sign out from Facebook
      await FacebookAuth.instance.logOut();

      debugPrint('✅ Signed out from all social providers');
    } catch (e) {
      debugPrint('⚠️ Error signing out from social providers: $e');
    }
  }

  /// Generate a cryptographically secure random nonce
  static String _generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  /// Returns the sha256 hash of [input] in hex notation
  static String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Check if Google Sign-In is available
  static Future<bool> isGoogleSignInAvailable() async {
    try {
      return await _googleSignIn.isSignedIn();
    } catch (e) {
      return false;
    }
  }

  /// Check if Apple Sign-In is available
  static bool isAppleSignInAvailable() {
    return Platform.isIOS || Platform.isMacOS;
  }
}

