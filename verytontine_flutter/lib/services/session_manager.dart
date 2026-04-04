import 'dart:convert';
import '../models/session_data.dart';
import '../utils/auth_logger.dart';
import 'secure_storage_service.dart';

/// Manages authentication session lifecycle
/// 
/// Handles session persistence, restoration, expiration checking,
/// and cleanup for zkLogin authentication.
class SessionManager {
  static const _sessionKey = 'auth_session';
  
  /// Stores a new authentication session
  /// 
  /// Persists all session data to secure storage for restoration
  /// on app restart.
  /// 
  /// Parameters:
  ///   - jwt: JWT ID token from OAuth
  ///   - salt: Salt used for address derivation
  ///   - ephemeralKey: Private key for transaction signing
  ///   - suiAddress: Derived Sui blockchain address
  /// 
  /// Example:
  /// ```dart
  /// await SessionManager().storeSession(
  ///   jwt: idToken,
  ///   salt: '12345',
  ///   ephemeralKey: 'abc...',
  ///   suiAddress: '0x123...',
  /// );
  /// ```
  Future<void> storeSession({
    required String jwt,
    required String salt,
    required String ephemeralKey,
    required String suiAddress,
  }) async {
    try {
      // Create session data
      final session = SessionData.fromToken(
        jwt: jwt,
        salt: salt,
        ephemeralKey: ephemeralKey,
        suiAddress: suiAddress,
      );
      
      // Convert to JSON and store
      final jsonStr = jsonEncode(session.toJson());
      await SecureStorageService.storeValue(_sessionKey, jsonStr);
      
      AuthLogger.i('Session stored', context: {
        'address': suiAddress,
        'expiresAt': session.expiresAt.toIso8601String(),
      });
    } catch (e) {
      AuthLogger.e('Failed to store session', error: e);
      rethrow;
    }
  }
  
  /// Attempts to restore a session from storage
  /// 
  /// Retrieves stored session data and validates it's not expired.
  /// 
  /// Returns: SessionData if valid session exists, null otherwise
  /// 
  /// Example:
  /// ```dart
  /// final session = await SessionManager().restoreSession();
  /// if (session != null) {
  ///   print('Restored session for ${session.suiAddress}');
  /// } else {
  ///   print('No valid session found');
  /// }
  /// ```
  Future<SessionData?> restoreSession() async {
    try {
      // Retrieve stored session
      final jsonStr = await SecureStorageService.getValue(_sessionKey);
      if (jsonStr == null) {
        AuthLogger.d('No stored session found');
        return null;
      }
      
      // Parse JSON
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      final session = SessionData.fromJson(json);
      
      // Check if expired
      if (session.isExpired) {
        AuthLogger.i('Stored session is expired', context: {
          'expiresAt': session.expiresAt.toIso8601String(),
        });
        await clearSession();
        return null;
      }
      
      AuthLogger.i('Session restored', context: {
        'address': session.suiAddress,
        'timeRemaining': session.timeUntilExpiration.inMinutes,
      });
      
      return session;
    } catch (e) {
      AuthLogger.e('Failed to restore session', error: e);
      // Clear corrupted session data
      await clearSession();
      return null;
    }
  }
  
  /// Checks if current session is valid (not expired)
  /// 
  /// Returns: true if a valid session exists, false otherwise
  /// 
  /// Example:
  /// ```dart
  /// if (await SessionManager().isSessionValid()) {
  ///   // Proceed with authenticated flow
  /// } else {
  ///   // Require re-authentication
  /// }
  /// ```
  Future<bool> isSessionValid() async {
    final session = await restoreSession();
    return session != null && !session.isExpired;
  }
  
  /// Gets time until session expires
  /// 
  /// Returns: Duration until expiration, or null if no session
  /// 
  /// Example:
  /// ```dart
  /// final timeLeft = await SessionManager().getTimeUntilExpiration();
  /// if (timeLeft != null) {
  ///   print('Session expires in ${timeLeft.inMinutes} minutes');
  /// }
  /// ```
  Future<Duration?> getTimeUntilExpiration() async {
    final session = await restoreSession();
    if (session == null) {
      return null;
    }
    
    return session.timeUntilExpiration;
  }
  
  /// Clears the current session
  /// 
  /// Removes all session data from secure storage.
  /// 
  /// Example:
  /// ```dart
  /// await SessionManager().clearSession();
  /// ```
  Future<void> clearSession() async {
    try {
      await SecureStorageService.deleteValue(_sessionKey);
      AuthLogger.i('Session cleared');
    } catch (e) {
      AuthLogger.e('Failed to clear session', error: e);
      rethrow;
    }
  }
  
  /// Checks if session is about to expire (within threshold)
  /// 
  /// Parameters:
  ///   - threshold: Time before expiration to consider "soon" (default: 1 hour)
  /// 
  /// Returns: true if session expires within threshold, false otherwise
  /// 
  /// Example:
  /// ```dart
  /// if (await SessionManager().isSessionExpiringSoon()) {
  ///   showExpirationWarning();
  /// }
  /// ```
  Future<bool> isSessionExpiringSoon({
    Duration threshold = const Duration(hours: 1),
  }) async {
    final session = await restoreSession();
    if (session == null) {
      return false;
    }
    
    return session.isExpiringSoon(threshold: threshold);
  }
}
