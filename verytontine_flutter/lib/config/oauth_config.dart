library oauth_config;

/// OAuth Configuration for VeryTontine
/// 
/// This file contains Google OAuth client IDs for different environments.
/// 
/// IMPORTANT: 
/// 1. Replace the placeholder client IDs with your actual credentials from Google Cloud Console
/// 2. Get credentials from: https://console.cloud.google.com/apis/credentials
/// 3. Never commit real credentials to version control
/// 4. Add this file to .gitignore for production apps

import '../utils/auth_logger.dart';

class OAuthConfig {
  /// Determines if the app is running in production mode
  /// Set via: flutter run --dart-define=PRODUCTION=true
  static const bool isProduction = bool.fromEnvironment(
    'PRODUCTION',
    defaultValue: false,
  );

  // ============================================================================
  // DEBUG CREDENTIALS (for development)
  // ============================================================================
  
  /// Debug Android OAuth Client ID
  /// 
  /// To get this:
  /// 1. Go to Google Cloud Console → APIs & Services → Credentials
  /// 2. Create OAuth client ID → Android
  /// 3. Package name: com.verytontine.verytontine_flutter
  /// 4. SHA-1: Get from debug keystore using:
  ///    keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
  /// Current SHA-1: 64:7C:92:7C:F0:42:90:7B:38:4C:F0:CD:E5:7F:D5:E3:BF:B8:C0:9C
  static const String debugAndroidClientId = 
      '427498483720-tdul9p1mvk4ilsaars981m4r553vjivn.apps.googleusercontent.com';

  /// **Web application** OAuth client ID only (Credentials → Web application). Do **not** paste your
  /// Android or "Desktop/installed" client ID here — that triggers `ApiException: 10` (DEVELOPER_ERROR).
  /// Leave empty until you create a Web client; sign-in may work without it, then set this if `idToken` is null.
  static const String debugWebServerClientId = '';

  /// Debug iOS OAuth Client ID (optional, for iOS support)
  static const String debugIOSClientId = 
      'YOUR_DEBUG_IOS_CLIENT_ID.apps.googleusercontent.com';

  // ============================================================================
  // PRODUCTION CREDENTIALS (for release builds)
  // ============================================================================
  
  /// Production Android OAuth Client ID
  /// 
  /// To get this:
  /// 1. Generate release keystore (if not exists)
  /// 2. Get SHA-1 from release keystore: 66:C0:10:43:81:24:DA:D7:28:FE:EE:59:E8:CA:23:38:DF:D1:94:6B
  /// 3. Create separate OAuth client ID in Google Cloud Console
  /// 4. Use release SHA-1 fingerprint
  static const String prodAndroidClientId = 
      '427498483720-tdul9p1mvk4ilsaars981m4r553vjivn.apps.googleusercontent.com';

  static const String prodWebServerClientId = '';

  /// Production iOS OAuth Client ID (optional, for iOS support)
  static const String prodIOSClientId = 
      'YOUR_PROD_IOS_CLIENT_ID.apps.googleusercontent.com';

  // ============================================================================
  // GETTERS (automatically select based on environment)
  // ============================================================================

  /// Returns the appropriate Android client ID based on environment
  static String get androidClientId {
    return isProduction ? prodAndroidClientId : debugAndroidClientId;
  }

  /// Returns the appropriate iOS client ID based on environment
  static String get iosClientId {
    return isProduction ? prodIOSClientId : debugIOSClientId;
  }

  /// Passed to [GoogleSignIn.serverClientId] so Google returns an OpenID ID token on Android.
  static String? get webServerClientId {
    final id = isProduction ? prodWebServerClientId : debugWebServerClientId;
    if (id.isEmpty || id.contains('YOUR_')) return null;
    return id;
  }

  // ============================================================================
  // VALIDATION
  // ============================================================================

  /// Validates that the OAuth configuration is properly set up
  /// 
  /// Returns true if configuration is valid, false otherwise
  static bool isConfigured() {
    final clientId = androidClientId;
    
    AuthLogger.d('Validating OAuth Config', context: {
      'clientId': clientId,
      'isEmpty': clientId.isEmpty,
      'hasValidSuffix': clientId.endsWith('.apps.googleusercontent.com'),
    });
    
    // Check if not empty and has valid format
    final isValid = clientId.isNotEmpty && 
                   clientId.endsWith('.apps.googleusercontent.com') &&
                   !clientId.contains('YOUR_') &&
                   !clientId.contains('PLACEHOLDER');
    
    AuthLogger.d('OAuth Config validation result', context: {'isValid': isValid});
    return isValid;
  }

  /// Returns a descriptive error message if configuration is invalid
  static String? getConfigurationError() {
    if (!isConfigured()) {
      return 'Google OAuth is not configured. Please update oauth_config.dart with your client ID from Google Cloud Console.';
    }
    return null;
  }

  /// Returns the current environment name
  static String get environmentName {
    return isProduction ? 'Production' : 'Debug';
  }

  // ============================================================================
  // OAUTH SCOPES
  // ============================================================================

  /// OAuth scopes required for zkLogin
  static const List<String> requiredScopes = [
    'openid',
    'email',
  ];

  // ============================================================================
  // REDIRECT URI
  // ============================================================================

  /// OAuth redirect URI for the app
  static const String redirectUri = 'com.verytontine.app:/oauth2redirect';
}
