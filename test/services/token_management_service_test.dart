import 'package:flutter_test/flutter_test.dart';
import '../../lib/services/token_management_service.dart';

void main() {
  group('TokenManagementService Tests', () {
    setUp(() async {
      // Clean up before each test
      await TokenManagementService.clearAllTokens();
    });

    tearDown(() async {
      // Clean up after each test
      await TokenManagementService.clearAllTokens();
    });

    group('Access Token Management', () {
      test('should store access token successfully', () async {
        // Arrange
        const token = 'test_access_token_12345';
        
        // Act
        await TokenManagementService.storeAccessToken(token);
        
        // Assert
        final retrievedToken = await TokenManagementService.getAccessToken();
        expect(retrievedToken, equals(token));
      });

      test('should retrieve stored access token', () async {
        // Arrange
        const token = 'test_access_token_12345';
        await TokenManagementService.storeAccessToken(token);
        
        // Act
        final retrievedToken = await TokenManagementService.getAccessToken();
        
        // Assert
        expect(retrievedToken, equals(token));
      });

      test('should return null when access token does not exist', () async {
        // Act
        final token = await TokenManagementService.getAccessToken();
        
        // Assert
        expect(token, isNull);
      });

      test('should update access token when new token is saved', () async {
        // Arrange
        const oldToken = 'old_access_token';
        const newToken = 'new_access_token';
        await TokenManagementService.storeAccessToken(oldToken);
        
        // Act
        await TokenManagementService.storeAccessToken(newToken);
        
        // Assert
        final retrievedToken = await TokenManagementService.getAccessToken();
        expect(retrievedToken, equals(newToken));
        expect(retrievedToken, isNot(equals(oldToken)));
      });

      test('should delete access token', () async {
        // Arrange
        const token = 'test_access_token';
        await TokenManagementService.storeAccessToken(token);
        
        // Act
        await TokenManagementService.clearAccessToken();
        
        // Assert
        final retrievedToken = await TokenManagementService.getAccessToken();
        expect(retrievedToken, isNull);
      });
    });

    group('Refresh Token Management', () {
      test('should store refresh token successfully', () async {
        // Arrange
        const token = 'test_refresh_token_12345';
        
        // Act
        await tokenService.saveRefreshToken(token);
        
        // Assert
        final retrievedToken = await tokenService.getRefreshToken();
        expect(retrievedToken, equals(token));
      });

      test('should retrieve stored refresh token', () async {
        // Arrange
        const token = 'test_refresh_token_12345';
        await tokenService.saveRefreshToken(token);
        
        // Act
        final retrievedToken = await tokenService.getRefreshToken();
        
        // Assert
        expect(retrievedToken, equals(token));
      });

      test('should return null when refresh token does not exist', () async {
        // Act
        final token = await tokenService.getRefreshToken();
        
        // Assert
        expect(token, isNull);
      });

      test('should update refresh token when new token is saved', () async {
        // Arrange
        const oldToken = 'old_refresh_token';
        const newToken = 'new_refresh_token';
        await tokenService.saveRefreshToken(oldToken);
        
        // Act
        await tokenService.saveRefreshToken(newToken);
        
        // Assert
        final retrievedToken = await tokenService.getRefreshToken();
        expect(retrievedToken, equals(newToken));
        expect(retrievedToken, isNot(equals(oldToken)));
      });

      test('should delete refresh token', () async {
        // Arrange
        const token = 'test_refresh_token';
        await tokenService.saveRefreshToken(token);
        
        // Act
        await tokenService.deleteRefreshToken();
        
        // Assert
        final retrievedToken = await tokenService.getRefreshToken();
        expect(retrievedToken, isNull);
      });
    });

    group('Token Pair Management', () {
      test('should store both access and refresh tokens', () async {
        // Arrange
        const accessToken = 'access_token_123';
        const refreshToken = 'refresh_token_456';
        
        // Act
        await tokenService.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );
        
        // Assert
        expect(await tokenService.getAccessToken(), equals(accessToken));
        expect(await tokenService.getRefreshToken(), equals(refreshToken));
      });

      test('should store only access token when refresh token is not provided', () async {
        // Arrange
        const accessToken = 'access_token_123';
        
        // Act
        await tokenService.saveTokens(accessToken: accessToken);
        
        // Assert
        expect(await tokenService.getAccessToken(), equals(accessToken));
        expect(await tokenService.getRefreshToken(), isNull);
      });

      test('should clear all tokens', () async {
        // Arrange
        const accessToken = 'access_token_123';
        const refreshToken = 'refresh_token_456';
        await tokenService.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );
        
        // Act
        await tokenService.clearTokens();
        
        // Assert
        expect(await tokenService.getAccessToken(), isNull);
        expect(await tokenService.getRefreshToken(), isNull);
      });

      test('should check if user is authenticated (has access token)', () async {
        // Test when not authenticated
        expect(await tokenService.isAuthenticated(), isFalse);
        
        // Test when authenticated
        await tokenService.saveAccessToken('test_token');
        expect(await tokenService.isAuthenticated(), isTrue);
        
        // Test after clearing
        await tokenService.clearTokens();
        expect(await tokenService.isAuthenticated(), isFalse);
      });
    });

    group('Token Expiry Management', () {
      test('should store token expiry time', () async {
        // Arrange
        const token = 'test_token';
        final expiry = DateTime.now().add(const Duration(hours: 1));
        
        // Act
        await tokenService.saveAccessToken(token);
        await tokenService.saveTokenExpiry(expiry);
        
        // Assert
        final storedExpiry = await tokenService.getTokenExpiry();
        expect(storedExpiry, isNotNull);
        expect(storedExpiry?.millisecondsSinceEpoch, 
               closeTo(expiry.millisecondsSinceEpoch, 1000));
      });

      test('should check if token is expired', () async {
        // Test with non-expired token
        const token = 'test_token';
        final futureExpiry = DateTime.now().add(const Duration(hours: 1));
        await tokenService.saveAccessToken(token);
        await tokenService.saveTokenExpiry(futureExpiry);
        expect(await tokenService.isTokenExpired(), isFalse);
        
        // Test with expired token
        final pastExpiry = DateTime.now().subtract(const Duration(hours: 1));
        await tokenService.saveTokenExpiry(pastExpiry);
        expect(await tokenService.isTokenExpired(), isTrue);
        
        // Test with no expiry set
        await tokenService.clearTokens();
        expect(await tokenService.isTokenExpired(), isTrue);
      });

      test('should return null for expiry when not set', () async {
        // Act
        final expiry = await tokenService.getTokenExpiry();
        
        // Assert
        expect(expiry, isNull);
      });
    });

    group('Edge Cases', () {
      test('should handle empty token string', () async {
        // Act
        await tokenService.saveAccessToken('');
        
        // Assert
        final token = await tokenService.getAccessToken();
        expect(token, equals(''));
      });

      test('should handle very long token', () async {
        // Arrange
        final longToken = 'a' * 10000;
        
        // Act
        await tokenService.saveAccessToken(longToken);
        
        // Assert
        final retrievedToken = await tokenService.getAccessToken();
        expect(retrievedToken, equals(longToken));
      });

      test('should handle special characters in token', () async {
        // Arrange
        const specialToken = 'token.with-special_chars@123!';
        
        // Act
        await tokenService.saveAccessToken(specialToken);
        
        // Assert
        final retrievedToken = await tokenService.getAccessToken();
        expect(retrievedToken, equals(specialToken));
      });

      test('should handle concurrent token saves', () async {
        // Arrange
        const token1 = 'token1';
        const token2 = 'token2';
        const token3 = 'token3';
        
        // Act
        await Future.wait([
          tokenService.saveAccessToken(token1),
          tokenService.saveAccessToken(token2),
          tokenService.saveAccessToken(token3),
        ]);
        
        // Assert - last write should win
        final retrievedToken = await tokenService.getAccessToken();
        expect(retrievedToken, isIn([token1, token2, token3]));
      });
    });
  });
}

