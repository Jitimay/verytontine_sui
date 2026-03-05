# Requirements Document: Google OAuth Configuration for zkLogin

## Introduction

This specification defines the requirements for configuring Google OAuth authentication in the VeryTontine Flutter app to enable zkLogin functionality. The current implementation has a placeholder client ID causing authentication failures with error code 10 (Developer Error).

## Glossary

- **OAuth_Client**: The Google Cloud Console OAuth 2.0 client credentials
- **Client_ID**: The unique identifier for the OAuth client application
- **SHA1_Fingerprint**: The cryptographic signature of the Android app signing certificate
- **Package_Name**: The Android application identifier (com.verytontine.verytontine_flutter)
- **zkLogin_Service**: The authentication service that integrates Google OAuth with Sui blockchain
- **Debug_Keystore**: The development signing certificate used for testing
- **Release_Keystore**: The production signing certificate used for app store releases

## Requirements

### Requirement 1: Google Cloud Console Configuration

**User Story:** As a developer, I want to configure Google OAuth credentials in Google Cloud Console, so that the app can authenticate users with Google Sign-In.

#### Acceptance Criteria

1. WHEN a developer creates a new Google Cloud project, THE System SHALL provide a valid project ID
2. WHEN OAuth consent screen is configured, THE System SHALL require app name, user support email, and developer contact information
3. WHEN OAuth 2.0 credentials are created, THE System SHALL generate both Android and Web client IDs
4. WHERE Android OAuth client is configured, THE System SHALL require package name and SHA-1 certificate fingerprint
5. WHEN credentials are saved, THE System SHALL provide downloadable JSON configuration files

### Requirement 2: Android Application Configuration

**User Story:** As a developer, I want to configure the Android app with Google OAuth credentials, so that Google Sign-In can authenticate users successfully.

#### Acceptance Criteria

1. WHEN the app is built, THE Build_System SHALL use the correct package name matching OAuth configuration
2. WHEN SHA-1 fingerprint is generated, THE System SHALL use the correct keystore (debug or release)
3. WHEN Google Services are initialized, THE System SHALL load the correct client ID from configuration
4. WHERE multiple build variants exist, THE System SHALL use appropriate credentials for each variant
5. WHEN the app starts, THE System SHALL validate OAuth configuration before attempting sign-in

### Requirement 3: zkLogin Service Integration

**User Story:** As a developer, I want to integrate the real Google OAuth client ID into zkLogin service, so that authentication works in production.

#### Acceptance Criteria

1. WHEN zkLogin service initializes, THE Service SHALL use the real OAuth client ID instead of placeholder
2. WHEN Google Sign-In is triggered, THE Service SHALL request openid and email scopes
3. WHEN authentication succeeds, THE Service SHALL receive a valid JWT ID token
4. WHEN JWT is received, THE Service SHALL extract sub and aud claims for address derivation
5. IF authentication fails, THEN THE Service SHALL provide descriptive error messages to users

### Requirement 4: Certificate Fingerprint Management

**User Story:** As a developer, I want to manage debug and release certificate fingerprints, so that authentication works in both development and production environments.

#### Acceptance Criteria

1. WHEN generating debug fingerprint, THE System SHALL use the default debug keystore location
2. WHEN generating release fingerprint, THE System SHALL use the production signing key
3. WHEN fingerprints are registered, THE System SHALL add both debug and release SHA-1 to OAuth client
4. WHERE keystore password is required, THE System SHALL use secure credential management
5. WHEN certificates expire, THE System SHALL provide clear error messages and renewal instructions

### Requirement 5: Environment-Specific Configuration

**User Story:** As a developer, I want to use different OAuth credentials for development and production, so that testing doesn't affect production users.

#### Acceptance Criteria

1. WHERE development environment is active, THE System SHALL use debug OAuth client credentials
2. WHERE production environment is active, THE System SHALL use release OAuth client credentials
3. WHEN switching environments, THE System SHALL load appropriate configuration automatically
4. WHEN configuration is missing, THE System SHALL fail fast with clear error messages
5. IF wrong credentials are used, THEN THE System SHALL prevent authentication attempts

### Requirement 6: Error Handling and Validation

**User Story:** As a user, I want clear error messages when authentication fails, so that I understand what went wrong and how to fix it.

#### Acceptance Criteria

1. WHEN OAuth client ID is invalid, THE System SHALL display "Configuration Error: Invalid Client ID"
2. WHEN SHA-1 fingerprint mismatch occurs, THE System SHALL display "App signature mismatch. Please reinstall."
3. WHEN network connection fails, THE System SHALL display "Network error. Please check your connection."
4. WHEN user cancels sign-in, THE System SHALL return to login screen without error message
5. WHEN authentication succeeds, THE System SHALL navigate to home screen with user data loaded

### Requirement 7: Security and Privacy

**User Story:** As a user, I want my Google authentication to be secure and private, so that my credentials are protected.

#### Acceptance Criteria

1. WHEN storing OAuth tokens, THE System SHALL use secure storage mechanisms
2. WHEN transmitting credentials, THE System SHALL use HTTPS connections only
3. WHEN user signs out, THE System SHALL clear all cached authentication data
4. WHERE sensitive data is logged, THE System SHALL redact credentials and tokens
5. WHEN app is uninstalled, THE System SHALL revoke OAuth tokens automatically

### Requirement 8: Testing and Verification

**User Story:** As a developer, I want to test Google OAuth integration, so that I can verify it works correctly before production deployment.

#### Acceptance Criteria

1. WHEN running in debug mode, THE System SHALL authenticate with debug OAuth credentials
2. WHEN test user signs in, THE System SHALL successfully retrieve JWT token
3. WHEN zkLogin address is computed, THE System SHALL produce valid Sui address format
4. WHEN transaction signing is tested, THE System SHALL use ephemeral keys correctly
5. WHEN all tests pass, THE System SHALL be ready for production deployment
