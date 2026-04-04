import 'package:equatable/equatable.dart';
import 'jwt_claims.dart';

/// Authentication session data
/// 
/// Contains all information needed to maintain an authenticated
/// session across app restarts.
class SessionData extends Equatable {
  /// JWT ID token from OAuth provider
  final String jwt;
  
  /// Salt used for zkLogin address derivation
  final String salt;
  
  /// Ephemeral private key for transaction signing
  final String ephemeralKey;
  
  /// Derived Sui blockchain address
  final String suiAddress;
  
  /// Token expiration time
  final DateTime expiresAt;
  
  /// JWT claims (parsed from token)
  final JWTClaims? claims;
  
  const SessionData({
    required this.jwt,
    required this.salt,
    required this.ephemeralKey,
    required this.suiAddress,
    required this.expiresAt,
    this.claims,
  });
  
  /// Creates SessionData from JWT token
  /// 
  /// Automatically parses the JWT to extract expiration time.
  /// 
  /// Parameters:
  ///   - jwt: JWT ID token
  ///   - salt: Salt for address derivation
  ///   - ephemeralKey: Private key for signing
  ///   - suiAddress: Derived blockchain address
  /// 
  /// Returns: SessionData with parsed expiration
  /// 
  /// Example:
  /// ```dart
  /// final session = SessionData.fromToken(
  ///   jwt: idToken,
  ///   salt: '12345',
  ///   ephemeralKey: 'abc...',
  ///   suiAddress: '0x123...',
  /// );
  /// ```
  factory SessionData.fromToken({
    required String jwt,
    required String salt,
    required String ephemeralKey,
    required String suiAddress,
  }) {
    try {
      final claims = JWTClaims.fromToken(jwt);
      return SessionData(
        jwt: jwt,
        salt: salt,
        ephemeralKey: ephemeralKey,
        suiAddress: suiAddress,
        expiresAt: claims.exp,
        claims: claims,
      );
    } catch (e) {
      // If JWT parsing fails, use a default expiration (1 hour from now)
      return SessionData(
        jwt: jwt,
        salt: salt,
        ephemeralKey: ephemeralKey,
        suiAddress: suiAddress,
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
        claims: null,
      );
    }
  }
  
  /// Checks if session is expired
  /// 
  /// Returns true if the current time is after the expiration time.
  bool get isExpired => DateTime.now().isAfter(expiresAt);
  
  /// Checks if session expires soon
  /// 
  /// Parameters:
  ///   - threshold: Time before expiration to consider "soon" (default: 1 hour)
  /// 
  /// Returns: true if session expires within the threshold
  bool isExpiringSoon({Duration threshold = const Duration(hours: 1)}) {
    final warningTime = expiresAt.subtract(threshold);
    return DateTime.now().isAfter(warningTime) && !isExpired;
  }
  
  /// Gets time remaining until expiration
  /// 
  /// Returns: Duration until session expires (negative if already expired)
  Duration get timeUntilExpiration => expiresAt.difference(DateTime.now());
  
  /// Converts to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'jwt': jwt,
      'salt': salt,
      'ephemeralKey': ephemeralKey,
      'suiAddress': suiAddress,
      'expiresAt': expiresAt.toIso8601String(),
    };
  }
  
  /// Creates SessionData from JSON
  factory SessionData.fromJson(Map<String, dynamic> json) {
    return SessionData(
      jwt: json['jwt'] as String,
      salt: json['salt'] as String,
      ephemeralKey: json['ephemeralKey'] as String,
      suiAddress: json['suiAddress'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );
  }
  
  @override
  List<Object?> get props => [
        jwt,
        salt,
        ephemeralKey,
        suiAddress,
        expiresAt,
      ];
  
  @override
  String toString() {
    return 'SessionData(address: $suiAddress, expiresAt: $expiresAt, isExpired: $isExpired)';
  }
}
