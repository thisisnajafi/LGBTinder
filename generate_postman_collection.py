import json
from datetime import datetime

def create_endpoint_item(name, method, path, description="", body=None, requires_auth=True):
    """Create a Postman request item"""
    url_parts = path.strip('/').split('/')
    path_parts = []
    query_parts = []
    
    # Handle path parameters and query strings
    for part in url_parts:
        if '{' in part:
            path_parts.append(f":{part.replace('{', '').replace('}', '')}")
        elif '?' in part:
            query_part, query_value = part.split('?')
            path_parts.append(query_part)
            if '=' in query_value:
                query_parts.append({"key": query_value.split('=')[0], "value": query_value.split('=')[1]})
        else:
            path_parts.append(part)
    
    item = {
        "name": name,
        "request": {
            "method": method,
            "header": [
                {"key": "Accept", "value": "application/json"},
                {"key": "Content-Type", "value": "application/json"}
            ],
            "url": {
                "raw": "{{base_url}}/" + path.strip('/'),
                "host": ["{{base_url}}"],
                "path": path_parts
            },
            "description": description
        },
        "response": []
    }
    
    if requires_auth:
        item["request"]["header"].append({
            "key": "Authorization",
            "value": "Bearer {{auth_token}}"
        })
    
    if body and method in ["POST", "PUT", "PATCH"]:
        item["request"]["body"] = {
            "mode": "raw",
            "raw": json.dumps(body, indent=2),
            "options": {"raw": {"language": "json"}}
        }
    
    if query_parts:
        item["request"]["url"]["query"] = query_parts
    
    return item

def create_postman_collection():
    """Create complete Postman collection with all API routes"""
    
    # Define all endpoints organized by category
    endpoints = {
        "Webhooks (Public - No Auth)": [
            ("Stripe Webhook", "POST", "/stripe/webhook", "Stripe payment webhook", None, False),
            ("Stripe Subscription Webhook", "POST", "/stripe/subscription-webhook", "Stripe subscription webhook", None, False),
            ("Superlike Packs Webhook", "POST", "/superlike-packs/stripe-webhook", "Superlike packs webhook", None, False),
            ("PayPal Webhook", "POST", "/paypal/webhook", "PayPal payment webhook", None, False),
        ],
        "Authentication": [
            ("Register", "POST", "/auth/register", "Register new user", {
                "first_name": "John",
                "last_name": "Doe",
                "email": "john.doe@example.com",
                "password": "password123",
                "referral_code": "ABC123"
            }, False),
            ("Login", "POST", "/auth/login", "Login with email (sends verification code)", {
                "email": "john.doe@example.com",
                "device_name": "iPhone 15 Pro"
            }, False),
            ("Login with Password", "POST", "/auth/login-password", "Traditional email/password login", {
                "email": "john.doe@example.com",
                "password": "password123",
                "device_name": "iPhone 15 Pro"
            }, False),
            ("Verify Login Code", "POST", "/auth/verify-login-code", "Verify email code for login", {
                "email": "john.doe@example.com",
                "code": "123456"
            }, False),
            ("Check User State", "POST", "/auth/check-user-state", "Check user state and requirements", {
                "email": "john.doe@example.com"
            }, False),
            ("Resend Verification", "POST", "/auth/resend-verification", "Resend email verification code", {
                "email": "john.doe@example.com"
            }, False),
            ("Resend Verification (Existing User)", "POST", "/auth/resend-verification-existing", "Resend verification for existing user", {
                "email": "john.doe@example.com"
            }, False),
            ("Verify Registration Code", "POST", "/auth/send-verification", "Verify email registration code", {
                "email": "john.doe@example.com",
                "code": "123456"
            }, False),
            ("Send OTP", "POST", "/auth/send-otp", "Send OTP to phone number", {
                "phone_number": "+1234567890"
            }, False),
            ("Verify OTP", "POST", "/auth/verify-otp", "Verify OTP code", {
                "phone_number": "+1234567890",
                "code": "123456"
            }, False),
            ("Reset Password", "POST", "/auth/reset-password", "Reset password using OTP", {
                "phone_number": "+1234567890",
                "code": "123456",
                "new_password": "newpassword123"
            }, False),
            ("Change Password", "POST", "/auth/change-password", "Change user password (requires auth)", {
                "current_password": "oldpassword",
                "new_password": "newpassword123"
            }, True),
            ("Delete Account", "DELETE", "/auth/delete-account", "Delete user account", {
                "password": "password123"
            }, True),
            ("Logout", "POST", "/auth/logout", "Logout user", None, True),
        ],
        "Social Authentication": [
            ("Get Google Auth URL", "GET", "/auth/google/url", "Get Google OAuth authorization URL", None, False),
            ("Google OAuth Callback", "POST", "/auth/google/callback", "Handle Google OAuth callback", {
                "code": "authorization_code_here"
            }, False),
            ("Get Linked Accounts", "GET", "/auth/linked-accounts", "Get user's linked social accounts", None, True),
            ("Unlink Google Account", "DELETE", "/auth/google/unlink", "Unlink Google account", None, True),
        ],
        "Profile Completion": [
            ("Complete Registration", "POST", "/complete-registration", "Complete profile registration", {
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
                "smoke": False,
                "drink": True,
                "gym": True,
                "music_genres": [1, 3, 5],
                "educations": [2, 3],
                "jobs": [1, 4],
                "languages": [1, 2],
                "interests": [1, 2, 3],
                "preferred_genders": [1, 3],
                "relation_goals": [1, 2]
            }, True),
        ],
        "Profile Wizard": [
            ("Get Current Step", "GET", "/profile-wizard/current-step", "Get current profile wizard step", None, True),
            ("Get Step Options", "GET", "/profile-wizard/step-options/:step", "Get options for wizard step", None, True),
            ("Save Step", "POST", "/profile-wizard/save-step/:step", "Save wizard step data", {
                "data": {}
            }, True),
        ],
        "User": [
            ("Get Current User", "GET", "/user", "Get authenticated user details", None, True),
            ("Set Show Adult Content", "POST", "/user/show-adult-content", "Update adult content preference", {
                "show_adult_content": True
            }, True),
            ("Save OneSignal Player ID", "POST", "/user/onesignal-player", "Save OneSignal player ID", {
                "player_id": "onesignal_player_id_here"
            }, True),
            ("Update Notification Preferences", "POST", "/user/notification-preferences", "Update notification preferences", {
                "match_notifications": True,
                "message_notifications": True,
                "like_notifications": True
            }, True),
            ("Get Notification History", "GET", "/user/notification-history", "Get user notification history", None, True),
        ],
        "Profile": [
            ("Get Profile", "GET", "/profile", "Get current user profile", None, True),
            ("Get Profile Badge Info", "GET", "/profile/badge/info", "Get profile badge information", None, True),
            ("Get User Profile", "GET", "/profile/:id", "Get specific user profile", None, True),
            ("Get User Feeds", "GET", "/profile/:id/feeds", "Get user's feed posts", None, True),
            ("Update Profile", "POST", "/profile/update", "Update user profile", {
                "profile_bio": "Updated bio",
                "height": 180,
                "weight": 75
            }, True),
            ("Change Email", "POST", "/profile/change-email", "Request email change", {
                "new_email": "newemail@example.com",
                "password": "currentpassword"
            }, True),
            ("Verify Email Change", "POST", "/profile/verify-email-change", "Verify email change code", {
                "code": "123456"
            }, True),
            ("Get Users by Job", "GET", "/profile/by-job/:jobId", "Get users by job", None, True),
            ("Get Users by Language", "GET", "/profile/by-language/:languageId", "Get users by language", None, True),
            ("Get Users by Relation Goal", "GET", "/profile/by-relation-goal/:relationGoalId", "Get users by relation goal", None, True),
            ("Get Users by Interest", "GET", "/profile/by-interest/:interestId", "Get users by interest", None, True),
            ("Get Users by Music Genre", "GET", "/profile/by-music-genre/:musicGenreId", "Get users by music genre", None, True),
            ("Get Users by Education", "GET", "/profile/by-education/:educationId", "Get users by education", None, True),
            ("Get Users by Preferred Gender", "GET", "/profile/by-preferred-gender/:preferredGenderId", "Get users by preferred gender", None, True),
            ("Get Users by Gender", "GET", "/profile/by-gender/:genderId", "Get users by gender", None, True),
        ],
        "Images": [
            ("Upload Image", "POST", "/images/upload", "Upload gallery image", None, True),
            ("Delete Image", "DELETE", "/images/:id", "Delete image", None, True),
            ("Reorder Images", "POST", "/images/reorder", "Reorder images", {
                "image_ids": [1, 2, 3, 4]
            }, True),
            ("Set Primary Image", "POST", "/images/:id/set-primary", "Set primary image", None, True),
            ("List Images", "GET", "/images/list", "List user images", None, True),
        ],
        "Profile Pictures": [
            ("Upload Profile Picture", "POST", "/profile-pictures/upload", "Upload profile picture", None, True),
            ("Delete Profile Picture", "DELETE", "/profile-pictures/:id", "Delete profile picture", None, True),
            ("Set Primary Profile Picture", "POST", "/profile-pictures/:id/set-primary", "Set primary profile picture", None, True),
            ("List Profile Pictures", "GET", "/profile-pictures/list", "List profile pictures", None, True),
        ],
        "Age Preferences": [
            ("Update Age Preference", "PUT", "/preferences/age", "Update age preferences", {
                "min_age": 21,
                "max_age": 35
            }, True),
            ("Get Age Preference", "GET", "/preferences/age", "Get age preferences", None, True),
            ("Reset Age Preference", "DELETE", "/preferences/age", "Reset age preferences", None, True),
        ],
        "Matching": [
            ("Get Matches", "GET", "/matching/matches", "Get user matches", None, True),
            ("Get Nearby Suggestions", "GET", "/matching/nearby-suggestions", "Get nearby user suggestions", None, True),
            ("Debug Matches", "GET", "/matching/debug", "Debug matching algorithm", None, True),
            ("Test User Data", "GET", "/matching/test", "Test user matching data", None, True),
            ("Get Advanced Matches", "GET", "/matching/advanced", "Get advanced matches", None, True),
            ("Get Compatibility Score", "GET", "/matching/compatibility-score", "Get compatibility score", None, True),
            ("Get AI Suggestions", "GET", "/matching/ai-suggestions", "Get AI match suggestions", None, True),
            ("Get Location Based Matches", "GET", "/matching/location-based", "Get location-based matches", None, True),
        ],
        "Likes": [
            ("Like User", "POST", "/likes/like", "Like a user", {
                "liked_user_id": 2
            }, True),
            ("Dislike User", "POST", "/likes/dislike", "Dislike a user", {
                "disliked_user_id": 2
            }, True),
            ("Superlike User", "POST", "/likes/superlike", "Superlike a user", {
                "superliked_user_id": 2
            }, True),
            ("Respond to Like", "POST", "/likes/respond", "Respond to a like", {
                "like_id": 1,
                "response": "accept"
            }, True),
            ("Get Matches", "GET", "/likes/matches", "Get matches from likes", None, True),
            ("Get Pending Likes", "GET", "/likes/pending", "Get pending likes", None, True),
            ("Get Superlike History", "GET", "/likes/superlike-history", "Get superlike history", None, True),
        ],
        "Chat": [
            ("Send Message", "POST", "/chat/send", "Send chat message", {
                "receiver_id": 2,
                "content": "Hello!",
                "type": "text"
            }, True),
            ("Get Chat History", "GET", "/chat/history", "Get chat history", None, True),
            ("Get Chat Users", "GET", "/chat/users", "Get users with chats", None, True),
            ("Get Chat Access Users", "GET", "/chat/access-users", "Get users with chat access", None, True),
            ("Delete Message", "DELETE", "/chat/message", "Delete message", {
                "message_id": 1
            }, True),
            ("Get Unread Count", "GET", "/chat/unread-count", "Get unread message count", None, True),
            ("Set Typing", "POST", "/chat/typing", "Set typing indicator", {
                "receiver_id": 2,
                "is_typing": True
            }, True),
            ("Mark as Read", "POST", "/chat/read", "Mark messages as read", {
                "message_id": 1
            }, True),
            ("Set Online Status", "POST", "/chat/online", "Set online status", {
                "is_online": True
            }, True),
            ("Serve Secure Media", "GET", "/secure-media/:message_id/:user_id/:token/:expires", "Serve secure media", None, True),
        ],
        "Group Chat": [
            ("Create Group", "POST", "/group-chat/create", "Create group chat", {
                "name": "Group Name",
                "member_ids": [2, 3, 4]
            }, True),
            ("Get User Groups", "GET", "/group-chat/groups", "Get user's groups", None, True),
            ("Get Group Details", "GET", "/group-chat/groups/:groupId", "Get group details", None, True),
            ("Send Group Message", "POST", "/group-chat/send-message", "Send group message", {
                "group_id": 1,
                "content": "Hello group!",
                "type": "text"
            }, True),
            ("Get Group Chat History", "GET", "/group-chat/groups/:groupId/messages", "Get group chat history", None, True),
            ("Add Members", "POST", "/group-chat/groups/:groupId/add-members", "Add members to group", {
                "member_ids": [5, 6]
            }, True),
            ("Remove Member", "DELETE", "/group-chat/groups/:groupId/remove-member", "Remove member from group", {
                "user_id": 5
            }, True),
            ("Leave Group", "POST", "/group-chat/groups/:groupId/leave", "Leave group", None, True),
        ],
        "Calls": [
            ("Initiate Call", "POST", "/calls/initiate", "Initiate call", {
                "receiver_id": 2,
                "call_type": "video"
            }, True),
            ("Accept Call", "POST", "/calls/accept", "Accept call", {
                "call_id": 1
            }, True),
            ("Reject Call", "POST", "/calls/reject", "Reject call", {
                "call_id": 1
            }, True),
            ("End Call", "POST", "/calls/end", "End call", {
                "call_id": 1
            }, True),
            ("Get Call History", "GET", "/calls/history", "Get call history", None, True),
            ("Get Active Call", "GET", "/calls/active", "Get active call", None, True),
            ("Get Call Settings", "GET", "/calls/settings", "Get call settings", None, True),
            ("Update Call Settings", "PUT", "/calls/settings", "Update call settings", {
                "auto_answer": False,
                "call_notifications": True
            }, True),
            ("Get Call Quota", "GET", "/calls/quota", "Get call quota", None, True),
            ("Get Call Statistics", "GET", "/calls/statistics", "Get call statistics", None, True),
        ],
        "Stories": [
            ("Get Stories", "GET", "/stories", "Get stories feed", None, True),
            ("Upload Story", "POST", "/stories/upload", "Upload story", None, True),
            ("Get Story", "GET", "/stories/:id", "Get story details", None, True),
            ("Like Story", "POST", "/stories/:id/like", "Like story", None, True),
            ("Delete Story", "DELETE", "/stories/:id", "Delete story", None, True),
            ("Get Story Replies", "GET", "/stories/:storyId/replies", "Get story replies", None, True),
            ("Reply to Story", "POST", "/stories/:storyId/reply", "Reply to story", {
                "content": "Great story!"
            }, True),
        ],
        "Feeds": [
            ("Get Feeds", "GET", "/feeds", "Get feeds feed", None, True),
            ("Create Feed", "POST", "/feeds/create", "Create feed post", {
                "content": "My post content",
                "images": []
            }, True),
            ("Get Feed", "GET", "/feeds/:id", "Get feed details", None, True),
            ("Update Feed", "PUT", "/feeds/update/:id", "Update feed post", {
                "content": "Updated content"
            }, True),
            ("Delete Feed", "DELETE", "/feeds/:id", "Delete feed post", None, True),
            ("Get Feed Comments", "GET", "/feeds/:feedId/comments", "Get feed comments", None, True),
            ("Create Comment", "POST", "/feeds/:feedId/comments", "Create comment", {
                "content": "Great post!"
            }, True),
            ("Like Comment", "POST", "/feeds/:feedId/comments/:commentId/like", "Like comment", None, True),
            ("Dislike Comment", "POST", "/feeds/:feedId/comments/:commentId/dislike", "Dislike comment", None, True),
            ("Update Comment", "PUT", "/feeds/:feedId/comments/:commentId", "Update comment", {
                "content": "Updated comment"
            }, True),
            ("Delete Comment", "DELETE", "/feeds/:feedId/comments/:commentId", "Delete comment", None, True),
            ("Add Reaction", "POST", "/feeds/:feedId/reactions", "Add reaction to feed", {
                "reaction_type": "like"
            }, True),
            ("Remove Reaction", "DELETE", "/feeds/:feedId/reactions", "Remove reaction", None, True),
            ("List Reactions", "GET", "/feeds/:feed/reactions", "List feed reactions", None, True),
            ("Get My Reaction", "GET", "/feeds/:feed/my-reaction", "Get my reaction", None, True),
            ("Get Liked Feeds", "GET", "/my/liked-feeds", "Get feeds I liked", None, True),
        ],
        "Favorites": [
            ("Add Favorite", "POST", "/favorites/add", "Add user to favorites", {
                "user_id": 2
            }, True),
            ("Remove Favorite", "DELETE", "/favorites/remove", "Remove from favorites", {
                "user_id": 2
            }, True),
            ("Get Favorites", "GET", "/favorites/list", "Get favorites list", None, True),
            ("Check If Favorited", "GET", "/favorites/check", "Check if user is favorited", {
                "user_id": 2
            }, True),
            ("Update Favorite Note", "PUT", "/favorites/note", "Update favorite note", {
                "user_id": 2,
                "note": "Met at coffee shop"
            }, True),
        ],
        "Blocking": [
            ("Block User", "POST", "/block/user", "Block user", {
                "user_id": 2
            }, True),
            ("Unblock User", "DELETE", "/block/user", "Unblock user", {
                "user_id": 2
            }, True),
            ("Get Blocked Users", "GET", "/block/list", "Get blocked users", None, True),
            ("Check If Blocked", "GET", "/block/check", "Check if user is blocked", {
                "user_id": 2
            }, True),
        ],
        "Mutes": [
            ("Mute User", "POST", "/mutes/mute", "Mute user", {
                "user_id": 2
            }, True),
            ("Unmute User", "DELETE", "/mutes/unmute", "Unmute user", {
                "user_id": 2
            }, True),
            ("Get Muted Users", "GET", "/mutes/list", "Get muted users", None, True),
            ("Update Mute Settings", "PUT", "/mutes/settings", "Update mute settings", {
                "mute_all_notifications": False
            }, True),
            ("Check Mute Status", "GET", "/mutes/check", "Check mute status", {
                "user_id": 2
            }, True),
        ],
        "Reports": [
            ("Get Reports", "GET", "/reports", "Get user reports", None, True),
            ("Create Report", "POST", "/reports", "Create report", {
                "reported_user_id": 2,
                "category": "inappropriate_behavior",
                "description": "Report description"
            }, True),
            ("Get Report", "GET", "/reports/:id", "Get report details", None, True),
        ],
        "Verification": [
            ("Get Verification Status", "GET", "/verification/status", "Get verification status", None, True),
            ("Get Guidelines", "GET", "/verification/guidelines", "Get verification guidelines", None, True),
            ("Get History", "GET", "/verification/history", "Get verification history", None, True),
            ("Submit Photo", "POST", "/verification/submit-photo", "Submit verification photo", None, True),
            ("Submit ID", "POST", "/verification/submit-id", "Submit ID document", None, True),
            ("Submit Video", "POST", "/verification/submit-video", "Submit verification video", None, True),
            ("Cancel Verification", "DELETE", "/verification/cancel/:verificationId", "Cancel verification", None, True),
        ],
        "Notifications": [
            ("Get Notifications", "GET", "/notifications", "Get notifications", None, True),
            ("Get Unread Count", "GET", "/notifications/unread-count", "Get unread notification count", None, True),
            ("Mark as Read", "POST", "/notifications/:id/read", "Mark notification as read", None, True),
            ("Mark All as Read", "POST", "/notifications/read-all", "Mark all as read", None, True),
            ("Delete Notification", "DELETE", "/notifications/:id", "Delete notification", None, True),
            ("Delete All Notifications", "DELETE", "/notifications", "Delete all notifications", None, True),
            ("Get Notification Permissions", "GET", "/notifications/permissions", "Get notification permissions", None, True),
        ],
        "Superlike Packs": [
            ("Get Available Packs", "GET", "/superlike-packs/available", "Get available superlike packs", None, True),
            ("Purchase Pack", "POST", "/superlike-packs/purchase", "Purchase superlike pack", {
                "pack_id": 1
            }, True),
            ("Get User Packs", "GET", "/superlike-packs/user-packs", "Get user's superlike packs", None, True),
            ("Get Purchase History", "GET", "/superlike-packs/purchase-history", "Get purchase history", None, True),
            ("Activate Pending Pack", "POST", "/superlike-packs/activate-pending", "Activate pending pack", {
                "purchase_id": 1
            }, True),
            ("Create Payment Intent", "POST", "/superlike-packs/create-payment-intent", "Create payment intent for pack", {
                "pack_id": 1
            }, True),
            ("Verify Payment Intent", "POST", "/superlike-packs/verify-payment-intent", "Verify payment intent", {
                "payment_intent_id": "pi_xxx"
            }, True),
            ("Stripe Checkout", "POST", "/superlike-packs/stripe-checkout", "Create Stripe checkout (legacy)", {
                "pack_id": 1
            }, True),
            ("Verify Stripe Payment", "POST", "/superlike-packs/stripe-verify-payment", "Verify Stripe payment", {
                "session_id": "cs_xxx"
            }, True),
            ("PayPal Checkout", "POST", "/superlike-packs/paypal-checkout", "Create PayPal checkout", {
                "pack_id": 1
            }, True),
        ],
        "Plans": [
            ("Get Plans", "GET", "/plans", "Get all plans", None, True),
            ("Get Plan", "GET", "/plans/:id", "Get plan details", None, False),
            ("Create Plan", "POST", "/plans", "Create plan (admin)", {
                "name": "Premium",
                "price": 29.99
            }, True),
            ("Update Plan", "PUT", "/plans/:id", "Update plan (admin)", {
                "name": "Premium Plus",
                "price": 39.99
            }, True),
            ("Delete Plan", "DELETE", "/plans/:id", "Delete plan (admin)", None, True),
            ("Create Sub Plan", "POST", "/plans/:planId/sub-plans", "Create sub plan", {
                "duration_months": 1,
                "price": 29.99
            }, True),
            ("Update Sub Plan", "PUT", "/plans/:planId/sub-plans/:subPlanId", "Update sub plan", {
                "price": 34.99
            }, True),
            ("Delete Sub Plan", "DELETE", "/plans/:planId/sub-plans/:subPlanId", "Delete sub plan", None, True),
        ],
        "Sub Plans": [
            ("Get Sub Plans", "GET", "/sub-plans", "Get all sub plans", None, True),
            ("Get by Duration", "GET", "/sub-plans/duration", "Get sub plans by duration", None, True),
            ("Compare Sub Plans", "POST", "/sub-plans/compare", "Compare sub plans", {
                "sub_plan_ids": [1, 2, 3]
            }, True),
            ("Get Plan Sub Plans", "GET", "/sub-plans/plan/:planId", "Get sub plans for plan", None, True),
            ("Get Upgrade Options", "GET", "/sub-plans/upgrade-options", "Get upgrade options", None, True),
            ("Upgrade Plan", "POST", "/sub-plans/upgrade", "Upgrade plan", {
                "sub_plan_id": 2
            }, True),
            ("Get Sub Plan", "GET", "/sub-plans/:subPlan", "Get sub plan details", None, True),
        ],
        "Subscriptions": [
            ("Get Plans", "GET", "/subscriptions/plans", "Get subscription plans", None, True),
            ("Create Checkout", "POST", "/subscriptions/create-checkout", "Create checkout session", {
                "sub_plan_id": 1
            }, True),
            ("Calculate Upgrade", "POST", "/subscriptions/calculate-upgrade", "Calculate upgrade price", {
                "sub_plan_id": 2
            }, True),
            ("Upgrade with Penalty", "POST", "/subscriptions/upgrade-with-penalty", "Upgrade with penalty", {
                "sub_plan_id": 2
            }, True),
            ("Get Status", "GET", "/subscriptions/status", "Get subscription status", None, True),
            ("Cancel Subscription", "POST", "/subscriptions/cancel", "Cancel subscription", None, True),
            ("Reactivate Subscription", "POST", "/subscriptions/reactivate", "Reactivate subscription", None, True),
            ("Update Subscription", "POST", "/subscriptions/update", "Update subscription", {
                "sub_plan_id": 2
            }, True),
            ("Verify Checkout", "GET", "/subscriptions/verify/:session_id", "Verify checkout session", None, True),
        ],
        "Stripe Payments": [
            ("Create Payment Intent", "POST", "/stripe/create-payment-intent", "Create payment intent (mobile)", {
                "sub_plan_id": 1
            }, True),
            ("Verify Payment Intent", "POST", "/stripe/verify-payment-intent", "Verify payment intent", {
                "payment_intent_id": "pi_xxx"
            }, True),
            ("Create Upgrade Payment Intent", "POST", "/stripe/create-upgrade-payment-intent", "Create upgrade payment intent", {
                "sub_plan_id": 2
            }, True),
            ("Verify Upgrade Payment Intent", "POST", "/stripe/verify-upgrade-payment-intent", "Verify upgrade payment intent", {
                "payment_intent_id": "pi_xxx"
            }, True),
            ("Payment Intent (Legacy)", "POST", "/stripe/payment-intent", "Create payment intent (legacy)", {
                "amount": 2999,
                "currency": "usd"
            }, True),
            ("Stripe Checkout", "POST", "/stripe/checkout", "Create checkout session (web)", {
                "sub_plan_id": 1
            }, True),
            ("Verify Stripe Payment", "POST", "/stripe/verify-payment", "Verify Stripe payment", {
                "session_id": "cs_xxx"
            }, True),
            ("Create Subscription", "POST", "/stripe/subscription", "Create subscription", {
                "sub_plan_id": 1
            }, True),
            ("Cancel Subscription", "DELETE", "/stripe/subscription/:subscriptionId", "Cancel subscription", None, True),
            ("Create Refund", "POST", "/stripe/refund", "Create refund", {
                "payment_id": "pi_xxx",
                "amount": 1000
            }, True),
            ("Get Analytics", "GET", "/stripe/analytics", "Get payment analytics", None, True),
        ],
        "PayPal Payments": [
            ("Create PayPal Order (Plan)", "POST", "/paypal/create-order-plan", "Create PayPal order for plan", {
                "sub_plan_id": 1
            }, True),
            ("Capture PayPal Order", "POST", "/paypal/capture-order", "Capture PayPal order", {
                "order_id": "ORDER_ID"
            }, True),
            ("Get PayPal Order", "GET", "/paypal/order/:orderId", "Get PayPal order", None, True),
        ],
        "Payment Methods": [
            ("Get Payment Methods", "GET", "/payment-methods", "Get payment methods", None, True),
            ("Get Payment Method", "GET", "/payment-methods/:id", "Get payment method", None, True),
            ("Get by Currency", "GET", "/payment-methods/currency/:currency", "Get by currency", None, True),
            ("Get by Type", "GET", "/payment-methods/type/:type", "Get by type", None, True),
            ("Validate Amount", "POST", "/payment-methods/validate-amount", "Validate payment amount", {
                "amount": 29.99,
                "currency": "usd"
            }, True),
        ],
        "User Payments": [
            ("Get Payment History", "GET", "/user/payments/history", "Get payment history", None, True),
            ("Get Active Subscription", "GET", "/user/payments/subscription", "Get active subscription", None, True),
            ("Get Payment Receipt", "GET", "/user/payments/receipt/:paymentId", "Get payment receipt", None, True),
            ("Get Failed Payments", "GET", "/user/payments/failed", "Get failed payments", None, True),
            ("Request Refund", "POST", "/user/payments/refund/:paymentId", "Request refund", {
                "reason": "Not satisfied"
            }, True),
        ],
        "Plan Purchases": [
            ("Get Plan Purchases", "GET", "/plan-purchases", "Get plan purchases", None, True),
            ("Create Plan Purchase", "POST", "/plan-purchases", "Create plan purchase", {
                "plan_id": 1,
                "sub_plan_id": 1
            }, True),
            ("Get User History", "GET", "/plan-purchases/history", "Get user purchase history", None, True),
            ("Get Active Plans", "GET", "/plan-purchases/active", "Get active plans", None, True),
            ("Get Expired Plans", "GET", "/plan-purchases/expired", "Get expired plans", None, True),
            ("Get Upgrade Options", "GET", "/plan-purchases/upgrade-options", "Get upgrade options", None, True),
            ("Get Plan Purchase", "GET", "/plan-purchases/:id", "Get plan purchase", None, True),
        ],
        "Plan Purchase Actions": [
            ("Get Actions", "GET", "/plan-purchase-actions", "Get plan purchase actions", None, True),
            ("Create Action", "POST", "/plan-purchase-actions", "Create action", {
                "plan_purchase_id": 1,
                "action": "upgrade"
            }, True),
            ("Get Statistics", "GET", "/plan-purchase-actions/statistics", "Get statistics", None, True),
            ("Get Today Actions", "GET", "/plan-purchase-actions/today", "Get today's actions", None, True),
            ("Get by Status", "GET", "/plan-purchase-actions/status", "Get actions by status", None, True),
            ("Get User Actions", "GET", "/plan-purchase-actions/user/:userId", "Get user actions", None, True),
            ("Get Action", "GET", "/plan-purchase-actions/:id", "Get action", None, True),
            ("Update Status", "PATCH", "/plan-purchase-actions/:id/status", "Update action status", {
                "status": "completed"
            }, True),
        ],
        "Safety": [
            ("Get Safety Guidelines", "GET", "/safety/guidelines", "Get safety guidelines", None, True),
            ("Get Emergency Contacts", "GET", "/safety/emergency-contacts", "Get emergency contacts", None, True),
            ("Add Emergency Contact", "POST", "/safety/emergency-contacts", "Add emergency contact", {
                "name": "John Doe",
                "phone": "+1234567890",
                "relationship": "friend"
            }, True),
            ("Send Emergency Alert", "POST", "/safety/emergency-alert", "Send emergency alert", {
                "message": "Help me!",
                "location": "123 Main St"
            }, True),
            ("Share Location", "POST", "/safety/share-location", "Share location", {
                "user_id": 2,
                "duration_minutes": 60
            }, True),
            ("Get Nearby Safe Places", "GET", "/safety/nearby-safe-places", "Get nearby safe places", None, True),
            ("Create Report", "POST", "/safety/report", "Create safety report", {
                "reported_user_id": 2,
                "category": "harassment",
                "description": "Report description"
            }, True),
            ("Get Report Categories", "GET", "/safety/report-categories", "Get report categories", None, True),
            ("Get Report History", "GET", "/safety/report-history", "Get report history", None, True),
            ("Moderate Content", "POST", "/safety/moderate-content", "Moderate content", {
                "content_id": 1,
                "action": "remove"
            }, True),
            ("Get Safety Statistics", "GET", "/safety/statistics", "Get safety statistics", None, True),
        ],
        "Analytics": [
            ("Get My Analytics", "GET", "/analytics/my-analytics", "Get user analytics", None, True),
            ("Get Engagement", "GET", "/analytics/engagement", "Get engagement analytics", None, True),
            ("Get Retention", "GET", "/analytics/retention", "Get retention analytics", None, True),
            ("Get Interactions", "GET", "/analytics/interactions", "Get interaction analytics", None, True),
            ("Get Profile Metrics", "GET", "/analytics/profile-metrics", "Get profile metrics", None, True),
            ("Track Activity", "POST", "/analytics/track-activity", "Track user activity", {
                "activity_type": "profile_view",
                "target_id": 2
            }, True),
        ],
        "Reference Data": [
            ("Get Countries", "GET", "/countries", "Get countries list", None, False),
            ("Get Country", "GET", "/countries/:id", "Get country details", None, False),
            ("Get Cities", "GET", "/cities", "Get cities list", None, False),
            ("Get Cities by Country", "GET", "/cities/country/:countryId", "Get cities by country", None, False),
            ("Get City", "GET", "/cities/:id", "Get city details", None, False),
            ("Get Genders", "GET", "/genders", "Get genders list", None, False),
            ("Get Preferred Genders", "GET", "/preferred-genders", "Get preferred genders", None, False),
            ("Get Jobs", "GET", "/jobs", "Get jobs list", None, False),
            ("Get Education", "GET", "/education", "Get education levels", None, False),
            ("Get Interests", "GET", "/interests", "Get interests list", None, False),
            ("Get Languages", "GET", "/languages", "Get languages list", None, False),
            ("Get Relation Goals", "GET", "/relation-goals", "Get relation goals", None, False),
            ("Get Music Genres", "GET", "/music-genres", "Get music genres", None, False),
        ],
        "Locales": [
            ("Get Locales", "GET", "/locales", "Get available locales", None, False),
            ("Get Translations", "GET", "/locales/translations", "Get translations", None, False),
            ("Get Current Locale", "GET", "/locales/current", "Get current locale", None, True),
            ("Update Locale", "PUT", "/locales", "Update locale preference", {
                "locale": "en"
            }, True),
        ],
        "Referrals": [
            ("Get Stats", "GET", "/referrals/stats", "Get referral statistics", None, True),
            ("Get Referral Code", "GET", "/referrals/code", "Get user referral code", None, True),
            ("Get History", "GET", "/referrals/history", "Get referral history", None, True),
            ("Get Tiers", "GET", "/referrals/tiers", "Get referral tiers", None, True),
            ("Validate Code", "POST", "/referrals/validate-code", "Validate referral code", {
                "code": "ABC123"
            }, True),
            ("Process Milestone", "POST", "/referrals/process-milestone", "Process milestone rewards", {
                "milestone_id": 1
            }, True),
            ("Mark Completed", "POST", "/referrals/mark-completed", "Mark referral as completed", {
                "referral_id": 1
            }, True),
        ],
        "OneSignal": [
            ("Update Player ID", "POST", "/onesignal/update-player-id", "Update OneSignal player ID", {
                "player_id": "player_id_here"
            }, True),
            ("Remove Player ID", "POST", "/onesignal/remove-player-id", "Remove OneSignal player ID", {
                "player_id": "player_id_here"
            }, True),
            ("Get Notification Info", "GET", "/onesignal/notification-info", "Get notification info", None, True),
            ("Update Preferences", "POST", "/onesignal/update-preferences", "Update notification preferences", {
                "push_enabled": True
            }, True),
            ("Reset Preferences", "POST", "/onesignal/reset-preferences", "Reset preferences", None, True),
            ("Test Notification", "POST", "/onesignal/test-notification", "Send test notification", None, True),
            ("Get Delivery Status", "GET", "/onesignal/delivery-status", "Get delivery status", None, True),
        ],
        "2FA": [
            ("Get 2FA Status", "GET", "/2fa/status", "Get 2FA status", None, True),
            ("Enable 2FA", "POST", "/2fa/enable", "Enable 2FA", {
                "password": "currentpassword"
            }, True),
            ("Verify 2FA", "POST", "/2fa/verify", "Verify 2FA code", {
                "code": "123456"
            }, True),
            ("Disable 2FA", "POST", "/2fa/disable", "Disable 2FA", {
                "password": "currentpassword"
            }, True),
            ("Get QR Code", "GET", "/2fa/qr-code", "Get 2FA QR code", None, True),
            ("Get Backup Codes", "POST", "/2fa/backup-codes", "Get backup codes", {
                "password": "currentpassword"
            }, True),
        ],
        "Sessions": [
            ("Get Sessions", "GET", "/sessions", "Get active sessions", None, True),
            ("Store Session", "POST", "/sessions/store", "Store new session", {
                "device_name": "iPhone 15 Pro",
                "ip_address": "192.168.1.1"
            }, True),
            ("Update Activity", "POST", "/sessions/activity", "Update session activity", {
                "session_id": 1
            }, True),
            ("Revoke Session", "POST", "/sessions/revoke/:id", "Revoke session", None, True),
            ("Revoke All Sessions", "POST", "/sessions/revoke-all", "Revoke all sessions", None, True),
        ],
        "Emergency Contacts": [
            ("Get Emergency Contacts", "GET", "/emergency-contacts", "Get emergency contacts", None, True),
            ("Create Emergency Contact", "POST", "/emergency-contacts", "Create emergency contact", {
                "name": "John Doe",
                "phone": "+1234567890",
                "relationship": "friend"
            }, True),
            ("Update Emergency Contact", "PUT", "/emergency-contacts/:id", "Update emergency contact", {
                "name": "Jane Doe",
                "phone": "+0987654321"
            }, True),
            ("Delete Emergency Contact", "DELETE", "/emergency-contacts/:id", "Delete emergency contact", None, True),
            ("Verify Emergency Contact", "POST", "/emergency-contacts/:id/verify", "Verify emergency contact", None, True),
            ("Confirm Emergency Contact", "POST", "/emergency-contacts/:id/confirm", "Confirm emergency contact", {
                "code": "123456"
            }, True),
            ("Trigger Emergency", "POST", "/emergency/trigger", "Trigger emergency alert", {
                "message": "Help!",
                "location": "123 Main St"
            }, True),
        ],
        "Account Management": [
            ("Change Email", "POST", "/account/change-email", "Change email", {
                "new_email": "newemail@example.com",
                "password": "currentpassword"
            }, True),
            ("Change Password", "POST", "/account/change-password", "Change password", {
                "current_password": "oldpassword",
                "new_password": "newpassword123"
            }, True),
            ("Deactivate Account", "POST", "/account/deactivate", "Deactivate account", {
                "password": "currentpassword"
            }, True),
            ("Reactivate Account", "POST", "/account/reactivate", "Reactivate account", None, True),
            ("Delete Account", "DELETE", "/account/delete", "Delete account permanently", {
                "password": "currentpassword"
            }, True),
        ],
        "Call Management": [
            ("Initiate Call", "POST", "/call-management/initiate", "Initiate call", {
                "receiver_id": 2,
                "call_type": "video"
            }, True),
            ("Accept Call", "POST", "/call-management/:id/accept", "Accept call", None, True),
            ("Reject Call", "POST", "/call-management/:id/reject", "Reject call", None, True),
            ("End Call", "POST", "/call-management/:id/end", "End call", None, True),
            ("Get Call History", "GET", "/call-management/history", "Get call history", None, True),
            ("Delete Call History", "DELETE", "/call-management/history/:id", "Delete call history", None, True),
            ("Get Call Statistics", "GET", "/call-management/statistics", "Get call statistics", None, True),
        ],
    }
    
    # Build collection structure
    collection = {
        "info": {
            "name": "LGBTinder API - Complete Collection",
            "description": f"Complete API collection for LGBTinder dating application. Generated on {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}. Contains all {sum(len(v) for v in endpoints.values())} endpoints organized by category.",
            "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json",
            "version": "3.0.0"
        },
        "auth": {
            "type": "bearer",
            "bearer": [
                {
                    "key": "token",
                    "value": "{{auth_token}}",
                    "type": "string"
                }
            ]
        },
        "variable": [
            {
                "key": "base_url",
                "value": "http://localhost:8000/api",
                "type": "string"
            },
            {
                "key": "auth_token",
                "value": "",
                "type": "string"
            },
            {
                "key": "user_id",
                "value": "",
                "type": "string"
            },
            {
                "key": "profile_completion_token",
                "value": "",
                "type": "string"
            }
        ],
        "item": []
    }
    
    # Create folders for each category
    for category, category_endpoints in endpoints.items():
        folder = {
            "name": category,
            "item": []
        }
        
        for name, method, path, description, body, requires_auth in category_endpoints:
            item = create_endpoint_item(name, method, path, description, body, requires_auth)
            folder["item"].append(item)
        
        collection["item"].append(folder)
    
    return collection

if __name__ == "__main__":
    collection = create_postman_collection()
    with open("LGBTinder_API_Postman_Collection_Complete.json", "w", encoding="utf-8") as f:
        json.dump(collection, f, indent=2, ensure_ascii=False)
    print("Postman collection created successfully!")
    print(f"Total endpoints: {sum(len(folder['item']) for folder in collection['item'])}")
    print(f"Total categories: {len(collection['item'])}")

