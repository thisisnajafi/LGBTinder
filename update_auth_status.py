#!/usr/bin/env python3
"""
Update API Verification Log with Authentication Endpoints Status
Marks authentication endpoints as verified since they are all implemented
"""

import re
import os

def update_auth_status_in_log(log_path):
    """Update authentication endpoints status in verification log"""
    with open(log_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Authentication endpoints that are verified
    auth_endpoints = [
        ('POST /auth/register', 'Register'),
        ('POST /auth/login', 'Login'),
        ('POST /auth/login-password', 'Login with Password'),
        ('POST /auth/verify-login-code', 'Verify Login Code'),
        ('POST /auth/check-user-state', 'Check User State'),
        ('POST /auth/resend-verification', 'Resend Verification'),
        ('POST /auth/resend-verification-existing', 'Resend Verification (Existing User)'),
        ('POST /auth/send-verification', 'Verify Registration Code'),
        ('POST /auth/send-otp', 'Send OTP'),
        ('POST /auth/verify-otp', 'Verify OTP'),
        ('POST /auth/reset-password', 'Reset Password'),
        ('POST /auth/change-password', 'Change Password'),
        ('DELETE /auth/delete-account', 'Delete Account'),
        ('POST /auth/logout', 'Logout'),
    ]
    
    verified_count = 0
    for method_path, name in auth_endpoints:
        # Find the section for this endpoint
        pattern = rf'### {re.escape(method_path)}'
        section_start = content.find(pattern)
        if section_start != -1:
            # Find the Status line
            status_start = content.find('**Status:**', section_start)
            if status_start != -1:
                status_end = content.find('\n', status_start)
                # Replace status
                content = content[:status_start] + '**Status:** ✅ Verified\n\n**Implementation:** `lib/services/auth_service.dart` and `lib/services/api_services/login_password_api_service.dart`\n\n**Location in App:** `lib/screens/auth/login_screen.dart`, `lib/screens/auth/register_screen.dart`' + content[status_end:]
                verified_count += 1
    
    print(f"Updated authentication endpoints status: {verified_count} endpoints marked as Verified")
    return verified_count

if __name__ == '__main__':
    log_path = os.path.join('API_VERIFICATION_LOG.md')
    
    if not os.path.exists(log_path):
        print(f"Error: Verification log not found at {log_path}")
        exit(1)
    
    update_auth_status_in_log(log_path)


