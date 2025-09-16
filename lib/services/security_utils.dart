import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

class SecurityUtils {
  /// Generate secure random string
  static String generateSecureRandomString(int length) {
    final random = Random.secure();
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return String.fromCharCodes(
      Iterable.generate(length, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }

  /// Generate secure random number
  static int generateSecureRandomNumber(int min, int max) {
    final random = Random.secure();
    return min + random.nextInt(max - min + 1);
  }

  /// Hash password with salt
  static String hashPassword(String password, String salt) {
    final bytes = utf8.encode(password + salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Generate salt
  static String generateSalt() {
    return generateSecureRandomString(32);
  }

  /// Verify password
  static bool verifyPassword(String password, String hash, String salt) {
    final hashedPassword = hashPassword(password, salt);
    return hashedPassword == hash;
  }

  /// Encrypt data (simple base64 for demo)
  static String encryptData(String data) {
    final bytes = utf8.encode(data);
    return base64Encode(bytes);
  }

  /// Decrypt data (simple base64 for demo)
  static String decryptData(String encryptedData) {
    final bytes = base64Decode(encryptedData);
    return utf8.decode(bytes);
  }

  /// Generate API key
  static String generateApiKey() {
    return generateSecureRandomString(64);
  }

  /// Generate session ID
  static String generateSessionId() {
    return generateSecureRandomString(32);
  }

  /// Generate CSRF token
  static String generateCsrfToken() {
    return generateSecureRandomString(32);
  }

  /// Validate CSRF token
  static bool validateCsrfToken(String token, String expectedToken) {
    return token == expectedToken;
  }

  /// Generate nonce
  static String generateNonce() {
    return generateSecureRandomString(16);
  }

  /// Validate nonce
  static bool validateNonce(String nonce, String expectedNonce) {
    return nonce == expectedNonce;
  }

  /// Generate UUID
  static String generateUuid() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (i) => random.nextInt(256));
    
    // Set version (4) and variant bits
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20, 32)}';
  }

  /// Validate UUID
  static bool validateUuid(String uuid) {
    final regex = RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$');
    return regex.hasMatch(uuid.toLowerCase());
  }

  /// Generate device fingerprint
  static String generateDeviceFingerprint() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (i) => random.nextInt(256));
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return hex;
  }

  /// Validate device fingerprint
  static bool validateDeviceFingerprint(String fingerprint) {
    return fingerprint.length == 32 && RegExp(r'^[0-9a-f]+$').hasMatch(fingerprint.toLowerCase());
  }

  /// Generate secure token
  static String generateSecureToken() {
    return generateSecureRandomString(32);
  }

  /// Validate secure token
  static bool validateSecureToken(String token) {
    return token.length == 32 && RegExp(r'^[a-zA-Z0-9]+$').hasMatch(token);
  }

  /// Generate password reset token
  static String generatePasswordResetToken() {
    return generateSecureRandomString(32);
  }

  /// Generate email verification token
  static String generateEmailVerificationToken() {
    return generateSecureRandomString(32);
  }

  /// Generate phone verification code
  static String generatePhoneVerificationCode() {
    final random = Random.secure();
    return (100000 + random.nextInt(900000)).toString();
  }

  /// Validate phone verification code
  static bool validatePhoneVerificationCode(String code) {
    return RegExp(r'^\d{6}$').hasMatch(code);
  }

  /// Generate 2FA code
  static String generate2FACode() {
    final random = Random.secure();
    return (100000 + random.nextInt(900000)).toString();
  }

  /// Validate 2FA code
  static bool validate2FACode(String code) {
    return RegExp(r'^\d{6}$').hasMatch(code);
  }

  /// Generate backup codes
  static List<String> generateBackupCodes(int count) {
    final codes = <String>[];
    for (int i = 0; i < count; i++) {
      codes.add(generateSecureRandomString(8));
    }
    return codes;
  }

  /// Validate backup code
  static bool validateBackupCode(String code) {
    return code.length == 8 && RegExp(r'^[a-zA-Z0-9]+$').hasMatch(code);
  }

  /// Generate QR code secret
  static String generateQrCodeSecret() {
    return generateSecureRandomString(32);
  }

  /// Validate QR code secret
  static bool validateQrCodeSecret(String secret) {
    return secret.length == 32 && RegExp(r'^[a-zA-Z0-9]+$').hasMatch(secret);
  }

  /// Generate recovery code
  static String generateRecoveryCode() {
    return generateSecureRandomString(16);
  }

  /// Validate recovery code
  static bool validateRecoveryCode(String code) {
    return code.length == 16 && RegExp(r'^[a-zA-Z0-9]+$').hasMatch(code);
  }

  /// Generate access token
  static String generateAccessToken() {
    return generateSecureRandomString(64);
  }

  /// Generate refresh token
  static String generateRefreshToken() {
    return generateSecureRandomString(64);
  }

  /// Validate access token
  static bool validateAccessToken(String token) {
    return token.length == 64 && RegExp(r'^[a-zA-Z0-9]+$').hasMatch(token);
  }

  /// Validate refresh token
  static bool validateRefreshToken(String token) {
    return token.length == 64 && RegExp(r'^[a-zA-Z0-9]+$').hasMatch(token);
  }

  /// Generate API secret
  static String generateApiSecret() {
    return generateSecureRandomString(128);
  }

  /// Validate API secret
  static bool validateApiSecret(String secret) {
    return secret.length == 128 && RegExp(r'^[a-zA-Z0-9]+$').hasMatch(secret);
  }

  /// Generate webhook secret
  static String generateWebhookSecret() {
    return generateSecureRandomString(64);
  }

  /// Validate webhook secret
  static bool validateWebhookSecret(String secret) {
    return secret.length == 64 && RegExp(r'^[a-zA-Z0-9]+$').hasMatch(secret);
  }

  /// Generate signature
  static String generateSignature(String data, String secret) {
    final bytes = utf8.encode(data + secret);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Validate signature
  static bool validateSignature(String data, String secret, String signature) {
    final expectedSignature = generateSignature(data, secret);
    return signature == expectedSignature;
  }

  /// Generate HMAC
  static String generateHmac(String data, String key) {
    final bytes = utf8.encode(data);
    final keyBytes = utf8.encode(key);
    final hmac = Hmac(sha256, keyBytes);
    final digest = hmac.convert(bytes);
    return digest.toString();
  }

  /// Validate HMAC
  static bool validateHmac(String data, String key, String hmac) {
    final expectedHmac = generateHmac(data, key);
    return hmac == expectedHmac;
  }

  /// Generate checksum
  static String generateChecksum(String data) {
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Validate checksum
  static bool validateChecksum(String data, String checksum) {
    final expectedChecksum = generateChecksum(data);
    return checksum == expectedChecksum;
  }

  /// Generate hash
  static String generateHash(String data) {
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Validate hash
  static bool validateHash(String data, String hash) {
    final expectedHash = generateHash(data);
    return hash == expectedHash;
  }

  /// Generate random bytes
  static List<int> generateRandomBytes(int length) {
    final random = Random.secure();
    return List<int>.generate(length, (i) => random.nextInt(256));
  }

  /// Generate random hex string
  static String generateRandomHexString(int length) {
    final bytes = generateRandomBytes(length);
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Generate random base64 string
  static String generateRandomBase64String(int length) {
    final bytes = generateRandomBytes(length);
    return base64Encode(bytes);
  }

  /// Generate random base32 string
  static String generateRandomBase32String(int length) {
    final bytes = generateRandomBytes(length);
    return base32Encode(bytes);
  }

  /// Base32 encode
  static String base32Encode(List<int> bytes) {
    const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
    final result = StringBuffer();
    
    for (int i = 0; i < bytes.length; i += 5) {
      int value = 0;
      int bits = 0;
      
      for (int j = 0; j < 5 && i + j < bytes.length; j++) {
        value = (value << 8) | bytes[i + j];
        bits += 8;
      }
      
      while (bits > 0) {
        final index = (value >> (bits - 5)) & 31;
        result.write(alphabet[index]);
        bits -= 5;
      }
    }
    
    return result.toString();
  }

  /// Base32 decode
  static List<int> base32Decode(String input) {
    const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
    final result = <int>[];
    
    int value = 0;
    int bits = 0;
    
    for (int i = 0; i < input.length; i++) {
      final char = input[i].toUpperCase();
      final index = alphabet.indexOf(char);
      
      if (index == -1) continue;
      
      value = (value << 5) | index;
      bits += 5;
      
      if (bits >= 8) {
        result.add((value >> (bits - 8)) & 255);
        bits -= 8;
      }
    }
    
    return result;
  }

  /// Generate time-based one-time password
  static String generateTOTP(String secret, int timeStep) {
    final time = (DateTime.now().millisecondsSinceEpoch / 1000 / timeStep).floor();
    final timeBytes = List<int>.generate(8, (i) => (time >> (56 - i * 8)) & 255);
    final hmac = generateHmac(base32Encode(timeBytes), secret);
    final offset = int.parse(hmac.substring(hmac.length - 1), radix: 16);
    final code = int.parse(hmac.substring(offset * 2, offset * 2 + 8), radix: 16);
    return (code % 1000000).toString().padLeft(6, '0');
  }

  /// Validate time-based one-time password
  static bool validateTOTP(String secret, String code, int timeStep, {int tolerance = 1}) {
    final currentTime = (DateTime.now().millisecondsSinceEpoch / 1000 / timeStep).floor();
    
    for (int i = -tolerance; i <= tolerance; i++) {
      final time = currentTime + i;
      final timeBytes = List<int>.generate(8, (j) => (time >> (56 - j * 8)) & 255);
      final hmac = generateHmac(base32Encode(timeBytes), secret);
      final offset = int.parse(hmac.substring(hmac.length - 1), radix: 16);
      final expectedCode = int.parse(hmac.substring(offset * 2, offset * 2 + 8), radix: 16);
      final expectedCodeString = (expectedCode % 1000000).toString().padLeft(6, '0');
      
      if (code == expectedCodeString) {
        return true;
      }
    }
    
    return false;
  }

  /// Generate counter-based one-time password
  static String generateHOTP(String secret, int counter) {
    final counterBytes = List<int>.generate(8, (i) => (counter >> (56 - i * 8)) & 255);
    final hmac = generateHmac(base32Encode(counterBytes), secret);
    final offset = int.parse(hmac.substring(hmac.length - 1), radix: 16);
    final code = int.parse(hmac.substring(offset * 2, offset * 2 + 8), radix: 16);
    return (code % 1000000).toString().padLeft(6, '0');
  }

  /// Validate counter-based one-time password
  static bool validateHOTP(String secret, String code, int counter, {int tolerance = 1}) {
    for (int i = 0; i <= tolerance; i++) {
      final expectedCode = generateHOTP(secret, counter + i);
      if (code == expectedCode) {
        return true;
      }
    }
    
    return false;
  }
}
