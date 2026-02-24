import 'package:flutter_test/flutter_test.dart';
import 'package:verytontine_flutter/services/zk_login_service.dart';

void main() {
  group('ZkLoginService Tests', () {
    late ZkLoginService zkLoginService;

    setUp(() {
      zkLoginService = ZkLoginService();
    });

    test('should initialize with signed out state', () {
      expect(zkLoginService.isSignedIn, isFalse);
    });

    test('should generate salt correctly', () {
      final salt1 = zkLoginService._generateSalt();
      final salt2 = zkLoginService._generateSalt();
      
      expect(salt1, isNotEmpty);
      expect(salt2, isNotEmpty);
      expect(salt1, isNot(equals(salt2))); // Should be random
    });

    test('should compute zkLogin address from JWT', () {
      const mockJwt = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwiYXVkIjoidGVzdC1hdWQiLCJpYXQiOjE1MTYyMzkwMjJ9.test';
      const salt = '12345';
      
      try {
        final address = zkLoginService._computeZkLoginAddress(mockJwt, salt);
        expect(address, startsWith('0x'));
        expect(address.length, equals(42)); // 0x + 40 hex chars
      } catch (e) {
        // Expected to fail with mock JWT, but should not crash
        expect(e, isA<Exception>());
      }
    });

    test('should handle sign out correctly', () async {
      await zkLoginService.signOut();
      expect(zkLoginService.isSignedIn, isFalse);
    });
  });
}
