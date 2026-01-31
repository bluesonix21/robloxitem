// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Roblox UGC Creator';

  @override
  String get appTagline => 'AI ile 3D modeller oluştur ✨';

  @override
  String get common_ok => 'Tamam';

  @override
  String get common_cancel => 'İptal';

  @override
  String get common_save => 'Kaydet';

  @override
  String get common_edit => 'Düzenle';

  @override
  String get common_delete => 'Sil';

  @override
  String get common_done => 'Bitti';

  @override
  String get common_loading => 'Yükleniyor...';

  @override
  String get common_error => 'Hata';

  @override
  String get common_success => 'Başarılı';

  @override
  String get common_retry => 'Tekrar Dene';

  @override
  String get common_close => 'Kapat';

  @override
  String get common_back => 'Geri';

  @override
  String get common_next => 'İleri';

  @override
  String get common_skip => 'Atla';

  @override
  String get common_continue => 'Devam Et';

  @override
  String get common_yes => 'Evet';

  @override
  String get common_no => 'Hayır';

  @override
  String get common_all => 'Tümü';

  @override
  String get common_apply => 'Uygula';

  @override
  String get common_reset => 'Sıfırla';

  @override
  String get common_search => 'Ara';

  @override
  String get common_filter => 'Filtrele';

  @override
  String get common_sort => 'Sırala';

  @override
  String get common_seeAll => 'Tümünü Gör';

  @override
  String get common_showMore => 'Daha Fazla';

  @override
  String get common_showLess => 'Daha Az';

  @override
  String get common_credits => 'kredi';

  @override
  String get common_credit => 'kredi';

  @override
  String common_creditCount(int count) {
    return '$count kredi';
  }

  @override
  String get home_greeting => 'Merhaba! 👋';

  @override
  String get home_title => 'Roblox UGC Creator';

  @override
  String get home_heroTitle => 'Bugün ne yaratacaksın?';

  @override
  String get home_searchHint => 'Şablon, tasarım veya ilham ara...';

  @override
  String get home_aiGeneratedTitle => '✨ AI ile Oluşturulanlar';

  @override
  String get home_aiGeneratedSubtitle =>
      'Topluluk tarafından yaratılan muhteşem tasarımlar';

  @override
  String get home_trendingTitle => '🔥 Trend Tasarımlar';

  @override
  String get home_trendingSubtitle => 'Bu hafta en popüler olanlar';

  @override
  String get home_yourDesignsTitle => '🎨 Senin Tasarımların';

  @override
  String get home_yourDesignsSubtitle => 'Kaldığın yerden devam et';

  @override
  String get home_inspirationTitle => '💡 İlham Al';

  @override
  String get home_createWithAI => 'AI ile Oluştur';

  @override
  String get home_createWithAISubtitle => 'Metin yaz, 3D al';

  @override
  String get home_templates => 'Şablonlar';

  @override
  String get home_templatesSubtitle => 'Hazır modeller';

  @override
  String get home_premiumLabel => '✨ PREMIUM';

  @override
  String get home_premiumTitle => 'Sınırsız AI Üretim';

  @override
  String get home_premiumSubtitle => 'Her ay 500+ kredi ve özel özellikler';

  @override
  String get home_keyboardShortcut => 'K';

  @override
  String get inspiration_animeCharacter => 'Anime Karakteri';

  @override
  String get inspiration_cyberpunkRobot => 'Cyberpunk Robot';

  @override
  String get inspiration_galaxyWings => 'Galaxy Kanatları';

  @override
  String get inspiration_fireEffect => 'Alev Efekti';

  @override
  String get inspiration_iceCrystal => 'Buz Kristali';

  @override
  String get auth_login => 'Giriş Yap';

  @override
  String get auth_register => 'Kayıt Ol';

  @override
  String get auth_loginTab => 'Giriş Yap';

  @override
  String get auth_registerTab => 'Kayıt Ol';

  @override
  String get auth_email => 'E-posta';

  @override
  String get auth_emailHint => 'ornek@email.com';

  @override
  String get auth_emailRequired => 'E-posta gerekli';

  @override
  String get auth_emailInvalid => 'Geçerli bir e-posta girin';

  @override
  String get auth_password => 'Şifre';

  @override
  String get auth_passwordHint => '••••••••';

  @override
  String get auth_passwordRequired => 'Şifre gerekli';

  @override
  String get auth_passwordMinLength => 'Şifre en az 6 karakter olmalı';

  @override
  String get auth_forgotPassword => 'Şifremi Unuttum';

  @override
  String get auth_forgotPasswordTitle => 'Şifremi Unuttum';

  @override
  String get auth_forgotPasswordDescription =>
      'E-posta adresinize şifre sıfırlama bağlantısı göndereceğiz.';

  @override
  String get auth_send => 'Gönder';

  @override
  String get auth_resetLinkSent => 'Şifre sıfırlama bağlantısı gönderildi.';

  @override
  String get auth_name => 'Ad Soyad';

  @override
  String get auth_nameHint => 'John Doe';

  @override
  String get auth_nameRequired => 'Ad soyad gerekli';

  @override
  String get auth_confirmPassword => 'Şifre Tekrar';

  @override
  String get auth_confirmPasswordHint => 'Şifrenizi tekrar girin';

  @override
  String get auth_confirmPasswordRequired => 'Şifre tekrarı gerekli';

  @override
  String get auth_passwordsDoNotMatch => 'Şifreler eşleşmiyor';

  @override
  String get auth_or => 'veya';

  @override
  String get auth_continueWithGoogle => 'Google ile devam et';

  @override
  String get auth_continueWithApple => 'Apple ile devam et';

  @override
  String auth_termsAgreement(String terms, String privacy) {
    return 'Devam ederek, $terms ve $privacy\'nı kabul etmiş olursunuz.';
  }

  @override
  String get auth_termsOfService => 'Kullanım Koşulları';

  @override
  String get auth_privacyPolicy => 'Gizlilik Politikası';

  @override
  String get auth_registerSuccess =>
      'Kayıt başarılı! E-postanızı kontrol edin.';

  @override
  String get auth_errorInvalidCredentials => 'E-posta veya şifre hatalı.';

  @override
  String get auth_errorEmailNotConfirmed => 'Lütfen e-postanızı onaylayın.';

  @override
  String get auth_errorUserAlreadyRegistered => 'Bu e-posta zaten kayıtlı.';

  @override
  String get auth_errorPasswordTooShort => 'Şifre en az 6 karakter olmalı.';

  @override
  String get auth_errorGeneric => 'Bir hata oluştu. Lütfen tekrar deneyin.';

  @override
  String get auth_errorGoogle => 'Google ile giriş yapılamadı.';

  @override
  String get auth_errorApple => 'Apple ile giriş yapılamadı.';

  @override
  String get discover_title => 'Keşfet';

  @override
  String get discover_subtitle => 'Topluluktan ilham al';

  @override
  String get discover_categoryAll => 'Tümü';

  @override
  String get discover_categoryPopular => 'Popüler';

  @override
  String get discover_categoryNew => 'Yeni';

  @override
  String get discover_categoryAccessory => 'Aksesuar';

  @override
  String get discover_categoryClothing => 'Giyim';

  @override
  String get discover_categoryHair => 'Saç';

  @override
  String get discover_categoryHat => 'Şapka';

  @override
  String get discover_categoryWeapon => 'Silah';

  @override
  String get discover_gallery => '🎨 Galeri';

  @override
  String get discover_sortPopular => 'En Popüler';

  @override
  String get discover_sortNewest => 'En Yeni';

  @override
  String get discover_noTrending => 'Henüz trend tasarım yok';

  @override
  String get discover_filter => 'Filtrele';

  @override
  String get discover_filterTitle => 'Filtrele';

  @override
  String get discover_sort => 'Sırala';

  @override
  String get discover_sortTitle => 'Sıralama';

  @override
  String get discover_reset => 'Sıfırla';

  @override
  String get discover_apply => 'Uygula';

  @override
  String get discover_trend => 'Trend';

  @override
  String get discover_aiBadge => 'AI';

  @override
  String get profile_title => 'Profil';

  @override
  String get profile_editProfile => 'Profili Düzenle';

  @override
  String get profile_editProfileTitle => 'Profili Düzenle';

  @override
  String get profile_displayNameLabel => 'Görünen ad';

  @override
  String get profile_displayNameHint => 'Adını gir';

  @override
  String get profile_displayNameEmpty => 'Görünen ad boş olamaz';

  @override
  String get profile_credits => 'Kredilerim';

  @override
  String get profile_credit => 'kredi';

  @override
  String get profile_buyCredits => 'Kredi Satın Al';

  @override
  String get profile_buyCreditsTitle => '💎 Kredi Satın Al';

  @override
  String get profile_saving => 'Kaydediliyor...';

  @override
  String get profile_updateSuccess => 'Profil güncellendi';

  @override
  String get profile_updateError => 'Profil güncellenemedi';

  @override
  String get profile_robloxAccount => 'Roblox Hesabı';

  @override
  String get profile_robloxConnected => 'Bağlı';

  @override
  String get profile_robloxNotConnected => 'Bağlı değil';

  @override
  String get profile_robloxConnect => 'Bağla';

  @override
  String get profile_robloxDisconnect => 'Bağlantıyı Kes';

  @override
  String get profile_robloxConnectError => 'Bağlantı açılamadı';

  @override
  String get profile_robloxOAuthError => 'OAuth başlatılamadı';

  @override
  String get profile_robloxConnectSuccess => 'Roblox bağlantısı başarılı! 🎉';

  @override
  String get profile_premium => 'Premium\'a Geç';

  @override
  String get profile_premiumTitle => '👑 PREMIUM';

  @override
  String get profile_premiumSubtitle => 'Sınırsız erişim ve özel özellikler';

  @override
  String get profile_settings => 'Ayarlar';

  @override
  String get profile_darkMode => 'Karanlık Mod';

  @override
  String get profile_notifications => 'Bildirimler';

  @override
  String get profile_language => 'Dil';

  @override
  String get profile_languageValue => 'Türkçe';

  @override
  String get profile_transactionHistory => 'İşlem Geçmişi';

  @override
  String get profile_helpSupport => 'Yardım & Destek';

  @override
  String get profile_about => 'Hakkında';

  @override
  String profile_version(String version) {
    return 'v$version';
  }

  @override
  String get profile_logout => 'Çıkış Yap';

  @override
  String get profile_logoutConfirm =>
      'Çıkış yapmak istediğinizden emin misiniz?';

  @override
  String get profile_creditPackagePopular => '⭐ En popüler';

  @override
  String profile_creditPackageBonus(int bonus) {
    return '+$bonus bonus';
  }

  @override
  String get settings_title => 'Ayarlar';

  @override
  String get settings_appearance => 'Görünüm';

  @override
  String get settings_darkMode => 'Karanlık Mod';

  @override
  String get settings_darkModeDescription => 'Uygulama temasını değiştir';

  @override
  String get settings_notifications => 'Bildirimler';

  @override
  String get settings_pushNotifications => 'Push Bildirimleri';

  @override
  String get settings_pushNotificationsDescription =>
      'İş tamamlandığında bildirim al';

  @override
  String get settings_emailNotifications => 'E-posta Bildirimleri';

  @override
  String get settings_emailNotificationsDescription =>
      'Önemli güncellemeler için e-posta al';

  @override
  String get settings_aiSettings => 'AI Ayarları';

  @override
  String get settings_defaultProvider => 'Varsayılan AI Sağlayıcı';

  @override
  String get settings_providerMeshy => 'Meshy';

  @override
  String get settings_providerMeshyDescription => 'Hızlı ve kaliteli';

  @override
  String get settings_providerTripo => 'Tripo';

  @override
  String get settings_providerTripoDescription => 'Detaylı modeller';

  @override
  String get settings_selectProvider => 'AI Sağlayıcı Seçin';

  @override
  String get settings_defaultQuality => 'Varsayılan Kalite';

  @override
  String get settings_qualityHigh => 'Yüksek';

  @override
  String get settings_qualityHighDescription => 'En iyi kalite';

  @override
  String get settings_qualityMedium => 'Orta';

  @override
  String get settings_qualityMediumDescription => 'Dengeli performans';

  @override
  String get settings_qualityLow => 'Düşük';

  @override
  String get settings_qualityLowDescription => 'Daha hızlı, daha az kredi';

  @override
  String get settings_selectQuality => 'Kalite Seçin';

  @override
  String get settings_storage => 'Depolama';

  @override
  String get settings_clearCache => 'Önbelleği Temizle';

  @override
  String settings_cacheSize(int size) {
    return '$size MB kullanılıyor';
  }

  @override
  String get settings_clearCacheTitle => 'Önbelleği Temizle';

  @override
  String settings_clearCacheDescription(int size) {
    return '$size MB önbellek temizlenecek. Bu işlem geri alınamaz.';
  }

  @override
  String get settings_clear => 'Temizle';

  @override
  String get settings_cacheCleared => 'Önbellek temizlendi';

  @override
  String get settings_downloadedFiles => 'İndirilen Dosyalar';

  @override
  String settings_downloadedFilesCount(int count) {
    return '$count dosya';
  }

  @override
  String get settings_about => 'Hakkında';

  @override
  String get settings_appVersion => 'Uygulama Sürümü';

  @override
  String settings_buildNumber(String number) {
    return 'Build $number';
  }

  @override
  String get settings_termsOfService => 'Kullanım Koşulları';

  @override
  String get settings_privacyPolicy => 'Gizlilik Politikası';

  @override
  String get settings_helpSupport => 'Yardım & Destek';

  @override
  String get create_title => 'AI ile Oluştur';

  @override
  String get create_subtitle => 'Hayalindeki 3D modeli yaz';

  @override
  String get create_aiPowered => 'Yapay Zeka Destekli';

  @override
  String get create_promptLabel => 'Ne oluşturmak istiyorsun? ✨';

  @override
  String get create_promptHint =>
      'Örn: \"Cyberpunk tarzı samurai kaskı, neon mavi detaylarla, parlak metalik yüzey\"';

  @override
  String get create_promptTip => 'Detaylı yazın, daha iyi sonuç alın';

  @override
  String create_characterCount(int current, int max) {
    return '$current/$max';
  }

  @override
  String get create_inspiration => 'İlham al';

  @override
  String get create_provider => 'AI Sağlayıcı';

  @override
  String get create_providerMeshy => 'Meshy';

  @override
  String get create_providerMeshyDesc => 'Yüksek kalite & detay';

  @override
  String get create_providerMeshyTime => '~2-3 dk';

  @override
  String get create_providerTripo => 'Tripo';

  @override
  String get create_providerTripoDesc => 'Ultra hızlı üretim';

  @override
  String get create_providerTripoTime => '~30 sn';

  @override
  String get create_category => 'Kategori';

  @override
  String get create_categoryAccessory => 'Aksesuar';

  @override
  String get create_categoryHat => 'Şapka';

  @override
  String get create_categoryHair => 'Saç';

  @override
  String get create_categoryClothing => 'Giyim';

  @override
  String get create_categoryBack => 'Sırt';

  @override
  String get create_categoryFace => 'Yüz';

  @override
  String get create_categoryWeapon => 'Silah';

  @override
  String get create_style => 'Stil';

  @override
  String get create_styleRealistic => 'Gerçekçi';

  @override
  String get create_styleAnime => 'Anime';

  @override
  String get create_styleCartoon => 'Cartoon';

  @override
  String get create_styleVoxel => 'Voxel';

  @override
  String get create_advancedOptions => 'Gelişmiş seçenekler';

  @override
  String get create_hideAdvanced => 'Gelişmiş seçenekleri gizle';

  @override
  String get create_estimatedCost => 'Tahmini maliyet';

  @override
  String create_creditsWillBeUsed(int cost) {
    return '$cost kredi kullanılacak';
  }

  @override
  String get create_button => 'AI ile Oluştur';

  @override
  String get create_buttonGenerating => 'Oluşturuluyor...';

  @override
  String get create_errorStart => 'İşlem başlatılamadı';

  @override
  String get create_successStart => 'AI üretimi başlatıldı! ✨';

  @override
  String get create_suggestion1 => 'Cyberpunk robot kaskı, neon mavi ışıklar';

  @override
  String get create_suggestion2 => 'Ateş kanatları, gerçekçi alev efekti';

  @override
  String get create_suggestion3 => 'Anime tarzı kristal taç, parıldayan';

  @override
  String get create_suggestion4 => 'Ejderha zırhı, altın detaylar';

  @override
  String get create_suggestion5 => 'Ay ışığı pelerin, mistik parıltı';

  @override
  String get create_suggestion6 => 'Samuray kılıcı, katana, parlak çelik';

  @override
  String get search_title => 'Ara';

  @override
  String get search_hint => 'Şablon, tasarım veya kullanıcı ara...';

  @override
  String get search_filterAll => 'Tümü';

  @override
  String get search_filterTemplates => 'Şablonlar';

  @override
  String get search_filterDesigns => 'Tasarımlar';

  @override
  String get search_filterUsers => 'Kullanıcılar';

  @override
  String get search_trending => 'Trend Aramalar';

  @override
  String get search_recent => 'Son Aramalar';

  @override
  String get search_clear => 'Temizle';

  @override
  String get search_quickAccess => 'Hızlı Erişim';

  @override
  String get search_error => 'Arama başarısız oldu';

  @override
  String get trending_cyberpunk => 'Cyberpunk';

  @override
  String get trending_animeStyle => 'Anime style';

  @override
  String get trending_wings => 'Kanatlar';

  @override
  String get trending_neon => 'Neon';

  @override
  String get trending_halloween => 'Halloween';

  @override
  String get trending_galaxy => 'Galaxy';

  @override
  String trending_count(String count) {
    return '${count}B';
  }

  @override
  String get status_completed => 'Tamamlandı';

  @override
  String get status_processing => 'İşleniyor';

  @override
  String get status_draft => 'Taslak';

  @override
  String get status_queued => 'Sırada';

  @override
  String get status_inProgress => 'Devam Ediyor';

  @override
  String get status_failed => 'Başarısız';

  @override
  String get status_published => 'Yayında';

  @override
  String get error_generic => 'Bir hata oluştu';

  @override
  String get error_network => 'Ağ hatası. Lütfen bağlantınızı kontrol edin.';

  @override
  String get error_server => 'Sunucu hatası. Lütfen daha sonra tekrar deneyin.';

  @override
  String get error_unauthorized =>
      'Yetkisiz erişim. Lütfen tekrar giriş yapın.';

  @override
  String get error_notFound => 'Bulunamadı';

  @override
  String get error_unknown => 'Bilinmeyen bir hata oluştu';
}
