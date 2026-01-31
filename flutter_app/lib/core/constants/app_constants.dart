/// App-wide constants
class AppConstants {
  // App Info
  static const String appName = 'Roblox UGC Creator';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // AI Generation
  static const int defaultMeshyCost = 35;
  static const int defaultTripoCost = 35;
  static const int maxPolygonCount = 4000;

  // Rate Limits
  static const int maxJobsPerHour = 10;
  static const int maxRobloxUploadsPerDay = 10;

  // Polling
  static const int maxPollAttempts = 60;
  static const int pollIntervalSeconds = 5;

  // UI
  static const double maxContentWidth = 600;
  static const int shimmerDuration = 1500;

  // Storage Keys
  static const String onboardingCompleteKey = 'onboarding_complete';
  static const String darkModeKey = 'dark_mode';
  static const String languageKey = 'language';

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Pagination
  static const int pageSize = 20;
  static const int initialPageSize = 10;
}

/// Asset Categories
class AssetCategories {
  static const List<String> all = [
    'Tümü',
    'Şapka',
    'Aksesuar',
    'Gözlük',
    'Kanat',
    'Sırt',
    'Silah',
    'Araç',
    'Diğer',
  ];

  static const Map<String, String> icons = {
    'Tümü': '🎨',
    'Şapka': '🎩',
    'Aksesuar': '💎',
    'Gözlük': '🕶️',
    'Kanat': '🦋',
    'Sırt': '🎒',
    'Silah': '⚔️',
    'Araç': '🚗',
    'Diğer': '📦',
  };
}

/// Prompt Suggestions for AI Generation
class PromptSuggestions {
  static const List<String> suggestions = [
    'Altın taç',
    'Neon kanatlar',
    'Kristal kılıç',
    'Robot kask',
    'Ejderha kanadı',
    'Uzay başlığı',
    'Sihirli asa',
    'Cyberpunk gözlük',
  ];

  static const Map<String, List<String>> categorySuggestions = {
    'Şapka': [
      'Altın taç',
      'Kovboy şapkası',
      'Uzay başlığı',
      'Viking kaskı',
    ],
    'Aksesuar': [
      'Kristal kolye',
      'Sihirli yüzük',
      'Güç bilekliği',
    ],
    'Gözlük': [
      'Neon VR gözlük',
      'Cyberpunk gözlük',
      'Steampunk gözlük',
    ],
    'Kanat': [
      'Melek kanatları',
      'Ejderha kanatları',
      'Neon kanatlar',
      'Buz kanatları',
    ],
    'Silah': [
      'Kristal kılıç',
      'Lazer tabancası',
      'Sihirli asa',
      'Enerji bıçağı',
    ],
  };
}

/// Error Messages
class ErrorMessages {
  static const String networkError =
      'İnternet bağlantınızı kontrol edin ve tekrar deneyin.';
  static const String serverError =
      'Sunucu hatası oluştu. Lütfen daha sonra tekrar deneyin.';
  static const String authError = 'Oturum süresi doldu. Lütfen tekrar giriş yapın.';
  static const String rateLimitError =
      'Çok fazla istek gönderdiniz. Lütfen biraz bekleyin.';
  static const String insufficientCredits =
      'Yeterli krediniz yok. Kredi satın alın.';
  static const String jobFailed = 'İşlem başarısız oldu. Tekrar deneyin.';
  static const String publishFailed =
      'Roblox\'a yükleme başarısız. Tekrar deneyin.';
  static const String unknownError = 'Bilinmeyen bir hata oluştu.';
}

/// Success Messages
class SuccessMessages {
  static const String jobCreated = 'AI üretimi başlatıldı!';
  static const String jobCompleted = 'Model başarıyla oluşturuldu!';
  static const String assetSaved = 'Tasarım kaydedildi.';
  static const String publishSuccess = 'Roblox\'a başarıyla yüklendi!';
  static const String creditPurchased = 'Krediler hesabınıza eklendi.';
  static const String robloxConnected = 'Roblox hesabı bağlandı!';
}
