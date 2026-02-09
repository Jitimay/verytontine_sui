import 'package:flutter_test/flutter_test.dart';
import 'package:verytontine_flutter/services/zk_login_service.dart';
import 'package:sui/sui.dart';

void main() {
  group('ZkLoginService Tests', () {
    final service = ZkLoginService();

    test('Nonce generation should return a valid base64 string', () {
      final keyPair = Ed25519Keypair();
      final publicKey = keyPair.getPublicKey() as Ed25519PublicKey;
      final randomness = 'test_randomness_string_1234567890';
      final maxEpoch = 100;

      final nonce = service.generateNonce(publicKey, maxEpoch, randomness);
      
      expect(nonce, isNotEmpty);
      expect(nonce.contains('='), isFalse); // Should be base64Url encoded without padding
    });

    test('Derive address should return a placeholder for mock data', () {
      // A minimally valid JWT structure: header.payload.signature (base64)
      const mockJwt = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c';
      final address = service.deriveZkLoginAddress(
        jwt: mockJwt,
        salt: 'mock_salt',
      );
      expect(address, equals('0x...'));
    });
  });
}
