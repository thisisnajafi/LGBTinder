import 'package:flutter_test/flutter_test.dart';
import 'package:lgbtinder/services/validation_service.dart';

void main() {
  group('ValidationService', () {
    group('Email Validation', () {
      test('should return true for valid email addresses', () {
        // Valid email formats
        expect(ValidationService.isValidEmail('test@example.com'), true);
        expect(ValidationService.isValidEmail('user.name@example.com'), true);
        expect(ValidationService.isValidEmail('user+tag@example.co.uk'), true);
        expect(ValidationService.isValidEmail('user_123@example-domain.com'), true);
      });

      test('should return false for invalid email addresses', () {
        // Invalid email formats
        expect(ValidationService.isValidEmail(''), false);
        expect(ValidationService.isValidEmail('notanemail'), false);
        expect(ValidationService.isValidEmail('@example.com'), false);
        expect(ValidationService.isValidEmail('user@'), false);
        expect(ValidationService.isValidEmail('user@.com'), false);
        expect(ValidationService.isValidEmail('user name@example.com'), false);
        expect(ValidationService.isValidEmail('user@example'), false);
      });

      test('should handle edge cases', () {
        expect(ValidationService.isValidEmail('a@b.c'), true);
        expect(ValidationService.isValidEmail('test@subdomain.example.com'), true);
      });
    });

    group('Password Validation', () {
      test('should return true for valid passwords', () {
        // Assuming minimum 8 characters
        expect(ValidationService.isValidPassword('Password123!'), true);
        expect(ValidationService.isValidPassword('12345678'), true);
        expect(ValidationService.isValidPassword('abcdefgh'), true);
      });

      test('should return false for invalid passwords', () {
        // Too short
        expect(ValidationService.isValidPassword(''), false);
        expect(ValidationService.isValidPassword('1234567'), false);
        expect(ValidationService.isValidPassword('Pass12!'), false);
      });
    });

    group('Phone Number Validation', () {
      test('should return true for valid phone numbers', () {
        expect(ValidationService.isValidPhone('+1234567890'), true);
        expect(ValidationService.isValidPhone('1234567890'), true);
        expect(ValidationService.isValidPhone('+12 345 678 90'), true);
      });

      test('should return false for invalid phone numbers', () {
        expect(ValidationService.isValidPhone(''), false);
        expect(ValidationService.isValidPhone('123'), false);
        expect(ValidationService.isValidPhone('abcdefghij'), false);
      });
    });

    group('Name Validation', () {
      test('should return true for valid names', () {
        expect(ValidationService.isValidName('John'), true);
        expect(ValidationService.isValidName('John Doe'), true);
        expect(ValidationService.isValidName("O'Brien"), true);
        expect(ValidationService.isValidName('José'), true);
      });

      test('should return false for invalid names', () {
        expect(ValidationService.isValidName(''), false);
        expect(ValidationService.isValidName('J'), false);
        expect(ValidationService.isValidName('123'), false);
        expect(ValidationService.isValidName('  '), false);
      });
    });

    group('Age Validation', () {
      test('should return true for valid ages', () {
        expect(ValidationService.isValidAge(18), true);
        expect(ValidationService.isValidAge(25), true);
        expect(ValidationService.isValidAge(100), true);
      });

      test('should return false for invalid ages', () {
        expect(ValidationService.isValidAge(17), false);
        expect(ValidationService.isValidAge(0), false);
        expect(ValidationService.isValidAge(-5), false);
        expect(ValidationService.isValidAge(101), false);
      });
    });

    group('URL Validation', () {
      test('should return true for valid URLs', () {
        expect(ValidationService.isValidUrl('https://example.com'), true);
        expect(ValidationService.isValidUrl('http://example.com'), true);
        expect(ValidationService.isValidUrl('https://www.example.com/path'), true);
        expect(ValidationService.isValidUrl('https://example.com/path?query=value'), true);
      });

      test('should return false for invalid URLs', () {
        expect(ValidationService.isValidUrl(''), false);
        expect(ValidationService.isValidUrl('not a url'), false);
        expect(ValidationService.isValidUrl('example.com'), false);
        expect(ValidationService.isValidUrl('ftp://example.com'), false);
      });
    });
  });
}

