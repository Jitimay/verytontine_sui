import '../config/oauth_config.dart';

/// Result of configuration validation
class ConfigValidationResult {
  final bool isValid;
  final String? errorMessage;
  final List<String> warnings;

  const ConfigValidationResult({
    required this.isValid,
    this.errorMessage,
    this.warnings = const [],
  });

  factory ConfigValidationResult.valid({List<String> warnings = const []}) {
    return ConfigValidationResult(
      isValid: true,
      warnings: warnings,
    );
  }

  factory ConfigValidationResult.invalid(String errorMessage) {
    return ConfigValidationResult(
      isValid: false,
      errorMessage: errorMessage,
    );
  }
}

/// Validates OAuth configuration before app startup
class ConfigValidator {
  /// Validates the OAuth configuration
  /// 
  /// Returns a ConfigValidationResult indicating whether the configuration is valid
  static ConfigValidationResult validateOAuthConfig() {
    final warnings = <String>[];

    // Check if OAuth is configured
    if (!OAuthConfig.isConfigured()) {
      return ConfigValidationResult.invalid(
        'Google OAuth is not configured.\n\n'
        'Please follow these steps:\n'
        '1. Get your SHA-1 fingerprint:\n'
        '   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android\n\n'
        '2. Go to Google Cloud Console:\n'
        '   https://console.cloud.google.com/apis/credentials\n\n'
        '3. Create OAuth client ID (Android):\n'
        '   - Package: com.verytontine.verytontine_flutter\n'
        '   - SHA-1: [paste from step 1]\n\n'
        '4. Update lib/config/oauth_config.dart with your Client ID',
      );
    }

    // Get the current client ID
    final clientId = OAuthConfig.androidClientId;

    // Validate client ID format
    if (!clientId.endsWith('.apps.googleusercontent.com')) {
      return ConfigValidationResult.invalid(
        'Invalid OAuth client ID format.\n'
        'Client ID should end with .apps.googleusercontent.com',
      );
    }

    // Check if client ID looks like a real Google client ID
    if (clientId.length < 50) {
      warnings.add(
        'Client ID seems unusually short. '
        'Please verify it was copied correctly from Google Cloud Console.',
      );
    }

    // Warn about environment
    if (!OAuthConfig.isProduction) {
      warnings.add(
        'Running in DEBUG mode with debug OAuth credentials. '
        'Use --dart-define=PRODUCTION=true for production builds.',
      );
    }

    return ConfigValidationResult.valid(warnings: warnings);
  }

  /// Validates configuration and throws an exception if invalid
  /// 
  /// This is useful for failing fast during app initialization
  static void validateOrThrow() {
    final result = validateOAuthConfig();
    if (!result.isValid) {
      throw ConfigurationException(result.errorMessage!);
    }
  }

  /// Prints validation warnings to console
  static void printWarnings() {
    final result = validateOAuthConfig();
    if (result.warnings.isNotEmpty) {
      print('⚠️  Configuration Warnings:');
      for (final warning in result.warnings) {
        print('   - $warning');
      }
      print('');
    }
  }
}

/// Exception thrown when configuration is invalid
class ConfigurationException implements Exception {
  final String message;

  ConfigurationException(this.message);

  @override
  String toString() => 'ConfigurationException: $message';
}
