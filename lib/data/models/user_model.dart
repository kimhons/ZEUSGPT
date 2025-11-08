import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// Subscription tier levels
enum SubscriptionTier {
  free,
  pro,
  team,
  enterprise,
}

/// Subscription status
enum SubscriptionStatus {
  active,
  canceled,
  past_due,
  trialing,
}

/// AI model provider
enum ModelProvider {
  openai,
  anthropic,
  google,
  meta,
  mistral,
  cohere,
}

/// User model representing a ZeusGPT user
@freezed
class UserModel with _$UserModel {
  const UserModel._();

  const factory UserModel({
    required String userId,
    required String email,
    required String displayName,
    String? photoURL,
    String? phoneNumber,
    @Default(false) bool emailVerified,
    required UserSubscription subscription,
    required UserPreferences preferences,
    required UserUsage usage,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? lastLoginAt,
    String? lastLoginIP,
    @Default(false) bool mfaEnabled,
    @Default([]) List<UserDevice> devices,
    @Default(false) bool onboardingCompleted,
    @Default('1.0') String termsAcceptedVersion,
    @Default('1.0') String privacyAcceptedVersion,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  /// Check if user has Pro subscription or higher
  bool get isPro =>
      subscription.tier == SubscriptionTier.pro ||
      subscription.tier == SubscriptionTier.team ||
      subscription.tier == SubscriptionTier.enterprise;

  /// Check if user has active subscription
  bool get hasActiveSubscription => subscription.status == SubscriptionStatus.active;

  /// Get initials for avatar
  String get initials {
    final names = displayName.split(' ');
    if (names.isEmpty) return '?';
    if (names.length == 1) return names[0][0].toUpperCase();
    return '${names[0][0]}${names[1][0]}'.toUpperCase();
  }
}

@freezed
class UserSubscription with _$UserSubscription {
  const factory UserSubscription({
    @Default(SubscriptionTier.free) SubscriptionTier tier,
    @Default(SubscriptionStatus.active) SubscriptionStatus status,
    DateTime? currentPeriodStart,
    DateTime? currentPeriodEnd,
    @Default(false) bool cancelAtPeriodEnd,
    String? revenueCatId,
  }) = _UserSubscription;

  factory UserSubscription.fromJson(Map<String, dynamic> json) =>
      _$UserSubscriptionFromJson(json);
}

@freezed
class UserPreferences with _$UserPreferences {
  const factory UserPreferences({
    @Default(ThemeMode.system) ThemeMode theme,
    @Default('gpt-4o') String defaultModel,
    String? defaultModelId,
    @Default(ModelProvider.openai) ModelProvider defaultProvider,
    @Default('maple') String voiceId,
    @Default('en') String language,
    @Default(true) bool enableNotifications,
    @Default(true) bool enableAnalytics,
    @Default(true) bool enableMemory,
  }) = _UserPreferences;

  factory UserPreferences.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesFromJson(json);
}

@freezed
class UserUsage with _$UserUsage {
  const factory UserUsage({
    @Default(0) int messagesThisMonth,
    @Default(0) int tokensThisMonth,
    @Default(0) int imagesThisMonth,
    DateTime? lastResetDate,
  }) = _UserUsage;

  factory UserUsage.fromJson(Map<String, dynamic> json) =>
      _$UserUsageFromJson(json);
}

@freezed
class UserDevice with _$UserDevice {
  const factory UserDevice({
    required String deviceId,
    required String deviceName,
    required DateTime lastActiveAt,
    required String platform, // ios, android, web
  }) = _UserDevice;

  factory UserDevice.fromJson(Map<String, dynamic> json) =>
      _$UserDeviceFromJson(json);
}
