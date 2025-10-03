# Email Verification API Documentation

## Overview

This document provides comprehensive documentation for all email verification related APIs in the LGBTinder backend system. The email verification system supports multiple verification flows including registration verification, login code verification, password reset OTP, and resend functionality with built-in rate limiting and security restrictions.

## Table of Contents

1. [Authentication & Authorization](#authentication--authorization)
2. [API Endpoints](#api-endpoints)
3. [Request/Response Formats](#requestresponse-formats)
4. [Error Handling](#error-handling)
5. [Rate Limiting & Restrictions](#rate-limiting--restrictions)
6. [Security Considerations](#security-considerations)
7. [Implementation Examples](#implementation-examples)

---

## Authentication & Authorization

### Base URL
```
Production: https://api.lgbtinder.com/api
Development: http://127.0.0.1:8000/api
```

### Headers
All API requests require the following headers:
```json
{
  "Content-Type": "application/json",
  "Accept": "application/json",
  "X-Requested-With": "XMLHttpRequest"
}
```

### Authentication
- **Registration Verification**: No authentication required
- **Login Code Verification**: No authentication required  
- **Password Reset OTP**: No authentication required
- **Resend Operations**: No authentication required

### Middleware Protection
All email verification endpoints are protected by the `email.rate_limit` middleware which provides:
- IP-based rate limiting
- Automatic lockout for excessive requests
- Progressive restriction enforcement
- Real-time attempt tracking

To apply the middleware to custom routes:
```php
Route::middleware('email.rate_limit')->group(function () {
    Route::post('/custom-verification', [CustomController::class, 'sendVerification']);
});
```

---

## API Endpoints

### 1. Send Login Code

**Endpoint**: `POST /api/send-login-code`

**Description**: Sends a 6-digit verification code to user's email for login authentication.

**Request Body**:
```json
{
  "email": "user@example.com"
}
```

**Request Validation**:
- `email`: Required, valid email format, must exist in users table

**Success Response** (200):
```json
{
  "status": true,
  "message": "Login code sent successfully! Please check your email.",
  "data": {
    "email": "user@example.com",
    "resend_available_at": "2024-01-15 14:32:00",
    "hourly_attempts_remaining": 2,
    "daily_attempts_remaining": 4,
    "restriction_tier": "normal"
  }
}
```

**Error Responses**:

*Validation Error* (422):
```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "email": [
      "The email field is required.",
      "The email must be a valid email address.",
      "The selected email is invalid."
    ]
  }
}
```

*Email Not Found* (422):
```json
{
  "status": false,
  "message": "Email not found in our system"
}
```

*IP Rate Limited* (429):
```json
{
  "status": false,
  "message": "IP address has been temporarily restricted due to excessive requests",
  "data": {
    "retry_after": 3600,
    "remaining_attempts": {
      "minute": 0,
      "hourly": 0,
      "daily": 0
    }
  }
}
```

*User Rate Limited* (429):
```json
{
  "status": false,
  "message": "Please wait before requesting a new code",
  "data": {
    "next_available_at": "2024-01-15 14:32:00",
    "seconds_remaining": 120,
    "hourly_attempts_remaining": 0,
    "daily_attempts_remaining": 0,
    "restriction_tier": "warning"
  }
}
```

*Server Error* (500):
```json
{
  "status": false,
  "message": "Failed to send login code",
  "error": "Internal server error message"
}
```

---

### 2. Verify Login Code

**Endpoint**: `POST /api/verify-login-code`

**Description**: Verifies the 6-digit code sent to user's email and authenticates the user.

**Request Body**:
```json
{
  "email": "user@example.com",
  "code": "123456"
}
```

**Request Validation**:
- `email`: Required, valid email format, must exist in users table
- `code`: Required, string, exactly 6 characters

**Success Response** (200):
```json
{
  "status": true,
  "message": "Login successful!",
  "data": {
    "user": {
      "id": 1,
      "name": "John Doe",
      "email": "user@example.com",
      "email_verified_at": "2024-01-15T14:30:00.000000Z",
      "status": 1,
      "is_verify": true,
      "created_at": "2024-01-15T14:00:00.000000Z",
      "updated_at": "2024-01-15T14:30:00.000000Z"
    },
    "token": "1|abcdef1234567890...",
    "token_type": "Bearer",
    "expires_in": 3600
  }
}
```

**Error Responses**:

*Invalid Code* (422):
```json
{
  "status": false,
  "message": "Invalid or expired verification code",
  "data": {
    "restriction_tier": "warning",
    "failed_attempts": 3
  }
}
```

*Code Expired* (422):
```json
{
  "status": false,
  "message": "Verification code has expired. Please request a new one."
}
```

*User Not Found* (422):
```json
{
  "status": false,
  "message": "User not found"
}
```

---

### 3. Resend Verification (New Users)

**Endpoint**: `POST /api/resend-verification`

**Description**: Resends verification code for new user registration.

**Request Body**:
```json
{
  "email": "newuser@example.com"
}
```

**Request Validation**:
- `email`: Required, valid email format, must exist in users table

**Success Response** (200):
```json
{
  "status": true,
  "message": "Verification code sent successfully!",
  "data": {
    "user_id": 1,
    "email": "newuser@example.com",
    "resend_available_at": "2024-01-15 14:32:00",
    "hourly_attempts_remaining": 2
  }
}
```

**Rate Limited Response** (429):
```json
{
  "status": false,
  "message": "Please wait before requesting a new code",
  "data": {
    "next_available_at": "2024-01-15 14:32:00",
    "seconds_remaining": 120,
    "hourly_attempts_remaining": 1
  }
}
```

**Already Verified Response** (422):
```json
{
  "status": false,
  "message": "Email is already verified. Please login instead.",
  "errors": {
    "email": ["Email is already verified. Please login instead."]
  }
}
```

---

### 4. Resend Verification (Existing Users)

**Endpoint**: `POST /api/resend-verification-existing`

**Description**: Resends verification code for existing users who need to verify their email.

**Request Body**:
```json
{
  "email": "existinguser@example.com"
}
```

**Request Validation**:
- `email`: Required, valid email format, must exist in users table

**Success Response** (200):
```json
{
  "status": true,
  "message": "Verification code sent successfully!",
  "data": {
    "user_id": 1,
    "email": "existinguser@example.com",
    "resend_available_at": "2024-01-15 14:32:00",
    "hourly_attempts_remaining": 2
  }
}
```

**Rate Limited Response** (429):
```json
{
  "status": false,
  "message": "Please wait before requesting a new code",
  "data": {
    "next_available_at": "2024-01-15 14:32:00",
    "seconds_remaining": 120,
    "hourly_attempts_remaining": 1
  }
}
```

---

### 5. Verify Registration Code

**Endpoint**: `POST /api/send-verification`

**Description**: Verifies the 6-digit registration code and activates the user account.

**Request Body**:
```json
{
  "email": "newuser@example.com",
  "code": "123456"
}
```

**Request Validation**:
- `email`: Required, valid email format, must exist in users table
- `code`: Required, string, exactly 6 characters

**Success Response** (200):
```json
{
  "status": true,
  "message": "Email verified successfully! Welcome to LGBTinder!",
  "data": {
    "user": {
      "id": 1,
      "name": "John Doe",
      "email": "newuser@example.com",
      "email_verified_at": "2024-01-15T14:30:00.000000Z",
      "status": 1,
      "is_verify": true,
      "created_at": "2024-01-15T14:00:00.000000Z",
      "updated_at": "2024-01-15T14:30:00.000000Z"
    },
    "token": "1|abcdef1234567890...",
    "token_type": "Bearer",
    "expires_in": 3600,
    "profile_completion_required": true
  }
}
```

**Error Responses**:

*Already Verified* (422):
```json
{
  "status": false,
  "message": "Email is already verified. Please login."
}
```

*Invalid Code* (422):
```json
{
  "status": false,
  "message": "Invalid or expired verification code"
}
```

---

### 6. Send Password Reset OTP

**Endpoint**: `POST /api/send-otp`

**Description**: Sends a 6-digit OTP for password reset functionality.

**Request Body**:
```json
{
  "email": "user@example.com"
}
```

**Request Validation**:
- `email`: Required, valid email format, must exist in users table

**Success Response** (200):
```json
{
  "status": true,
  "message": "OTP sent successfully! Please check your email.",
  "data": {
    "email": "user@example.com",
    "resend_available_at": "2024-01-15 14:32:00",
    "hourly_attempts_remaining": 2
  }
}
```

**Rate Limited Response** (429):
```json
{
  "status": false,
  "message": "Too many attempts. Please try again later.",
  "data": {
    "retry_after": 300,
    "attempts_remaining": 0
  }
}
```

---

### 7. Verify Password Reset OTP

**Endpoint**: `POST /api/verify-otp`

**Description**: Verifies the OTP for password reset and allows password change.

**Request Body**:
```json
{
  "email": "user@example.com",
  "code": "123456"
}
```

**Request Validation**:
- `email`: Required, valid email format, must exist in users table
- `code`: Required, string, exactly 6 characters

**Success Response** (200):
```json
{
  "status": true,
  "message": "OTP verified successfully! You can now reset your password.",
  "data": {
    "email": "user@example.com",
    "reset_token": "reset_token_here",
    "expires_at": "2024-01-15 15:30:00"
  }
}
```

**Error Responses**:

*Invalid OTP* (422):
```json
{
  "status": false,
  "message": "Invalid or expired OTP"
}
```

*OTP Expired* (422):
```json
{
  "status": false,
  "message": "OTP has expired. Please request a new one."
}
```

---

### 8. Reset Password

**Endpoint**: `POST /api/reset-password`

**Description**: Resets user password using the reset token from OTP verification.

**Request Body**:
```json
{
  "email": "user@example.com",
  "reset_token": "reset_token_here",
  "password": "newpassword123",
  "password_confirmation": "newpassword123"
}
```

**Request Validation**:
- `email`: Required, valid email format, must exist in users table
- `reset_token`: Required, string
- `password`: Required, string, minimum 8 characters
- `password_confirmation`: Required, string, must match password

**Success Response** (200):
```json
{
  "status": true,
  "message": "Password reset successfully! You can now login with your new password.",
  "data": {
    "email": "user@example.com",
    "password_changed_at": "2024-01-15T14:30:00.000000Z"
  }
}
```

**Error Responses**:

*Invalid Token* (422):
```json
{
  "status": false,
  "message": "Invalid or expired reset token"
}
```

*Password Mismatch* (422):
```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "password_confirmation": ["The password confirmation does not match."]
  }
}
```

---

## Request/Response Formats

### Common Request Headers
```json
{
  "Content-Type": "application/json",
  "Accept": "application/json",
  "X-Requested-With": "XMLHttpRequest",
  "User-Agent": "LGBTinder-Mobile/1.0.0"
}
```

### Common Response Structure
```json
{
  "status": true|false,
  "message": "Human readable message",
  "data": {
    // Response data object
  },
  "errors": {
    // Validation errors (only present on validation failure)
  }
}
```

### Pagination (if applicable)
```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {
    "items": [],
    "pagination": {
      "current_page": 1,
      "last_page": 10,
      "per_page": 15,
      "total": 150,
      "from": 1,
      "to": 15
    }
  }
}
```

---

## Error Handling

### HTTP Status Codes

| Code | Description | Usage |
|------|-------------|-------|
| 200 | Success | Request completed successfully |
| 422 | Validation Error | Invalid request data or business logic error |
| 429 | Too Many Requests | Rate limit exceeded |
| 500 | Server Error | Internal server error |

### Error Response Format
```json
{
  "status": false,
  "message": "Error description",
  "errors": {
    "field_name": ["Error message for field"]
  },
  "error_code": "ERROR_CODE_IF_APPLICABLE"
}
```

### Common Error Codes

| Error Code | Description |
|------------|-------------|
| `VALIDATION_ERROR` | Request validation failed |
| `RATE_LIMIT_EXCEEDED` | Too many requests |
| `INVALID_CODE` | Verification code is invalid |
| `EXPIRED_CODE` | Verification code has expired |
| `EMAIL_NOT_FOUND` | Email address not found |
| `ALREADY_VERIFIED` | Email already verified |
| `USER_NOT_FOUND` | User account not found |

---

## Rate Limiting & Restrictions

### Enhanced Implementation

#### Per User Limits
- **Registration Verification**: 
  - Daily Limit: 5 attempts per day per email
  - Hourly Limit: 3 attempts per hour per email  
  - Resend Cooldown: 2 minutes between resends
  - Token Expiry: 15 minutes (reduced from 24 hours)

- **Login Code Verification**: 
  - Daily Limit: 10 attempts per day per email
  - Hourly Limit: 5 attempts per hour per email
  - Resend Cooldown: 1 minute between resends
  - Token Expiry: 5 minutes

#### Per IP Limits
- **Daily Limit**: 50 verification emails per IP per day
- **Hourly Limit**: 20 verification emails per IP per hour
- **Minute Limit**: 5 emails per IP per minute
- **Automatic IP Blocking**: 24-hour lockout for excessive violations

#### Progressive Restrictions (Escalating Penalties)
1. **Normal Tier**: Standard limits apply (2-minute cooldown, 3 hourly attempts)
2. **Warning Tier**: Increased cooldown (5 minutes), same hourly limit
3. **Restricted Tier**: Reduced hourly limit (2 attempts), 10-minute cooldown
4. **Locked Tier**: Temporary account lockout (1 hour), 60-minute cooldown

#### Security Measures
- **Suspicious Activity Detection**: 
  - 3+ attempts within 30 seconds = Temporary lockout (5 minutes)
  - 5+ attempts within 1 minute = Extended lockout (15 minutes)
- **Multiple Accounts per IP**: 
  - 5+ different email addresses from same IP in 1 hour = Rate limit reduced by 50%
  - 10+ different email addresses from same IP in 24 hours = IP flagged for review
- **Disposable Email Blocking**: Known temporary email services blocked

### Rate Limit Headers
```json
{
  "X-RateLimit-Limit": "3",
  "X-RateLimit-Remaining": "2",
  "X-RateLimit-Reset": "1642248000"
}
```

### Rate Limit Response (429)
```json
{
  "status": false,
  "message": "Rate limit exceeded. Please try again later.",
  "data": {
    "retry_after": 120,
    "limit": 3,
    "remaining": 0,
    "reset_at": "2024-01-15T14:32:00Z",
    "restriction_tier": "warning",
    "remaining_attempts": {
      "hourly": 0,
      "daily": 2
    }
  }
}
```

### Enhanced Response Data Structure

All email verification endpoints now return enhanced data including:

```json
{
  "status": true|false,
  "message": "Human readable message",
  "data": {
    "email": "user@example.com",
    "resend_available_at": "2024-01-15 14:32:00",
    "hourly_attempts_remaining": 2,
    "daily_attempts_remaining": 4,
    "restriction_tier": "normal|warning|restricted|locked",
    "failed_attempts": 0,
    "next_available_at": "2024-01-15 14:32:00",
    "seconds_remaining": 120,
    "remaining_attempts": {
      "minute": 4,
      "hourly": 2,
      "daily": 4
    }
  }
}
```

### Restriction Tier Explanations

- **normal**: Standard limits apply, no restrictions
- **warning**: Increased cooldown periods, same attempt limits
- **restricted**: Reduced hourly limits, longer cooldowns
- **locked**: Temporary account lockout, maximum restrictions

---

## Security Considerations

### Code Generation
- **Format**: 6-digit numeric codes (000000-999999)
- **Entropy**: Cryptographically secure random generation
- **Uniqueness**: Codes are unique per user session

### Token Security
- **Expiration**: All tokens have expiration times
- **Single Use**: Tokens are deleted after successful verification
- **Secure Storage**: Tokens are hashed in database

### Rate Limiting Security
- **IP-based Limits**: Prevent abuse from single IP addresses
- **User-based Limits**: Prevent individual user abuse
- **Progressive Penalties**: Escalating restrictions for repeated violations

### Email Security
- **Domain Validation**: Email domains are validated
- **Disposable Email Detection**: Block known temporary email services
- **SMTP Security**: Secure email delivery with TLS

### Configuration Options

The email verification system is highly configurable through environment variables:

```env
# Email Verification Limits
EMAIL_VERIFICATION_DAILY_LIMIT=5
EMAIL_VERIFICATION_HOURLY_LIMIT=3
EMAIL_VERIFICATION_COOLDOWN=2
EMAIL_VERIFICATION_EXPIRY=15

LOGIN_CODE_DAILY_LIMIT=10
LOGIN_CODE_HOURLY_LIMIT=5
LOGIN_CODE_COOLDOWN=1
LOGIN_CODE_EXPIRY=5

# IP Limits
IP_EMAIL_DAILY_LIMIT=50
IP_EMAIL_HOURLY_LIMIT=20
IP_EMAIL_MINUTE_LIMIT=5

# Progressive Restrictions
TIER_1_MAX_ATTEMPTS=3
TIER_2_MAX_ATTEMPTS=6
TIER_3_MAX_ATTEMPTS=10
TIER_3_LOCKOUT_HOURS=1
TIER_4_LOCKOUT_HOURS=24
```

---

## Implementation Examples

### JavaScript/Fetch Example
```javascript
// Send login code
async function sendLoginCode(email) {
  try {
    const response = await fetch('/api/send-login-code', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-Requested-With': 'XMLHttpRequest'
      },
      body: JSON.stringify({ email })
    });
    
    const data = await response.json();
    
    if (data.status) {
      console.log('Code sent:', data.message);
      return data.data;
    } else {
      throw new Error(data.message);
    }
  } catch (error) {
    console.error('Error sending code:', error);
    throw error;
  }
}

// Verify login code
async function verifyLoginCode(email, code) {
  try {
    const response = await fetch('/api/verify-login-code', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-Requested-With': 'XMLHttpRequest'
      },
      body: JSON.stringify({ email, code })
    });
    
    const data = await response.json();
    
    if (data.status) {
      // Store token for authenticated requests
      localStorage.setItem('auth_token', data.data.token);
      console.log('Login successful:', data.message);
      return data.data;
    } else {
      throw new Error(data.message);
    }
  } catch (error) {
    console.error('Error verifying code:', error);
    throw error;
  }
}
```

### React Native Example
```javascript
import AsyncStorage from '@react-native-async-storage/async-storage';

class EmailVerificationService {
  constructor(baseURL) {
    this.baseURL = baseURL;
  }

  async sendLoginCode(email) {
    const response = await fetch(`${this.baseURL}/api/send-login-code`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: JSON.stringify({ email })
    });

    const data = await response.json();
    
    if (!data.status) {
      throw new Error(data.message);
    }
    
    return data.data;
  }

  async verifyLoginCode(email, code) {
    const response = await fetch(`${this.baseURL}/api/verify-login-code`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: JSON.stringify({ email, code })
    });

    const data = await response.json();
    
    if (!data.status) {
      throw new Error(data.message);
    }
    
    // Store authentication token
    await AsyncStorage.setItem('auth_token', data.data.token);
    
    return data.data;
  }

  async resendVerification(email) {
    const response = await fetch(`${this.baseURL}/api/resend-verification`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: JSON.stringify({ email })
    });

    const data = await response.json();
    
    if (!data.status) {
      throw new Error(data.message);
    }
    
    return data.data;
  }
}

// Usage
const emailService = new EmailVerificationService('https://api.lgbtinder.com');

// Send code
emailService.sendLoginCode('user@example.com')
  .then(data => {
    console.log('Code sent, resend available at:', data.resend_available_at);
  })
  .catch(error => {
    console.error('Failed to send code:', error.message);
  });

// Verify code
emailService.verifyLoginCode('user@example.com', '123456')
  .then(data => {
    console.log('Login successful:', data.user.name);
  })
  .catch(error => {
    console.error('Failed to verify code:', error.message);
  });
```

### Flutter/Dart Example
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EmailVerificationService {
  final String baseURL;
  
  EmailVerificationService({required this.baseURL});

  Future<Map<String, dynamic>> sendLoginCode(String email) async {
    final response = await http.post(
      Uri.parse('$baseURL/api/send-login-code'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode({'email': email}),
    );

    final data = json.decode(response.body);
    
    if (!data['status']) {
      throw Exception(data['message']);
    }
    
    return data['data'];
  }

  Future<Map<String, dynamic>> verifyLoginCode(String email, String code) async {
    final response = await http.post(
      Uri.parse('$baseURL/api/verify-login-code'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode({'email': email, 'code': code}),
    );

    final data = json.decode(response.body);
    
    if (!data['status']) {
      throw Exception(data['message']);
    }
    
    // Store authentication token
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', data['data']['token']);
    
    return data['data'];
  }

  Future<Map<String, dynamic>> resendVerification(String email) async {
    final response = await http.post(
      Uri.parse('$baseURL/api/resend-verification'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode({'email': email}),
    );

    final data = json.decode(response.body);
    
    if (!data['status']) {
      throw Exception(data['message']);
    }
    
    return data['data'];
  }
}

// Usage
final emailService = EmailVerificationService(baseURL: 'https://api.lgbtinder.com');

try {
  // Send code
  final result = await emailService.sendLoginCode('user@example.com');
  print('Code sent, resend available at: ${result['resend_available_at']}');
  
  // Verify code
  final loginResult = await emailService.verifyLoginCode('user@example.com', '123456');
  print('Login successful: ${loginResult['user']['name']}');
} catch (e) {
  print('Error: $e');
}
```

---

## Testing

### Test Cases

#### Happy Path Tests
1. **Send Login Code**: Valid email → Success response
2. **Verify Login Code**: Valid email + code → Authentication success
3. **Resend Verification**: Valid email → New code sent
4. **Password Reset**: Valid email → OTP sent
5. **Verify OTP**: Valid email + OTP → Reset token provided

#### Error Path Tests
1. **Invalid Email**: Non-existent email → 422 error
2. **Invalid Code**: Wrong verification code → 422 error
3. **Expired Code**: Expired verification code → 422 error
4. **Rate Limiting**: Too many requests → 429 error
5. **Already Verified**: Verified email → 422 error

#### Edge Cases
1. **Empty Request Body**: Missing required fields → 422 error
2. **Malformed JSON**: Invalid JSON → 400 error
3. **Network Timeout**: Request timeout → 500 error
4. **Server Error**: Internal server error → 500 error

### Postman Collection
```json
{
  "info": {
    "name": "LGBTinder Email Verification API",
    "description": "Complete API collection for email verification endpoints"
  },
  "item": [
    {
      "name": "Send Login Code",
      "request": {
        "method": "POST",
        "header": [
          {
            "key": "Content-Type",
            "value": "application/json"
          }
        ],
        "body": {
          "mode": "raw",
          "raw": "{\n  \"email\": \"user@example.com\"\n}"
        },
        "url": {
          "raw": "{{base_url}}/api/send-login-code",
          "host": ["{{base_url}}"],
          "path": ["api", "send-login-code"]
        }
      }
    }
  ]
}
```

---

## Monitoring & Analytics

### Key Metrics to Track
- **Success Rate**: Percentage of successful verifications
- **Failure Rate**: Percentage of failed verification attempts
- **Rate Limit Hits**: Number of rate limit violations
- **Average Response Time**: API response time metrics
- **Email Delivery Rate**: Success rate of email delivery

### Logging
All email verification activities are logged with:
- Timestamp
- User ID (if available)
- IP Address
- User Agent
- Request/Response data
- Error details (if applicable)

### Alerts
Set up alerts for:
- High failure rates (>10%)
- Rate limit violations
- Email delivery failures
- Unusual traffic patterns
- Security threats

---

## Conclusion

This documentation provides comprehensive coverage of all email verification APIs in the LGBTinder system. The enhanced implementation includes:

### Key Features Implemented
- **Progressive Restrictions**: 4-tier system with escalating penalties
- **IP-based Rate Limiting**: Protection against abuse from single IP addresses
- **User-based Limits**: Individual user protection with daily/hourly limits
- **Security Monitoring**: Comprehensive logging and alerting
- **Automated Maintenance**: Counter resets and cleanup jobs
- **Configurable Limits**: Environment-based configuration for all restrictions
- **Enhanced Responses**: Detailed feedback on remaining attempts and restriction tiers

### Security Benefits
- **Abuse Prevention**: Multiple layers of protection against malicious users
- **Resource Protection**: Prevents email service abuse and server overload
- **User Experience**: Clear feedback on restrictions and remaining attempts
- **Compliance**: Meets industry standards for email verification security

The APIs are designed with security, rate limiting, and user experience in mind. All restrictions are configurable and can be adjusted based on business requirements.

For any questions or clarifications, please contact the development team.

---

**Last Updated**: January 15, 2024  
**Version**: 2.0.0 (Enhanced with Progressive Restrictions)  
**Maintainer**: LGBTinder Development Team
