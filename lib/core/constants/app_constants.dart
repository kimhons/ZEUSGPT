/// App-wide constants and configuration
class AppConstants {
  AppConstants._(); // Private constructor to prevent instantiation

  // App Info
  static const String appName = 'ZeusGPT';
  static const String appTagline = 'Unleash the Power of 500+ AI Models';
  static const String appVersion = '0.1.0';
  static const int appBuildNumber = 1;

  // Links
  static const String websiteUrl = 'https://zeusgpt.com';
  static const String termsUrl = 'https://zeusgpt.com/terms';
  static const String privacyUrl = 'https://zeusgpt.com/privacy';
  static const String supportUrl = 'https://zeusgpt.com/support';
  static const String blogUrl = 'https://zeusgpt.com/blog';

  // Contact
  static const String supportEmail = 'support@zeusgpt.com';
  static const String helloEmail = 'hello@zeusgpt.com';
  static const String securityEmail = 'security@zeusgpt.com';

  // Social Media
  static const String twitterHandle = '@ZeusGPT';
  static const String twitterUrl = 'https://twitter.com/ZeusGPT';
  static const String linkedInUrl = 'https://linkedin.com/company/zeusgpt';

  // API Endpoints (should be loaded from environment)
  static const String aimlApiBaseUrl = 'https://api.aimlapi.com/v1';
  static const String togetherApiBaseUrl = 'https://api.together.xyz/v1';

  // Pagination
  static const int messagesPerPage = 50;
  static const int conversationsPerPage = 20;
  static const int modelsPerPage = 50;

  // Rate Limits (Free Tier)
  static const int freeMessagesPerDay = 25;
  static const int freeTokensPerDay = 10000;
  static const int freeImagesPerDay = 3;

  // Rate Limits (Pro Tier)
  static const int proMessagesPerDay = -1; // unlimited
  static const int proTokensPerDay = -1; // unlimited
  static const int proImagesPerDay = 100;

  // File Upload Limits
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedFileTypes = [
    'pdf',
    'txt',
    'doc',
    'docx',
    'png',
    'jpg',
    'jpeg',
  ];

  // Message Limits
  static const int maxMessageLength = 10000; // characters
  static const int maxConversationTitle = 100;
  static const int maxSystemPromptLength = 2000;

  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration uploadTimeout = Duration(minutes: 2);
  static const Duration streamTimeout = Duration(minutes: 5);

  // Cache Duration
  static const Duration userProfileCacheDuration = Duration(hours: 1);
  static const Duration modelsCacheDuration = Duration(hours: 6);
  static const Duration conversationsCacheDuration = Duration(minutes: 30);

  // Animation Durations
  static const Duration fastAnimation = Duration(milliseconds: 150);
  static const Duration normalAnimation = Duration(milliseconds: 250);
  static const Duration slowAnimation = Duration(milliseconds: 350);

  // Debounce Durations
  static const Duration searchDebounce = Duration(milliseconds: 300);
  static const Duration typingDebounce = Duration(milliseconds: 500);

  // AI Model Defaults
  static const String defaultModel = 'gpt-4o';
  static const double defaultTemperature = 0.7;
  static const int defaultMaxTokens = 2048;
  static const String defaultVoiceId = 'maple';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String conversationsCollection = 'conversations';
  static const String messagesCollection = 'messages';
  static const String modelsCollection = 'models';
  static const String teamsCollection = 'teams';
  static const String subscriptionsCollection = 'subscriptions';
  static const String apiUsageCollection = 'api_usage';
  static const String systemCollection = 'system';

  // Storage Paths
  static const String userAvatarsPath = 'avatars';
  static const String conversationFilesPath = 'conversation_files';
  static const String generatedImagesPath = 'generated_images';
  static const String voiceRecordingsPath = 'voice_recordings';

  // Hive Boxes (Local Storage)
  static const String settingsBox = 'settings';
  static const String cacheBox = 'cache';
  static const String conversationsBox = 'conversations';
  static const String messagesBox = 'messages';

  // Secure Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String apiKeyKey = 'api_key';
  static const String encryptionKeyKey = 'encryption_key';

  // Shared Preferences Keys
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';
  static const String onboardingCompletedKey = 'onboarding_completed';
  static const String lastSyncKey = 'last_sync';

  // Feature Flags (should be from Remote Config)
  static const bool enableVoiceMode = true;
  static const bool enableImageGeneration = true;
  static const bool enableWebSearch = true;
  static const bool enableTeamFeatures = true;
  static const bool enableCustomModels = false;

  // Analytics Events
  static const String eventAppOpened = 'app_opened';
  static const String eventMessageSent = 'message_sent';
  static const String eventModelSwitched = 'model_switched';
  static const String eventConversationCreated = 'conversation_created';
  static const String eventImageGenerated = 'image_generated';
  static const String eventVoiceUsed = 'voice_used';
  static const String eventSubscriptionStarted = 'subscription_started';
  static const String eventSubscriptionCanceled = 'subscription_canceled';

  // Error Messages
  static const String errorNetwork = 'Network error. Please check your connection.';
  static const String errorAuth = 'Authentication failed. Please login again.';
  static const String errorRateLimit = 'Rate limit exceeded. Please try again later.';
  static const String errorServerError = 'Server error. Please try again.';
  static const String errorUnknown = 'An unexpected error occurred.';

  // Success Messages
  static const String successMessageSent = 'Message sent successfully';
  static const String successConversationCreated = 'Conversation created';
  static const String successProfileUpdated = 'Profile updated successfully';
  static const String successSettingsSaved = 'Settings saved';

  // Subscription Tiers
  static const String tierFree = 'free';
  static const String tierPro = 'pro';
  static const String tierTeam = 'team';
  static const String tierEnterprise = 'enterprise';

  // Subscription Prices (USD)
  static const double priceProMonthly = 19.99;
  static const double priceProYearly = 199.99;
  static const double priceTeamMonthly = 49.99;
  static const double priceTeamYearly = 499.99;

  // RevenueCat Product IDs
  static const String productProMonthly = 'zeusgpt_pro_monthly';
  static const String productProYearly = 'zeusgpt_pro_yearly';
  static const String productTeamMonthly = 'zeusgpt_team_monthly';
  static const String productTeamYearly = 'zeusgpt_team_yearly';

  // Entitlement IDs
  static const String entitlementPro = 'pro';
  static const String entitlementTeam = 'team';

  // Model Categories
  static const String categoryText = 'text';
  static const String categoryImage = 'image';
  static const String categoryAudio = 'audio';
  static const String categoryMultimodal = 'multimodal';

  // Model Providers
  static const String providerOpenAI = 'openai';
  static const String providerAnthropic = 'anthropic';
  static const String providerGoogle = 'google';
  static const String providerMeta = 'meta';
  static const String providerMistral = 'mistral';
  static const String providerCohere = 'cohere';

  // Voice IDs (example voices)
  static const String voiceMaple = 'maple';
  static const String voiceCove = 'cove';
  static const String voiceBreeze = 'breeze';
  static const String voiceJuniper = 'juniper';

  // Message Roles
  static const String roleUser = 'user';
  static const String roleAssistant = 'assistant';
  static const String roleSystem = 'system';

  // Message Status
  static const String statusSending = 'sending';
  static const String statusSent = 'sent';
  static const String statusDelivered = 'delivered';
  static const String statusFailed = 'failed';
  static const String statusStreaming = 'streaming';

  // Regex Patterns
  static final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  static final RegExp urlRegex = RegExp(
    r'https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)',
  );
  static final RegExp phoneRegex = RegExp(
    r'^\+?[1-9]\d{1,14}$',
  );

  // Keyboard Shortcuts (for web/desktop)
  static const String shortcutNewChat = 'Cmd+N';
  static const String shortcutSearch = 'Cmd+K';
  static const String shortcutSettings = 'Cmd+,';
  static const String shortcutSendMessage = 'Enter';
  static const String shortcutNewLine = 'Shift+Enter';

  // Date Formats
  static const String dateFormatFull = 'MMMM d, yyyy';
  static const String dateFormatShort = 'MMM d';
  static const String dateFormatTime = 'h:mm a';
  static const String dateFormatDateTime = 'MMM d, h:mm a';

  // Image Generation
  static const int defaultImageWidth = 1024;
  static const int defaultImageHeight = 1024;
  static const String defaultImageStyle = 'natural';

  // Web Search
  static const int maxSearchResults = 5;
  static const Duration searchTimeout = Duration(seconds: 10);
}
