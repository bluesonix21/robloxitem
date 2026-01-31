/// User profile model
class UserProfile {
  final String id;
  final String email;
  final String? displayName;
  final String? avatarUrl;
  final bool isPremium;
  final DateTime createdAt;
  final UserSettings settings;

  UserProfile({
    required this.id,
    required this.email,
    this.displayName,
    this.avatarUrl,
    this.isPremium = false,
    required this.createdAt,
    this.settings = const UserSettings(),
  });

  /// Create from Supabase user data
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['display_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      isPremium: json['is_premium'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      settings: json['settings'] != null
          ? UserSettings.fromJson(json['settings'] as Map<String, dynamic>)
          : const UserSettings(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'is_premium': isPremium,
      'created_at': createdAt.toIso8601String(),
      'settings': settings.toJson(),
    };
  }

  /// Get display name or fallback to email
  String get name => displayName ?? email.split('@').first;

  /// Get initials for avatar
  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 2).toUpperCase();
  }

  /// Copy with method
  UserProfile copyWith({
    String? id,
    String? email,
    String? displayName,
    String? avatarUrl,
    bool? isPremium,
    DateTime? createdAt,
    UserSettings? settings,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isPremium: isPremium ?? this.isPremium,
      createdAt: createdAt ?? this.createdAt,
      settings: settings ?? this.settings,
    );
  }
}

/// User settings/preferences
class UserSettings {
  final bool darkMode;
  final bool notifications;
  final String language;
  final AIProvider preferredProvider;

  const UserSettings({
    this.darkMode = false,
    this.notifications = true,
    this.language = 'tr',
    this.preferredProvider = AIProvider.meshy,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      darkMode: json['dark_mode'] as bool? ?? false,
      notifications: json['notifications'] as bool? ?? true,
      language: json['language'] as String? ?? 'tr',
      preferredProvider: _parseProvider(json['preferred_provider'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dark_mode': darkMode,
      'notifications': notifications,
      'language': language,
      'preferred_provider': preferredProvider.name,
    };
  }

  UserSettings copyWith({
    bool? darkMode,
    bool? notifications,
    String? language,
    AIProvider? preferredProvider,
  }) {
    return UserSettings(
      darkMode: darkMode ?? this.darkMode,
      notifications: notifications ?? this.notifications,
      language: language ?? this.language,
      preferredProvider: preferredProvider ?? this.preferredProvider,
    );
  }

  static AIProvider _parseProvider(String? value) {
    switch (value?.toLowerCase()) {
      case 'tripo':
        return AIProvider.tripo;
      case 'meshy':
      default:
        return AIProvider.meshy;
    }
  }
}

/// AI Provider enum (duplicated from job_model for convenience)
enum AIProvider {
  meshy,
  tripo,
}

/// Extension for AI provider display
extension AIProviderExtension on AIProvider {
  String get displayName {
    switch (this) {
      case AIProvider.meshy:
        return 'Meshy';
      case AIProvider.tripo:
        return 'Tripo AI';
    }
  }

  String get description {
    switch (this) {
      case AIProvider.meshy:
        return 'Hızlı ve kaliteli 3D model üretimi';
      case AIProvider.tripo:
        return 'Detaylı ve gerçekçi 3D modeller';
    }
  }

  int get creditCost {
    switch (this) {
      case AIProvider.meshy:
        return 5;
      case AIProvider.tripo:
        return 8;
    }
  }
}
