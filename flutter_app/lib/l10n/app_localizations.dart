import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr')
  ];

  /// Application title displayed in app bar and task switcher
  ///
  /// In en, this message translates to:
  /// **'Roblox UGC Creator'**
  String get appTitle;

  /// Application tagline shown on auth screen
  ///
  /// In en, this message translates to:
  /// **'Create 3D models with AI ✨'**
  String get appTagline;

  /// No description provided for @common_ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get common_ok;

  /// No description provided for @common_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get common_cancel;

  /// No description provided for @common_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get common_save;

  /// No description provided for @common_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get common_edit;

  /// No description provided for @common_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get common_delete;

  /// No description provided for @common_done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get common_done;

  /// No description provided for @common_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get common_loading;

  /// No description provided for @common_error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get common_error;

  /// No description provided for @common_success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get common_success;

  /// No description provided for @common_retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get common_retry;

  /// No description provided for @common_close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get common_close;

  /// No description provided for @common_back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get common_back;

  /// No description provided for @common_next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get common_next;

  /// No description provided for @common_skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get common_skip;

  /// No description provided for @common_continue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get common_continue;

  /// No description provided for @common_yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get common_yes;

  /// No description provided for @common_no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get common_no;

  /// No description provided for @common_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get common_all;

  /// No description provided for @common_apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get common_apply;

  /// No description provided for @common_reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get common_reset;

  /// No description provided for @common_search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get common_search;

  /// No description provided for @common_filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get common_filter;

  /// No description provided for @common_sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get common_sort;

  /// No description provided for @common_seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get common_seeAll;

  /// No description provided for @common_showMore.
  ///
  /// In en, this message translates to:
  /// **'Show More'**
  String get common_showMore;

  /// No description provided for @common_showLess.
  ///
  /// In en, this message translates to:
  /// **'Show Less'**
  String get common_showLess;

  /// No description provided for @common_credits.
  ///
  /// In en, this message translates to:
  /// **'credits'**
  String get common_credits;

  /// No description provided for @common_credit.
  ///
  /// In en, this message translates to:
  /// **'credit'**
  String get common_credit;

  /// Number of credits
  ///
  /// In en, this message translates to:
  /// **'{count} credits'**
  String common_creditCount(int count);

  /// No description provided for @home_greeting.
  ///
  /// In en, this message translates to:
  /// **'Hello! 👋'**
  String get home_greeting;

  /// No description provided for @home_title.
  ///
  /// In en, this message translates to:
  /// **'Roblox UGC Creator'**
  String get home_title;

  /// Main hero section title with gradient styling
  ///
  /// In en, this message translates to:
  /// **'What will you create today?'**
  String get home_heroTitle;

  /// No description provided for @home_searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search templates, designs, or inspiration...'**
  String get home_searchHint;

  /// No description provided for @home_aiGeneratedTitle.
  ///
  /// In en, this message translates to:
  /// **'✨ AI Generated'**
  String get home_aiGeneratedTitle;

  /// No description provided for @home_aiGeneratedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Amazing designs created by the community'**
  String get home_aiGeneratedSubtitle;

  /// No description provided for @home_trendingTitle.
  ///
  /// In en, this message translates to:
  /// **'🔥 Trending Designs'**
  String get home_trendingTitle;

  /// No description provided for @home_trendingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Most popular this week'**
  String get home_trendingSubtitle;

  /// No description provided for @home_yourDesignsTitle.
  ///
  /// In en, this message translates to:
  /// **'🎨 Your Designs'**
  String get home_yourDesignsTitle;

  /// No description provided for @home_yourDesignsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Continue where you left off'**
  String get home_yourDesignsSubtitle;

  /// No description provided for @home_inspirationTitle.
  ///
  /// In en, this message translates to:
  /// **'💡 Get Inspired'**
  String get home_inspirationTitle;

  /// No description provided for @home_createWithAI.
  ///
  /// In en, this message translates to:
  /// **'Create with AI'**
  String get home_createWithAI;

  /// No description provided for @home_createWithAISubtitle.
  ///
  /// In en, this message translates to:
  /// **'Type text, get 3D'**
  String get home_createWithAISubtitle;

  /// No description provided for @home_templates.
  ///
  /// In en, this message translates to:
  /// **'Templates'**
  String get home_templates;

  /// No description provided for @home_templatesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ready-made models'**
  String get home_templatesSubtitle;

  /// No description provided for @home_premiumLabel.
  ///
  /// In en, this message translates to:
  /// **'✨ PREMIUM'**
  String get home_premiumLabel;

  /// No description provided for @home_premiumTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlimited AI Generation'**
  String get home_premiumTitle;

  /// No description provided for @home_premiumSubtitle.
  ///
  /// In en, this message translates to:
  /// **'500+ credits and premium features every month'**
  String get home_premiumSubtitle;

  /// No description provided for @home_keyboardShortcut.
  ///
  /// In en, this message translates to:
  /// **'K'**
  String get home_keyboardShortcut;

  /// No description provided for @inspiration_animeCharacter.
  ///
  /// In en, this message translates to:
  /// **'Anime Character'**
  String get inspiration_animeCharacter;

  /// No description provided for @inspiration_cyberpunkRobot.
  ///
  /// In en, this message translates to:
  /// **'Cyberpunk Robot'**
  String get inspiration_cyberpunkRobot;

  /// No description provided for @inspiration_galaxyWings.
  ///
  /// In en, this message translates to:
  /// **'Galaxy Wings'**
  String get inspiration_galaxyWings;

  /// No description provided for @inspiration_fireEffect.
  ///
  /// In en, this message translates to:
  /// **'Fire Effect'**
  String get inspiration_fireEffect;

  /// No description provided for @inspiration_iceCrystal.
  ///
  /// In en, this message translates to:
  /// **'Ice Crystal'**
  String get inspiration_iceCrystal;

  /// No description provided for @auth_login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get auth_login;

  /// No description provided for @auth_register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get auth_register;

  /// No description provided for @auth_loginTab.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get auth_loginTab;

  /// No description provided for @auth_registerTab.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get auth_registerTab;

  /// No description provided for @auth_email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get auth_email;

  /// No description provided for @auth_emailHint.
  ///
  /// In en, this message translates to:
  /// **'example@email.com'**
  String get auth_emailHint;

  /// No description provided for @auth_emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get auth_emailRequired;

  /// No description provided for @auth_emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get auth_emailInvalid;

  /// No description provided for @auth_password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get auth_password;

  /// No description provided for @auth_passwordHint.
  ///
  /// In en, this message translates to:
  /// **'••••••••'**
  String get auth_passwordHint;

  /// No description provided for @auth_passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get auth_passwordRequired;

  /// No description provided for @auth_passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get auth_passwordMinLength;

  /// No description provided for @auth_forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get auth_forgotPassword;

  /// No description provided for @auth_forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get auth_forgotPasswordTitle;

  /// No description provided for @auth_forgotPasswordDescription.
  ///
  /// In en, this message translates to:
  /// **'We\'ll send a password reset link to your email.'**
  String get auth_forgotPasswordDescription;

  /// No description provided for @auth_send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get auth_send;

  /// No description provided for @auth_resetLinkSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset link sent.'**
  String get auth_resetLinkSent;

  /// No description provided for @auth_name.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get auth_name;

  /// No description provided for @auth_nameHint.
  ///
  /// In en, this message translates to:
  /// **'John Doe'**
  String get auth_nameHint;

  /// No description provided for @auth_nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Full name is required'**
  String get auth_nameRequired;

  /// No description provided for @auth_confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get auth_confirmPassword;

  /// No description provided for @auth_confirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your password'**
  String get auth_confirmPasswordHint;

  /// No description provided for @auth_confirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password confirmation is required'**
  String get auth_confirmPasswordRequired;

  /// No description provided for @auth_passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get auth_passwordsDoNotMatch;

  /// No description provided for @auth_or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get auth_or;

  /// No description provided for @auth_continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get auth_continueWithGoogle;

  /// No description provided for @auth_continueWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get auth_continueWithApple;

  /// Terms agreement text with links
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to our {terms} and {privacy}.'**
  String auth_termsAgreement(String terms, String privacy);

  /// No description provided for @auth_termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get auth_termsOfService;

  /// No description provided for @auth_privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get auth_privacyPolicy;

  /// No description provided for @auth_registerSuccess.
  ///
  /// In en, this message translates to:
  /// **'Registration successful! Please check your email.'**
  String get auth_registerSuccess;

  /// No description provided for @auth_errorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password.'**
  String get auth_errorInvalidCredentials;

  /// No description provided for @auth_errorEmailNotConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your email.'**
  String get auth_errorEmailNotConfirmed;

  /// No description provided for @auth_errorUserAlreadyRegistered.
  ///
  /// In en, this message translates to:
  /// **'This email is already registered.'**
  String get auth_errorUserAlreadyRegistered;

  /// No description provided for @auth_errorPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password should be at least 6 characters.'**
  String get auth_errorPasswordTooShort;

  /// No description provided for @auth_errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please try again.'**
  String get auth_errorGeneric;

  /// No description provided for @auth_errorGoogle.
  ///
  /// In en, this message translates to:
  /// **'Could not sign in with Google.'**
  String get auth_errorGoogle;

  /// No description provided for @auth_errorApple.
  ///
  /// In en, this message translates to:
  /// **'Could not sign in with Apple.'**
  String get auth_errorApple;

  /// No description provided for @discover_title.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get discover_title;

  /// No description provided for @discover_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Get inspired by the community'**
  String get discover_subtitle;

  /// No description provided for @discover_categoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get discover_categoryAll;

  /// No description provided for @discover_categoryPopular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get discover_categoryPopular;

  /// No description provided for @discover_categoryNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get discover_categoryNew;

  /// No description provided for @discover_categoryAccessory.
  ///
  /// In en, this message translates to:
  /// **'Accessory'**
  String get discover_categoryAccessory;

  /// No description provided for @discover_categoryClothing.
  ///
  /// In en, this message translates to:
  /// **'Clothing'**
  String get discover_categoryClothing;

  /// No description provided for @discover_categoryHair.
  ///
  /// In en, this message translates to:
  /// **'Hair'**
  String get discover_categoryHair;

  /// No description provided for @discover_categoryHat.
  ///
  /// In en, this message translates to:
  /// **'Hat'**
  String get discover_categoryHat;

  /// No description provided for @discover_categoryWeapon.
  ///
  /// In en, this message translates to:
  /// **'Weapon'**
  String get discover_categoryWeapon;

  /// No description provided for @discover_gallery.
  ///
  /// In en, this message translates to:
  /// **'🎨 Gallery'**
  String get discover_gallery;

  /// No description provided for @discover_sortPopular.
  ///
  /// In en, this message translates to:
  /// **'Most Popular'**
  String get discover_sortPopular;

  /// No description provided for @discover_sortNewest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get discover_sortNewest;

  /// No description provided for @discover_noTrending.
  ///
  /// In en, this message translates to:
  /// **'No trending designs yet'**
  String get discover_noTrending;

  /// No description provided for @discover_filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get discover_filter;

  /// No description provided for @discover_filterTitle.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get discover_filterTitle;

  /// No description provided for @discover_sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get discover_sort;

  /// No description provided for @discover_sortTitle.
  ///
  /// In en, this message translates to:
  /// **'Sort By'**
  String get discover_sortTitle;

  /// No description provided for @discover_reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get discover_reset;

  /// No description provided for @discover_apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get discover_apply;

  /// No description provided for @discover_trend.
  ///
  /// In en, this message translates to:
  /// **'Trend'**
  String get discover_trend;

  /// No description provided for @discover_aiBadge.
  ///
  /// In en, this message translates to:
  /// **'AI'**
  String get discover_aiBadge;

  /// No description provided for @profile_title.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile_title;

  /// No description provided for @profile_editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get profile_editProfile;

  /// No description provided for @profile_editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get profile_editProfileTitle;

  /// No description provided for @profile_displayNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get profile_displayNameLabel;

  /// No description provided for @profile_displayNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get profile_displayNameHint;

  /// No description provided for @profile_displayNameEmpty.
  ///
  /// In en, this message translates to:
  /// **'Display name cannot be empty'**
  String get profile_displayNameEmpty;

  /// No description provided for @profile_credits.
  ///
  /// In en, this message translates to:
  /// **'My Credits'**
  String get profile_credits;

  /// No description provided for @profile_credit.
  ///
  /// In en, this message translates to:
  /// **'credit'**
  String get profile_credit;

  /// No description provided for @profile_buyCredits.
  ///
  /// In en, this message translates to:
  /// **'Buy Credits'**
  String get profile_buyCredits;

  /// No description provided for @profile_buyCreditsTitle.
  ///
  /// In en, this message translates to:
  /// **'💎 Buy Credits'**
  String get profile_buyCreditsTitle;

  /// No description provided for @profile_saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get profile_saving;

  /// No description provided for @profile_updateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get profile_updateSuccess;

  /// No description provided for @profile_updateError.
  ///
  /// In en, this message translates to:
  /// **'Could not update profile'**
  String get profile_updateError;

  /// No description provided for @profile_robloxAccount.
  ///
  /// In en, this message translates to:
  /// **'Roblox Account'**
  String get profile_robloxAccount;

  /// No description provided for @profile_robloxConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get profile_robloxConnected;

  /// No description provided for @profile_robloxNotConnected.
  ///
  /// In en, this message translates to:
  /// **'Not connected'**
  String get profile_robloxNotConnected;

  /// No description provided for @profile_robloxConnect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get profile_robloxConnect;

  /// No description provided for @profile_robloxDisconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get profile_robloxDisconnect;

  /// No description provided for @profile_robloxConnectError.
  ///
  /// In en, this message translates to:
  /// **'Could not open connection'**
  String get profile_robloxConnectError;

  /// No description provided for @profile_robloxOAuthError.
  ///
  /// In en, this message translates to:
  /// **'Could not start OAuth'**
  String get profile_robloxOAuthError;

  /// No description provided for @profile_robloxConnectSuccess.
  ///
  /// In en, this message translates to:
  /// **'Roblox connection successful! 🎉'**
  String get profile_robloxConnectSuccess;

  /// No description provided for @profile_premium.
  ///
  /// In en, this message translates to:
  /// **'Go Premium'**
  String get profile_premium;

  /// No description provided for @profile_premiumTitle.
  ///
  /// In en, this message translates to:
  /// **'👑 PREMIUM'**
  String get profile_premiumTitle;

  /// No description provided for @profile_premiumSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unlimited access and premium features'**
  String get profile_premiumSubtitle;

  /// No description provided for @profile_settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profile_settings;

  /// No description provided for @profile_darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get profile_darkMode;

  /// No description provided for @profile_notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get profile_notifications;

  /// No description provided for @profile_language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profile_language;

  /// No description provided for @profile_languageValue.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get profile_languageValue;

  /// No description provided for @profile_transactionHistory.
  ///
  /// In en, this message translates to:
  /// **'Transaction History'**
  String get profile_transactionHistory;

  /// No description provided for @profile_helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get profile_helpSupport;

  /// No description provided for @profile_about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get profile_about;

  /// App version number
  ///
  /// In en, this message translates to:
  /// **'v{version}'**
  String profile_version(String version);

  /// No description provided for @profile_logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get profile_logout;

  /// No description provided for @profile_logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get profile_logoutConfirm;

  /// No description provided for @profile_creditPackagePopular.
  ///
  /// In en, this message translates to:
  /// **'⭐ Most Popular'**
  String get profile_creditPackagePopular;

  /// Bonus credits amount
  ///
  /// In en, this message translates to:
  /// **'+{bonus} bonus'**
  String profile_creditPackageBonus(int bonus);

  /// No description provided for @settings_title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_title;

  /// No description provided for @settings_appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settings_appearance;

  /// No description provided for @settings_darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get settings_darkMode;

  /// No description provided for @settings_darkModeDescription.
  ///
  /// In en, this message translates to:
  /// **'Change app theme'**
  String get settings_darkModeDescription;

  /// No description provided for @settings_notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settings_notifications;

  /// No description provided for @settings_pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get settings_pushNotifications;

  /// No description provided for @settings_pushNotificationsDescription.
  ///
  /// In en, this message translates to:
  /// **'Get notified when jobs complete'**
  String get settings_pushNotificationsDescription;

  /// No description provided for @settings_emailNotifications.
  ///
  /// In en, this message translates to:
  /// **'Email Notifications'**
  String get settings_emailNotifications;

  /// No description provided for @settings_emailNotificationsDescription.
  ///
  /// In en, this message translates to:
  /// **'Receive emails for important updates'**
  String get settings_emailNotificationsDescription;

  /// No description provided for @settings_aiSettings.
  ///
  /// In en, this message translates to:
  /// **'AI Settings'**
  String get settings_aiSettings;

  /// No description provided for @settings_defaultProvider.
  ///
  /// In en, this message translates to:
  /// **'Default AI Provider'**
  String get settings_defaultProvider;

  /// No description provided for @settings_providerMeshy.
  ///
  /// In en, this message translates to:
  /// **'Meshy'**
  String get settings_providerMeshy;

  /// No description provided for @settings_providerMeshyDescription.
  ///
  /// In en, this message translates to:
  /// **'Fast and high quality'**
  String get settings_providerMeshyDescription;

  /// No description provided for @settings_providerTripo.
  ///
  /// In en, this message translates to:
  /// **'Tripo'**
  String get settings_providerTripo;

  /// No description provided for @settings_providerTripoDescription.
  ///
  /// In en, this message translates to:
  /// **'Detailed models'**
  String get settings_providerTripoDescription;

  /// No description provided for @settings_selectProvider.
  ///
  /// In en, this message translates to:
  /// **'Select AI Provider'**
  String get settings_selectProvider;

  /// No description provided for @settings_defaultQuality.
  ///
  /// In en, this message translates to:
  /// **'Default Quality'**
  String get settings_defaultQuality;

  /// No description provided for @settings_qualityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get settings_qualityHigh;

  /// No description provided for @settings_qualityHighDescription.
  ///
  /// In en, this message translates to:
  /// **'Best quality'**
  String get settings_qualityHighDescription;

  /// No description provided for @settings_qualityMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get settings_qualityMedium;

  /// No description provided for @settings_qualityMediumDescription.
  ///
  /// In en, this message translates to:
  /// **'Balanced performance'**
  String get settings_qualityMediumDescription;

  /// No description provided for @settings_qualityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get settings_qualityLow;

  /// No description provided for @settings_qualityLowDescription.
  ///
  /// In en, this message translates to:
  /// **'Faster, less credits'**
  String get settings_qualityLowDescription;

  /// No description provided for @settings_selectQuality.
  ///
  /// In en, this message translates to:
  /// **'Select Quality'**
  String get settings_selectQuality;

  /// No description provided for @settings_storage.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get settings_storage;

  /// No description provided for @settings_clearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear Cache'**
  String get settings_clearCache;

  /// Cache size in MB
  ///
  /// In en, this message translates to:
  /// **'{size} MB used'**
  String settings_cacheSize(int size);

  /// No description provided for @settings_clearCacheTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear Cache'**
  String get settings_clearCacheTitle;

  /// Cache clear confirmation message
  ///
  /// In en, this message translates to:
  /// **'{size} MB cache will be cleared. This cannot be undone.'**
  String settings_clearCacheDescription(int size);

  /// No description provided for @settings_clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get settings_clear;

  /// No description provided for @settings_cacheCleared.
  ///
  /// In en, this message translates to:
  /// **'Cache cleared'**
  String get settings_cacheCleared;

  /// No description provided for @settings_downloadedFiles.
  ///
  /// In en, this message translates to:
  /// **'Downloaded Files'**
  String get settings_downloadedFiles;

  /// Number of downloaded files
  ///
  /// In en, this message translates to:
  /// **'{count} files'**
  String settings_downloadedFilesCount(int count);

  /// No description provided for @settings_about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settings_about;

  /// No description provided for @settings_appVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get settings_appVersion;

  /// Build number
  ///
  /// In en, this message translates to:
  /// **'Build {number}'**
  String settings_buildNumber(String number);

  /// No description provided for @settings_termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get settings_termsOfService;

  /// No description provided for @settings_privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settings_privacyPolicy;

  /// No description provided for @settings_helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get settings_helpSupport;

  /// No description provided for @create_title.
  ///
  /// In en, this message translates to:
  /// **'Create with AI'**
  String get create_title;

  /// No description provided for @create_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Write your dream 3D model'**
  String get create_subtitle;

  /// No description provided for @create_aiPowered.
  ///
  /// In en, this message translates to:
  /// **'AI Powered'**
  String get create_aiPowered;

  /// No description provided for @create_promptLabel.
  ///
  /// In en, this message translates to:
  /// **'What do you want to create? ✨'**
  String get create_promptLabel;

  /// No description provided for @create_promptHint.
  ///
  /// In en, this message translates to:
  /// **'E.g., \"Cyberpunk style samurai helmet with neon blue details, shiny metallic surface\"'**
  String get create_promptHint;

  /// No description provided for @create_promptTip.
  ///
  /// In en, this message translates to:
  /// **'Write detailed for better results'**
  String get create_promptTip;

  /// Character count for prompt
  ///
  /// In en, this message translates to:
  /// **'{current}/{max}'**
  String create_characterCount(int current, int max);

  /// No description provided for @create_inspiration.
  ///
  /// In en, this message translates to:
  /// **'Get inspired'**
  String get create_inspiration;

  /// No description provided for @create_provider.
  ///
  /// In en, this message translates to:
  /// **'AI Provider'**
  String get create_provider;

  /// No description provided for @create_providerMeshy.
  ///
  /// In en, this message translates to:
  /// **'Meshy'**
  String get create_providerMeshy;

  /// No description provided for @create_providerMeshyDesc.
  ///
  /// In en, this message translates to:
  /// **'High quality & detail'**
  String get create_providerMeshyDesc;

  /// No description provided for @create_providerMeshyTime.
  ///
  /// In en, this message translates to:
  /// **'~2-3 min'**
  String get create_providerMeshyTime;

  /// No description provided for @create_providerTripo.
  ///
  /// In en, this message translates to:
  /// **'Tripo'**
  String get create_providerTripo;

  /// No description provided for @create_providerTripoDesc.
  ///
  /// In en, this message translates to:
  /// **'Ultra fast generation'**
  String get create_providerTripoDesc;

  /// No description provided for @create_providerTripoTime.
  ///
  /// In en, this message translates to:
  /// **'~30 sec'**
  String get create_providerTripoTime;

  /// No description provided for @create_category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get create_category;

  /// No description provided for @create_categoryAccessory.
  ///
  /// In en, this message translates to:
  /// **'Accessory'**
  String get create_categoryAccessory;

  /// No description provided for @create_categoryHat.
  ///
  /// In en, this message translates to:
  /// **'Hat'**
  String get create_categoryHat;

  /// No description provided for @create_categoryHair.
  ///
  /// In en, this message translates to:
  /// **'Hair'**
  String get create_categoryHair;

  /// No description provided for @create_categoryClothing.
  ///
  /// In en, this message translates to:
  /// **'Clothing'**
  String get create_categoryClothing;

  /// No description provided for @create_categoryBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get create_categoryBack;

  /// No description provided for @create_categoryFace.
  ///
  /// In en, this message translates to:
  /// **'Face'**
  String get create_categoryFace;

  /// No description provided for @create_categoryWeapon.
  ///
  /// In en, this message translates to:
  /// **'Weapon'**
  String get create_categoryWeapon;

  /// No description provided for @create_style.
  ///
  /// In en, this message translates to:
  /// **'Style'**
  String get create_style;

  /// No description provided for @create_styleRealistic.
  ///
  /// In en, this message translates to:
  /// **'Realistic'**
  String get create_styleRealistic;

  /// No description provided for @create_styleAnime.
  ///
  /// In en, this message translates to:
  /// **'Anime'**
  String get create_styleAnime;

  /// No description provided for @create_styleCartoon.
  ///
  /// In en, this message translates to:
  /// **'Cartoon'**
  String get create_styleCartoon;

  /// No description provided for @create_styleVoxel.
  ///
  /// In en, this message translates to:
  /// **'Voxel'**
  String get create_styleVoxel;

  /// No description provided for @create_advancedOptions.
  ///
  /// In en, this message translates to:
  /// **'Advanced Options'**
  String get create_advancedOptions;

  /// No description provided for @create_hideAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Hide Advanced Options'**
  String get create_hideAdvanced;

  /// No description provided for @create_estimatedCost.
  ///
  /// In en, this message translates to:
  /// **'Estimated Cost'**
  String get create_estimatedCost;

  /// Credits that will be used
  ///
  /// In en, this message translates to:
  /// **'{cost} credits will be used'**
  String create_creditsWillBeUsed(int cost);

  /// No description provided for @create_button.
  ///
  /// In en, this message translates to:
  /// **'Create with AI'**
  String get create_button;

  /// No description provided for @create_buttonGenerating.
  ///
  /// In en, this message translates to:
  /// **'Generating...'**
  String get create_buttonGenerating;

  /// No description provided for @create_errorStart.
  ///
  /// In en, this message translates to:
  /// **'Could not start process'**
  String get create_errorStart;

  /// No description provided for @create_successStart.
  ///
  /// In en, this message translates to:
  /// **'AI generation started! ✨'**
  String get create_successStart;

  /// No description provided for @create_suggestion1.
  ///
  /// In en, this message translates to:
  /// **'Cyberpunk robot helmet, neon blue lights'**
  String get create_suggestion1;

  /// No description provided for @create_suggestion2.
  ///
  /// In en, this message translates to:
  /// **'Fire wings, realistic flame effect'**
  String get create_suggestion2;

  /// No description provided for @create_suggestion3.
  ///
  /// In en, this message translates to:
  /// **'Anime style crystal crown, glowing'**
  String get create_suggestion3;

  /// No description provided for @create_suggestion4.
  ///
  /// In en, this message translates to:
  /// **'Dragon armor, golden details'**
  String get create_suggestion4;

  /// No description provided for @create_suggestion5.
  ///
  /// In en, this message translates to:
  /// **'Moonlight cloak, mystical glow'**
  String get create_suggestion5;

  /// No description provided for @create_suggestion6.
  ///
  /// In en, this message translates to:
  /// **'Samurai sword, katana, shiny steel'**
  String get create_suggestion6;

  /// No description provided for @search_title.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search_title;

  /// No description provided for @search_hint.
  ///
  /// In en, this message translates to:
  /// **'Search templates, designs, or users...'**
  String get search_hint;

  /// No description provided for @search_filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get search_filterAll;

  /// No description provided for @search_filterTemplates.
  ///
  /// In en, this message translates to:
  /// **'Templates'**
  String get search_filterTemplates;

  /// No description provided for @search_filterDesigns.
  ///
  /// In en, this message translates to:
  /// **'Designs'**
  String get search_filterDesigns;

  /// No description provided for @search_filterUsers.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get search_filterUsers;

  /// No description provided for @search_trending.
  ///
  /// In en, this message translates to:
  /// **'Trending Searches'**
  String get search_trending;

  /// No description provided for @search_recent.
  ///
  /// In en, this message translates to:
  /// **'Recent Searches'**
  String get search_recent;

  /// No description provided for @search_clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get search_clear;

  /// No description provided for @search_quickAccess.
  ///
  /// In en, this message translates to:
  /// **'Quick Access'**
  String get search_quickAccess;

  /// No description provided for @search_error.
  ///
  /// In en, this message translates to:
  /// **'Search failed'**
  String get search_error;

  /// No description provided for @trending_cyberpunk.
  ///
  /// In en, this message translates to:
  /// **'Cyberpunk'**
  String get trending_cyberpunk;

  /// No description provided for @trending_animeStyle.
  ///
  /// In en, this message translates to:
  /// **'Anime style'**
  String get trending_animeStyle;

  /// No description provided for @trending_wings.
  ///
  /// In en, this message translates to:
  /// **'Wings'**
  String get trending_wings;

  /// No description provided for @trending_neon.
  ///
  /// In en, this message translates to:
  /// **'Neon'**
  String get trending_neon;

  /// No description provided for @trending_halloween.
  ///
  /// In en, this message translates to:
  /// **'Halloween'**
  String get trending_halloween;

  /// No description provided for @trending_galaxy.
  ///
  /// In en, this message translates to:
  /// **'Galaxy'**
  String get trending_galaxy;

  /// Trending count in thousands
  ///
  /// In en, this message translates to:
  /// **'{count}K'**
  String trending_count(String count);

  /// No description provided for @status_completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get status_completed;

  /// No description provided for @status_processing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get status_processing;

  /// No description provided for @status_draft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get status_draft;

  /// No description provided for @status_queued.
  ///
  /// In en, this message translates to:
  /// **'Queued'**
  String get status_queued;

  /// No description provided for @status_inProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get status_inProgress;

  /// No description provided for @status_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get status_failed;

  /// No description provided for @status_published.
  ///
  /// In en, this message translates to:
  /// **'Published'**
  String get status_published;

  /// No description provided for @error_generic.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get error_generic;

  /// No description provided for @error_network.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection.'**
  String get error_network;

  /// No description provided for @error_server.
  ///
  /// In en, this message translates to:
  /// **'Server error. Please try again later.'**
  String get error_server;

  /// No description provided for @error_unauthorized.
  ///
  /// In en, this message translates to:
  /// **'Unauthorized. Please login again.'**
  String get error_unauthorized;

  /// No description provided for @error_notFound.
  ///
  /// In en, this message translates to:
  /// **'Not found'**
  String get error_notFound;

  /// No description provided for @error_unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown error occurred'**
  String get error_unknown;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
