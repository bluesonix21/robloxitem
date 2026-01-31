/// API Configuration and Endpoints
class ApiConfig {
  // Singleton pattern
  static final ApiConfig _instance = ApiConfig._internal();
  factory ApiConfig() => _instance;
  ApiConfig._internal();


  // ═══════════════════════════════════════════════════════════════════════════
  // BASE URLS
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Supabase project URL (replace with your project)
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://pewdlzrpziltvabaqytk.supabase.co',
  );
  
  /// Supabase Edge Functions base URL
  static const String functionsUrl = String.fromEnvironment(
    'SUPABASE_FUNCTIONS_URL',
    defaultValue: 'https://pewdlzrpziltvabaqytk.functions.supabase.co',
  );
  
  /// Supabase anon key (replace with your key)
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBld2RsenJwemlsdHZhYmFxeXRrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk3ODAzNDYsImV4cCI6MjA4NTM1NjM0Nn0.0qysGDItHd1v3xGV_OVBtoQ305dBmBiAF_Q7H19xE6U',
  );

  /// OAuth return URL (deep link) configured in Roblox Open Cloud
  static const String robloxOAuthReturnUrl = 'robloxugc://oauth';

  // ═══════════════════════════════════════════════════════════════════════════
  // API ENDPOINTS (Edge Functions)
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Job creation endpoint
  static const String jobCreate = '/job-create';
  
  /// Job status endpoint
  static const String jobStatus = '/job-status';
  
  /// Job cancel endpoint
  static const String jobCancel = '/job-cancel';
  
  /// Credits endpoint
  static const String credits = '/credits';
  
  /// Asset fetch endpoint
  static const String assetFetch = '/asset-fetch';
  
  /// Meshy polling endpoint
  static const String meshyPoll = '/meshy-poll';
  
  /// Tripo polling endpoint
  static const String tripoPoll = '/tripo-poll';
  
  /// Roblox OAuth start
  static const String robloxOAuthStart = '/roblox-oauth-start';
  
  /// Roblox OAuth callback
  static const String robloxOAuthCallback = '/roblox-oauth-callback';

  /// Roblox profile endpoint
  static const String robloxProfile = '/roblox-profile';
  
  /// Roblox publish endpoint
  static const String robloxPublish = '/roblox-publish';
  
  /// Roblox publish status endpoint
  static const String robloxPublishStatus = '/roblox-publish-status';

  /// Premium checkout
  static const String premiumCheckout = '/premium-checkout';

  /// Account deletion
  static const String deleteAccount = '/delete-account';

  // ═══════════════════════════════════════════════════════════════════════════
  // TIMEOUTS
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Default request timeout
  static const Duration requestTimeout = Duration(seconds: 30);
  
  /// Long request timeout (for AI operations)
  static const Duration longRequestTimeout = Duration(seconds: 120);
  
  /// Polling interval for job status
  static const Duration pollingInterval = Duration(seconds: 3);

  // ═══════════════════════════════════════════════════════════════════════════
  // ROBLOX INTEGRATION
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Roblox deep link base URL
  static const String robloxDeepLinkBase = 'roblox://';
  
  /// Your Roblox homestore place ID
  static const String robloxPlaceId = String.fromEnvironment(
    'ROBLOX_PLACE_ID',
    defaultValue: 'YOUR_PLACE_ID',
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Build full endpoint URL
  static String endpoint(String path) => '$functionsUrl$path';

  /// Resolve Supabase storage base URL (direct host)
  static String storageBaseUrl() {
    final uri = Uri.parse(supabaseUrl);
    final host = uri.host;
    if (host.endsWith('.supabase.co')) {
      final projectRef = host.split('.').first;
      return '${uri.scheme}://$projectRef.storage.supabase.co';
    }
    return '${uri.scheme}://${uri.host}';
  }
  
  /// Build Roblox deep link with launch data
  static String buildRobloxDeepLink(String assetId) {
    final launchData = '{"id":"$assetId"}';
    final encoded = Uri.encodeComponent(launchData);
    return '${robloxDeepLinkBase}placeId=$robloxPlaceId&launchData=$encoded';
  }
}
