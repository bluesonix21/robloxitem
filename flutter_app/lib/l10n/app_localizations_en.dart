// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Roblox UGC Creator';

  @override
  String get appTagline => 'Create 3D models with AI ✨';

  @override
  String get common_ok => 'OK';

  @override
  String get common_cancel => 'Cancel';

  @override
  String get common_save => 'Save';

  @override
  String get common_edit => 'Edit';

  @override
  String get common_delete => 'Delete';

  @override
  String get common_done => 'Done';

  @override
  String get common_loading => 'Loading...';

  @override
  String get common_error => 'Error';

  @override
  String get common_success => 'Success';

  @override
  String get common_retry => 'Retry';

  @override
  String get common_close => 'Close';

  @override
  String get common_back => 'Back';

  @override
  String get common_next => 'Next';

  @override
  String get common_skip => 'Skip';

  @override
  String get common_continue => 'Continue';

  @override
  String get common_yes => 'Yes';

  @override
  String get common_no => 'No';

  @override
  String get common_all => 'All';

  @override
  String get common_apply => 'Apply';

  @override
  String get common_reset => 'Reset';

  @override
  String get common_search => 'Search';

  @override
  String get common_filter => 'Filter';

  @override
  String get common_sort => 'Sort';

  @override
  String get common_seeAll => 'See All';

  @override
  String get common_showMore => 'Show More';

  @override
  String get common_showLess => 'Show Less';

  @override
  String get common_credits => 'credits';

  @override
  String get common_credit => 'credit';

  @override
  String common_creditCount(int count) {
    return '$count credits';
  }

  @override
  String get home_greeting => 'Hello! 👋';

  @override
  String get home_title => 'Roblox UGC Creator';

  @override
  String get home_heroTitle => 'What will you create today?';

  @override
  String get home_searchHint => 'Search templates, designs, or inspiration...';

  @override
  String get home_aiGeneratedTitle => '✨ AI Generated';

  @override
  String get home_aiGeneratedSubtitle =>
      'Amazing designs created by the community';

  @override
  String get home_trendingTitle => '🔥 Trending Designs';

  @override
  String get home_trendingSubtitle => 'Most popular this week';

  @override
  String get home_yourDesignsTitle => '🎨 Your Designs';

  @override
  String get home_yourDesignsSubtitle => 'Continue where you left off';

  @override
  String get home_inspirationTitle => '💡 Get Inspired';

  @override
  String get home_createWithAI => 'Create with AI';

  @override
  String get home_createWithAISubtitle => 'Type text, get 3D';

  @override
  String get home_templates => 'Templates';

  @override
  String get home_templatesSubtitle => 'Ready-made models';

  @override
  String get home_premiumLabel => '✨ PREMIUM';

  @override
  String get home_premiumTitle => 'Unlimited AI Generation';

  @override
  String get home_premiumSubtitle =>
      '500+ credits and premium features every month';

  @override
  String get home_keyboardShortcut => 'K';

  @override
  String get inspiration_animeCharacter => 'Anime Character';

  @override
  String get inspiration_cyberpunkRobot => 'Cyberpunk Robot';

  @override
  String get inspiration_galaxyWings => 'Galaxy Wings';

  @override
  String get inspiration_fireEffect => 'Fire Effect';

  @override
  String get inspiration_iceCrystal => 'Ice Crystal';

  @override
  String get auth_login => 'Login';

  @override
  String get auth_register => 'Register';

  @override
  String get auth_loginTab => 'Login';

  @override
  String get auth_registerTab => 'Register';

  @override
  String get auth_email => 'Email';

  @override
  String get auth_emailHint => 'example@email.com';

  @override
  String get auth_emailRequired => 'Email is required';

  @override
  String get auth_emailInvalid => 'Please enter a valid email';

  @override
  String get auth_password => 'Password';

  @override
  String get auth_passwordHint => '••••••••';

  @override
  String get auth_passwordRequired => 'Password is required';

  @override
  String get auth_passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get auth_forgotPassword => 'Forgot Password?';

  @override
  String get auth_forgotPasswordTitle => 'Forgot Password';

  @override
  String get auth_forgotPasswordDescription =>
      'We\'ll send a password reset link to your email.';

  @override
  String get auth_send => 'Send';

  @override
  String get auth_resetLinkSent => 'Password reset link sent.';

  @override
  String get auth_name => 'Full Name';

  @override
  String get auth_nameHint => 'John Doe';

  @override
  String get auth_nameRequired => 'Full name is required';

  @override
  String get auth_confirmPassword => 'Confirm Password';

  @override
  String get auth_confirmPasswordHint => 'Re-enter your password';

  @override
  String get auth_confirmPasswordRequired =>
      'Password confirmation is required';

  @override
  String get auth_passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get auth_or => 'or';

  @override
  String get auth_continueWithGoogle => 'Continue with Google';

  @override
  String get auth_continueWithApple => 'Continue with Apple';

  @override
  String auth_termsAgreement(String terms, String privacy) {
    return 'By continuing, you agree to our $terms and $privacy.';
  }

  @override
  String get auth_termsOfService => 'Terms of Service';

  @override
  String get auth_privacyPolicy => 'Privacy Policy';

  @override
  String get auth_registerSuccess =>
      'Registration successful! Please check your email.';

  @override
  String get auth_errorInvalidCredentials => 'Invalid email or password.';

  @override
  String get auth_errorEmailNotConfirmed => 'Please confirm your email.';

  @override
  String get auth_errorUserAlreadyRegistered =>
      'This email is already registered.';

  @override
  String get auth_errorPasswordTooShort =>
      'Password should be at least 6 characters.';

  @override
  String get auth_errorGeneric => 'An error occurred. Please try again.';

  @override
  String get auth_errorGoogle => 'Could not sign in with Google.';

  @override
  String get auth_errorApple => 'Could not sign in with Apple.';

  @override
  String get discover_title => 'Discover';

  @override
  String get discover_subtitle => 'Get inspired by the community';

  @override
  String get discover_categoryAll => 'All';

  @override
  String get discover_categoryPopular => 'Popular';

  @override
  String get discover_categoryNew => 'New';

  @override
  String get discover_categoryAccessory => 'Accessory';

  @override
  String get discover_categoryClothing => 'Clothing';

  @override
  String get discover_categoryHair => 'Hair';

  @override
  String get discover_categoryHat => 'Hat';

  @override
  String get discover_categoryWeapon => 'Weapon';

  @override
  String get discover_gallery => '🎨 Gallery';

  @override
  String get discover_sortPopular => 'Most Popular';

  @override
  String get discover_sortNewest => 'Newest';

  @override
  String get discover_noTrending => 'No trending designs yet';

  @override
  String get discover_filter => 'Filter';

  @override
  String get discover_filterTitle => 'Filter';

  @override
  String get discover_sort => 'Sort';

  @override
  String get discover_sortTitle => 'Sort By';

  @override
  String get discover_reset => 'Reset';

  @override
  String get discover_apply => 'Apply';

  @override
  String get discover_trend => 'Trend';

  @override
  String get discover_aiBadge => 'AI';

  @override
  String get profile_title => 'Profile';

  @override
  String get profile_editProfile => 'Edit Profile';

  @override
  String get profile_editProfileTitle => 'Edit Profile';

  @override
  String get profile_displayNameLabel => 'Display Name';

  @override
  String get profile_displayNameHint => 'Enter your name';

  @override
  String get profile_displayNameEmpty => 'Display name cannot be empty';

  @override
  String get profile_credits => 'My Credits';

  @override
  String get profile_credit => 'credit';

  @override
  String get profile_buyCredits => 'Buy Credits';

  @override
  String get profile_buyCreditsTitle => '💎 Buy Credits';

  @override
  String get profile_saving => 'Saving...';

  @override
  String get profile_updateSuccess => 'Profile updated';

  @override
  String get profile_updateError => 'Could not update profile';

  @override
  String get profile_robloxAccount => 'Roblox Account';

  @override
  String get profile_robloxConnected => 'Connected';

  @override
  String get profile_robloxNotConnected => 'Not connected';

  @override
  String get profile_robloxConnect => 'Connect';

  @override
  String get profile_robloxDisconnect => 'Disconnect';

  @override
  String get profile_robloxConnectError => 'Could not open connection';

  @override
  String get profile_robloxOAuthError => 'Could not start OAuth';

  @override
  String get profile_robloxConnectSuccess => 'Roblox connection successful! 🎉';

  @override
  String get profile_premium => 'Go Premium';

  @override
  String get profile_premiumTitle => '👑 PREMIUM';

  @override
  String get profile_premiumSubtitle => 'Unlimited access and premium features';

  @override
  String get profile_settings => 'Settings';

  @override
  String get profile_darkMode => 'Dark Mode';

  @override
  String get profile_notifications => 'Notifications';

  @override
  String get profile_language => 'Language';

  @override
  String get profile_languageValue => 'English';

  @override
  String get profile_transactionHistory => 'Transaction History';

  @override
  String get profile_helpSupport => 'Help & Support';

  @override
  String get profile_about => 'About';

  @override
  String profile_version(String version) {
    return 'v$version';
  }

  @override
  String get profile_logout => 'Logout';

  @override
  String get profile_logoutConfirm => 'Are you sure you want to logout?';

  @override
  String get profile_creditPackagePopular => '⭐ Most Popular';

  @override
  String profile_creditPackageBonus(int bonus) {
    return '+$bonus bonus';
  }

  @override
  String get settings_title => 'Settings';

  @override
  String get settings_appearance => 'Appearance';

  @override
  String get settings_darkMode => 'Dark Mode';

  @override
  String get settings_darkModeDescription => 'Change app theme';

  @override
  String get settings_notifications => 'Notifications';

  @override
  String get settings_pushNotifications => 'Push Notifications';

  @override
  String get settings_pushNotificationsDescription =>
      'Get notified when jobs complete';

  @override
  String get settings_emailNotifications => 'Email Notifications';

  @override
  String get settings_emailNotificationsDescription =>
      'Receive emails for important updates';

  @override
  String get settings_aiSettings => 'AI Settings';

  @override
  String get settings_defaultProvider => 'Default AI Provider';

  @override
  String get settings_providerMeshy => 'Meshy';

  @override
  String get settings_providerMeshyDescription => 'Fast and high quality';

  @override
  String get settings_providerTripo => 'Tripo';

  @override
  String get settings_providerTripoDescription => 'Detailed models';

  @override
  String get settings_selectProvider => 'Select AI Provider';

  @override
  String get settings_defaultQuality => 'Default Quality';

  @override
  String get settings_qualityHigh => 'High';

  @override
  String get settings_qualityHighDescription => 'Best quality';

  @override
  String get settings_qualityMedium => 'Medium';

  @override
  String get settings_qualityMediumDescription => 'Balanced performance';

  @override
  String get settings_qualityLow => 'Low';

  @override
  String get settings_qualityLowDescription => 'Faster, less credits';

  @override
  String get settings_selectQuality => 'Select Quality';

  @override
  String get settings_storage => 'Storage';

  @override
  String get settings_clearCache => 'Clear Cache';

  @override
  String settings_cacheSize(int size) {
    return '$size MB used';
  }

  @override
  String get settings_clearCacheTitle => 'Clear Cache';

  @override
  String settings_clearCacheDescription(int size) {
    return '$size MB cache will be cleared. This cannot be undone.';
  }

  @override
  String get settings_clear => 'Clear';

  @override
  String get settings_cacheCleared => 'Cache cleared';

  @override
  String get settings_downloadedFiles => 'Downloaded Files';

  @override
  String settings_downloadedFilesCount(int count) {
    return '$count files';
  }

  @override
  String get settings_about => 'About';

  @override
  String get settings_appVersion => 'App Version';

  @override
  String settings_buildNumber(String number) {
    return 'Build $number';
  }

  @override
  String get settings_termsOfService => 'Terms of Service';

  @override
  String get settings_privacyPolicy => 'Privacy Policy';

  @override
  String get settings_helpSupport => 'Help & Support';

  @override
  String get create_title => 'Create with AI';

  @override
  String get create_subtitle => 'Write your dream 3D model';

  @override
  String get create_aiPowered => 'AI Powered';

  @override
  String get create_promptLabel => 'What do you want to create? ✨';

  @override
  String get create_promptHint =>
      'E.g., \"Cyberpunk style samurai helmet with neon blue details, shiny metallic surface\"';

  @override
  String get create_promptTip => 'Write detailed for better results';

  @override
  String create_characterCount(int current, int max) {
    return '$current/$max';
  }

  @override
  String get create_inspiration => 'Get inspired';

  @override
  String get create_provider => 'AI Provider';

  @override
  String get create_providerMeshy => 'Meshy';

  @override
  String get create_providerMeshyDesc => 'High quality & detail';

  @override
  String get create_providerMeshyTime => '~2-3 min';

  @override
  String get create_providerTripo => 'Tripo';

  @override
  String get create_providerTripoDesc => 'Ultra fast generation';

  @override
  String get create_providerTripoTime => '~30 sec';

  @override
  String get create_category => 'Category';

  @override
  String get create_categoryAccessory => 'Accessory';

  @override
  String get create_categoryHat => 'Hat';

  @override
  String get create_categoryHair => 'Hair';

  @override
  String get create_categoryClothing => 'Clothing';

  @override
  String get create_categoryBack => 'Back';

  @override
  String get create_categoryFace => 'Face';

  @override
  String get create_categoryWeapon => 'Weapon';

  @override
  String get create_style => 'Style';

  @override
  String get create_styleRealistic => 'Realistic';

  @override
  String get create_styleAnime => 'Anime';

  @override
  String get create_styleCartoon => 'Cartoon';

  @override
  String get create_styleVoxel => 'Voxel';

  @override
  String get create_advancedOptions => 'Advanced Options';

  @override
  String get create_hideAdvanced => 'Hide Advanced Options';

  @override
  String get create_estimatedCost => 'Estimated Cost';

  @override
  String create_creditsWillBeUsed(int cost) {
    return '$cost credits will be used';
  }

  @override
  String get create_button => 'Create with AI';

  @override
  String get create_buttonGenerating => 'Generating...';

  @override
  String get create_errorStart => 'Could not start process';

  @override
  String get create_successStart => 'AI generation started! ✨';

  @override
  String get create_suggestion1 => 'Cyberpunk robot helmet, neon blue lights';

  @override
  String get create_suggestion2 => 'Fire wings, realistic flame effect';

  @override
  String get create_suggestion3 => 'Anime style crystal crown, glowing';

  @override
  String get create_suggestion4 => 'Dragon armor, golden details';

  @override
  String get create_suggestion5 => 'Moonlight cloak, mystical glow';

  @override
  String get create_suggestion6 => 'Samurai sword, katana, shiny steel';

  @override
  String get search_title => 'Search';

  @override
  String get search_hint => 'Search templates, designs, or users...';

  @override
  String get search_filterAll => 'All';

  @override
  String get search_filterTemplates => 'Templates';

  @override
  String get search_filterDesigns => 'Designs';

  @override
  String get search_filterUsers => 'Users';

  @override
  String get search_trending => 'Trending Searches';

  @override
  String get search_recent => 'Recent Searches';

  @override
  String get search_clear => 'Clear';

  @override
  String get search_quickAccess => 'Quick Access';

  @override
  String get search_error => 'Search failed';

  @override
  String get trending_cyberpunk => 'Cyberpunk';

  @override
  String get trending_animeStyle => 'Anime style';

  @override
  String get trending_wings => 'Wings';

  @override
  String get trending_neon => 'Neon';

  @override
  String get trending_halloween => 'Halloween';

  @override
  String get trending_galaxy => 'Galaxy';

  @override
  String trending_count(String count) {
    return '${count}K';
  }

  @override
  String get status_completed => 'Completed';

  @override
  String get status_processing => 'Processing';

  @override
  String get status_draft => 'Draft';

  @override
  String get status_queued => 'Queued';

  @override
  String get status_inProgress => 'In Progress';

  @override
  String get status_failed => 'Failed';

  @override
  String get status_published => 'Published';

  @override
  String get error_generic => 'An error occurred';

  @override
  String get error_network => 'Network error. Please check your connection.';

  @override
  String get error_server => 'Server error. Please try again later.';

  @override
  String get error_unauthorized => 'Unauthorized. Please login again.';

  @override
  String get error_notFound => 'Not found';

  @override
  String get error_unknown => 'Unknown error occurred';
}
