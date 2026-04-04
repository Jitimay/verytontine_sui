import 'package:equatable/equatable.dart';

/// Represents the result of an authentication attempt
class AuthenticationResult extends Equatable {
  final bool success;
  final String? suiAddress;
  final String? idToken;
  final String? errorMessage;
  final AuthErrorType? errorType;

  const AuthenticationResult({
    required this.success,
    this.suiAddress,
    this.idToken,
    this.errorMessage,
    this.errorType,
  });

  /// Creates a successful authentication result
  factory AuthenticationResult.success({
    required String suiAddress,
    required String idToken,
  }) {
    return AuthenticationResult(
      success: true,
      suiAddress: suiAddress,
      idToken: idToken,
    );
  }

  /// Creates a failed authentication result
  factory AuthenticationResult.failure({
    required String errorMessage,
    required AuthErrorType errorType,
  }) {
    return AuthenticationResult(
      success: false,
      errorMessage: errorMessage,
      errorType: errorType,
    );
  }

  @override
  List<Object?> get props => [
        success,
        suiAddress,
        idToken,
        errorMessage,
        errorType,
      ];
}

/// Types of authentication errors
enum AuthErrorType {
  /// Invalid OAuth client ID or configuration
  configurationError,

  /// SHA-1 fingerprint mismatch between app and Google Cloud Console
  signatureMismatch,

  /// Network connection issues
  networkError,

  /// User cancelled the sign-in process
  userCancelled,

  /// Failed to retrieve or parse JWT token
  tokenError,

  /// Unknown or unhandled error
  unknown,
}

/// Extension to provide user-friendly error messages
extension AuthErrorTypeExtension on AuthErrorType {
  /// Returns a user-friendly error message for this error type
  String get userMessage {
    switch (this) {
      case AuthErrorType.configurationError:
        return 'Sign-in is not set up for this app yet (Google OAuth).';
      case AuthErrorType.signatureMismatch:
        return 'App signature mismatch. Please reinstall the app.';
      case AuthErrorType.networkError:
        return 'Network connection failed. Please check your internet connection.';
      case AuthErrorType.userCancelled:
        return 'Sign-in cancelled.';
      case AuthErrorType.tokenError:
        return 'Failed to complete authentication. Please try again.';
      case AuthErrorType.unknown:
        return 'Authentication failed. Please try again.';
    }
  }

  /// Returns true if this error should be shown to the user
  bool get shouldShowToUser {
    // Don't show error for user cancellation
    return this != AuthErrorType.userCancelled;
  }
}

/// OAuth credentials configuration
class OAuthCredentials extends Equatable {
  final String clientId;
  final String clientSecret;
  final List<String> scopes;
  final String redirectUri;

  const OAuthCredentials({
    required this.clientId,
    this.clientSecret = '',
    required this.scopes,
    required this.redirectUri,
  });

  @override
  List<Object> get props => [clientId, clientSecret, scopes, redirectUri];
}
