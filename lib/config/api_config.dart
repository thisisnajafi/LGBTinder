class ApiConfig {
  // Base URL for the API
  static const String baseUrl = 'http://127.0.0.1:8000/api'; // Using the server URL from API docs
  
  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String verifyLoginCode = '/auth/verify-login-code';
  static const String resendVerification = '/auth/resend-verification';
  static const String resendVerificationExisting = '/auth/resend-verification-existing';
  static const String sendVerification = '/auth/send-verification';
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String resetPassword = '/auth/reset-password';
  static const String changePassword = '/auth/change-password';
  static const String deleteAccount = '/auth/delete-account';
  static const String logout = '/auth/logout';
  
  // User preferences endpoints  
  static const String preferencesAge = '/preferences/age';
  
  // Profile endpoints
  static const String profile = '/profile';
  static const String profileUpdate = '/profile/update';
  static const String profileBadgeInfo = '/profile/badge/info';
  static const String profileById = '/profile/{id}';
  static const String profileFeeds = '/profile/{id}/feeds';
  static const String profileByJob = '/profile/by-job/{jobId}';
  static const String profileByLanguage = '/profile/by-language/{languageId}';
  static const String profileByRelationGoal = '/profile/by-relation-goal/{relationGoalId}';
  static const String profileByInterest = '/profile/by-interest/{interestId}';
  static const String profileByMusicGenre = '/profile/by-music-genre/{musicGenreId}';
  static const String profileByEducation = '/profile/by-education/{educationId}';
  static const String profileByPreferredGender = '/profile/by-preferred-gender/{preferredGenderId}';
  static const String profileByGender = '/profile/by-gender/{genderId}';
  
  // Image management endpoints
  static const String imagesUpload = '/images/upload';
  static const String imagesDelete = '/images/{id}';
  static const String imagesSetPrimary = '/images/{id}/set-primary';
  static const String imagesList = '/images/list';
  
  // Profile pictures endpoints
  static const String profilePicturesUpload = '/profile-pictures/upload';
  static const String profilePicturesDelete = '/profile-pictures/{id}';
  static const String profilePicturesSetPrimary = '/profile-pictures/{id}/set-primary';
  static const String profilePicturesList = '/profile-pictures/list';
  
  // Verification endpoints
  static const String verificationStatus = '/verification/status';
  static const String verificationGuidelines = '/verification/guidelines';
  static const String verificationHistory = '/verification/history';
  static const String verificationSubmitPhoto = '/verification/submit-photo';
  static const String verificationSubmitId = '/verification/submit-id';
  static const String verificationSubmitVideo = '/verification/submit-video';
  static const String verificationCancel = '/verification/cancel/{verificationId}';
  
  // Matching endpoints
  static const String matchingMatches = '/matching/matches';
  static const String matchingNearby = '/matching/nearby-suggestions';
  static const String matchingDebug = '/matching/debug';
  static const String matchingTest = '/matching/test';
  static const String matchingAdvanced = '/matching/advanced';
  static const String matchingCompatibility = '/matching/compatibility-score';
  static const String matchingAi = '/matching/ai-suggestions';
  static const String matchingLocation = '/matching/location-based';
  
  // Likes endpoints
  static const String likesLike = '/likes/like';
  static const String likesDislike = '/likes/dislike';
  static const String likesSuperlike = '/likes/superlike';
  static const String likesRespond = '/likes/respond';
  static const String likesMatches = '/likes/matches';
  static const String likesPending = '/likes/pending';
  static const String likesSuperlieHistory = '/likes/superlike-history';
  
  // Chat endpoints
  static const String chatSend = '/chat/send';
  static const String chatHistory = '/chat/history';
  static const String chatUsers = '/chat/users';
  static const String chatAccessUsers = '/chat/access-users';
  static const String chatMessage = '/chat/message';
  static const String chatUnreadCount = '/chat/unread-count';
  static const String chatTyping = '/chat/typing';
  static const String chatRead = '/chat/read';
  static const String chatOnline = '/chat/online';
  
  // Group chat endpoints
  static const String groupChatCreate = '/group-chat/create';
  static const String groupChatGroups = '/group-chat/groups';
  static const String groupChatGroupById = '/group-chat/groups/{groupId}';
  static const String groupChatSendMessage = '/group-chat/send-message';
  static const String groupChatMessages = '/group-chat/groups/{groupId}/messages';
  static const String groupChatAddMembers = '/group-chat/groups/{groupId}/add-members';
  static const String groupChatRemoveMember = '/group-chat/groups/{groupId}/remove-member';
  static const String groupChatLeave = '/group-chat/groups/{groupId}/leave';
  
  // Calls endpoints
  static const String callsInitiate = '/calls/initiate';
  static const String callsAccept = '/calls/accept';
  static const String callsReject = '/calls/reject';
  static const String callsEnd = '/calls/end';
  static const String callsHistory = '/calls/history';
  static const String callsActive = '/calls/active';
  
  // Feeds endpoints
  static const String feeds = '/feeds';
  static const String feedsCreate = '/feeds/create';
  static const String feedsById = '/feeds/{id}';
  static const String feedsUpdate = '/feeds/update/{id}';
  static const String feedsComments = '/feeds/{feedId}/comments';
  static const String feedsCommentLike = '/feeds/{feedId}/comments/{commentId}/like';
  static const String feedsCommentDislike = '/feeds/{feedId}/comments/{commentId}/dislike';
  static const String feedsCommentUpdate = '/feeds/{feedId}/comments/{commentId}';
  static const String feedsReactions = '/feeds/{feedId}/reactions';
  static const String feedsMyReaction = '/feeds/{feedId}/my-reaction';
  static const String feedsLiked = '/my/liked-feeds';
  
  // Stories endpoints
  static const String stories = '/stories';
  static const String storiesUpload = '/stories/upload';
  static const String storiesById = '/stories/{id}';
  static const String storiesLike = '/stories/{id}/like';
  static const String storiesReplies = '/stories/{storyId}/replies';
  static const String storiesReply = '/stories/{storyId}/reply';
  
  // Favorites endpoints
  static const String favoritesAdd = '/favorites/add';
  static const String favoritesRemove = '/favorites/remove';
  static const String favoritesList = '/favorites/list';
  static const String favoritesCheck = '/favorites/check';
  static const String favoritesNote = '/favorites/note';
  
  // Block endpoints
  static const String blockUser = '/block/user';
  static const String blockList = '/block/list';
  static const String blockCheck = '/block/check';
  
  // Mutes endpoints
  static const String mutesMute = '/mutes/mute';
  static const String mutesUnmute = '/mutes/unmute';
  static const String mutesList = '/mutes/list';
  static const String mutesSettings = '/mutes/settings';
  static const String mutesCheck = '/mutes/check';
  
  // Notifications endpoints
  static const String notifications = '/notifications';
  static const String notificationsUnreadCount = '/notifications/unread-count';
  static const String notificationsRead = '/notifications/{id}/read';
  static const String notificationsReadAll = '/notifications/read-all';
  static const String notificationsDelete = '/notifications/{id}';
  
  // User settings endpoints
  static const String userShowAdultContent = '/user/show-adult-content';
  static const String userOnesignalPlayer = '/user/onesignal-player';
  static const String userNotificationPreferences = '/user/notification-preferences';
  static const String userNotificationHistory = '/user/notification-history';
  static const String completeRegistration = '/complete-registration';
  
  // Profile wizard endpoints
  static const String profileWizardCurrentStep = '/profile-wizard/current-step';
  static const String profileWizardStepOptions = '/profile-wizard/step-options/{step}';
  static const String profileWizardSaveStep = '/profile-wizard/save-step/{step}';
  
  // Payment endpoints
  static const String stripePaymentIntent = '/stripe/payment-intent';
  static const String stripeCheckout = '/stripe/checkout';
  static const String stripeSubscription = '/stripe/subscription';
  static const String stripeSubscriptionDelete = '/stripe/subscription/{subscriptionId}';
  static const String stripeRefund = '/stripe/refund';
  static const String stripeAnalytics = '/stripe/analytics';
  static const String stripeWebhook = '/stripe/webhook';
  
  // Payment methods endpoints
  static const String paymentMethods = '/payment-methods';
  static const String paymentMethodsById = '/payment-methods/{id}';
  static const String paymentMethodsCurrency = '/payment-methods/currency/{currency}';
  static const String paymentMethodsType = '/payment-methods/type/{type}';
  static const String paymentMethodsValidate = '/payment-methods/validate-amount';
  
  // Plan purchase actions endpoints
  static const String planPurchaseActions = '/plan-purchase-actions';
  static const String planPurchaseActionsStats = '/plan-purchase-actions/statistics';
  static const String planPurchaseActionsToday = '/plan-purchase-actions/today';
  static const String planPurchaseActionsStatus = '/plan-purchase-actions/status';
  static const String planPurchaseActionsUser = '/plan-purchase-actions/user/{userId}';
  static const String planPurchaseActionsById = '/plan-purchase-actions/{id}';
  static const String planPurchaseActionsUpdateStatus = '/plan-purchase-actions/{id}/status';
  
  // Plan purchases endpoints
  static const String planPurchases = '/plan-purchases';
  static const String planPurchasesHistory = '/plan-purchases/history';
  static const String planPurchasesActive = '/plan-purchases/active';
  static const String planPurchasesExpired = '/plan-purchases/expired';
  static const String planPurchasesUpgradeOptions = '/plan-purchases/upgrade-options';
  static const String planPurchasesById = '/plan-purchases/{id}';
  
  // Subscription plans endpoints
  static const String subPlans = '/sub-plans';
  static const String subPlansDuration = '/sub-plans/duration';
  static const String subPlansCompare = '/sub-plans/compare';
  static const String subPlansByPlan = '/sub-plans/plan/{planId}';
  static const String subPlansUpgradeOptions = '/sub-plans/upgrade-options';
  static const String subPlansUpgrade = '/sub-plans/upgrade';
  static const String subPlansById = '/sub-plans/{subPlan}';
  
  // Superlike packs endpoints
  static const String superlikePacksWebhook = '/superlike-packs/stripe-webhook';
  static const String superlikePacksCheckout = '/superlike-packs/stripe-checkout';
  static const String superlikePacksAvailable = '/superlike-packs/available';
  static const String superlikePacksPurchase = '/superlike-packs/purchase';
  static const String superlikePacksUserPacks = '/superlike-packs/user-packs';
  static const String superlikePacksHistory = '/superlike-packs/purchase-history';
  static const String superlikePacksActivate = '/superlike-packs/activate-pending';
  
  // Reports endpoints
  static const String reports = '/reports';
  static const String reportsById = '/reports/{id}';
  
  // Safety endpoints
  static const String safetyGuidelines = '/safety/guidelines';
  static const String safetyEmergencyContacts = '/safety/emergency-contacts';
  static const String safetyEmergencyAlert = '/safety/emergency-alert';
  static const String safetyShareLocation = '/safety/share-location';
  static const String safetySafePlaces = '/safety/nearby-safe-places';
  static const String safetyReport = '/safety/report';
  static const String safetyReportCategories = '/safety/report-categories';
  static const String safetyReportHistory = '/safety/report-history';
  static const String safetyModerateContent = '/safety/moderate-content';
  static const String safetyStatistics = '/safety/statistics';
  
  // Analytics endpoints
  static const String analyticsMyAnalytics = '/analytics/my-analytics';
  static const String analyticsEngagement = '/analytics/engagement';
  static const String analyticsRetention = '/analytics/retention';
  static const String analyticsInteractions = '/analytics/interactions';
  static const String analyticsProfileMetrics = '/analytics/profile-metrics';
  static const String analyticsTrackActivity = '/analytics/track-activity';
  
  // Reference data endpoints
  static const String education = '/education';
  static const String genders = '/genders';
  static const String interests = '/interests';
  static const String jobs = '/jobs';
  static const String languages = '/languages';
  static const String musicGenres = '/music-genres';
  static const String preferredGenders = '/preferred-genders';
  static const String relationGoals = '/relation-goals';
  
  // Helper method to get full URL
  static String getUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }
  
  // Helper method to replace path parameters
  static String getUrlWithParams(String endpoint, Map<String, String> params) {
    String url = endpoint;
    params.forEach((key, value) {
      url = url.replaceAll('{$key}', value);
    });
    return getUrl(url);
  }
}
