import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:sui/sui.dart';
import 'package:http/http.dart' as http;
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class ZkLoginService {
  static const String proverUrl = 'https://prover.mystenlabs.com/v1'; // Example Prover URL
  
  // These should be configured via environment or a config file
  static const String googleClientId = 'YOUR_GOOGLE_CLIENT_ID';
  static const String redirectUri = 'com.example.verytontine:/oauth2redirect';

  /// Generates a random string of fixed length
  String _generateRandomness() {
    final random = Random.secure();
    final values = List<int>.generate(32, (i) => random.nextInt(256));
    return base64Url.encode(values).replaceAll('=', '');
  }

  /// Generates the zkLogin nonce
  /// [publicKey] is the ephemeral public key
  /// [maxEpoch] is the epoch after which the ephemeral key expires
  /// [randomness] is a random string used for privacy
  String generateNonce(Ed25519PublicKey publicKey, int maxEpoch, String randomness) {
    // 1. Get the bytes of the public key
    final pubKeyBytes = publicKey.toRawBytes();
    
    // 2. Hash the public key, maxEpoch, and randomness
    // Note: The exact implementation depends on the Sui SDK's helper if available.
    // In Sui, the nonce is: base64(BigInt(hash(pubKey, maxEpoch, randomness)))
    // For now, we'll placeholder the logic as per the spec.
    
    // This is a simplified version of the nonce generation
    final input = '${base64Url.encode(pubKeyBytes)}|$maxEpoch|$randomness';
    final hash = sha256.convert(utf8.encode(input)).bytes;
    return base64Url.encode(hash).replaceAll('=', '');
  }

  /// Fetches the Zero-Knowledge Proof (ZKP) from the prover service
  Future<Map<String, dynamic>> getZkProof({
    required String jwt,
    required String randomness,
    required int maxEpoch,
    required String ephemeralPublicKey,
    required String salt,
  }) async {
    final response = await http.post(
      Uri.parse(proverUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'jwt': jwt,
        'extendedEphemeralPublicKey': ephemeralPublicKey,
        'maxEpoch': maxEpoch,
        'jwtNonce': _extractNonceFromJwt(jwt),
        'salt': salt,
        'randomness': randomness,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch ZKP: ${response.body}');
    }
  }

  String _extractNonceFromJwt(String jwt) {
    final decoded = JWT.decode(jwt);
    return decoded.payload['nonce'] as String;
  }

  /// Simplified address derivation for zkLogin
  String deriveZkLoginAddress({
    required String jwt,
    required String salt,
  }) {
    final decoded = JWT.decode(jwt);
    final sub = decoded.payload['sub'];
    final aud = decoded.payload['aud'];
    final iss = decoded.payload['iss'];

    // In a real implementation, we use the Sui SDK's computeZkLoginAddress
    // computeZkLoginAddress(claimName: 'sub', claimValue: sub, ...);
    return '0x...'; // Placeholder
  }
}
