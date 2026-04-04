import 'dart:convert';
import 'package:equatable/equatable.dart';

/// JWT token claims extracted from Google OAuth ID token
/// 
/// Contains user identity information and token metadata
/// used for zkLogin authentication.
class JWTClaims extends Equatable {
  /// Subject - unique user identifier from OAuth provider
  final String sub;
  
  /// Audience - OAuth client ID
  final String aud;
  
  /// Nonce - number used once for replay protection
  final String? nonce;
  
  /// Expiration time - when the token expires
  final DateTime exp;
  
  /// Issued at time - when the token was created
  final DateTime iat;
  
  /// Email address (if available)
  final String? email;
  
  const JWTClaims({
    required this.sub,
    required this.aud,
    this.nonce,
    required this.exp,
    required this.iat,
    this.email,
  });
  
  /// Decodes JWT and extracts claims
  /// 
  /// Parses a JWT token string and extracts the claims from the payload.
  /// 
  /// Parameters:
  ///   - jwt: The JWT token string (format: header.payload.signature)
  /// 
  /// Returns: JWTClaims object with extracted data
  /// 
  /// Throws:
  ///   - FormatException if JWT format is invalid
  ///   - Exception if required claims are missing
  /// 
  /// Example:
  /// ```dart
  /// final claims = JWTClaims.fromToken(idToken);
  /// print('User: ${claims.sub}');
  /// print('Expires: ${claims.exp}');
  /// ```
  factory JWTClaims.fromToken(String jwt) {
    try {
      // Split JWT into parts
      final parts = jwt.split('.');
      if (parts.length != 3) {
        throw const FormatException('Invalid JWT format: expected 3 parts');
      }
      
      // Decode payload (second part)
      final payload = parts[1];
      
      // Add padding if needed for base64 decoding
      var paddedPayload = payload;
      while (paddedPayload.length % 4 != 0) {
        paddedPayload += '=';
      }
      
      // Decode base64url
      final decoded = base64Url.decode(paddedPayload);
      final jsonStr = utf8.decode(decoded);
      final claims = jsonDecode(jsonStr) as Map<String, dynamic>;
      
      // Extract required claims
      final sub = claims['sub'] as String?;
      final aud = claims['aud'] as String?;
      
      if (sub == null || aud == null) {
        throw Exception('Missing required JWT claims: sub or aud');
      }
      
      // Extract timestamps
      final expTimestamp = claims['exp'] as int?;
      final iatTimestamp = claims['iat'] as int?;
      
      if (expTimestamp == null || iatTimestamp == null) {
        throw Exception('Missing required JWT claims: exp or iat');
      }
      
      // Convert Unix timestamps to DateTime
      final exp = DateTime.fromMillisecondsSinceEpoch(expTimestamp * 1000);
      final iat = DateTime.fromMillisecondsSinceEpoch(iatTimestamp * 1000);
      
      // Extract optional claims
      final nonce = claims['nonce'] as String?;
      final email = claims['email'] as String?;
      
      return JWTClaims(
        sub: sub,
        aud: aud,
        nonce: nonce,
        exp: exp,
        iat: iat,
        email: email,
      );
    } catch (e) {
      throw Exception('Failed to parse JWT token: $e');
    }
  }
  
  /// Checks if token is expired
  /// 
  /// Returns true if the current time is after the expiration time.
  bool get isExpired => DateTime.now().isAfter(exp);
  
  /// Checks if token expires soon
  /// 
  /// Parameters:
  ///   - threshold: Time before expiration to consider "soon" (default: 1 hour)
  /// 
  /// Returns: true if token expires within the threshold
  /// 
  /// Example:
  /// ```dart
  /// if (claims.isExpiringSoon()) {
  ///   print('Token expires in less than 1 hour');
  /// }
  /// 
  /// if (claims.isExpiringSoon(threshold: Duration(minutes: 30))) {
  ///   print('Token expires in less than 30 minutes');
  /// }
  /// ```
  bool isExpiringSoon({Duration threshold = const Duration(hours: 1)}) {
    final expirationWarningTime = exp.subtract(threshold);
    return DateTime.now().isAfter(expirationWarningTime);
  }
  
  /// Gets time remaining until expiration
  /// 
  /// Returns: Duration until token expires (negative if already expired)
  Duration get timeUntilExpiration => exp.difference(DateTime.now());
  
  @override
  List<Object?> get props => [sub, aud, nonce, exp, iat, email];
  
  @override
  String toString() {
    return 'JWTClaims(sub: $sub, aud: $aud, exp: $exp, email: $email)';
  }
}
