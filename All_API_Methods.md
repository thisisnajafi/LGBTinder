# LGBTinder API - Complete Methods Documentation

**Generated from:** Postman Collection
**Base URL:** `http://localhost:8000/api`
**Total Categories:** 44

---

## Webhooks (Public - No Auth)

**Total Endpoints:** 4

- [ ] Stripe Webhook - `POST` `BASE_URL/stripe/webhook`

### Stripe Webhook

**Method:** `POST`

**Endpoint:** `BASE_URL/stripe/webhook`

**Description:** Stripe payment webhook

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Stripe Subscription Webhook - `POST` `BASE_URL/stripe/subscription-webhook`

### Stripe Subscription Webhook

**Method:** `POST`

**Endpoint:** `BASE_URL/stripe/subscription-webhook`

**Description:** Stripe subscription webhook

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Superlike Packs Webhook - `POST` `BASE_URL/superlike-packs/stripe-webhook`

### Superlike Packs Webhook

**Method:** `POST`

**Endpoint:** `BASE_URL/superlike-packs/stripe-webhook`

**Description:** Superlike packs webhook

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "User liked successfully",
  "data": {
    "like_id": 1,
    "target_user_id": 2,
    "status": "pending",
    "is_match": false,
    "created_at": "2024-01-01T12:00:00Z"
  }
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data.like_id` (integer) - Like record ID
- `data.target_user_id` (integer) - Liked user ID
- `data.status` (string) - Like status (pending/accepted/rejected)
- `data.is_match` (boolean) - Whether it's a match
- `data.created_at` (string) - Creation timestamp

#### Match Response (200) - When Mutual Like Occurs

```json
{
  "status": true,
  "message": "It's a match!",
  "data": {
    "is_match": true,
    "match_id": 1,
    "users": [
      {"id": 1, "name": "User 1"},
      {"id": 2, "name": "User 2"}
    ],
    "created_at": "2024-01-01T12:00:00Z"
  }
}
```

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] PayPal Webhook - `POST` `BASE_URL/paypal/webhook`

### PayPal Webhook

**Method:** `POST`

**Endpoint:** `BASE_URL/paypal/webhook`

**Description:** PayPal payment webhook

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information


---

## Authentication

**Total Endpoints:** 14

- [ ] Register - `POST` `BASE_URL/auth/register`

### Register

**Method:** `POST`

**Endpoint:** `BASE_URL/auth/register`

**Description:** Register new user

**Request Body:**

```json
{
  "first_name": "John",
  "last_name": "Doe",
  "email": "john.doe@example.com",
  "password": "password123",
  "referral_code": "ABC123"
}
```

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Registration successful! Please check your email for verification code.",
  "data": {
    "user_id": 1,
    "email": "user@example.com",
    "email_sent": true,
    "resend_available_at": "2024-01-01 12:02:00",
    "hourly_attempts_remaining": 2
  }
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data.user_id` (integer) - Created user ID
- `data.email` (string) - User email address
- `data.email_sent` (boolean) - Whether email was sent
- `data.resend_available_at` (string) - When resend is available
- `data.hourly_attempts_remaining` (integer) - Remaining attempts

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Login - `POST` `BASE_URL/auth/login`

### Login

**Method:** `POST`

**Endpoint:** `BASE_URL/auth/login`

**Description:** Login with email (sends verification code)

**Request Body:**

```json
{
  "email": "john.doe@example.com",
  "device_name": "iPhone 15 Pro"
}
```

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Login successful",
  "data": {
    "user": {},
    "token": "auth_token_here",
    "token_type": "Bearer",
    "profile_completed": true,
    "needs_profile_completion": false,
    "user_state": "ready_for_app"
  }
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data.user` (object) - User object
- `data.token` (string) - Authentication token
- `data.token_type` (string) - Token type (Bearer)
- `data.profile_completed` (boolean) - Profile completion status
- `data.needs_profile_completion` (boolean) - Whether profile completion is needed
- `data.user_state` (string) - Current user state

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Login with Password - `POST` `BASE_URL/auth/login-password`

### Login with Password

**Method:** `POST`

**Endpoint:** `BASE_URL/auth/login-password`

**Description:** Traditional email/password login

**Request Body:**

```json
{
  "email": "john.doe@example.com",
  "password": "password123",
  "device_name": "iPhone 15 Pro"
}
```

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Login successful",
  "data": {
    "user": {},
    "token": "auth_token_here",
    "token_type": "Bearer",
    "profile_completed": true,
    "needs_profile_completion": false,
    "user_state": "ready_for_app"
  }
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data.user` (object) - User object
- `data.token` (string) - Authentication token
- `data.token_type` (string) - Token type (Bearer)
- `data.profile_completed` (boolean) - Profile completion status
- `data.needs_profile_completion` (boolean) - Whether profile completion is needed
- `data.user_state` (string) - Current user state

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Verify Login Code - `POST` `BASE_URL/auth/verify-login-code`

### Verify Login Code

**Method:** `POST`

**Endpoint:** `BASE_URL/auth/verify-login-code`

**Description:** Verify email code for login

**Request Body:**

```json
{
  "email": "john.doe@example.com",
  "code": "123456"
}
```

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Login successful",
  "data": {
    "user": {},
    "token": "auth_token_here",
    "token_type": "Bearer",
    "profile_completed": true,
    "needs_profile_completion": false,
    "user_state": "ready_for_app"
  }
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data.user` (object) - User object
- `data.token` (string) - Authentication token
- `data.token_type` (string) - Token type (Bearer)
- `data.profile_completed` (boolean) - Profile completion status
- `data.needs_profile_completion` (boolean) - Whether profile completion is needed
- `data.user_state` (string) - Current user state

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Check User State - `POST` `BASE_URL/auth/check-user-state`

### Check User State

**Method:** `POST`

**Endpoint:** `BASE_URL/auth/check-user-state`

**Description:** Check user state and requirements

**Request Body:**

```json
{
  "email": "john.doe@example.com"
}
```

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Resend Verification - `POST` `BASE_URL/auth/resend-verification`

### Resend Verification

**Method:** `POST`

**Endpoint:** `BASE_URL/auth/resend-verification`

**Description:** Resend email verification code

**Request Body:**

```json
{
  "email": "john.doe@example.com"
}
```

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Resend Verification (Existing User) - `POST` `BASE_URL/auth/resend-verification-existing`

### Resend Verification (Existing User)

**Method:** `POST`

**Endpoint:** `BASE_URL/auth/resend-verification-existing`

**Description:** Resend verification for existing user

**Request Body:**

```json
{
  "email": "john.doe@example.com"
}
```

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Verify Registration Code - `POST` `BASE_URL/auth/send-verification`

### Verify Registration Code

**Method:** `POST`

**Endpoint:** `BASE_URL/auth/send-verification`

**Description:** Verify email registration code

**Request Body:**

```json
{
  "email": "john.doe@example.com",
  "code": "123456"
}
```

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Send OTP - `POST` `BASE_URL/auth/send-otp`

### Send OTP

**Method:** `POST`

**Endpoint:** `BASE_URL/auth/send-otp`

**Description:** Send OTP to phone number

**Request Body:**

```json
{
  "phone_number": "+1234567890"
}
```

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Verify OTP - `POST` `BASE_URL/auth/verify-otp`

### Verify OTP

**Method:** `POST`

**Endpoint:** `BASE_URL/auth/verify-otp`

**Description:** Verify OTP code

**Request Body:**

```json
{
  "phone_number": "+1234567890",
  "code": "123456"
}
```

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Reset Password - `POST` `BASE_URL/auth/reset-password`

### Reset Password

**Method:** `POST`

**Endpoint:** `BASE_URL/auth/reset-password`

**Description:** Reset password using OTP

**Request Body:**

```json
{
  "phone_number": "+1234567890",
  "code": "123456",
  "new_password": "newpassword123"
}
```

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Change Password - `POST` `BASE_URL/auth/change-password`

### Change Password

**Method:** `POST`

**Endpoint:** `BASE_URL/auth/change-password`

**Description:** Change user password (requires auth)

**Request Body:**

```json
{
  "current_password": "oldpassword",
  "new_password": "newpassword123"
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Delete Account - `DELETE` `BASE_URL/auth/delete-account`

### Delete Account

**Method:** `DELETE`

**Endpoint:** `BASE_URL/auth/delete-account`

**Description:** Delete user account

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Deleted successfully"
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Logout - `POST` `BASE_URL/auth/logout`

### Logout

**Method:** `POST`

**Endpoint:** `BASE_URL/auth/logout`

**Description:** Logout user

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information


---

## Social Authentication

**Total Endpoints:** 4

- [ ] Get Google Auth URL - `GET` `BASE_URL/auth/google/url`

### Get Google Auth URL

**Method:** `GET`

**Endpoint:** `BASE_URL/auth/google/url`

**Description:** Get Google OAuth authorization URL

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Google OAuth Callback - `POST` `BASE_URL/auth/google/callback`

### Google OAuth Callback

**Method:** `POST`

**Endpoint:** `BASE_URL/auth/google/callback`

**Description:** Handle Google OAuth callback

**Request Body:**

```json
{
  "code": "authorization_code_here"
}
```

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Linked Accounts - `GET` `BASE_URL/auth/linked-accounts`

### Get Linked Accounts

**Method:** `GET`

**Endpoint:** `BASE_URL/auth/linked-accounts`

**Description:** Get user's linked social accounts

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Unlink Google Account - `DELETE` `BASE_URL/auth/google/unlink`

### Unlink Google Account

**Method:** `DELETE`

**Endpoint:** `BASE_URL/auth/google/unlink`

**Description:** Unlink Google account

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Deleted successfully"
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information


---

## Profile Completion

**Total Endpoints:** 1

- [ ] Complete Registration - `POST` `BASE_URL/complete-registration`

### Complete Registration

**Method:** `POST`

**Endpoint:** `BASE_URL/complete-registration`

**Description:** Complete profile registration

**Request Body:**

```json
{
  "device_name": "iPhone 15 Pro",
  "country_id": 1,
  "city_id": 1,
  "gender": 1,
  "birth_date": "1995-06-15",
  "min_age_preference": 21,
  "max_age_preference": 35,
  "profile_bio": "Love traveling and music!",
  "height": 175,
  "weight": 70,
  "smoke": false,
  "drink": true,
  "gym": true,
  "music_genres": [
    1,
    3,
    5
  ],
  "educations": [
    2,
    3
  ],
  "jobs": [
    1,
    4
  ],
  "languages": [
    1,
    2
  ],
  "interests": [
    1,
    2,
    3
  ],
  "preferred_genders": [
    1,
    3
  ],
  "relation_goals": [
    1,
    2
  ]
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information


---

## Profile Wizard

**Total Endpoints:** 3

- [ ] Get Current Step - `GET` `BASE_URL/profile-wizard/current-step`

### Get Current Step

**Method:** `GET`

**Endpoint:** `BASE_URL/profile-wizard/current-step`

**Description:** Get current profile wizard step

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Step Options - `GET` `BASE_URL/profile-wizard/step-options/:step`

### Get Step Options

**Method:** `GET`

**Endpoint:** `BASE_URL/profile-wizard/step-options/:step`

**Description:** Get options for wizard step

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Save Step - `POST` `BASE_URL/profile-wizard/save-step/:step`

### Save Step

**Method:** `POST`

**Endpoint:** `BASE_URL/profile-wizard/save-step/:step`

**Description:** Save wizard step data

**Request Body:**

```json
{
  "data": {}
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information


---

## User

**Total Endpoints:** 5

- [ ] Get Current User - `GET` `BASE_URL/user`

### Get Current User

**Method:** `GET`

**Endpoint:** `BASE_URL/user`

**Description:** Get authenticated user details

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Set Show Adult Content - `POST` `BASE_URL/user/show-adult-content`

### Set Show Adult Content

**Method:** `POST`

**Endpoint:** `BASE_URL/user/show-adult-content`

**Description:** Update adult content preference

**Request Body:**

```json
{
  "show_adult_content": true
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Save OneSignal Player ID - `POST` `BASE_URL/user/onesignal-player`

### Save OneSignal Player ID

**Method:** `POST`

**Endpoint:** `BASE_URL/user/onesignal-player`

**Description:** Save OneSignal player ID

**Request Body:**

```json
{
  "player_id": "onesignal_player_id_here"
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Update Notification Preferences - `POST` `BASE_URL/user/notification-preferences`

### Update Notification Preferences

**Method:** `POST`

**Endpoint:** `BASE_URL/user/notification-preferences`

**Description:** Update notification preferences

**Request Body:**

```json
{
  "match_notifications": true,
  "message_notifications": true,
  "like_notifications": true
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Notification History - `GET` `BASE_URL/user/notification-history`

### Get Notification History

**Method:** `GET`

**Endpoint:** `BASE_URL/user/notification-history`

**Description:** Get user notification history

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {
    "items": [],
    "current_page": 1,
    "per_page": 15,
    "total": 0,
    "last_page": 1
  }
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data.items` (array) - List of items
- `data.current_page` (integer) - Current page number
- `data.per_page` (integer) - Items per page
- `data.total` (integer) - Total number of items
- `data.last_page` (integer) - Last page number

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information


---

## Profile

**Total Endpoints:** 15

- [ ] Get Profile - `GET` `BASE_URL/profile`

### Get Profile

**Method:** `GET`

**Endpoint:** `BASE_URL/profile`

**Description:** Get current user profile

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Profile Badge Info - `GET` `BASE_URL/profile/badge/info`

### Get Profile Badge Info

**Method:** `GET`

**Endpoint:** `BASE_URL/profile/badge/info`

**Description:** Get profile badge information

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get User Profile - `GET` `BASE_URL/profile/:id`

### Get User Profile

**Method:** `GET`

**Endpoint:** `BASE_URL/profile/:id`

**Description:** Get specific user profile

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get User Feeds - `GET` `BASE_URL/profile/:id/feeds`

### Get User Feeds

**Method:** `GET`

**Endpoint:** `BASE_URL/profile/:id/feeds`

**Description:** Get user's feed posts

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Update Profile - `POST` `BASE_URL/profile/update`

### Update Profile

**Method:** `POST`

**Endpoint:** `BASE_URL/profile/update`

**Description:** Update user profile

**Request Body:**

```json
{
  "profile_bio": "Updated bio",
  "height": 180,
  "weight": 75
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Change Email - `POST` `BASE_URL/profile/change-email`

### Change Email

**Method:** `POST`

**Endpoint:** `BASE_URL/profile/change-email`

**Description:** Request email change

**Request Body:**

```json
{
  "new_email": "newemail@example.com",
  "password": "currentpassword"
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Verify Email Change - `POST` `BASE_URL/profile/verify-email-change`

### Verify Email Change

**Method:** `POST`

**Endpoint:** `BASE_URL/profile/verify-email-change`

**Description:** Verify email change code

**Request Body:**

```json
{
  "code": "123456"
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Users by Job - `GET` `BASE_URL/profile/by-job/:jobId`

### Get Users by Job

**Method:** `GET`

**Endpoint:** `BASE_URL/profile/by-job/:jobId`

**Description:** Get users by job

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Users by Language - `GET` `BASE_URL/profile/by-language/:languageId`

### Get Users by Language

**Method:** `GET`

**Endpoint:** `BASE_URL/profile/by-language/:languageId`

**Description:** Get users by language

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Users by Relation Goal - `GET` `BASE_URL/profile/by-relation-goal/:relationGoalId`

### Get Users by Relation Goal

**Method:** `GET`

**Endpoint:** `BASE_URL/profile/by-relation-goal/:relationGoalId`

**Description:** Get users by relation goal

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Users by Interest - `GET` `BASE_URL/profile/by-interest/:interestId`

### Get Users by Interest

**Method:** `GET`

**Endpoint:** `BASE_URL/profile/by-interest/:interestId`

**Description:** Get users by interest

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Users by Music Genre - `GET` `BASE_URL/profile/by-music-genre/:musicGenreId`

### Get Users by Music Genre

**Method:** `GET`

**Endpoint:** `BASE_URL/profile/by-music-genre/:musicGenreId`

**Description:** Get users by music genre

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Users by Education - `GET` `BASE_URL/profile/by-education/:educationId`

### Get Users by Education

**Method:** `GET`

**Endpoint:** `BASE_URL/profile/by-education/:educationId`

**Description:** Get users by education

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Users by Preferred Gender - `GET` `BASE_URL/profile/by-preferred-gender/:preferredGenderId`

### Get Users by Preferred Gender

**Method:** `GET`

**Endpoint:** `BASE_URL/profile/by-preferred-gender/:preferredGenderId`

**Description:** Get users by preferred gender

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Users by Gender - `GET` `BASE_URL/profile/by-gender/:genderId`

### Get Users by Gender

**Method:** `GET`

**Endpoint:** `BASE_URL/profile/by-gender/:genderId`

**Description:** Get users by gender

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information


---

## Images

**Total Endpoints:** 5

- [ ] Upload Image - `POST` `BASE_URL/images/upload`

### Upload Image

**Method:** `POST`

**Endpoint:** `BASE_URL/images/upload`

**Description:** Upload gallery image

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Delete Image - `DELETE` `BASE_URL/images/:id`

### Delete Image

**Method:** `DELETE`

**Endpoint:** `BASE_URL/images/:id`

**Description:** Delete image

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Deleted successfully"
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Reorder Images - `POST` `BASE_URL/images/reorder`

### Reorder Images

**Method:** `POST`

**Endpoint:** `BASE_URL/images/reorder`

**Description:** Reorder images

**Request Body:**

```json
{
  "image_ids": [
    1,
    2,
    3,
    4
  ]
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Set Primary Image - `POST` `BASE_URL/images/:id/set-primary`

### Set Primary Image

**Method:** `POST`

**Endpoint:** `BASE_URL/images/:id/set-primary`

**Description:** Set primary image

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] List Images - `GET` `BASE_URL/images/list`

### List Images

**Method:** `GET`

**Endpoint:** `BASE_URL/images/list`

**Description:** List user images

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {
    "items": [],
    "current_page": 1,
    "per_page": 15,
    "total": 0,
    "last_page": 1
  }
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data.items` (array) - List of items
- `data.current_page` (integer) - Current page number
- `data.per_page` (integer) - Items per page
- `data.total` (integer) - Total number of items
- `data.last_page` (integer) - Last page number

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information


---

## Profile Pictures

**Total Endpoints:** 4

- [ ] Upload Profile Picture - `POST` `BASE_URL/profile-pictures/upload`

### Upload Profile Picture

**Method:** `POST`

**Endpoint:** `BASE_URL/profile-pictures/upload`

**Description:** Upload profile picture

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Delete Profile Picture - `DELETE` `BASE_URL/profile-pictures/:id`

### Delete Profile Picture

**Method:** `DELETE`

**Endpoint:** `BASE_URL/profile-pictures/:id`

**Description:** Delete profile picture

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Deleted successfully"
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Set Primary Profile Picture - `POST` `BASE_URL/profile-pictures/:id/set-primary`

### Set Primary Profile Picture

**Method:** `POST`

**Endpoint:** `BASE_URL/profile-pictures/:id/set-primary`

**Description:** Set primary profile picture

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] List Profile Pictures - `GET` `BASE_URL/profile-pictures/list`

### List Profile Pictures

**Method:** `GET`

**Endpoint:** `BASE_URL/profile-pictures/list`

**Description:** List profile pictures

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {
    "items": [],
    "current_page": 1,
    "per_page": 15,
    "total": 0,
    "last_page": 1
  }
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data.items` (array) - List of items
- `data.current_page` (integer) - Current page number
- `data.per_page` (integer) - Items per page
- `data.total` (integer) - Total number of items
- `data.last_page` (integer) - Last page number

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information


---

## Age Preferences

**Total Endpoints:** 3

- [ ] Update Age Preference - `PUT` `BASE_URL/preferences/age`

### Update Age Preference

**Method:** `PUT`

**Endpoint:** `BASE_URL/preferences/age`

**Description:** Update age preferences

**Request Body:**

```json
{
  "min_age": 21,
  "max_age": 35
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Updated successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Updated data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["Error message"]
  }
}
```

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Age Preference - `GET` `BASE_URL/preferences/age`

### Get Age Preference

**Method:** `GET`

**Endpoint:** `BASE_URL/preferences/age`

**Description:** Get age preferences

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Reset Age Preference - `DELETE` `BASE_URL/preferences/age`

### Reset Age Preference

**Method:** `DELETE`

**Endpoint:** `BASE_URL/preferences/age`

**Description:** Reset age preferences

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Deleted successfully"
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information


---

## Matching

**Total Endpoints:** 8

- [ ] Get Matches - `GET` `BASE_URL/matching/matches`

### Get Matches

**Method:** `GET`

**Endpoint:** `BASE_URL/matching/matches`

**Description:** Get user matches

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {
    "items": [],
    "current_page": 1,
    "per_page": 15,
    "total": 0,
    "last_page": 1
  }
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data.items` (array) - List of items
- `data.current_page` (integer) - Current page number
- `data.per_page` (integer) - Items per page
- `data.total` (integer) - Total number of items
- `data.last_page` (integer) - Last page number

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Nearby Suggestions - `GET` `BASE_URL/matching/nearby-suggestions`

### Get Nearby Suggestions

**Method:** `GET`

**Endpoint:** `BASE_URL/matching/nearby-suggestions`

**Description:** Get nearby user suggestions

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Debug Matches - `GET` `BASE_URL/matching/debug`

### Debug Matches

**Method:** `GET`

**Endpoint:** `BASE_URL/matching/debug`

**Description:** Debug matching algorithm

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Test User Data - `GET` `BASE_URL/matching/test`

### Test User Data

**Method:** `GET`

**Endpoint:** `BASE_URL/matching/test`

**Description:** Test user matching data

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Advanced Matches - `GET` `BASE_URL/matching/advanced`

### Get Advanced Matches

**Method:** `GET`

**Endpoint:** `BASE_URL/matching/advanced`

**Description:** Get advanced matches

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Compatibility Score - `GET` `BASE_URL/matching/compatibility-score`

### Get Compatibility Score

**Method:** `GET`

**Endpoint:** `BASE_URL/matching/compatibility-score`

**Description:** Get compatibility score

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get AI Suggestions - `GET` `BASE_URL/matching/ai-suggestions`

### Get AI Suggestions

**Method:** `GET`

**Endpoint:** `BASE_URL/matching/ai-suggestions`

**Description:** Get AI match suggestions

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Location Based Matches - `GET` `BASE_URL/matching/location-based`

### Get Location Based Matches

**Method:** `GET`

**Endpoint:** `BASE_URL/matching/location-based`

**Description:** Get location-based matches

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information


---

## Likes

**Total Endpoints:** 7

- [ ] Like User - `POST` `BASE_URL/likes/like`

### Like User

**Method:** `POST`

**Endpoint:** `BASE_URL/likes/like`

**Description:** Like a user

**Request Body:**

```json
{
  "liked_user_id": 2
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "User liked successfully",
  "data": {
    "like_id": 1,
    "target_user_id": 2,
    "status": "pending",
    "is_match": false,
    "created_at": "2024-01-01T12:00:00Z"
  }
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data.like_id` (integer) - Like record ID
- `data.target_user_id` (integer) - Liked user ID
- `data.status` (string) - Like status (pending/accepted/rejected)
- `data.is_match` (boolean) - Whether it's a match
- `data.created_at` (string) - Creation timestamp

#### Match Response (200) - When Mutual Like Occurs

```json
{
  "status": true,
  "message": "It's a match!",
  "data": {
    "is_match": true,
    "match_id": 1,
    "users": [
      {"id": 1, "name": "User 1"},
      {"id": 2, "name": "User 2"}
    ],
    "created_at": "2024-01-01T12:00:00Z"
  }
}
```

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Dislike User - `POST` `BASE_URL/likes/dislike`

### Dislike User

**Method:** `POST`

**Endpoint:** `BASE_URL/likes/dislike`

**Description:** Dislike a user

**Request Body:**

```json
{
  "disliked_user_id": 2
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "User liked successfully",
  "data": {
    "like_id": 1,
    "target_user_id": 2,
    "status": "pending",
    "is_match": false,
    "created_at": "2024-01-01T12:00:00Z"
  }
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data.like_id` (integer) - Like record ID
- `data.target_user_id` (integer) - Liked user ID
- `data.status` (string) - Like status (pending/accepted/rejected)
- `data.is_match` (boolean) - Whether it's a match
- `data.created_at` (string) - Creation timestamp

#### Match Response (200) - When Mutual Like Occurs

```json
{
  "status": true,
  "message": "It's a match!",
  "data": {
    "is_match": true,
    "match_id": 1,
    "users": [
      {"id": 1, "name": "User 1"},
      {"id": 2, "name": "User 2"}
    ],
    "created_at": "2024-01-01T12:00:00Z"
  }
}
```

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Superlike User - `POST` `BASE_URL/likes/superlike`

### Superlike User

**Method:** `POST`

**Endpoint:** `BASE_URL/likes/superlike`

**Description:** Superlike a user

**Request Body:**

```json
{
  "superliked_user_id": 2
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "User liked successfully",
  "data": {
    "like_id": 1,
    "target_user_id": 2,
    "status": "pending",
    "is_match": false,
    "created_at": "2024-01-01T12:00:00Z"
  }
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data.like_id` (integer) - Like record ID
- `data.target_user_id` (integer) - Liked user ID
- `data.status` (string) - Like status (pending/accepted/rejected)
- `data.is_match` (boolean) - Whether it's a match
- `data.created_at` (string) - Creation timestamp

#### Match Response (200) - When Mutual Like Occurs

```json
{
  "status": true,
  "message": "It's a match!",
  "data": {
    "is_match": true,
    "match_id": 1,
    "users": [
      {"id": 1, "name": "User 1"},
      {"id": 2, "name": "User 2"}
    ],
    "created_at": "2024-01-01T12:00:00Z"
  }
}
```

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Respond to Like - `POST` `BASE_URL/likes/respond`

### Respond to Like

**Method:** `POST`

**Endpoint:** `BASE_URL/likes/respond`

**Description:** Respond to a like

**Request Body:**

```json
{
  "like_id": 1,
  "response": "accept"
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "User liked successfully",
  "data": {
    "like_id": 1,
    "target_user_id": 2,
    "status": "pending",
    "is_match": false,
    "created_at": "2024-01-01T12:00:00Z"
  }
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data.like_id` (integer) - Like record ID
- `data.target_user_id` (integer) - Liked user ID
- `data.status` (string) - Like status (pending/accepted/rejected)
- `data.is_match` (boolean) - Whether it's a match
- `data.created_at` (string) - Creation timestamp

#### Match Response (200) - When Mutual Like Occurs

```json
{
  "status": true,
  "message": "It's a match!",
  "data": {
    "is_match": true,
    "match_id": 1,
    "users": [
      {"id": 1, "name": "User 1"},
      {"id": 2, "name": "User 2"}
    ],
    "created_at": "2024-01-01T12:00:00Z"
  }
}
```

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Matches - `GET` `BASE_URL/likes/matches`

### Get Matches

**Method:** `GET`

**Endpoint:** `BASE_URL/likes/matches`

**Description:** Get matches from likes

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {
    "items": [],
    "current_page": 1,
    "per_page": 15,
    "total": 0,
    "last_page": 1
  }
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data.items` (array) - List of items
- `data.current_page` (integer) - Current page number
- `data.per_page` (integer) - Items per page
- `data.total` (integer) - Total number of items
- `data.last_page` (integer) - Last page number

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Pending Likes - `GET` `BASE_URL/likes/pending`

### Get Pending Likes

**Method:** `GET`

**Endpoint:** `BASE_URL/likes/pending`

**Description:** Get pending likes

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Superlike History - `GET` `BASE_URL/likes/superlike-history`

### Get Superlike History

**Method:** `GET`

**Endpoint:** `BASE_URL/likes/superlike-history`

**Description:** Get superlike history

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {
    "items": [],
    "current_page": 1,
    "per_page": 15,
    "total": 0,
    "last_page": 1
  }
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data.items` (array) - List of items
- `data.current_page` (integer) - Current page number
- `data.per_page` (integer) - Items per page
- `data.total` (integer) - Total number of items
- `data.last_page` (integer) - Last page number

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information


---

## Chat

**Total Endpoints:** 10

- [ ] Send Message - `POST` `BASE_URL/chat/send`

### Send Message

**Method:** `POST`

**Endpoint:** `BASE_URL/chat/send`

**Description:** Send chat message

**Request Body:**

```json
{
  "receiver_id": 2,
  "content": "Hello!",
  "type": "text"
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Chat History - `GET` `BASE_URL/chat/history`

### Get Chat History

**Method:** `GET`

**Endpoint:** `BASE_URL/chat/history`

**Description:** Get chat history

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {
    "items": [],
    "current_page": 1,
    "per_page": 15,
    "total": 0,
    "last_page": 1
  }
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data.items` (array) - List of items
- `data.current_page` (integer) - Current page number
- `data.per_page` (integer) - Items per page
- `data.total` (integer) - Total number of items
- `data.last_page` (integer) - Last page number

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Chat Users - `GET` `BASE_URL/chat/users`

### Get Chat Users

**Method:** `GET`

**Endpoint:** `BASE_URL/chat/users`

**Description:** Get users with chats

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Chat Access Users - `GET` `BASE_URL/chat/access-users`

### Get Chat Access Users

**Method:** `GET`

**Endpoint:** `BASE_URL/chat/access-users`

**Description:** Get users with chat access

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Delete Message - `DELETE` `BASE_URL/chat/message`

### Delete Message

**Method:** `DELETE`

**Endpoint:** `BASE_URL/chat/message`

**Description:** Delete message

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Deleted successfully"
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Unread Count - `GET` `BASE_URL/chat/unread-count`

### Get Unread Count

**Method:** `GET`

**Endpoint:** `BASE_URL/chat/unread-count`

**Description:** Get unread message count

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Set Typing - `POST` `BASE_URL/chat/typing`

### Set Typing

**Method:** `POST`

**Endpoint:** `BASE_URL/chat/typing`

**Description:** Set typing indicator

**Request Body:**

```json
{
  "receiver_id": 2,
  "is_typing": true
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Mark as Read - `POST` `BASE_URL/chat/read`

### Mark as Read

**Method:** `POST`

**Endpoint:** `BASE_URL/chat/read`

**Description:** Mark messages as read

**Request Body:**

```json
{
  "message_id": 1
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Set Online Status - `POST` `BASE_URL/chat/online`

### Set Online Status

**Method:** `POST`

**Endpoint:** `BASE_URL/chat/online`

**Description:** Set online status

**Request Body:**

```json
{
  "is_online": true
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Serve Secure Media - `GET` `BASE_URL/secure-media/:message_id/:user_id/:token/:expires`

### Serve Secure Media

**Method:** `GET`

**Endpoint:** `BASE_URL/secure-media/:message_id/:user_id/:token/:expires`

**Description:** Serve secure media

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information


---

## Group Chat

**Total Endpoints:** 8

- [ ] Create Group - `POST` `BASE_URL/group-chat/create`

### Create Group

**Method:** `POST`

**Endpoint:** `BASE_URL/group-chat/create`

**Description:** Create group chat

**Request Body:**

```json
{
  "name": "Group Name",
  "member_ids": [
    2,
    3,
    4
  ]
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get User Groups - `GET` `BASE_URL/group-chat/groups`

### Get User Groups

**Method:** `GET`

**Endpoint:** `BASE_URL/group-chat/groups`

**Description:** Get user's groups

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Group Details - `GET` `BASE_URL/group-chat/groups/:groupId`

### Get Group Details

**Method:** `GET`

**Endpoint:** `BASE_URL/group-chat/groups/:groupId`

**Description:** Get group details

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Send Group Message - `POST` `BASE_URL/group-chat/send-message`

### Send Group Message

**Method:** `POST`

**Endpoint:** `BASE_URL/group-chat/send-message`

**Description:** Send group message

**Request Body:**

```json
{
  "group_id": 1,
  "content": "Hello group!",
  "type": "text"
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Message sent successfully",
  "data": {
    "message": {
      "id": 1,
      "chat_id": 1,
      "sender_id": 1,
      "receiver_id": 2,
      "content": "Hello!",
      "type": "text",
      "created_at": "2024-01-01T12:00:00Z",
      "read_at": null
    }
  }
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data.message.id` (integer) - Message ID
- `data.message.chat_id` (integer) - Chat ID
- `data.message.sender_id` (integer) - Sender user ID
- `data.message.receiver_id` (integer) - Receiver user ID
- `data.message.content` (string) - Message content
- `data.message.type` (string) - Message type (text/image/video)
- `data.message.created_at` (string) - Creation timestamp
- `data.message.read_at` (string|null) - Read timestamp

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Group Chat History - `GET` `BASE_URL/group-chat/groups/:groupId/messages`

### Get Group Chat History

**Method:** `GET`

**Endpoint:** `BASE_URL/group-chat/groups/:groupId/messages`

**Description:** Get group chat history

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Add Members - `POST` `BASE_URL/group-chat/groups/:groupId/add-members`

### Add Members

**Method:** `POST`

**Endpoint:** `BASE_URL/group-chat/groups/:groupId/add-members`

**Description:** Add members to group

**Request Body:**

```json
{
  "member_ids": [
    5,
    6
  ]
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Remove Member - `DELETE` `BASE_URL/group-chat/groups/:groupId/remove-member`

### Remove Member

**Method:** `DELETE`

**Endpoint:** `BASE_URL/group-chat/groups/:groupId/remove-member`

**Description:** Remove member from group

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Deleted successfully"
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Leave Group - `POST` `BASE_URL/group-chat/groups/:groupId/leave`

### Leave Group

**Method:** `POST`

**Endpoint:** `BASE_URL/group-chat/groups/:groupId/leave`

**Description:** Leave group

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information


---

## Calls

**Total Endpoints:** 10

- [ ] Initiate Call - `POST` `BASE_URL/calls/initiate`

### Initiate Call

**Method:** `POST`

**Endpoint:** `BASE_URL/calls/initiate`

**Description:** Initiate call

**Request Body:**

```json
{
  "receiver_id": 2,
  "call_type": "video"
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Accept Call - `POST` `BASE_URL/calls/accept`

### Accept Call

**Method:** `POST`

**Endpoint:** `BASE_URL/calls/accept`

**Description:** Accept call

**Request Body:**

```json
{
  "call_id": 1
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Reject Call - `POST` `BASE_URL/calls/reject`

### Reject Call

**Method:** `POST`

**Endpoint:** `BASE_URL/calls/reject`

**Description:** Reject call

**Request Body:**

```json
{
  "call_id": 1
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] End Call - `POST` `BASE_URL/calls/end`

### End Call

**Method:** `POST`

**Endpoint:** `BASE_URL/calls/end`

**Description:** End call

**Request Body:**

```json
{
  "call_id": 1
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Call History - `GET` `BASE_URL/calls/history`

### Get Call History

**Method:** `GET`

**Endpoint:** `BASE_URL/calls/history`

**Description:** Get call history

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {
    "items": [],
    "current_page": 1,
    "per_page": 15,
    "total": 0,
    "last_page": 1
  }
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data.items` (array) - List of items
- `data.current_page` (integer) - Current page number
- `data.per_page` (integer) - Items per page
- `data.total` (integer) - Total number of items
- `data.last_page` (integer) - Last page number

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Active Call - `GET` `BASE_URL/calls/active`

### Get Active Call

**Method:** `GET`

**Endpoint:** `BASE_URL/calls/active`

**Description:** Get active call

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Call Settings - `GET` `BASE_URL/calls/settings`

### Get Call Settings

**Method:** `GET`

**Endpoint:** `BASE_URL/calls/settings`

**Description:** Get call settings

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Update Call Settings - `PUT` `BASE_URL/calls/settings`

### Update Call Settings

**Method:** `PUT`

**Endpoint:** `BASE_URL/calls/settings`

**Description:** Update call settings

**Request Body:**

```json
{
  "auto_answer": false,
  "call_notifications": true
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Updated successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Updated data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["Error message"]
  }
}
```

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Call Quota - `GET` `BASE_URL/calls/quota`

### Get Call Quota

**Method:** `GET`

**Endpoint:** `BASE_URL/calls/quota`

**Description:** Get call quota

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Call Statistics - `GET` `BASE_URL/calls/statistics`

### Get Call Statistics

**Method:** `GET`

**Endpoint:** `BASE_URL/calls/statistics`

**Description:** Get call statistics

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information


---

## Stories

**Total Endpoints:** 7

- [ ] Get Stories - `GET` `BASE_URL/stories`

### Get Stories

**Method:** `GET`

**Endpoint:** `BASE_URL/stories`

**Description:** Get stories feed

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Upload Story - `POST` `BASE_URL/stories/upload`

### Upload Story

**Method:** `POST`

**Endpoint:** `BASE_URL/stories/upload`

**Description:** Upload story

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Story - `GET` `BASE_URL/stories/:id`

### Get Story

**Method:** `GET`

**Endpoint:** `BASE_URL/stories/:id`

**Description:** Get story details

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Like Story - `POST` `BASE_URL/stories/:id/like`

### Like Story

**Method:** `POST`

**Endpoint:** `BASE_URL/stories/:id/like`

**Description:** Like story

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "User liked successfully",
  "data": {
    "like_id": 1,
    "target_user_id": 2,
    "status": "pending",
    "is_match": false,
    "created_at": "2024-01-01T12:00:00Z"
  }
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data.like_id` (integer) - Like record ID
- `data.target_user_id` (integer) - Liked user ID
- `data.status` (string) - Like status (pending/accepted/rejected)
- `data.is_match` (boolean) - Whether it's a match
- `data.created_at` (string) - Creation timestamp

#### Match Response (200) - When Mutual Like Occurs

```json
{
  "status": true,
  "message": "It's a match!",
  "data": {
    "is_match": true,
    "match_id": 1,
    "users": [
      {"id": 1, "name": "User 1"},
      {"id": 2, "name": "User 2"}
    ],
    "created_at": "2024-01-01T12:00:00Z"
  }
}
```

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Delete Story - `DELETE` `BASE_URL/stories/:id`

### Delete Story

**Method:** `DELETE`

**Endpoint:** `BASE_URL/stories/:id`

**Description:** Delete story

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Deleted successfully"
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Story Replies - `GET` `BASE_URL/stories/:storyId/replies`

### Get Story Replies

**Method:** `GET`

**Endpoint:** `BASE_URL/stories/:storyId/replies`

**Description:** Get story replies

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Reply to Story - `POST` `BASE_URL/stories/:storyId/reply`

### Reply to Story

**Method:** `POST`

**Endpoint:** `BASE_URL/stories/:storyId/reply`

**Description:** Reply to story

**Request Body:**

```json
{
  "content": "Great story!"
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information


---

## Feeds

**Total Endpoints:** 16

- [ ] Get Feeds - `GET` `BASE_URL/feeds`

### Get Feeds

**Method:** `GET`

**Endpoint:** `BASE_URL/feeds`

**Description:** Get feeds feed

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Create Feed - `POST` `BASE_URL/feeds/create`

### Create Feed

**Method:** `POST`

**Endpoint:** `BASE_URL/feeds/create`

**Description:** Create feed post

**Request Body:**

```json
{
  "content": "My post content",
  "images": []
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Feed - `GET` `BASE_URL/feeds/:id`

### Get Feed

**Method:** `GET`

**Endpoint:** `BASE_URL/feeds/:id`

**Description:** Get feed details

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Update Feed - `PUT` `BASE_URL/feeds/update/:id`

### Update Feed

**Method:** `PUT`

**Endpoint:** `BASE_URL/feeds/update/:id`

**Description:** Update feed post

**Request Body:**

```json
{
  "content": "Updated content"
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Updated successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Updated data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["Error message"]
  }
}
```

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Delete Feed - `DELETE` `BASE_URL/feeds/:id`

### Delete Feed

**Method:** `DELETE`

**Endpoint:** `BASE_URL/feeds/:id`

**Description:** Delete feed post

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Deleted successfully"
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Feed Comments - `GET` `BASE_URL/feeds/:feedId/comments`

### Get Feed Comments

**Method:** `GET`

**Endpoint:** `BASE_URL/feeds/:feedId/comments`

**Description:** Get feed comments

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Create Comment - `POST` `BASE_URL/feeds/:feedId/comments`

### Create Comment

**Method:** `POST`

**Endpoint:** `BASE_URL/feeds/:feedId/comments`

**Description:** Create comment

**Request Body:**

```json
{
  "content": "Great post!"
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Like Comment - `POST` `BASE_URL/feeds/:feedId/comments/:commentId/like`

### Like Comment

**Method:** `POST`

**Endpoint:** `BASE_URL/feeds/:feedId/comments/:commentId/like`

**Description:** Like comment

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "User liked successfully",
  "data": {
    "like_id": 1,
    "target_user_id": 2,
    "status": "pending",
    "is_match": false,
    "created_at": "2024-01-01T12:00:00Z"
  }
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data.like_id` (integer) - Like record ID
- `data.target_user_id` (integer) - Liked user ID
- `data.status` (string) - Like status (pending/accepted/rejected)
- `data.is_match` (boolean) - Whether it's a match
- `data.created_at` (string) - Creation timestamp

#### Match Response (200) - When Mutual Like Occurs

```json
{
  "status": true,
  "message": "It's a match!",
  "data": {
    "is_match": true,
    "match_id": 1,
    "users": [
      {"id": 1, "name": "User 1"},
      {"id": 2, "name": "User 2"}
    ],
    "created_at": "2024-01-01T12:00:00Z"
  }
}
```

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Dislike Comment - `POST` `BASE_URL/feeds/:feedId/comments/:commentId/dislike`

### Dislike Comment

**Method:** `POST`

**Endpoint:** `BASE_URL/feeds/:feedId/comments/:commentId/dislike`

**Description:** Dislike comment

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "User liked successfully",
  "data": {
    "like_id": 1,
    "target_user_id": 2,
    "status": "pending",
    "is_match": false,
    "created_at": "2024-01-01T12:00:00Z"
  }
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data.like_id` (integer) - Like record ID
- `data.target_user_id` (integer) - Liked user ID
- `data.status` (string) - Like status (pending/accepted/rejected)
- `data.is_match` (boolean) - Whether it's a match
- `data.created_at` (string) - Creation timestamp

#### Match Response (200) - When Mutual Like Occurs

```json
{
  "status": true,
  "message": "It's a match!",
  "data": {
    "is_match": true,
    "match_id": 1,
    "users": [
      {"id": 1, "name": "User 1"},
      {"id": 2, "name": "User 2"}
    ],
    "created_at": "2024-01-01T12:00:00Z"
  }
}
```

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Update Comment - `PUT` `BASE_URL/feeds/:feedId/comments/:commentId`

### Update Comment

**Method:** `PUT`

**Endpoint:** `BASE_URL/feeds/:feedId/comments/:commentId`

**Description:** Update comment

**Request Body:**

```json
{
  "content": "Updated comment"
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Updated successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Updated data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["Error message"]
  }
}
```

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Delete Comment - `DELETE` `BASE_URL/feeds/:feedId/comments/:commentId`

### Delete Comment

**Method:** `DELETE`

**Endpoint:** `BASE_URL/feeds/:feedId/comments/:commentId`

**Description:** Delete comment

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Deleted successfully"
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Add Reaction - `POST` `BASE_URL/feeds/:feedId/reactions`

### Add Reaction

**Method:** `POST`

**Endpoint:** `BASE_URL/feeds/:feedId/reactions`

**Description:** Add reaction to feed

**Request Body:**

```json
{
  "reaction_type": "like"
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Remove Reaction - `DELETE` `BASE_URL/feeds/:feedId/reactions`

### Remove Reaction

**Method:** `DELETE`

**Endpoint:** `BASE_URL/feeds/:feedId/reactions`

**Description:** Remove reaction

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Deleted successfully"
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] List Reactions - `GET` `BASE_URL/feeds/:feed/reactions`

### List Reactions

**Method:** `GET`

**Endpoint:** `BASE_URL/feeds/:feed/reactions`

**Description:** List feed reactions

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get My Reaction - `GET` `BASE_URL/feeds/:feed/my-reaction`

### Get My Reaction

**Method:** `GET`

**Endpoint:** `BASE_URL/feeds/:feed/my-reaction`

**Description:** Get my reaction

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Liked Feeds - `GET` `BASE_URL/my/liked-feeds`

### Get Liked Feeds

**Method:** `GET`

**Endpoint:** `BASE_URL/my/liked-feeds`

**Description:** Get feeds I liked

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information


---

## Favorites

**Total Endpoints:** 5

- [ ] Add Favorite - `POST` `BASE_URL/favorites/add`

### Add Favorite

**Method:** `POST`

**Endpoint:** `BASE_URL/favorites/add`

**Description:** Add user to favorites

**Request Body:**

```json
{
  "user_id": 2
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Remove Favorite - `DELETE` `BASE_URL/favorites/remove`

### Remove Favorite

**Method:** `DELETE`

**Endpoint:** `BASE_URL/favorites/remove`

**Description:** Remove from favorites

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Deleted successfully"
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Favorites - `GET` `BASE_URL/favorites/list`

### Get Favorites

**Method:** `GET`

**Endpoint:** `BASE_URL/favorites/list`

**Description:** Get favorites list

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {
    "items": [],
    "current_page": 1,
    "per_page": 15,
    "total": 0,
    "last_page": 1
  }
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data.items` (array) - List of items
- `data.current_page` (integer) - Current page number
- `data.per_page` (integer) - Items per page
- `data.total` (integer) - Total number of items
- `data.last_page` (integer) - Last page number

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Check If Favorited - `GET` `BASE_URL/favorites/check`

### Check If Favorited

**Method:** `GET`

**Endpoint:** `BASE_URL/favorites/check`

**Description:** Check if user is favorited

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Update Favorite Note - `PUT` `BASE_URL/favorites/note`

### Update Favorite Note

**Method:** `PUT`

**Endpoint:** `BASE_URL/favorites/note`

**Description:** Update favorite note

**Request Body:**

```json
{
  "user_id": 2,
  "note": "Met at coffee shop"
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Updated successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Updated data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["Error message"]
  }
}
```

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information


---

## Blocking

**Total Endpoints:** 4

- [ ] Block User - `POST` `BASE_URL/block/user`

### Block User

**Method:** `POST`

**Endpoint:** `BASE_URL/block/user`

**Description:** Block user

**Request Body:**

```json
{
  "user_id": 2
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Unblock User - `DELETE` `BASE_URL/block/user`

### Unblock User

**Method:** `DELETE`

**Endpoint:** `BASE_URL/block/user`

**Description:** Unblock user

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Deleted successfully"
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Blocked Users - `GET` `BASE_URL/block/list`

### Get Blocked Users

**Method:** `GET`

**Endpoint:** `BASE_URL/block/list`

**Description:** Get blocked users

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {
    "items": [],
    "current_page": 1,
    "per_page": 15,
    "total": 0,
    "last_page": 1
  }
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data.items` (array) - List of items
- `data.current_page` (integer) - Current page number
- `data.per_page` (integer) - Items per page
- `data.total` (integer) - Total number of items
- `data.last_page` (integer) - Last page number

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Check If Blocked - `GET` `BASE_URL/block/check`

### Check If Blocked

**Method:** `GET`

**Endpoint:** `BASE_URL/block/check`

**Description:** Check if user is blocked

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information


---

## Mutes

**Total Endpoints:** 5

- [ ] Mute User - `POST` `BASE_URL/mutes/mute`

### Mute User

**Method:** `POST`

**Endpoint:** `BASE_URL/mutes/mute`

**Description:** Mute user

**Request Body:**

```json
{
  "user_id": 2
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Unmute User - `DELETE` `BASE_URL/mutes/unmute`

### Unmute User

**Method:** `DELETE`

**Endpoint:** `BASE_URL/mutes/unmute`

**Description:** Unmute user

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Deleted successfully"
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Muted Users - `GET` `BASE_URL/mutes/list`

### Get Muted Users

**Method:** `GET`

**Endpoint:** `BASE_URL/mutes/list`

**Description:** Get muted users

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {
    "items": [],
    "current_page": 1,
    "per_page": 15,
    "total": 0,
    "last_page": 1
  }
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data.items` (array) - List of items
- `data.current_page` (integer) - Current page number
- `data.per_page` (integer) - Items per page
- `data.total` (integer) - Total number of items
- `data.last_page` (integer) - Last page number

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Update Mute Settings - `PUT` `BASE_URL/mutes/settings`

### Update Mute Settings

**Method:** `PUT`

**Endpoint:** `BASE_URL/mutes/settings`

**Description:** Update mute settings

**Request Body:**

```json
{
  "mute_all_notifications": false
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Updated successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Updated data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["Error message"]
  }
}
```

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Check Mute Status - `GET` `BASE_URL/mutes/check`

### Check Mute Status

**Method:** `GET`

**Endpoint:** `BASE_URL/mutes/check`

**Description:** Check mute status

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information


---

## Reports

**Total Endpoints:** 3

- [ ] Get Reports - `GET` `BASE_URL/reports`

### Get Reports

**Method:** `GET`

**Endpoint:** `BASE_URL/reports`

**Description:** Get user reports

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Create Report - `POST` `BASE_URL/reports`

### Create Report

**Method:** `POST`

**Endpoint:** `BASE_URL/reports`

**Description:** Create report

**Request Body:**

```json
{
  "reported_user_id": 2,
  "category": "inappropriate_behavior",
  "description": "Report description"
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Report - `GET` `BASE_URL/reports/:id`

### Get Report

**Method:** `GET`

**Endpoint:** `BASE_URL/reports/:id`

**Description:** Get report details

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information


---

## Verification

**Total Endpoints:** 7

- [ ] Get Verification Status - `GET` `BASE_URL/verification/status`

### Get Verification Status

**Method:** `GET`

**Endpoint:** `BASE_URL/verification/status`

**Description:** Get verification status

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Guidelines - `GET` `BASE_URL/verification/guidelines`

### Get Guidelines

**Method:** `GET`

**Endpoint:** `BASE_URL/verification/guidelines`

**Description:** Get verification guidelines

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get History - `GET` `BASE_URL/verification/history`

### Get History

**Method:** `GET`

**Endpoint:** `BASE_URL/verification/history`

**Description:** Get verification history

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {
    "items": [],
    "current_page": 1,
    "per_page": 15,
    "total": 0,
    "last_page": 1
  }
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data.items` (array) - List of items
- `data.current_page` (integer) - Current page number
- `data.per_page` (integer) - Items per page
- `data.total` (integer) - Total number of items
- `data.last_page` (integer) - Last page number

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Submit Photo - `POST` `BASE_URL/verification/submit-photo`

### Submit Photo

**Method:** `POST`

**Endpoint:** `BASE_URL/verification/submit-photo`

**Description:** Submit verification photo

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Submit ID - `POST` `BASE_URL/verification/submit-id`

### Submit ID

**Method:** `POST`

**Endpoint:** `BASE_URL/verification/submit-id`

**Description:** Submit ID document

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Submit Video - `POST` `BASE_URL/verification/submit-video`

### Submit Video

**Method:** `POST`

**Endpoint:** `BASE_URL/verification/submit-video`

**Description:** Submit verification video

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Cancel Verification - `DELETE` `BASE_URL/verification/cancel/:verificationId`

### Cancel Verification

**Method:** `DELETE`

**Endpoint:** `BASE_URL/verification/cancel/:verificationId`

**Description:** Cancel verification

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Deleted successfully"
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information


---

## Notifications

**Total Endpoints:** 7

- [ ] Get Notifications - `GET` `BASE_URL/notifications`

### Get Notifications

**Method:** `GET`

**Endpoint:** `BASE_URL/notifications`

**Description:** Get notifications

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Unread Count - `GET` `BASE_URL/notifications/unread-count`

### Get Unread Count

**Method:** `GET`

**Endpoint:** `BASE_URL/notifications/unread-count`

**Description:** Get unread notification count

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Mark as Read - `POST` `BASE_URL/notifications/:id/read`

### Mark as Read

**Method:** `POST`

**Endpoint:** `BASE_URL/notifications/:id/read`

**Description:** Mark notification as read

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Mark All as Read - `POST` `BASE_URL/notifications/read-all`

### Mark All as Read

**Method:** `POST`

**Endpoint:** `BASE_URL/notifications/read-all`

**Description:** Mark all as read

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Delete Notification - `DELETE` `BASE_URL/notifications/:id`

### Delete Notification

**Method:** `DELETE`

**Endpoint:** `BASE_URL/notifications/:id`

**Description:** Delete notification

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Deleted successfully"
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Delete All Notifications - `DELETE` `BASE_URL/notifications`

### Delete All Notifications

**Method:** `DELETE`

**Endpoint:** `BASE_URL/notifications`

**Description:** Delete all notifications

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Deleted successfully"
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Notification Permissions - `GET` `BASE_URL/notifications/permissions`

### Get Notification Permissions

**Method:** `GET`

**Endpoint:** `BASE_URL/notifications/permissions`

**Description:** Get notification permissions

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information


---

## Superlike Packs

**Total Endpoints:** 10

- [ ] Get Available Packs - `GET` `BASE_URL/superlike-packs/available`

### Get Available Packs

**Method:** `GET`

**Endpoint:** `BASE_URL/superlike-packs/available`

**Description:** Get available superlike packs

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Purchase Pack - `POST` `BASE_URL/superlike-packs/purchase`

### Purchase Pack

**Method:** `POST`

**Endpoint:** `BASE_URL/superlike-packs/purchase`

**Description:** Purchase superlike pack

**Request Body:**

```json
{
  "pack_id": 1
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "User liked successfully",
  "data": {
    "like_id": 1,
    "target_user_id": 2,
    "status": "pending",
    "is_match": false,
    "created_at": "2024-01-01T12:00:00Z"
  }
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data.like_id` (integer) - Like record ID
- `data.target_user_id` (integer) - Liked user ID
- `data.status` (string) - Like status (pending/accepted/rejected)
- `data.is_match` (boolean) - Whether it's a match
- `data.created_at` (string) - Creation timestamp

#### Match Response (200) - When Mutual Like Occurs

```json
{
  "status": true,
  "message": "It's a match!",
  "data": {
    "is_match": true,
    "match_id": 1,
    "users": [
      {"id": 1, "name": "User 1"},
      {"id": 2, "name": "User 2"}
    ],
    "created_at": "2024-01-01T12:00:00Z"
  }
}
```

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get User Packs - `GET` `BASE_URL/superlike-packs/user-packs`

### Get User Packs

**Method:** `GET`

**Endpoint:** `BASE_URL/superlike-packs/user-packs`

**Description:** Get user's superlike packs

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Purchase History - `GET` `BASE_URL/superlike-packs/purchase-history`

### Get Purchase History

**Method:** `GET`

**Endpoint:** `BASE_URL/superlike-packs/purchase-history`

**Description:** Get purchase history

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {
    "items": [],
    "current_page": 1,
    "per_page": 15,
    "total": 0,
    "last_page": 1
  }
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data.items` (array) - List of items
- `data.current_page` (integer) - Current page number
- `data.per_page` (integer) - Items per page
- `data.total` (integer) - Total number of items
- `data.last_page` (integer) - Last page number

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Activate Pending Pack - `POST` `BASE_URL/superlike-packs/activate-pending`

### Activate Pending Pack

**Method:** `POST`

**Endpoint:** `BASE_URL/superlike-packs/activate-pending`

**Description:** Activate pending pack

**Request Body:**

```json
{
  "purchase_id": 1
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "User liked successfully",
  "data": {
    "like_id": 1,
    "target_user_id": 2,
    "status": "pending",
    "is_match": false,
    "created_at": "2024-01-01T12:00:00Z"
  }
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data.like_id` (integer) - Like record ID
- `data.target_user_id` (integer) - Liked user ID
- `data.status` (string) - Like status (pending/accepted/rejected)
- `data.is_match` (boolean) - Whether it's a match
- `data.created_at` (string) - Creation timestamp

#### Match Response (200) - When Mutual Like Occurs

```json
{
  "status": true,
  "message": "It's a match!",
  "data": {
    "is_match": true,
    "match_id": 1,
    "users": [
      {"id": 1, "name": "User 1"},
      {"id": 2, "name": "User 2"}
    ],
    "created_at": "2024-01-01T12:00:00Z"
  }
}
```

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Create Payment Intent - `POST` `BASE_URL/superlike-packs/create-payment-intent`

### Create Payment Intent

**Method:** `POST`

**Endpoint:** `BASE_URL/superlike-packs/create-payment-intent`

**Description:** Create payment intent for pack

**Request Body:**

```json
{
  "pack_id": 1
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "User liked successfully",
  "data": {
    "like_id": 1,
    "target_user_id": 2,
    "status": "pending",
    "is_match": false,
    "created_at": "2024-01-01T12:00:00Z"
  }
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data.like_id` (integer) - Like record ID
- `data.target_user_id` (integer) - Liked user ID
- `data.status` (string) - Like status (pending/accepted/rejected)
- `data.is_match` (boolean) - Whether it's a match
- `data.created_at` (string) - Creation timestamp

#### Match Response (200) - When Mutual Like Occurs

```json
{
  "status": true,
  "message": "It's a match!",
  "data": {
    "is_match": true,
    "match_id": 1,
    "users": [
      {"id": 1, "name": "User 1"},
      {"id": 2, "name": "User 2"}
    ],
    "created_at": "2024-01-01T12:00:00Z"
  }
}
```

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Verify Payment Intent - `POST` `BASE_URL/superlike-packs/verify-payment-intent`

### Verify Payment Intent

**Method:** `POST`

**Endpoint:** `BASE_URL/superlike-packs/verify-payment-intent`

**Description:** Verify payment intent

**Request Body:**

```json
{
  "payment_intent_id": "pi_xxx"
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "User liked successfully",
  "data": {
    "like_id": 1,
    "target_user_id": 2,
    "status": "pending",
    "is_match": false,
    "created_at": "2024-01-01T12:00:00Z"
  }
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data.like_id` (integer) - Like record ID
- `data.target_user_id` (integer) - Liked user ID
- `data.status` (string) - Like status (pending/accepted/rejected)
- `data.is_match` (boolean) - Whether it's a match
- `data.created_at` (string) - Creation timestamp

#### Match Response (200) - When Mutual Like Occurs

```json
{
  "status": true,
  "message": "It's a match!",
  "data": {
    "is_match": true,
    "match_id": 1,
    "users": [
      {"id": 1, "name": "User 1"},
      {"id": 2, "name": "User 2"}
    ],
    "created_at": "2024-01-01T12:00:00Z"
  }
}
```

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Stripe Checkout - `POST` `BASE_URL/superlike-packs/stripe-checkout`

### Stripe Checkout

**Method:** `POST`

**Endpoint:** `BASE_URL/superlike-packs/stripe-checkout`

**Description:** Create Stripe checkout (legacy)

**Request Body:**

```json
{
  "pack_id": 1
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "User liked successfully",
  "data": {
    "like_id": 1,
    "target_user_id": 2,
    "status": "pending",
    "is_match": false,
    "created_at": "2024-01-01T12:00:00Z"
  }
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data.like_id` (integer) - Like record ID
- `data.target_user_id` (integer) - Liked user ID
- `data.status` (string) - Like status (pending/accepted/rejected)
- `data.is_match` (boolean) - Whether it's a match
- `data.created_at` (string) - Creation timestamp

#### Match Response (200) - When Mutual Like Occurs

```json
{
  "status": true,
  "message": "It's a match!",
  "data": {
    "is_match": true,
    "match_id": 1,
    "users": [
      {"id": 1, "name": "User 1"},
      {"id": 2, "name": "User 2"}
    ],
    "created_at": "2024-01-01T12:00:00Z"
  }
}
```

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Verify Stripe Payment - `POST` `BASE_URL/superlike-packs/stripe-verify-payment`

### Verify Stripe Payment

**Method:** `POST`

**Endpoint:** `BASE_URL/superlike-packs/stripe-verify-payment`

**Description:** Verify Stripe payment

**Request Body:**

```json
{
  "session_id": "cs_xxx"
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "User liked successfully",
  "data": {
    "like_id": 1,
    "target_user_id": 2,
    "status": "pending",
    "is_match": false,
    "created_at": "2024-01-01T12:00:00Z"
  }
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data.like_id` (integer) - Like record ID
- `data.target_user_id` (integer) - Liked user ID
- `data.status` (string) - Like status (pending/accepted/rejected)
- `data.is_match` (boolean) - Whether it's a match
- `data.created_at` (string) - Creation timestamp

#### Match Response (200) - When Mutual Like Occurs

```json
{
  "status": true,
  "message": "It's a match!",
  "data": {
    "is_match": true,
    "match_id": 1,
    "users": [
      {"id": 1, "name": "User 1"},
      {"id": 2, "name": "User 2"}
    ],
    "created_at": "2024-01-01T12:00:00Z"
  }
}
```

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] PayPal Checkout - `POST` `BASE_URL/superlike-packs/paypal-checkout`

### PayPal Checkout

**Method:** `POST`

**Endpoint:** `BASE_URL/superlike-packs/paypal-checkout`

**Description:** Create PayPal checkout

**Request Body:**

```json
{
  "pack_id": 1
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "User liked successfully",
  "data": {
    "like_id": 1,
    "target_user_id": 2,
    "status": "pending",
    "is_match": false,
    "created_at": "2024-01-01T12:00:00Z"
  }
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data.like_id` (integer) - Like record ID
- `data.target_user_id` (integer) - Liked user ID
- `data.status` (string) - Like status (pending/accepted/rejected)
- `data.is_match` (boolean) - Whether it's a match
- `data.created_at` (string) - Creation timestamp

#### Match Response (200) - When Mutual Like Occurs

```json
{
  "status": true,
  "message": "It's a match!",
  "data": {
    "is_match": true,
    "match_id": 1,
    "users": [
      {"id": 1, "name": "User 1"},
      {"id": 2, "name": "User 2"}
    ],
    "created_at": "2024-01-01T12:00:00Z"
  }
}
```

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information


---

## Plans

**Total Endpoints:** 8

- [ ] Get Plans - `GET` `BASE_URL/plans`

### Get Plans

**Method:** `GET`

**Endpoint:** `BASE_URL/plans`

**Description:** Get all plans

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Plan - `GET` `BASE_URL/plans/:id`

### Get Plan

**Method:** `GET`

**Endpoint:** `BASE_URL/plans/:id`

**Description:** Get plan details

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Create Plan - `POST` `BASE_URL/plans`

### Create Plan

**Method:** `POST`

**Endpoint:** `BASE_URL/plans`

**Description:** Create plan (admin)

**Request Body:**

```json
{
  "name": "Premium",
  "price": 29.99
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Update Plan - `PUT` `BASE_URL/plans/:id`

### Update Plan

**Method:** `PUT`

**Endpoint:** `BASE_URL/plans/:id`

**Description:** Update plan (admin)

**Request Body:**

```json
{
  "name": "Premium Plus",
  "price": 39.99
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Updated successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Updated data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["Error message"]
  }
}
```

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Delete Plan - `DELETE` `BASE_URL/plans/:id`

### Delete Plan

**Method:** `DELETE`

**Endpoint:** `BASE_URL/plans/:id`

**Description:** Delete plan (admin)

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Deleted successfully"
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Create Sub Plan - `POST` `BASE_URL/plans/:planId/sub-plans`

### Create Sub Plan

**Method:** `POST`

**Endpoint:** `BASE_URL/plans/:planId/sub-plans`

**Description:** Create sub plan

**Request Body:**

```json
{
  "duration_months": 1,
  "price": 29.99
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Update Sub Plan - `PUT` `BASE_URL/plans/:planId/sub-plans/:subPlanId`

### Update Sub Plan

**Method:** `PUT`

**Endpoint:** `BASE_URL/plans/:planId/sub-plans/:subPlanId`

**Description:** Update sub plan

**Request Body:**

```json
{
  "price": 34.99
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Updated successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Updated data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["Error message"]
  }
}
```

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Delete Sub Plan - `DELETE` `BASE_URL/plans/:planId/sub-plans/:subPlanId`

### Delete Sub Plan

**Method:** `DELETE`

**Endpoint:** `BASE_URL/plans/:planId/sub-plans/:subPlanId`

**Description:** Delete sub plan

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Deleted successfully"
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information


---

## Sub Plans

**Total Endpoints:** 7

- [ ] Get Sub Plans - `GET` `BASE_URL/sub-plans`

### Get Sub Plans

**Method:** `GET`

**Endpoint:** `BASE_URL/sub-plans`

**Description:** Get all sub plans

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get by Duration - `GET` `BASE_URL/sub-plans/duration`

### Get by Duration

**Method:** `GET`

**Endpoint:** `BASE_URL/sub-plans/duration`

**Description:** Get sub plans by duration

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Compare Sub Plans - `POST` `BASE_URL/sub-plans/compare`

### Compare Sub Plans

**Method:** `POST`

**Endpoint:** `BASE_URL/sub-plans/compare`

**Description:** Compare sub plans

**Request Body:**

```json
{
  "sub_plan_ids": [
    1,
    2,
    3
  ]
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Plan Sub Plans - `GET` `BASE_URL/sub-plans/plan/:planId`

### Get Plan Sub Plans

**Method:** `GET`

**Endpoint:** `BASE_URL/sub-plans/plan/:planId`

**Description:** Get sub plans for plan

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Upgrade Options - `GET` `BASE_URL/sub-plans/upgrade-options`

### Get Upgrade Options

**Method:** `GET`

**Endpoint:** `BASE_URL/sub-plans/upgrade-options`

**Description:** Get upgrade options

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Upgrade Plan - `POST` `BASE_URL/sub-plans/upgrade`

### Upgrade Plan

**Method:** `POST`

**Endpoint:** `BASE_URL/sub-plans/upgrade`

**Description:** Upgrade plan

**Request Body:**

```json
{
  "sub_plan_id": 2
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Sub Plan - `GET` `BASE_URL/sub-plans/:subPlan`

### Get Sub Plan

**Method:** `GET`

**Endpoint:** `BASE_URL/sub-plans/:subPlan`

**Description:** Get sub plan details

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information


---

## Subscriptions

**Total Endpoints:** 9

- [ ] Get Plans - `GET` `BASE_URL/subscriptions/plans`

### Get Plans

**Method:** `GET`

**Endpoint:** `BASE_URL/subscriptions/plans`

**Description:** Get subscription plans

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Create Checkout - `POST` `BASE_URL/subscriptions/create-checkout`

### Create Checkout

**Method:** `POST`

**Endpoint:** `BASE_URL/subscriptions/create-checkout`

**Description:** Create checkout session

**Request Body:**

```json
{
  "sub_plan_id": 1
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Calculate Upgrade - `POST` `BASE_URL/subscriptions/calculate-upgrade`

### Calculate Upgrade

**Method:** `POST`

**Endpoint:** `BASE_URL/subscriptions/calculate-upgrade`

**Description:** Calculate upgrade price

**Request Body:**

```json
{
  "sub_plan_id": 2
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Upgrade with Penalty - `POST` `BASE_URL/subscriptions/upgrade-with-penalty`

### Upgrade with Penalty

**Method:** `POST`

**Endpoint:** `BASE_URL/subscriptions/upgrade-with-penalty`

**Description:** Upgrade with penalty

**Request Body:**

```json
{
  "sub_plan_id": 2
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Status - `GET` `BASE_URL/subscriptions/status`

### Get Status

**Method:** `GET`

**Endpoint:** `BASE_URL/subscriptions/status`

**Description:** Get subscription status

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Cancel Subscription - `POST` `BASE_URL/subscriptions/cancel`

### Cancel Subscription

**Method:** `POST`

**Endpoint:** `BASE_URL/subscriptions/cancel`

**Description:** Cancel subscription

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Reactivate Subscription - `POST` `BASE_URL/subscriptions/reactivate`

### Reactivate Subscription

**Method:** `POST`

**Endpoint:** `BASE_URL/subscriptions/reactivate`

**Description:** Reactivate subscription

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Update Subscription - `POST` `BASE_URL/subscriptions/update`

### Update Subscription

**Method:** `POST`

**Endpoint:** `BASE_URL/subscriptions/update`

**Description:** Update subscription

**Request Body:**

```json
{
  "sub_plan_id": 2
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Verify Checkout - `GET` `BASE_URL/subscriptions/verify/:session_id`

### Verify Checkout

**Method:** `GET`

**Endpoint:** `BASE_URL/subscriptions/verify/:session_id`

**Description:** Verify checkout session

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information


---

## Stripe Payments

**Total Endpoints:** 11

- [ ] Create Payment Intent - `POST` `BASE_URL/stripe/create-payment-intent`

### Create Payment Intent

**Method:** `POST`

**Endpoint:** `BASE_URL/stripe/create-payment-intent`

**Description:** Create payment intent (mobile)

**Request Body:**

```json
{
  "sub_plan_id": 1
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Verify Payment Intent - `POST` `BASE_URL/stripe/verify-payment-intent`

### Verify Payment Intent

**Method:** `POST`

**Endpoint:** `BASE_URL/stripe/verify-payment-intent`

**Description:** Verify payment intent

**Request Body:**

```json
{
  "payment_intent_id": "pi_xxx"
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Create Upgrade Payment Intent - `POST` `BASE_URL/stripe/create-upgrade-payment-intent`

### Create Upgrade Payment Intent

**Method:** `POST`

**Endpoint:** `BASE_URL/stripe/create-upgrade-payment-intent`

**Description:** Create upgrade payment intent

**Request Body:**

```json
{
  "sub_plan_id": 2
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Verify Upgrade Payment Intent - `POST` `BASE_URL/stripe/verify-upgrade-payment-intent`

### Verify Upgrade Payment Intent

**Method:** `POST`

**Endpoint:** `BASE_URL/stripe/verify-upgrade-payment-intent`

**Description:** Verify upgrade payment intent

**Request Body:**

```json
{
  "payment_intent_id": "pi_xxx"
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Payment Intent (Legacy) - `POST` `BASE_URL/stripe/payment-intent`

### Payment Intent (Legacy)

**Method:** `POST`

**Endpoint:** `BASE_URL/stripe/payment-intent`

**Description:** Create payment intent (legacy)

**Request Body:**

```json
{
  "amount": 2999,
  "currency": "usd"
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Stripe Checkout - `POST` `BASE_URL/stripe/checkout`

### Stripe Checkout

**Method:** `POST`

**Endpoint:** `BASE_URL/stripe/checkout`

**Description:** Create checkout session (web)

**Request Body:**

```json
{
  "sub_plan_id": 1
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Verify Stripe Payment - `POST` `BASE_URL/stripe/verify-payment`

### Verify Stripe Payment

**Method:** `POST`

**Endpoint:** `BASE_URL/stripe/verify-payment`

**Description:** Verify Stripe payment

**Request Body:**

```json
{
  "session_id": "cs_xxx"
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Create Subscription - `POST` `BASE_URL/stripe/subscription`

### Create Subscription

**Method:** `POST`

**Endpoint:** `BASE_URL/stripe/subscription`

**Description:** Create subscription

**Request Body:**

```json
{
  "sub_plan_id": 1
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Cancel Subscription - `DELETE` `BASE_URL/stripe/subscription/:subscriptionId`

### Cancel Subscription

**Method:** `DELETE`

**Endpoint:** `BASE_URL/stripe/subscription/:subscriptionId`

**Description:** Cancel subscription

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Deleted successfully"
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Create Refund - `POST` `BASE_URL/stripe/refund`

### Create Refund

**Method:** `POST`

**Endpoint:** `BASE_URL/stripe/refund`

**Description:** Create refund

**Request Body:**

```json
{
  "payment_id": "pi_xxx",
  "amount": 1000
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Analytics - `GET` `BASE_URL/stripe/analytics`

### Get Analytics

**Method:** `GET`

**Endpoint:** `BASE_URL/stripe/analytics`

**Description:** Get payment analytics

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information


---

## PayPal Payments

**Total Endpoints:** 3

- [ ] Create PayPal Order (Plan) - `POST` `BASE_URL/paypal/create-order-plan`

### Create PayPal Order (Plan)

**Method:** `POST`

**Endpoint:** `BASE_URL/paypal/create-order-plan`

**Description:** Create PayPal order for plan

**Request Body:**

```json
{
  "sub_plan_id": 1
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Capture PayPal Order - `POST` `BASE_URL/paypal/capture-order`

### Capture PayPal Order

**Method:** `POST`

**Endpoint:** `BASE_URL/paypal/capture-order`

**Description:** Capture PayPal order

**Request Body:**

```json
{
  "order_id": "ORDER_ID"
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get PayPal Order - `GET` `BASE_URL/paypal/order/:orderId`

### Get PayPal Order

**Method:** `GET`

**Endpoint:** `BASE_URL/paypal/order/:orderId`

**Description:** Get PayPal order

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information


---

## Payment Methods

**Total Endpoints:** 5

- [ ] Get Payment Methods - `GET` `BASE_URL/payment-methods`

### Get Payment Methods

**Method:** `GET`

**Endpoint:** `BASE_URL/payment-methods`

**Description:** Get payment methods

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Payment Method - `GET` `BASE_URL/payment-methods/:id`

### Get Payment Method

**Method:** `GET`

**Endpoint:** `BASE_URL/payment-methods/:id`

**Description:** Get payment method

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get by Currency - `GET` `BASE_URL/payment-methods/currency/:currency`

### Get by Currency

**Method:** `GET`

**Endpoint:** `BASE_URL/payment-methods/currency/:currency`

**Description:** Get by currency

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get by Type - `GET` `BASE_URL/payment-methods/type/:type`

### Get by Type

**Method:** `GET`

**Endpoint:** `BASE_URL/payment-methods/type/:type`

**Description:** Get by type

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Validate Amount - `POST` `BASE_URL/payment-methods/validate-amount`

### Validate Amount

**Method:** `POST`

**Endpoint:** `BASE_URL/payment-methods/validate-amount`

**Description:** Validate payment amount

**Request Body:**

```json
{
  "amount": 29.99,
  "currency": "usd"
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information


---

## User Payments

**Total Endpoints:** 5

- [ ] Get Payment History - `GET` `BASE_URL/user/payments/history`

### Get Payment History

**Method:** `GET`

**Endpoint:** `BASE_URL/user/payments/history`

**Description:** Get payment history

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {
    "items": [],
    "current_page": 1,
    "per_page": 15,
    "total": 0,
    "last_page": 1
  }
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data.items` (array) - List of items
- `data.current_page` (integer) - Current page number
- `data.per_page` (integer) - Items per page
- `data.total` (integer) - Total number of items
- `data.last_page` (integer) - Last page number

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Active Subscription - `GET` `BASE_URL/user/payments/subscription`

### Get Active Subscription

**Method:** `GET`

**Endpoint:** `BASE_URL/user/payments/subscription`

**Description:** Get active subscription

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Payment Receipt - `GET` `BASE_URL/user/payments/receipt/:paymentId`

### Get Payment Receipt

**Method:** `GET`

**Endpoint:** `BASE_URL/user/payments/receipt/:paymentId`

**Description:** Get payment receipt

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Failed Payments - `GET` `BASE_URL/user/payments/failed`

### Get Failed Payments

**Method:** `GET`

**Endpoint:** `BASE_URL/user/payments/failed`

**Description:** Get failed payments

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Request Refund - `POST` `BASE_URL/user/payments/refund/:paymentId`

### Request Refund

**Method:** `POST`

**Endpoint:** `BASE_URL/user/payments/refund/:paymentId`

**Description:** Request refund

**Request Body:**

```json
{
  "reason": "Not satisfied"
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information


---

## Plan Purchases

**Total Endpoints:** 7

- [ ] Get Plan Purchases - `GET` `BASE_URL/plan-purchases`

### Get Plan Purchases

**Method:** `GET`

**Endpoint:** `BASE_URL/plan-purchases`

**Description:** Get plan purchases

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Create Plan Purchase - `POST` `BASE_URL/plan-purchases`

### Create Plan Purchase

**Method:** `POST`

**Endpoint:** `BASE_URL/plan-purchases`

**Description:** Create plan purchase

**Request Body:**

```json
{
  "plan_id": 1,
  "sub_plan_id": 1
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get User History - `GET` `BASE_URL/plan-purchases/history`

### Get User History

**Method:** `GET`

**Endpoint:** `BASE_URL/plan-purchases/history`

**Description:** Get user purchase history

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {
    "items": [],
    "current_page": 1,
    "per_page": 15,
    "total": 0,
    "last_page": 1
  }
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data.items` (array) - List of items
- `data.current_page` (integer) - Current page number
- `data.per_page` (integer) - Items per page
- `data.total` (integer) - Total number of items
- `data.last_page` (integer) - Last page number

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Active Plans - `GET` `BASE_URL/plan-purchases/active`

### Get Active Plans

**Method:** `GET`

**Endpoint:** `BASE_URL/plan-purchases/active`

**Description:** Get active plans

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Expired Plans - `GET` `BASE_URL/plan-purchases/expired`

### Get Expired Plans

**Method:** `GET`

**Endpoint:** `BASE_URL/plan-purchases/expired`

**Description:** Get expired plans

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Upgrade Options - `GET` `BASE_URL/plan-purchases/upgrade-options`

### Get Upgrade Options

**Method:** `GET`

**Endpoint:** `BASE_URL/plan-purchases/upgrade-options`

**Description:** Get upgrade options

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Plan Purchase - `GET` `BASE_URL/plan-purchases/:id`

### Get Plan Purchase

**Method:** `GET`

**Endpoint:** `BASE_URL/plan-purchases/:id`

**Description:** Get plan purchase

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information


---

## Plan Purchase Actions

**Total Endpoints:** 8

- [ ] Get Actions - `GET` `BASE_URL/plan-purchase-actions`

### Get Actions

**Method:** `GET`

**Endpoint:** `BASE_URL/plan-purchase-actions`

**Description:** Get plan purchase actions

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Create Action - `POST` `BASE_URL/plan-purchase-actions`

### Create Action

**Method:** `POST`

**Endpoint:** `BASE_URL/plan-purchase-actions`

**Description:** Create action

**Request Body:**

```json
{
  "plan_purchase_id": 1,
  "action": "upgrade"
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Statistics - `GET` `BASE_URL/plan-purchase-actions/statistics`

### Get Statistics

**Method:** `GET`

**Endpoint:** `BASE_URL/plan-purchase-actions/statistics`

**Description:** Get statistics

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Today Actions - `GET` `BASE_URL/plan-purchase-actions/today`

### Get Today Actions

**Method:** `GET`

**Endpoint:** `BASE_URL/plan-purchase-actions/today`

**Description:** Get today's actions

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get by Status - `GET` `BASE_URL/plan-purchase-actions/status`

### Get by Status

**Method:** `GET`

**Endpoint:** `BASE_URL/plan-purchase-actions/status`

**Description:** Get actions by status

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get User Actions - `GET` `BASE_URL/plan-purchase-actions/user/:userId`

### Get User Actions

**Method:** `GET`

**Endpoint:** `BASE_URL/plan-purchase-actions/user/:userId`

**Description:** Get user actions

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Action - `GET` `BASE_URL/plan-purchase-actions/:id`

### Get Action

**Method:** `GET`

**Endpoint:** `BASE_URL/plan-purchase-actions/:id`

**Description:** Get action

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Update Status - `PATCH` `BASE_URL/plan-purchase-actions/:id/status`

### Update Status

**Method:** `PATCH`

**Endpoint:** `BASE_URL/plan-purchase-actions/:id/status`

**Description:** Update action status

**Request Body:**

```json
{
  "status": "completed"
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Updated successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Updated data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["Error message"]
  }
}
```

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information


---

## Safety

**Total Endpoints:** 11

- [ ] Get Safety Guidelines - `GET` `BASE_URL/safety/guidelines`

### Get Safety Guidelines

**Method:** `GET`

**Endpoint:** `BASE_URL/safety/guidelines`

**Description:** Get safety guidelines

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Emergency Contacts - `GET` `BASE_URL/safety/emergency-contacts`

### Get Emergency Contacts

**Method:** `GET`

**Endpoint:** `BASE_URL/safety/emergency-contacts`

**Description:** Get emergency contacts

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Add Emergency Contact - `POST` `BASE_URL/safety/emergency-contacts`

### Add Emergency Contact

**Method:** `POST`

**Endpoint:** `BASE_URL/safety/emergency-contacts`

**Description:** Add emergency contact

**Request Body:**

```json
{
  "name": "John Doe",
  "phone": "+1234567890",
  "relationship": "friend"
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Send Emergency Alert - `POST` `BASE_URL/safety/emergency-alert`

### Send Emergency Alert

**Method:** `POST`

**Endpoint:** `BASE_URL/safety/emergency-alert`

**Description:** Send emergency alert

**Request Body:**

```json
{
  "message": "Help me!",
  "location": "123 Main St"
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Share Location - `POST` `BASE_URL/safety/share-location`

### Share Location

**Method:** `POST`

**Endpoint:** `BASE_URL/safety/share-location`

**Description:** Share location

**Request Body:**

```json
{
  "user_id": 2,
  "duration_minutes": 60
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Nearby Safe Places - `GET` `BASE_URL/safety/nearby-safe-places`

### Get Nearby Safe Places

**Method:** `GET`

**Endpoint:** `BASE_URL/safety/nearby-safe-places`

**Description:** Get nearby safe places

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Create Report - `POST` `BASE_URL/safety/report`

### Create Report

**Method:** `POST`

**Endpoint:** `BASE_URL/safety/report`

**Description:** Create safety report

**Request Body:**

```json
{
  "reported_user_id": 2,
  "category": "harassment",
  "description": "Report description"
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Report Categories - `GET` `BASE_URL/safety/report-categories`

### Get Report Categories

**Method:** `GET`

**Endpoint:** `BASE_URL/safety/report-categories`

**Description:** Get report categories

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Report History - `GET` `BASE_URL/safety/report-history`

### Get Report History

**Method:** `GET`

**Endpoint:** `BASE_URL/safety/report-history`

**Description:** Get report history

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {
    "items": [],
    "current_page": 1,
    "per_page": 15,
    "total": 0,
    "last_page": 1
  }
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data.items` (array) - List of items
- `data.current_page` (integer) - Current page number
- `data.per_page` (integer) - Items per page
- `data.total` (integer) - Total number of items
- `data.last_page` (integer) - Last page number

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Moderate Content - `POST` `BASE_URL/safety/moderate-content`

### Moderate Content

**Method:** `POST`

**Endpoint:** `BASE_URL/safety/moderate-content`

**Description:** Moderate content

**Request Body:**

```json
{
  "content_id": 1,
  "action": "remove"
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Safety Statistics - `GET` `BASE_URL/safety/statistics`

### Get Safety Statistics

**Method:** `GET`

**Endpoint:** `BASE_URL/safety/statistics`

**Description:** Get safety statistics

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information


---

## Analytics

**Total Endpoints:** 6

- [ ] Get My Analytics - `GET` `BASE_URL/analytics/my-analytics`

### Get My Analytics

**Method:** `GET`

**Endpoint:** `BASE_URL/analytics/my-analytics`

**Description:** Get user analytics

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Engagement - `GET` `BASE_URL/analytics/engagement`

### Get Engagement

**Method:** `GET`

**Endpoint:** `BASE_URL/analytics/engagement`

**Description:** Get engagement analytics

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Retention - `GET` `BASE_URL/analytics/retention`

### Get Retention

**Method:** `GET`

**Endpoint:** `BASE_URL/analytics/retention`

**Description:** Get retention analytics

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Interactions - `GET` `BASE_URL/analytics/interactions`

### Get Interactions

**Method:** `GET`

**Endpoint:** `BASE_URL/analytics/interactions`

**Description:** Get interaction analytics

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Profile Metrics - `GET` `BASE_URL/analytics/profile-metrics`

### Get Profile Metrics

**Method:** `GET`

**Endpoint:** `BASE_URL/analytics/profile-metrics`

**Description:** Get profile metrics

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Track Activity - `POST` `BASE_URL/analytics/track-activity`

### Track Activity

**Method:** `POST`

**Endpoint:** `BASE_URL/analytics/track-activity`

**Description:** Track user activity

**Request Body:**

```json
{
  "activity_type": "profile_view",
  "target_id": 2
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information


---

## Reference Data

**Total Endpoints:** 13

- [ ] Get Countries - `GET` `BASE_URL/countries`

### Get Countries

**Method:** `GET`

**Endpoint:** `BASE_URL/countries`

**Description:** Get countries list

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Country - `GET` `BASE_URL/countries/:id`

### Get Country

**Method:** `GET`

**Endpoint:** `BASE_URL/countries/:id`

**Description:** Get country details

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Cities - `GET` `BASE_URL/cities`

### Get Cities

**Method:** `GET`

**Endpoint:** `BASE_URL/cities`

**Description:** Get cities list

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Cities by Country - `GET` `BASE_URL/cities/country/:countryId`

### Get Cities by Country

**Method:** `GET`

**Endpoint:** `BASE_URL/cities/country/:countryId`

**Description:** Get cities by country

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get City - `GET` `BASE_URL/cities/:id`

### Get City

**Method:** `GET`

**Endpoint:** `BASE_URL/cities/:id`

**Description:** Get city details

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Genders - `GET` `BASE_URL/genders`

### Get Genders

**Method:** `GET`

**Endpoint:** `BASE_URL/genders`

**Description:** Get genders list

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Preferred Genders - `GET` `BASE_URL/preferred-genders`

### Get Preferred Genders

**Method:** `GET`

**Endpoint:** `BASE_URL/preferred-genders`

**Description:** Get preferred genders

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Jobs - `GET` `BASE_URL/jobs`

### Get Jobs

**Method:** `GET`

**Endpoint:** `BASE_URL/jobs`

**Description:** Get jobs list

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Education - `GET` `BASE_URL/education`

### Get Education

**Method:** `GET`

**Endpoint:** `BASE_URL/education`

**Description:** Get education levels

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Interests - `GET` `BASE_URL/interests`

### Get Interests

**Method:** `GET`

**Endpoint:** `BASE_URL/interests`

**Description:** Get interests list

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Languages - `GET` `BASE_URL/languages`

### Get Languages

**Method:** `GET`

**Endpoint:** `BASE_URL/languages`

**Description:** Get languages list

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Relation Goals - `GET` `BASE_URL/relation-goals`

### Get Relation Goals

**Method:** `GET`

**Endpoint:** `BASE_URL/relation-goals`

**Description:** Get relation goals

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Music Genres - `GET` `BASE_URL/music-genres`

### Get Music Genres

**Method:** `GET`

**Endpoint:** `BASE_URL/music-genres`

**Description:** Get music genres

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information


---

## Locales

**Total Endpoints:** 4

- [ ] Get Locales - `GET` `BASE_URL/locales`

### Get Locales

**Method:** `GET`

**Endpoint:** `BASE_URL/locales`

**Description:** Get available locales

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Translations - `GET` `BASE_URL/locales/translations`

### Get Translations

**Method:** `GET`

**Endpoint:** `BASE_URL/locales/translations`

**Description:** Get translations

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Current Locale - `GET` `BASE_URL/locales/current`

### Get Current Locale

**Method:** `GET`

**Endpoint:** `BASE_URL/locales/current`

**Description:** Get current locale

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Update Locale - `PUT` `BASE_URL/locales`

### Update Locale

**Method:** `PUT`

**Endpoint:** `BASE_URL/locales`

**Description:** Update locale preference

**Request Body:**

```json
{
  "locale": "en"
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Updated successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Updated data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["Error message"]
  }
}
```

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information


---

## Referrals

**Total Endpoints:** 7

- [ ] Get Stats - `GET` `BASE_URL/referrals/stats`

### Get Stats

**Method:** `GET`

**Endpoint:** `BASE_URL/referrals/stats`

**Description:** Get referral statistics

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Referral Code - `GET` `BASE_URL/referrals/code`

### Get Referral Code

**Method:** `GET`

**Endpoint:** `BASE_URL/referrals/code`

**Description:** Get user referral code

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get History - `GET` `BASE_URL/referrals/history`

### Get History

**Method:** `GET`

**Endpoint:** `BASE_URL/referrals/history`

**Description:** Get referral history

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {
    "items": [],
    "current_page": 1,
    "per_page": 15,
    "total": 0,
    "last_page": 1
  }
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data.items` (array) - List of items
- `data.current_page` (integer) - Current page number
- `data.per_page` (integer) - Items per page
- `data.total` (integer) - Total number of items
- `data.last_page` (integer) - Last page number

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Tiers - `GET` `BASE_URL/referrals/tiers`

### Get Tiers

**Method:** `GET`

**Endpoint:** `BASE_URL/referrals/tiers`

**Description:** Get referral tiers

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Validate Code - `POST` `BASE_URL/referrals/validate-code`

### Validate Code

**Method:** `POST`

**Endpoint:** `BASE_URL/referrals/validate-code`

**Description:** Validate referral code

**Request Body:**

```json
{
  "code": "ABC123"
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Process Milestone - `POST` `BASE_URL/referrals/process-milestone`

### Process Milestone

**Method:** `POST`

**Endpoint:** `BASE_URL/referrals/process-milestone`

**Description:** Process milestone rewards

**Request Body:**

```json
{
  "milestone_id": 1
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Mark Completed - `POST` `BASE_URL/referrals/mark-completed`

### Mark Completed

**Method:** `POST`

**Endpoint:** `BASE_URL/referrals/mark-completed`

**Description:** Mark referral as completed

**Request Body:**

```json
{
  "referral_id": 1
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information


---

## OneSignal

**Total Endpoints:** 7

- [ ] Update Player ID - `POST` `BASE_URL/onesignal/update-player-id`

### Update Player ID

**Method:** `POST`

**Endpoint:** `BASE_URL/onesignal/update-player-id`

**Description:** Update OneSignal player ID

**Request Body:**

```json
{
  "player_id": "player_id_here"
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Remove Player ID - `POST` `BASE_URL/onesignal/remove-player-id`

### Remove Player ID

**Method:** `POST`

**Endpoint:** `BASE_URL/onesignal/remove-player-id`

**Description:** Remove OneSignal player ID

**Request Body:**

```json
{
  "player_id": "player_id_here"
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Notification Info - `GET` `BASE_URL/onesignal/notification-info`

### Get Notification Info

**Method:** `GET`

**Endpoint:** `BASE_URL/onesignal/notification-info`

**Description:** Get notification info

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Update Preferences - `POST` `BASE_URL/onesignal/update-preferences`

### Update Preferences

**Method:** `POST`

**Endpoint:** `BASE_URL/onesignal/update-preferences`

**Description:** Update notification preferences

**Request Body:**

```json
{
  "push_enabled": true
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Reset Preferences - `POST` `BASE_URL/onesignal/reset-preferences`

### Reset Preferences

**Method:** `POST`

**Endpoint:** `BASE_URL/onesignal/reset-preferences`

**Description:** Reset preferences

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Test Notification - `POST` `BASE_URL/onesignal/test-notification`

### Test Notification

**Method:** `POST`

**Endpoint:** `BASE_URL/onesignal/test-notification`

**Description:** Send test notification

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Delivery Status - `GET` `BASE_URL/onesignal/delivery-status`

### Get Delivery Status

**Method:** `GET`

**Endpoint:** `BASE_URL/onesignal/delivery-status`

**Description:** Get delivery status

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information


---

## 2FA

**Total Endpoints:** 6

- [ ] Get 2FA Status - `GET` `BASE_URL/2fa/status`

### Get 2FA Status

**Method:** `GET`

**Endpoint:** `BASE_URL/2fa/status`

**Description:** Get 2FA status

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Enable 2FA - `POST` `BASE_URL/2fa/enable`

### Enable 2FA

**Method:** `POST`

**Endpoint:** `BASE_URL/2fa/enable`

**Description:** Enable 2FA

**Request Body:**

```json
{
  "password": "currentpassword"
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Verify 2FA - `POST` `BASE_URL/2fa/verify`

### Verify 2FA

**Method:** `POST`

**Endpoint:** `BASE_URL/2fa/verify`

**Description:** Verify 2FA code

**Request Body:**

```json
{
  "code": "123456"
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Disable 2FA - `POST` `BASE_URL/2fa/disable`

### Disable 2FA

**Method:** `POST`

**Endpoint:** `BASE_URL/2fa/disable`

**Description:** Disable 2FA

**Request Body:**

```json
{
  "password": "currentpassword"
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get QR Code - `GET` `BASE_URL/2fa/qr-code`

### Get QR Code

**Method:** `GET`

**Endpoint:** `BASE_URL/2fa/qr-code`

**Description:** Get 2FA QR code

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Backup Codes - `POST` `BASE_URL/2fa/backup-codes`

### Get Backup Codes

**Method:** `POST`

**Endpoint:** `BASE_URL/2fa/backup-codes`

**Description:** Get backup codes

**Request Body:**

```json
{
  "password": "currentpassword"
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information


---

## Sessions

**Total Endpoints:** 5

- [ ] Get Sessions - `GET` `BASE_URL/sessions`

### Get Sessions

**Method:** `GET`

**Endpoint:** `BASE_URL/sessions`

**Description:** Get active sessions

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Store Session - `POST` `BASE_URL/sessions/store`

### Store Session

**Method:** `POST`

**Endpoint:** `BASE_URL/sessions/store`

**Description:** Store new session

**Request Body:**

```json
{
  "device_name": "iPhone 15 Pro",
  "ip_address": "192.168.1.1"
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Update Activity - `POST` `BASE_URL/sessions/activity`

### Update Activity

**Method:** `POST`

**Endpoint:** `BASE_URL/sessions/activity`

**Description:** Update session activity

**Request Body:**

```json
{
  "session_id": 1
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Revoke Session - `POST` `BASE_URL/sessions/revoke/:id`

### Revoke Session

**Method:** `POST`

**Endpoint:** `BASE_URL/sessions/revoke/:id`

**Description:** Revoke session

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Revoke All Sessions - `POST` `BASE_URL/sessions/revoke-all`

### Revoke All Sessions

**Method:** `POST`

**Endpoint:** `BASE_URL/sessions/revoke-all`

**Description:** Revoke all sessions

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information


---

## Emergency Contacts

**Total Endpoints:** 7

- [ ] Get Emergency Contacts - `GET` `BASE_URL/emergency-contacts`

### Get Emergency Contacts

**Method:** `GET`

**Endpoint:** `BASE_URL/emergency-contacts`

**Description:** Get emergency contacts

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Create Emergency Contact - `POST` `BASE_URL/emergency-contacts`

### Create Emergency Contact

**Method:** `POST`

**Endpoint:** `BASE_URL/emergency-contacts`

**Description:** Create emergency contact

**Request Body:**

```json
{
  "name": "John Doe",
  "phone": "+1234567890",
  "relationship": "friend"
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Update Emergency Contact - `PUT` `BASE_URL/emergency-contacts/:id`

### Update Emergency Contact

**Method:** `PUT`

**Endpoint:** `BASE_URL/emergency-contacts/:id`

**Description:** Update emergency contact

**Request Body:**

```json
{
  "name": "Jane Doe",
  "phone": "+0987654321"
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Updated successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Updated data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["Error message"]
  }
}
```

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Delete Emergency Contact - `DELETE` `BASE_URL/emergency-contacts/:id`

### Delete Emergency Contact

**Method:** `DELETE`

**Endpoint:** `BASE_URL/emergency-contacts/:id`

**Description:** Delete emergency contact

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Deleted successfully"
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Verify Emergency Contact - `POST` `BASE_URL/emergency-contacts/:id/verify`

### Verify Emergency Contact

**Method:** `POST`

**Endpoint:** `BASE_URL/emergency-contacts/:id/verify`

**Description:** Verify emergency contact

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Confirm Emergency Contact - `POST` `BASE_URL/emergency-contacts/:id/confirm`

### Confirm Emergency Contact

**Method:** `POST`

**Endpoint:** `BASE_URL/emergency-contacts/:id/confirm`

**Description:** Confirm emergency contact

**Request Body:**

```json
{
  "code": "123456"
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Trigger Emergency - `POST` `BASE_URL/emergency/trigger`

### Trigger Emergency

**Method:** `POST`

**Endpoint:** `BASE_URL/emergency/trigger`

**Description:** Trigger emergency alert

**Request Body:**

```json
{
  "message": "Help!",
  "location": "123 Main St"
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information


---

## Account Management

**Total Endpoints:** 5

- [ ] Change Email - `POST` `BASE_URL/account/change-email`

### Change Email

**Method:** `POST`

**Endpoint:** `BASE_URL/account/change-email`

**Description:** Change email

**Request Body:**

```json
{
  "new_email": "newemail@example.com",
  "password": "currentpassword"
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Change Password - `POST` `BASE_URL/account/change-password`

### Change Password

**Method:** `POST`

**Endpoint:** `BASE_URL/account/change-password`

**Description:** Change password

**Request Body:**

```json
{
  "current_password": "oldpassword",
  "new_password": "newpassword123"
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Deactivate Account - `POST` `BASE_URL/account/deactivate`

### Deactivate Account

**Method:** `POST`

**Endpoint:** `BASE_URL/account/deactivate`

**Description:** Deactivate account

**Request Body:**

```json
{
  "password": "currentpassword"
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Reactivate Account - `POST` `BASE_URL/account/reactivate`

### Reactivate Account

**Method:** `POST`

**Endpoint:** `BASE_URL/account/reactivate`

**Description:** Reactivate account

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Delete Account - `DELETE` `BASE_URL/account/delete`

### Delete Account

**Method:** `DELETE`

**Endpoint:** `BASE_URL/account/delete`

**Description:** Delete account permanently

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Deleted successfully"
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information


---

## Call Management

**Total Endpoints:** 7

- [ ] Initiate Call - `POST` `BASE_URL/call-management/initiate`

### Initiate Call

**Method:** `POST`

**Endpoint:** `BASE_URL/call-management/initiate`

**Description:** Initiate call

**Request Body:**

```json
{
  "receiver_id": 2,
  "call_type": "video"
}
```

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Accept Call - `POST` `BASE_URL/call-management/:id/accept`

### Accept Call

**Method:** `POST`

**Endpoint:** `BASE_URL/call-management/:id/accept`

**Description:** Accept call

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Reject Call - `POST` `BASE_URL/call-management/:id/reject`

### Reject Call

**Method:** `POST`

**Endpoint:** `BASE_URL/call-management/:id/reject`

**Description:** Reject call

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] End Call - `POST` `BASE_URL/call-management/:id/end`

### End Call

**Method:** `POST`

**Endpoint:** `BASE_URL/call-management/:id/end`

**Description:** End call

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Operation successful",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message
- `data` (object) - Response data object

#### Validation Error Response (422)

```json
{
  "status": false,
  "message": "Validation error",
  "errors": {
    "field_name": ["The field name is required.", "The field name must be at least 3 characters."]
  }
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `errors` (object) - Validation errors object with field names as keys and array of error messages as values

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Call History - `GET` `BASE_URL/call-management/history`

### Get Call History

**Method:** `GET`

**Endpoint:** `BASE_URL/call-management/history`

**Description:** Get call history

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {
    "items": [],
    "current_page": 1,
    "per_page": 15,
    "total": 0,
    "last_page": 1
  }
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data.items` (array) - List of items
- `data.current_page` (integer) - Current page number
- `data.per_page` (integer) - Items per page
- `data.total` (integer) - Total number of items
- `data.last_page` (integer) - Last page number

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Delete Call History - `DELETE` `BASE_URL/call-management/history/:id`

### Delete Call History

**Method:** `DELETE`

**Endpoint:** `BASE_URL/call-management/history/:id`

**Description:** Delete call history

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Deleted successfully"
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Success message

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information

- [ ] Get Call Statistics - `GET` `BASE_URL/call-management/statistics`

### Get Call Statistics

**Method:** `GET`

**Endpoint:** `BASE_URL/call-management/statistics`

**Description:** Get call statistics

**Authentication:** Required (Bearer Token)

**Responses:**

#### Success Response (200)

```json
{
  "status": true,
  "message": "Data retrieved successfully",
  "data": {}
}
```

**Response Fields:**

- `status` (boolean) - Operation status
- `message` (string) - Response message
- `data` (object) - Response data object

#### Unauthorized Response (401)

```json
{
  "message": "Unauthenticated"
}
```

**Response Fields:**

- `message` (string) - Error message indicating authentication is required

#### Not Found Response (404)

```json
{
  "status": false,
  "message": "Resource not found"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message

#### Server Error Response (500)

```json
{
  "status": false,
  "message": "Internal server error",
  "error": "Detailed error message"
}
```

**Response Fields:**

- `status` (boolean) - Always false for errors
- `message` (string) - Error message
- `error` (string) - Detailed error information


---


## Summary

- **Total Categories:** 44
- **Total Endpoints:** 306
- **Documentation Generated:** 446725 characters
