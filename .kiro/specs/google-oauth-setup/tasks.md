# Implementation Plan: Google OAuth Configuration for zkLogin

## Overview

This plan provides step-by-step tasks to configure Google OAuth authentication and fix the current authentication error (ApiException: 10). The implementation will enable production-ready zkLogin functionality.

## Tasks

- [x] 1. Generate Android certificate fingerprints
  - Get debug keystore SHA-1 fingerprint using keytool command
  - Store fingerprint for Google Cloud Console configuration
  - _Requirements: 4.1, 4.2_

- [ ] 2. Configure Google Cloud Console
  - [ ] 2.1 Create or select Google Cloud project
    - Navigate to Google Cloud Console
    - Create new project named "VeryTontine" or select existing
    - Note the Project ID for reference
    - _Requirements: 1.1_

  - [ ] 2.2 Configure OAuth consent screen
    - Set app name to "VeryTontine"
    - Add user support email and developer contact
    - Configure scopes: openid, email
    - Save consent screen configuration
    - _Requirements: 1.2_

  - [ ] 2.3 Create Android OAuth 2.0 client
    - Create OAuth client ID with type "Android"
    - Set package name: com.verytontine.verytontine_flutter
    - Add debug SHA-1 fingerprint from task 1
    - Save and copy the generated Client ID
    - _Requirements: 1.3, 1.4, 2.2_

  - [ ] 2.4 Verify OAuth configuration
    - Confirm client ID format is correct
    - Verify package name matches exactly
    - Verify SHA-1 fingerprint is registered
    - _Requirements: 1.5, 2.1_

- [x] 3. Create OAuth configuration module
  - [x] 3.1 Create oauth_config.dart file
    - Create file at lib/config/oauth_config.dart
    - Define OAuthConfig class with debug and production client IDs
    - Add environment-based client ID selection logic
    - Add validation for client ID format
    - _Requirements: 5.1, 5.2, 5.3_

  - [ ]* 3.2 Write unit tests for OAuth configuration
    - Test client ID format validation
    - Test environment-specific credential loading
    - Test configuration error detection
    - _Requirements: 8.1_

- [x] 4. Update zkLogin service with real credentials
  - [x] 4.1 Update zk_login_service.dart
    - Import oauth_config.dart
    - Replace placeholder client ID with OAuthConfig.androidClientId
    - Update GoogleSignIn initialization to use config
    - Remove unused _redirectUri and _appAuth fields
    - _Requirements: 3.1, 3.2_

  - [x] 4.2 Implement enhanced error handling
    - Create AuthenticationResult model
    - Create AuthErrorType enum
    - Implement _handleGoogleSignInError method
    - Map Google error codes to user-friendly messages
    - Update signInWithGoogle to return AuthenticationResult
    - _Requirements: 6.1, 6.2, 6.3, 6.4_

  - [ ]* 4.3 Write unit tests for error handling
    - Test error code mapping
    - Test user-friendly message generation
    - Test error type classification
    - _Requirements: 6.5_

- [x] 5. Update AuthBloc to handle new error types
  - [x] 5.1 Update AuthBloc error handling
    - Import AuthenticationResult model
    - Update _onZkLoginRequested to handle AuthenticationResult
    - Emit appropriate error states based on AuthErrorType
    - Add user-friendly error messages to AuthError state
    - _Requirements: 6.1, 6.5_

  - [ ]* 5.2 Write integration tests for AuthBloc
    - Test successful authentication flow
    - Test configuration error handling
    - Test network error handling
    - Test user cancellation handling
    - _Requirements: 8.2_

- [x] 6. Add configuration validation on app startup
  - [x] 6.1 Create configuration validator
    - Create lib/utils/config_validator.dart
    - Implement validateOAuthConfig method
    - Check client ID is not placeholder
    - Check client ID format is valid
    - Return validation result with error details
    - _Requirements: 2.5, 5.4_

  - [x] 6.2 Integrate validator in main.dart
    - Call validateOAuthConfig on app startup
    - Show error dialog if configuration is invalid
    - Prevent app from proceeding with invalid config
    - _Requirements: 5.4_

- [ ] 7. Test authentication flow
  - [ ] 7.1 Test debug build authentication
    - Clean and rebuild the app
    - Run app on physical device or emulator
    - Attempt Google Sign-In
    - Verify successful authentication
    - Verify Sui address is generated
    - _Requirements: 8.1, 8.2_

  - [ ] 7.2 Test error scenarios
    - Test with airplane mode (network error)
    - Test user cancellation
    - Verify error messages are user-friendly
    - Verify app doesn't crash on errors
    - _Requirements: 6.1, 6.2, 6.3, 6.4_

  - [ ] 7.3 Test sign-out functionality
    - Sign in successfully
    - Trigger sign-out
    - Verify all auth data is cleared
    - Verify user returns to login screen
    - _Requirements: 7.3_

- [ ] 8. Checkpoint - Verify debug authentication works
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 9. Prepare for production release
  - [ ] 9.1 Generate release keystore
    - Generate release keystore with keytool
    - Store keystore securely
    - Document keystore password securely
    - Get release SHA-1 fingerprint
    - _Requirements: 4.2, 4.4_

  - [ ] 9.2 Create production OAuth client
    - Create new OAuth client ID for production
    - Use same package name
    - Add release SHA-1 fingerprint
    - Copy production Client ID
    - _Requirements: 1.3, 1.4, 5.2_

  - [ ] 9.3 Update oauth_config.dart with production credentials
    - Add production client ID to OAuthConfig
    - Verify environment switching logic
    - Test with --dart-define=PRODUCTION=true
    - _Requirements: 5.1, 5.2_

  - [ ] 9.4 Configure release signing in build.gradle.kts
    - Add signingConfigs for release
    - Reference release keystore
    - Update release buildType to use signing config
    - _Requirements: 2.1_

- [ ] 10. Security hardening
  - [ ] 10.1 Add oauth_config.dart to .gitignore
    - Update .gitignore to exclude config file
    - Create oauth_config.example.dart template
    - Document configuration process in README
    - _Requirements: 7.1, 7.4_

  - [ ] 10.2 Implement secure token storage
    - Add flutter_secure_storage dependency
    - Update zkLogin service to use secure storage
    - Store JWT tokens securely
    - Clear secure storage on sign-out
    - _Requirements: 7.1, 7.3_

- [ ] 11. Final testing and verification
  - [ ] 11.1 Test complete authentication flow
    - Test sign-in with multiple Google accounts
    - Test account switching
    - Test persistence across app restarts
    - Verify trust scores load correctly
    - _Requirements: 8.3, 8.4_

  - [ ] 11.2 Test transaction signing
    - Sign in successfully
    - Create a test circle
    - Verify transaction signing works
    - Verify transaction executes on blockchain
    - _Requirements: 8.4_

  - [ ]* 11.3 Perform security audit
    - Verify no credentials in logs
    - Verify secure storage is used
    - Verify HTTPS is enforced
    - Verify token cleanup on sign-out
    - _Requirements: 7.1, 7.2, 7.3, 7.4_

- [ ] 12. Final checkpoint - Production ready
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation
- Focus on getting debug authentication working first (tasks 1-8)
- Production setup (tasks 9-12) can be done later
- The immediate blocker is task 2.3 (creating OAuth client with correct SHA-1)

## Quick Start (Minimum Viable Fix)

To fix the current error immediately:

1. Complete task 1 (get SHA-1 fingerprint)
2. Complete task 2.3 (create OAuth client)
3. Complete task 4.1 (update client ID in code)
4. Complete task 7.1 (test authentication)

This will unblock development while the full production setup is completed.
