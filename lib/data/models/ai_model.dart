import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_model.freezed.dart';
part 'ai_model.g.dart';

/// AI Model representing an available LLM
@freezed
class AIModel with _$AIModel {
  const AIModel._();

  const factory AIModel({
    required String modelId,
    required String name,
    required String displayName,
    required String description,
    required String provider, // openai, anthropic, google, meta, etc.
    @Default('text') String category, // text, image, audio, multimodal
    @Default('free') String tier, // free, pro, premium
    @Default([]) List<String> capabilities, // text, vision, function_calling, streaming
    required int contextWindow,
    required int maxOutputTokens,
    required int averageLatency, // in milliseconds
    required double speedRating, // 1-5
    required double qualityRating, // 1-5
    required ModelPricing pricing,
    required bool isAvailable,
    @Default([]) List<String> requiresSubscription, // [], ["pro"], ["team", "enterprise"]
    @Default(['us', 'eu', 'asia']) List<String> regions,
    required ModelRateLimits rateLimits,
    String? icon, // URL to provider icon
    String? color, // Brand color hex
    String? badge, // "Most Popular", "Fastest", "New", null
    required DateTime addedAt,
    required DateTime updatedAt,
    @Default(false) bool deprecated,
    DateTime? deprecationDate,
  }) = _AIModel;

  factory AIModel.fromJson(Map<String, dynamic> json) =>
      _$AIModelFromJson(json);

  /// Check if model is free to use
  bool get isFree => tier == 'free';

  /// Check if model requires Pro subscription
  bool get requiresPro => requiresSubscription.contains('pro');

  /// Check if model is multimodal (supports multiple input types)
  bool get isMultimodal => category == 'multimodal';

  /// Check if model supports vision
  bool get supportsVision => capabilities.contains('vision');

  /// Check if model supports function calling
  bool get supportsFunctionCalling => capabilities.contains('function_calling');

  /// Check if model supports streaming
  bool get supportsStreaming => capabilities.contains('streaming');

  /// Get estimated cost for a conversation with given token counts
  double estimateCost({required int promptTokens, required int completionTokens}) {
    return (promptTokens / 1000 * pricing.inputCostPer1kTokens) +
        (completionTokens / 1000 * pricing.outputCostPer1kTokens);
  }

  /// Get speed category (Fast, Medium, Slow)
  String get speedCategory {
    if (speedRating >= 4.0) return 'Fast';
    if (speedRating >= 3.0) return 'Medium';
    return 'Slow';
  }

  /// Get quality category (Excellent, Good, Fair)
  String get qualityCategory {
    if (qualityRating >= 4.5) return 'Excellent';
    if (qualityRating >= 3.5) return 'Good';
    return 'Fair';
  }

  /// Get formatted context window (e.g., "128K", "32K")
  String get formattedContextWindow {
    if (contextWindow >= 1000000) {
      return '${(contextWindow / 1000000).toStringAsFixed(1)}M';
    } else if (contextWindow >= 1000) {
      return '${(contextWindow / 1000).toStringAsFixed(0)}K';
    }
    return contextWindow.toString();
  }

  /// Get provider display name
  String get providerDisplayName {
    switch (provider.toLowerCase()) {
      case 'openai':
        return 'OpenAI';
      case 'anthropic':
        return 'Anthropic';
      case 'google':
        return 'Google';
      case 'meta':
        return 'Meta';
      case 'mistral':
        return 'Mistral AI';
      case 'cohere':
        return 'Cohere';
      default:
        return provider;
    }
  }
}

@freezed
class ModelPricing with _$ModelPricing {
  const factory ModelPricing({
    required double inputCostPer1kTokens, // USD
    required double outputCostPer1kTokens, // USD
    @Default('USD') String currency,
  }) = _ModelPricing;

  factory ModelPricing.fromJson(Map<String, dynamic> json) =>
      _$ModelPricingFromJson(json);
}

@freezed
class ModelRateLimits with _$ModelRateLimits {
  const factory ModelRateLimits({
    required int requestsPerMinute,
    required int tokensPerMinute,
  }) = _ModelRateLimits;

  factory ModelRateLimits.fromJson(Map<String, dynamic> json) =>
      _$ModelRateLimitsFromJson(json);
}

/// Model category filter enum
enum ModelCategory {
  all,
  text,
  image,
  audio,
  multimodal;

  String get displayName {
    switch (this) {
      case ModelCategory.all:
        return 'All Models';
      case ModelCategory.text:
        return 'Text';
      case ModelCategory.image:
        return 'Image';
      case ModelCategory.audio:
        return 'Audio';
      case ModelCategory.multimodal:
        return 'Multimodal';
    }
  }
}

/// Model tier filter enum
enum ModelTier {
  all,
  free,
  pro,
  premium;

  String get displayName {
    switch (this) {
      case ModelTier.all:
        return 'All Tiers';
      case ModelTier.free:
        return 'Free';
      case ModelTier.pro:
        return 'Pro';
      case ModelTier.premium:
        return 'Premium';
    }
  }
}

/// Model provider filter enum
enum ModelProvider {
  all,
  openai,
  anthropic,
  google,
  meta,
  mistral,
  cohere,
  other;

  String get displayName {
    switch (this) {
      case ModelProvider.all:
        return 'All Providers';
      case ModelProvider.openai:
        return 'OpenAI';
      case ModelProvider.anthropic:
        return 'Anthropic';
      case ModelProvider.google:
        return 'Google';
      case ModelProvider.meta:
        return 'Meta';
      case ModelProvider.mistral:
        return 'Mistral AI';
      case ModelProvider.cohere:
        return 'Cohere';
      case ModelProvider.other:
        return 'Other';
    }
  }
}

/// Model sorting options
enum ModelSortBy {
  popular,
  speed,
  quality,
  costLowToHigh,
  costHighToLow,
  newest;

  String get displayName {
    switch (this) {
      case ModelSortBy.popular:
        return 'Most Popular';
      case ModelSortBy.speed:
        return 'Fastest';
      case ModelSortBy.quality:
        return 'Highest Quality';
      case ModelSortBy.costLowToHigh:
        return 'Cost: Low to High';
      case ModelSortBy.costHighToLow:
        return 'Cost: High to Low';
      case ModelSortBy.newest:
        return 'Newest First';
    }
  }
}
