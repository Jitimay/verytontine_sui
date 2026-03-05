/// OAuth Configuration for VeryTontine
/// 
/// This file contains Google OAuth client IDs for different environments.
/// 
/// IMPORTANT: 
/// 1. Replace the placeholder client IDs with your actual credentials from Google Cloud Console
/// 2. Get credentials from: https://console.cloud.google.com/apis/credentials
/// 3. Never commit real credentials to version control
/// 4. Add this file to .gitignore for production apps

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
  static const String debugAndroidClientId = 
      'YOUR_DEBUG_CLIENT_ID.apps.googleusercontent.com';

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
  /// 2. Get SHA-1 from release keystore
  /// 3. Create separate OAuth client ID in Google Cloud Console
  /// 4. Use release SHA-1 fingerprint
  static const String prodAndroidClientId = 
      'YOUR_PROD_CLIENT_ID.apps.googleusercontent.com';

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

  // ============================================================================
  // VALIDATION
  // ============================================================================

  /// Validates that the OAuth configuration is properly set up
  /// 
  /// Returns true if configuration is valid, false otherwise
  static bool isConfigured() {
    final clientId = androidClientId;
    
    // Check if still using placeholder
    if (clientId.contains('YOUR_') || clientId.contains('CLIENT_ID')) {
      return false;
    }
    
    // Check if format is valid (should end with .apps.googleusercontent.com)
    if (!clientId.endsWith('.apps.googleusercontent.com')) {
      return false;
    }
    
    // Check if not empty
    if (clientId.isEmpty) {
      return false;
    }
    
    return true;
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
